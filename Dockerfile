FROM jenkins:latest

LABEL maintainer="Bendy Zhang <zb@bndy.net>"
 
USER root

RUN apt-get update &&\
    apt-get install -y sudo apt-utils &&\
    rm -rf /var/lib/apt/lists/*
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers

# install chrome
RUN echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN apt-get update
# RUN apt-get -y install libxpm4 libxrender1 libgtk2.0-0 libnss3 libgconf-2-4
# RUN apt-get -y install xfonts-cyrillic xfonts-100dpi xfonts-75dpi xfonts-base xfonts-scalable
RUN apt-get -y install google-chrome-stable

# install xvfb(X Virtual Frame Buffer) for browser testing
RUN apt-get update
RUN apt-get install -y xvfb
ADD xvfb.init /etc/init.d/xvfb
RUN chmod +x /etc/init.d/xvfb
RUN update-rc.d xvfb defaults

# append starting script to ENTRYPOINT file for xvfb
ARG entrypoint="/usr/local/bin/jenkins.sh"
RUN echo "#! /bin/bash -e\n\
service xvfb start\n\
export DISPLAY=:10\n\
echo '============================================'" | cat - ${entrypoint} > temp && mv temp ${entrypoint}
RUN chmod +x ${entrypoint}

# install nodejs and yarn
RUN cd ~ &&\
    curl -sL https://deb.nodesource.com/setup_6.x -o nodesource_setup.sh &&\
    bash nodesource_setup.sh &&\
    apt-get install nodejs -y &&\
    npm install -g yarn

# install java
# RUN apt-get install default-jdk -y

# install maven
RUN apt-get install maven -y

# Clean clears out the local repository of retrieved package files. Run apt-get clean from time to time to free up disk space.
RUN apt-get clean \
  && rm -rf /var/lib/apt/lists/*

USER jenkins

