# ![Docker](https://www.docker.com/favicon/favicon-32x32.png)  Jenkins Docker image

Custom Jenkins image based on [`jenkins/jenkins:lts-jdk21`](https://hub.docker.com/r/jenkins/jenkins) (latest LTS, JDK 21).

## What's inside

- Base image: `jenkins/jenkins:lts-jdk21` (latest LTS)
- Setup wizard **disabled** (`-Djenkins.install.runSetupWizard=false`)
- Plugins preinstalled from [`plugins.txt`](plugins.txt)
- Init scripts in [`init.groovy.d/`](init.groovy.d/) (0 executors on the built-in node, workspace cleanup thread disabled)

## Build

> docker build -t bndynet/jenkins .

Or use the helper script:

> ./rebuild.sh                    # build & run, plugins downloaded at build time
> ./rebuild.sh --predownloaded    # slow networks: pre-download plugins first

On slow networks, `--predownloaded` runs [`sync-plugins.py`](sync-plugins.py) first, which downloads all plugins and their dependencies from a China-friendly mirror into `plugins/`, so the build itself needs no network access for plugins.

## Start a container

All Jenkins data lives in `/var/jenkins_home` (plugins, jobs, configuration). Make it a persistent volume (recommended):

```bash
docker run --name my-jenkins \
  -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -d \
  bndynet/jenkins
```

To let Jenkins build Docker images (docker-in-jenkins), also mount the Docker socket:

```bash
docker run --name my-jenkins \
  -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -d \
  bndynet/jenkins
```

> The container runs as the `jenkins` user. To grant access to `/var/run/docker.sock`, add the `jenkins` user (uid 1000) to the host's `docker` group instead of running the container with `--user root`.

## Run bash

> docker exec -it my-jenkins bash

## Notes

- **Setup wizard is disabled**, so there is **no initial admin password** — `/var/jenkins_home/secrets/initialAdminPassword` is not generated.
- Security is **not configured out of the box** (anonymous full access). Configure it with the already-installed [`configuration-as-code`](https://plugins.jenkins.io/configuration-as-code) (JCasC) and/or [`matrix-auth`](https://plugins.jenkins.io/matrix-auth) plugins.

## Reset a forgotten password

If you have enabled security and locked yourself out:

> 1. Stop Jenkins: `docker stop my-jenkins`
> 2. Open `config.xml` in the Jenkins home volume
> 3. Find `<useSecurity>true</useSecurity>` and change it to `<useSecurity>false</useSecurity>`
> 4. Start Jenkins: `docker start my-jenkins`
