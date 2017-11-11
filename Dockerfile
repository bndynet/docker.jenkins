FROM jenkins:latest

LABEL maintainer="Bendy Zhang <zb@bndy.net>"
 
USER root

RUN apt-get update &&\
    apt-get -y install sudo apt-utils &&\
    rm -rf /var/lib/apt/lists/*
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers

# install dotnet
ARG DOTNET_VERSION
ENV DOTNET_VERSION ${DOTNET_VERSION:-2.0.2}
RUN apt-get update
RUN apt-get -y install curl libunwind8 gettext apt-transport-https
RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
RUN mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
RUN sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-stretch-prod stretch main" > /etc/apt/sources.list.d/dotnetdev.list'
RUN apt-get update
RUN apt-get -y install dotnet-sdk-${DOTNET_VERSION}

# install chrome
RUN echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN apt-get update
RUN apt-get -y install google-chrome-stable

# install xvfb(X Virtual Frame Buffer) for browser testing
RUN apt-get update
RUN apt-get -y install xvfb
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

# install nodejs, yarn
RUN cd ~ &&\
    curl -sL https://deb.nodesource.com/setup_6.x -o nodesource_setup.sh &&\
    bash nodesource_setup.sh &&\
    apt-get -y install nodejs &&\
    npm install -g yarn
# install nvm plugin for node version management
RUN /usr/local/bin/install-plugins.sh nvm-wrapper

# install maven
RUN apt-get -y install maven

# Clean clears out the local repository of retrieved package files. Run apt-get clean from time to time to free up disk space.
RUN apt-get clean \
  && rm -rf /var/lib/apt/lists/*

USER jenkins

