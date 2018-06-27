#!/bin/bash

#
# Arduino get version script
#

ARDUINO_VERSION="$(wget -nv -q -O - https://www.arduino.cc/en/Main/Software | grep -Po '(?!arduino-)([0-9\.]{5,})(?=-linux64\.tar\.xz)')"
if [ "$ARDUINO_VERSION" == "" ]
then
    echo "Failed to get Arduino IDE version"
    exit 1
fi
echo "${ARDUINO_VERSION}"
exit 0