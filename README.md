# Docker Arduino

## What it is docker-arduino ?
_Docker-arduino_ is **docker image** for simple building and testing _Arduino_ **sketches** and **libraries**.

## Tools included
Images has preinstalled whole _Arduino IDE_ from [Arduino webside](https://www.arduino.cc/en/Main/Software). This also includes **arduino** and **arduino-builder** which are linked in a way that they can be easy accessed by typing `arduino` or `arduino-builder`.

## Enviroment variables
Images also includes enviroment variables for easier building.

|Variable name|Description|
|:-----------:|:----------|
|**ARDUINO_DIR**|Directory where Arduino IDE is installed.|
|**ARDUINO_EXAMPLES**|Directory where Arduino build-in examples are installed.|
|**ARDUINO_HARDWARE**|Hardware directory of Arduino IDE|
|**ARDUINO_LIBS**|Directory where Arduino build-in libraries are installed.|
|**ARDUINO_TOOLS**|Directory with hardware tools of Arduino IDE.|
|**ARDUINO_TOOLS_BUILDER**|Directory with tools-builder of Arduino IDE|
|**ARDUINO_VERSION**|Version of Arduino IDE|
|**A_FQBN**|Arduino fully Qualified Board Name prefix|
|**BIN_DIR**|Directory where links for binaries are created.|


## Examples

Currenty there aren't any yet, but look at [documentation of arduino-builder](https://github.com/arduino/arduino-builder) and [CI tutorial](https://github.com/arduino/arduino-builder/wiki/Doing-continuous-integration-with-arduino-builder).
