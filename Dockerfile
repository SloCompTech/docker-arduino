FROM ubuntu:latest

# Add properties to container
LABEL maintainer="Martin Dagarin <martin.dagarin@gmail.com>" version="1.8.5"

# Version of Arduino IDE to download
ENV ARDUINO_VERSION="1.8.5"

# Where Arduino IDE should be installed
ENV ARDUINO_DIR="/opt/arduino"

# Arduino built-in libraries directory
ENV ARDUINO_LIBS="${ARDUINO_DIR}/libraries"

# Arduino built-in examples directory
ENV ARDUINO_EXAMPLES="${ARDUINO_DIR}/examples"

# Binary directory
ENV BIN_DIR="/usr/local/bin"

# Get updates and install dependencies
RUN apt-get update && apt-get install wget tar xz-utils -y && apt-get clean && rm -rf /var/lib/apt/list/*

# Get and install Arduino IDE
RUN wget -q https://downloads.arduino.cc/arduino-${ARDUINO_VERSION}-linux64.tar.xz -O arduino.tar.xz && \
    tar -xf arduino.tar.xz && \
    rm arduino.tar.xz && \
    mv arduino-${ARDUINO_VERSION} ${ARDUINO_DIR} && \
    ln -s ${ARDUINO_DIR}/arduino ${BIN_DIR}/arduino && \
    ln -s ${ARDUINO_DIR}/arduino-builder ${BIN_DIR}/arduino-builder && \
    echo "${ARDUINO_VERSION}" > ${ARDUINO_DIR}/version.txt
