#!/bin/bash

#
#   Export variables script
#

ARDUINO_NET_VERSION="$(./arduino_get_version.sh)" # Version of Arduino IDE from Internet
ARDUINO_DIR="/opt/arduino" # Path to Arduino IDE install dir
ARDUINO_LIBS="${ARDUINO_DIR}/libraries" # Path to built-in libraries dir
ARDUINO_EXAMPLES="${ARDUINO_DIR}/examples" # Path to built-in examples dir
ARDUINO_VERSION="" # Holds currently installed version of IDE

if cat ${ARDUINO_DIR}/version.txt > /dev/null; then
    ARDUINO_VERSION="$(cat ${ARDUINO_DIR}/version.txt)"
fi
echo "export ARDUINO_NET_VERSION=\"${ARDUINO_NET_VERSION}\""
echo "export ARDUINO_VERSION=\"${ARDUINO_VERSION}\""
echo "export ARDUINO_DIR=\"${ARDUINO_DIR}\""
echo "export ARDUINO_LIBS=\"${ARDUINO_LIBS}\""
echo "export ARDUINO_EXAMPLES=\"${ARDUINO_EXAMPLES}\""