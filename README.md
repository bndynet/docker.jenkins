# ![Docker](https://www.docker.com/favicon/favicon-32x32.png)  Jenkins Docker image

## How to use this image

### Get docker image

> docker pull bndynet/jenkins

### Start a container

Below will store the workspace in /var/jenkins_home. All Jenkins data lives in there - including plugins and configuration. You will probably want to make that a persistent volume (recommended):

```bash
docker run --name my-jenkins -p 8080:8080 -p 50000:50000 [-v /your/home:/var/jenkins_home] \
  -d \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --restart unless-stopped \
  --user root \
  bndynet/jenkins
```

### Run bash

> docker exec -it my-jenkins bash

### Misc

- Initial Admin Password: /var/jenkins_home/secrets/initialAdminPassword

- Forgot Password or Reset:

> 1. Stop the Jenkins service
> 1. Open the `config.xml` file
> 1. Find this `<useSecurity>true</useSecurity>` and change it to `<useSecurity>false</useSecurity>`
> 1. Start Jenkins service
