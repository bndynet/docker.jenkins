#!/usr/bin/env python3
"""Download all Jenkins plugins (and their dependencies) into ./plugins/.

Resolves the plugin list from plugins.txt against the official LTS update center,
rewrites the download URLs to the Tsinghua mirror (fast in mainland China), then
downloads every .hpi sequentially with retries. The resulting ./plugins directory
is copied into the image by the Dockerfile (ref/plugins mechanism), so no network
access is needed during `docker build`.
"""
import json
import os
import time
import urllib.request

OFFICIAL_UC = "https://updates.jenkins.io/stable/update-center.actual.json"
DOWNLOAD_BASE = "https://updates.jenkins.io/download/plugins/"
MIRROR_BASE = "https://mirrors.tuna.tsinghua.edu.cn/jenkins/plugins/"
PLUGIN_LIST = "plugins.txt"
OUTPUT_DIR = "plugins"


def fetch_update_center() -> dict:
    print(f"Fetching {OFFICIAL_UC} ...")
    with urllib.request.urlopen(OFFICIAL_UC, timeout=120) as resp:
        return json.load(resp)


def resolve(data: dict, requested: list[str]) -> dict[str, str]:
    """Return {pluginId: downloadUrl} for requested plugins and all required deps."""
    plugins = data["plugins"]
    resolved: dict[str, str] = {}
    queue = list(requested)
    while queue:
        name = queue.pop(0)
        if name in resolved:
            continue
        meta = plugins.get(name)
        if meta is None:
            print(f"WARNING: plugin not found in update center: {name}")
            continue
        url = meta.get("url", "")
        if url.startswith(DOWNLOAD_BASE):
            url = MIRROR_BASE + url[len(DOWNLOAD_BASE):]
        resolved[name] = url
        for dep in meta.get("dependencies", []):
            if not dep.get("optional", False):
                queue.append(dep["name"])
    return resolved


def download(name: str, url: str, dest_dir: str) -> bool:
    dest = os.path.join(dest_dir, f"{name}.jpi")
    if os.path.exists(dest) and os.path.getsize(dest) > 0:
        return True  # already downloaded
    for attempt in range(1, 4):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": "jenkins-plugin-sync/1.0"})
            with urllib.request.urlopen(req, timeout=60) as resp:
                body = resp.read()
            if not body.startswith(b"PK"):
                raise RuntimeError(f"not a ZIP file ({len(body)} bytes)")
            with open(dest, "wb") as f:
                f.write(body)
            print(f"  OK   {name} ({len(body)} bytes)")
            return True
        except Exception as exc:  # noqa: BLE001
            print(f"  RETRY({attempt}/3) {name}: {exc}")
            time.sleep(2 * attempt)
    print(f"  FAIL {name}")
    return False


def main() -> None:
    requested = []
    with open(PLUGIN_LIST, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("#") and ":" not in line:
                requested.append(line)

    data = fetch_update_center()
    resolved = resolve(data, requested)
    print(f"Resolved {len(resolved)} plugins (including dependencies).")

    os.makedirs(OUTPUT_DIR, exist_ok=True)
    failed = []
    for name, url in resolved.items():
        if not download(name, url, OUTPUT_DIR):
            failed.append(name)

    print(f"Done. {len(resolved) - len(failed)}/{len(resolved)} plugins downloaded to {OUTPUT_DIR}/")
    if failed:
        print("Failed:", ", ".join(failed))
        raise SystemExit(1)


if __name__ == "__main__":
    main()
