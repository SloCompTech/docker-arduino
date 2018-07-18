FROM debian:stretch-slim

# Version of arduino IDE
ARG VERSION="1.8.5"

# Version of Arduino IDE to download
ENV ARDUINO_VERSION=$VERSION

# Where Arduino IDE should be installed
ENV ARDUINO_DIR="/opt/arduino"

# Arduino built-in examples
ENV ARDUINO_EXAMPLES="${ARDUINO_DIR}/examples"

# Arduino hardware
ENV ARDUINO_HARDWARE="${ARDUINO_DIR}/hardware"

# Arduino built-in libraries
ENV ARDUINO_LIBS="${ARDUINO_DIR}/libraries"

# Arduino tools
ENV ARDUINO_TOOLS="${ARDUINO_HARDWARE}/tools"

# Arduino tools-builder
ENV ARDUINO_TOOLS_BUILDER="${ARDUINO_DIR}/tools-builder"

# Arduino boards FQBN prefix
ENV A_FQBN="arduino:avr"

# Binary directory
ENV A_BIN_DIR="/usr/local/bin"

# Tools directory
ENV A_TOOLS_DIR="/opt/tools"

# Home directory
ENV A_HOME="/root"

# Shell
SHELL ["/bin/bash","-c"]

# Working directory
WORKDIR ${A_HOME}

# Get updates and install dependencies
RUN apt-get update && apt-get install wget tar xz-utils git xvfb -y && apt-get clean && rm -rf /var/lib/apt/list/*

# Get and install Arduino IDE
RUN wget -q https://downloads.arduino.cc/arduino-${ARDUINO_VERSION}-linux64.tar.xz -O arduino.tar.xz && \
    tar -xf arduino.tar.xz && \
    rm arduino.tar.xz && \
    mv arduino-${ARDUINO_VERSION} ${ARDUINO_DIR} && \
    ln -s ${ARDUINO_DIR}/arduino ${A_BIN_DIR}/arduino && \
    ln -s ${ARDUINO_DIR}/arduino-builder ${A_BIN_DIR}/arduino-builder && \
    echo "${ARDUINO_VERSION}" > ${A_ARDUINO_DIR}/version.txt

# Install additional commands & directories
RUN mkdir ${A_TOOLS_DIR}
COPY tools/* ${A_TOOLS_DIR}/
RUN chmod +x ${A_TOOLS_DIR}/* && \
    ln -s ${A_TOOLS_DIR}/* ${A_BIN_DIR}/ && \
    mkdir ${A_HOME}/Arduino && \
    mkdir ${A_HOME}/Arduino/libraries && \
    mkdir ${A_HOME}/Arduino/hardware && \
    mkdir ${A_HOME}/Arduino/tools

# Install additional Arduino boards and libraries
RUN arduino_add_board_url https://adafruit.github.io/arduino-board-index/package_adafruit_index.json,http://arduino.esp8266.com/stable/package_esp8266com_index.json && \
    arduino_install_board arduino:sam && \
    arduino_install_board arduino:samd && \
    arduino_install_board esp8266:esp8266 && \
    arduino_install_board adafruit:avr && \
    arduino_install_board adafruit:samd && \
    arduino --pref "compiler.warning_level=all" --save-prefs 2>&1

