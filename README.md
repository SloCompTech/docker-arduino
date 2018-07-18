# Docker Arduino

[![Build Status](https://travis-ci.org/SloCompTech/docker-arduino.svg?branch=master)](https://travis-ci.org/SloCompTech/docker-arduino)

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

### Pure commands
Here is how would look command to compile your sketch.
```bash
arduino-builder -hardware ${ARDUINO_HARDWARE} -tools ${ARDUINO_TOOLS}/avr -tools ${ARDUINO_TOOLS_BUILDER} -libraries ${ARDUINO_LIBS} -libraries <your lib folder> -fqbn ${A_FQBN}:<arduino board name> <sketch>
```
**Note:** If you are running above command with `sudo docker exec <container>`, use `'`, so in the end you get `sudo docker exec <container> bash -c '<command>'`.

or
```bash
arduino --verify <sketch>
```

### Integrated commands & special directories & files
|**Command**|**Description**|
|:---------:|:--------------|
|arduino_add_board_url _\<url>_|Add Arduino platform url|
|adruino_build_lib _\<path to lib dir>_|Build whole libariy with examples|
|arduino_build_sketch _\<path to sketch>_|Builds sketch|
|arduino_build_sketches _\<path to folder or sketch>_|Builds folder which contains sketch or folders with sketches or sketch itself|
|arduino_emulate_gui|Starts fake GUI for Arduino IDE|
|arduino_install_board _\<boards>_|Installs additional boards|
|arduino_install_lib _{\<lib name>\|\<git url>}_|Installs library|
|arduino_verify_sketch _\<sketch>_| Same as arduino_build_sketch exept that command uses _arduino_ instead of _arduino-builder_|

**Note:** Scripts for building libs and multiple sketches expect that sketch has same name as folder and .ino extension.

**Special directories**
Home directory(/root)
- Arduino
    - libraries (folder for additional libraries)
    - hardware (folder for hardware)
    - tools (additional tools)
- arduino_hardware.txt (additional links to hardware, separate with new line)
- arduino_platforms.txt (override default boards, separate with new line)
- arduino_tools.txt (additional links to tools)

**Examples:**

Full example:
```
arduino_install_board <board> # Install additional boards
arduino_install_lib <lib_name1>,<git_url>,<lib_name2> # Download libraries
git clone https://github.com/user/repo.git repo
arduino_build_lib repo
```

Set boards with command:
`àrduino_build_lib repo arduino:avr:uno,arduino:avr:nano,...`

Build sketch:
`arduino_build_sketch repo/repo.ino`

### Example repositories
- [QList](https://github.com/SloCompTech/QList)

Feel free to contribute

### Board list (not all, but most of them)
```
arduino:avr:uno
arduino:avr:pro
arduino:avr:lilypad
arduino:avr:mini:cpu=atmega328
arduino:avr:esplora
arduino:avr:micro:cpu=atmega328
arduino:avr:nano:cpu=atmega328
arduino:avr:mega:cpu=atmega2560
arduino:avr:diecimila
arduino:avr:yun
arduino:sam:arduino_due_x
arduino:samd:arduino_zero_native
esp8266:esp8266:huzzah:FlashSize=4M3M,CpuFrequency=80
arduino:avr:leonardo
adafruit:samd:adafruit_metro_m4
adafruit:avr:trinket5
arduino:avr:gemma
```

## External documentation
- [arduino CLI commands](https://github.com/arduino/Arduino/blob/master/build/shared/manpage.adoc)
- [arduino-builder](https://github.com/arduino/arduino-builder)
- [arduino-builder CI tutorial](https://github.com/arduino/arduino-builder/wiki/Doing-continuous-integration-with-arduino-builder).
