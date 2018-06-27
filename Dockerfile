FROM ubuntu:latest

# Add properties to container
LABEL maintainer="Martin Dagarin <martin.dagarin@gmail.com>"
LABEL version="1.8.5"

# Get updates and install dependencies
RUN apt-get update && apt-get install wget tar xz-utils -y && apt-get clean && rm -rf /var/lib/apt/list/*

# Copy files to image
COPY arduino_get_version.sh arduino_get_version.sh
COPY get_vars.sh get_vars.sh
COPY install_arduino.sh install_arduino.sh
COPY print_vars.sh print_vars.sh

# Run commands to setup image
RUN ./install_arduino.sh
RUN ./get_vars.sh



