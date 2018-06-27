FROM ubuntu:latest

LABEL maintainer="Martin Dagarin <martin.dagarin@gmail.com>"
LABEL version="1.0"

RUN apt-get update && apt-get install wget tar xz-utils -y && apt-get clean && rm -rf /var/lib/apt/list/*

ADD install_arduino.sh /install_arduino.sh
RUN /install_arduino.sh




