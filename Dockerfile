FROM jenkins/jenkins
LABEL maintainer="Bendy Zhang <zb@bndy.net>"

# Skip initial setup
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

COPY init.groovy.d/executors.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY init.groovy.d/startup-properties.groovy /usr/share/jenkins/ref/init.groovy.d/

# install plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt

# drop back to the regular jenkins user - good practice
USER jenkins
