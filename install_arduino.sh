#!/bin/bash

#
#   Script that installs arduino platform
#

echo "Getting Arduino IDE version"
ARDUINO_VERSION="$(wget -nv -q -O - https://www.arduino.cc/en/Main/Software | grep -Po '(?!arduino-)([0-9\.]{5,})(?=-linux64\.tar\.xz)')"
if [ "$ARDUINO_VERSION" == "" ]
then
    echo "Failed to get Arduino IDE version"
    exit -1
fi
echo "Arduino IDE versiom ${ARDUINO_VERSION}" 
echo "Downloading Arduino IDE ..."
wget -nv -q https://downloads.arduino.cc/arduino-${ARDUINO_VERSION}-linux64.tar.xz -O arduino.tar.xz
echo "Extracting ..."
tar -xf arduino.tar.xz
rm arduino.tar.xz
mv arduino-${ARDUINO_VERSION} /opt/arduino
ln -s /opt/arduino /usr/local/bin/arduino
ln -s /opt/arduino-builder /usr/local/bin/arduino-builder
exit 0