## How to use this image

**Get docker image**
> docker pull bndynet/jenkins

**Start a container**

Below will store the workspace in /var/jenkins_home. All Jenkins data lives in there - including plugins and configuration. You will probably want to make that a persistent volume (recommended):

> docker run --name my-jenkins -p 8080:8080 -p 50000:50000 [-v /your/home:/var/jenkins_home] jenkins

**Run bash**
> docker exec -it [image] bash

NOTE: If you run testing about browser, you NEED go to bash and run `service xvfb start; export DISPLAY=:10` to start Xvfb for browser testing.

