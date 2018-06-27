#!/bin/bash

#
#   Script that installs arduino platform
#

echo "Getting Arduino IDE version"
eval $(./get_vars.sh)
if [ "$ARDUINO_NET_VERSION" == "" ]; then
    echo "Failed to get Arduino IDE version"
    exit 1
fi
echo "Arduino IDE versiom ${ARDUINO_NET_VERSION}" 
if [ "$ARDUINO_DIR" == "" ]; then
    echo "Failed to get Arduino IDE install path"
    exit 2
fi
echo "Downloading Arduino IDE ..."
wget -nv -q https://downloads.arduino.cc/arduino-${ARDUINO_NET_VERSION}-linux64.tar.xz -O arduino.tar.xz
echo "Extracting ..."
tar -xf arduino.tar.xz
rm arduino.tar.xz
echo "Installling ..."
mv arduino-${ARDUINO_NET_VERSION} ${ARDUINO_DIR}
echo "Linking ..."
ln -s ${ARDUINO_DIR}/arduino /usr/local/bin/arduino
ln -s ${ARDUINO_DIR}/arduino-builder /usr/local/bin/arduino-builder
echo "Writing current version ..."
echo "${ARDUINO_NET_VERSION}" > ${ARDUINO_DIR}/version.txt
cat ${ARDUINO_DIR}/version.txt
echo "Done ..."

exit 0