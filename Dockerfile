From jenkins:latest
 
USER root

RUN apt-get update &&\
    apt-get install -y sudo &&\
    rm -rf /var/lib/apt/lists/*
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers

# install node and yarn
RUN cd ~ &&\
    curl -sL https://deb.nodesource.com/setup_6.x -o nodesource_setup.sh &&\
    bash nodesource_setup.sh &&\
    apt-get install nodejs &&\
    npm install -g yarn

# install java
RUN apt-get install default-jdk

# install maven
RUN apt-get install maven
 
USER jenkins

