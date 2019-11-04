FROM ubuntu

# install pip and zip so you can install packages and zip them up for Lambda
RUN apt-get update && apt-get install python-pip \
    zip -y

# creates a working directory. this should be mounted to a local folder with your code via docker run
RUN mkdir working

# starts container in /working
ENV foo /working
WORKDIR ${foo}