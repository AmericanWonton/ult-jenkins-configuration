FROM jenkins/jenkins:latest
#Need to be root User to do all this stuff
USER root
#This prevents the container from performing the initial setup wizard
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
#This adds environment variables for our Jenkins to use
ENV CASC_JENKINS_CONFIG /var/jenkins_home/casc.yaml
COPY ./credential_setup/casc.yaml /var/jenkins_home/casc.yaml
#Copy Plugins
# Old version: COPY ./plugins_setup/plugins.txt /usr/share/jenkins/ref/plugins.txt
COPY --chown=jenkins:jenkins ./plugins_setup/plugins.txt /usr/share/jenkins/ref/plugins.txt
#Make directory for Jenkins Secret stuff
#Install plugins
# Old version: RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt
#This will attempt to install make
RUN apt-get update -y 
RUN apt-get install build-essential -y
#install sudo for script use
RUN apt-get install sudo
#This is for running Docker inside our Docker container with jenkins
RUN apt-get install apt-utils
#This is for debugging and stuff
RUN apt-get -y install nano
#Install Docker
RUN curl -sSL https://get.docker.com/ | sh
#Switch to the jenkins User
USER jenkins
#RUN mkdir
RUN mkdir /var/jenkins_home/somesecrets
#Copy resume key for server
COPY --chown=jenkins:jenkins ./creds_listing/resumekeygen /var/jenkins_home/somesecrets/resumekeygen
COPY --chown=jenkins:jenkins ./creds_listing/resumekeygen.pub /var/jenkins_home/somesecrets/resumekeygen.pub
COPY --chown=jenkins:jenkins ./creds_listing/env-creds.list /var/jenkins_home/somesecrets/env-creds.list
RUN chmod 777 -R /var/jenkins_home/somesecrets/*
#Add User with Sudo permissions
#RUN useradd -aG sudo jenkins
#Checks Sudo permissions
#RUN getent group sudo
#Expose our ports
EXPOSE 7070
EXPOSE 5000