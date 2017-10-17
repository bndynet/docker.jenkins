## How to use this image

**Get docker image**
> docker pull bndynet/jenkins

**Start a container**

Below will store the workspace in /var/jenkins_home. All Jenkins data lives in there - including plugins and configuration. You will probably want to make that a persistent volume (recommended):

> docker run --name my-jenkins -p 8080:8080 -p 50000:50000 [-v /your/home:/var/jenkins_home] jenkins


