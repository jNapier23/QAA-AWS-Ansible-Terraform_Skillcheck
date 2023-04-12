#Specifies image
FROM ubuntu:latest
#Clones repo containing application to run
RUN git clone https://gitlab.com/Reece-Elder/devops-m5-nodeproject/
RUN cd devops-m5-nodeprojct
#Install requirements
RUN sudo apt update && sudo apt install nodejs
RUN node -v
RUN sudo apt install npm
#Install application
RUN node index.js
#Should return "Hello World" if app has successfully installed
RUN cat localhost:5000