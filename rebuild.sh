#!/usr/bin/env bash
set -e

# Usage:
#   ./rebuild.sh                 # standard: download plugins at build time (portable)
#   ./rebuild.sh --predownloaded # slow networks: pre-download plugins first, then build
DOCKERFILE="Dockerfile"
if [ "${1:-}" = "--predownloaded" ]; then
    python3 sync-plugins.py
    DOCKERFILE="Dockerfile.predownloaded"
fi

docker rm -f -v my-jenkins || true
docker image rm bndynet/jenkins || true
docker build -f "$DOCKERFILE" -t bndynet/jenkins .
docker run --name my-jenkins -p 8080:8080 -p 50000:50000  \
  -d \
  bndynet/jenkins

xdg-open http://127.0.0.1:8080