#!/bin/bash

#
#   Tools for Docker-arduino image
#

AT_PLATFORMS="arduino_platforms.txt"
AT_HARDWARE="arduino_hardware.txt"
AT_TOOLS="arduino_tools.txt"
AT_DEF_PLATFORMS=(arduino:avr:uno arduino:avr:mega:cpu=atmega2560 arduino:avr:nano:cpu=atmega328)
AT_SHOW_RESULT=0
AT_ADDITIONAL_ARGS=""

# Check if url has specified extension
function url_check_ext() {
    if [ $# -lt 2 ]; then
        echo "Usage: url_check_ext <string> <extension>"
        return 1
    fi
    IFS='.' read -ra arr <<< "$1"
    local arr_len=${#arr[*]}
    if [ $arr_len -lt 2 ]; then
        return 2
    elif [ "${arr[$arr_len-1]}" = "$2" ]; then
        return 0
    else
        return 3
    fi
}

# Get repo name from git URL
function get_name_from_url() {
    if [ $# -lt 1 ]; then
        echo "Usage: get_name_from_url <string>"
        return 1
    fi
    IFS='/' read -ra arr <<< "$1"
    local arr_len=${#arr[*]}
    if [ $arr_len -lt 1 ]; then
        return 2
    fi
    IFS='.' read -ra arr1 <<< "${arr[$arr_len-1]}"
    local arr1_len=${#arr1[*]}
    if [ $arr1_len -lt 2 ]; then
        echo "${arr1[0]}"
        return 0
    fi
    echo "${arr[$arr_len-1]:0:(${#arr[$arr_len-1]}-${#arr1[$arr1_len-1]}-1)}"
    return 0
}

# Install Arduino board package
function at_install_board() {
    if [ $# -lt 1 ]; then
        echo "Usage: arduino_install_board <package_name>:<platform> <architecture>[:version]"
        return 1
    fi

    echo -n "Installing board($@): "
    local output
    output=$(arduino --install-boards $@ 2>&1)
    if [ $? -ne 0 ]; then 
        echo -e "\xe2\x9c\x96"
        echo $output
        return 2
    else 
        echo -e "\xe2\x9c\x93"
        return 0
    fi
}

# Install arduino library
function at_install_lib() {
    if [ $# -lt 1 ]; then
        echo "Usage: arduino_install_lib {<lib_name>[:<version>][,<lib_name>[:version]]|<git_url>[,<git_url>]}"
        return 1
    fi

    # Separate library list (separated with ,)
    local libraries
    local count_total=0
    local count_ok=0
    local count_fail=0

    IFS=',' read -ra libraries <<< "$1"
    for library in "${libraries[@]}"; do
        # Process each library
        ((count_total++))
        # Check if it is git URL
        url_check_ext $library git
        case $? in
        0)
            # Git URL
            local repo_name
            repo_name=$(get_name_from_url $library)
            if [ $? -ne 0 ]; then
                echo "Unknown repo name"
                ((count_fail++))
                continue
            fi
            echo -n "Installing library($repo_name): "
            local output
            output=$(git clone $library $HOME/Arduino/libraries/$repo_name 2>&1)
            if [ $? -ne 0 ]; then
                echo -e "\xe2\x9c\x96"
                echo $output
                ((count_fail++))
                continue
            else
                echo -e "\xe2\x9c\x93"
                ((count_ok++))
                continue
            fi
            ;;
        2)
            # Normal libary name
            echo -n "Installing library($library): "
            local output
            output=$(arduino --install-library $library 2>&1)
            if [ $? -ne 0 ]; then
                echo -e "\xe2\x9c\x96"
                echo $output
                ((count_fail++))
                continue
            else
                echo -e "\xe2\x9c\x93"
                ((count_ok++))
                continue
            fi
            ;;
        3)
            # Unknown url
            echo "Unknown git URL"
            ((count_fail++))
            continue
            ;;
        *)
            # ?
            echo "Unknown error"
            ((count_fail++))
            continue
            ;;
        esac
    done
    echo "Total: ${count_total}, Installed: ${count_ok}, Failed: ${count_fail}"
    if [[ $count_fail -gt 0 ]]; then
        return 1
    else
        return 0
    fi
}

# Build Arduino sketch
function at_build_sketch() {
    if [ $# -lt 1 ]; then
        echo "Usage: arduino_build_sketch <sketch_name> [<platform>[,<platform>]]"
        return 1
    fi
    
    # Check if sketch exist
    if [ ! -f "$1" ]; then
        echo "Sketch $1 does not exists"
        return 2
    fi

    # Check if we explicitly defined platforms for sketch
    local platforms=()
    if [ $# -ge 2 ]; then
        # Read platforms as argument (separated with ,)
        IFS=',' read -ra platforms <<< "$2"
    else
        if [ -f $HOME/$AT_PLATFORMS ]; then
            # Get settings from files
            readarray -t platforms < "$HOME/$AT_PLATFORMS"
        else
            # Use default platforms
            platforms=${AT_DEF_PLATFORMS[@]}
        fi
    fi

    # Check if we have to include other hardware folders
    local hardware
    local hardware_str=""
    if [ -f $HOME/$AT_HARDWARE ]; then
        # Get settings from files
        readarray -t hardware < "$HOME/$AT_HARDWARE"
        
        for hw in "${hardware[@]}"; do
            if [ "${hardware_str}" = "" ]; then
                hardware_str="-tools ${hw}"
            else
                hardware_str="$hardware_str -tools $hw"
            fi
        done
    fi

    # Check if we have to include other tools
    local tools
    local tools_str=""
    if [ -f $HOME/$AT_TOOLS ]; then
        # Get settings from files
        readarray -t tools < "$HOME/$AT_TOOLS"
        for tool in "${tools[@]}"; do
            if [ "${tools_str}" = "" ]; then
                tools_str="-tools $tool"
            else
                tools_str="$tools_str -tools $tool"
            fi
        done
    fi

    # Get sketch name
    local arr
    local arr2
    local sketch_name=""
    IFS='/' read -ra arr <<< "$1"
    if [ ${#arr[*]} -eq 1 ]; then
        sketch_name=${arr[0]}
    else
        sketch_name=${arr[-1]}
    fi

    local output
    local result=0
    echo "Sketch: $sketch_name"
    for board in ${platforms[*]}; do
        echo -n "   $board: "
        output=$(arduino-builder -hardware ${ARDUINO_HARDWARE} -hardware $HOME/Arduino/hardware ${hardware_str} -tools ${ARDUINO_TOOLS}/avr -tools ${ARDUINO_TOOLS_BUILDER} -tools $HOME/Arduino/tools ${tools_str} -libraries ${ARDUINO_LIBS} -libraries $HOME/Arduino/libraries ${AT_ADDITIONAL_ARGS} -fqbn $board $1 2>&1)
        if [ $? -ne 0 ]; then
            echo -e "\xe2\x9c\x96"
            if [ "$output" != "" ]; then
                echo $output
            fi
            result=3
        else
            echo -e "\xe2\x9c\x93"
            if [ $AT_SHOW_RESULT -ne 0 ]; then
                if [ "$output" != "" ]; then
                    echo $output
                fi
            fi
        fi
    done
    return $result
}

# Build Arduino sketch using GUI
function at_verify_sketch() {
    if [ $# -lt 1 ]; then
        echo "Usage: arduino_build_sketch <sketch_name> [<platform>[,<platform>]]"
        return 1
    fi
    
    # Check if sketch exist
    if [ ! -f "$1" ]; then
        echo "Sketch $1 does not exists"
        return 2
    fi

    # Check if we explicitly defined platforms for sketch
    local platforms=()
    if [ $# -ge 2 ]; then
        # Read platforms as argument (separated with ,)
        IFS=',' read -ra platforms <<< "$2"
    else
        if [ -f $HOME/$AT_PLATFORMS ]; then
            # Get settings from files
            readarray -t platforms < "$HOME/$AT_PLATFORMS"
        else
            # Use default platforms
            platforms=${AT_DEF_PLATFORMS[@]}
        fi
    fi

    # Get sketch name
    local arr
    local arr2
    local sketch_name=""
    IFS='/' read -ra arr <<< "$1"
    if [ ${#arr[*]} -eq 1 ]; then
        sketch_name=${arr[0]}
    else
        sketch_name=${arr[-1]}
    fi

    local output
    local result=0
    echo "Sketch: $sketch_name"
    for board in ${platforms[*]}; do
        echo -n "   $board: "
        output=$(arduino --board $board --save-prefs 2>&1)
        if [ $? -ne 0 ]; then
            echo "Failed to change the board"
            return 4
        fi
        output=$(arduino ${AT_ADDITIONAL_ARGS} --verify $1 2>&1)
        if [ $? -ne 0 ]; then
            echo -e "\xe2\x9c\x96"
            if [ "$output" != "" ]; then
                echo $output
            fi
            result=5
        else
            echo -e "\xe2\x9c\x93"
            if [ $AT_SHOW_RESULT -ne 0 ]; then
                if [ "$output" != "" ]; then
                    echo $output
                fi
            fi
        fi
    done
    return $result
}

# Build Arduino library folder (build all examples in library)
function at_build_lib() {
    if [ $# -lt 1 ]; then
        echo "Usage: arduino_build_lib <lib_folder> [<platform>[,<platform>]]"
        return 1
    fi
    if [ ! -d $1 ]; then
        echo "Directory $1 does not exist"
        return 2
    fi
    path=$1
    if [ ${path:${#path}-1:1} = '/' ]; then
        path=${path:0:${#path}-1}
    fi
    if [ ! -d $path/examples ]; then
        echo "No examples to build"
        return 3
    fi

    # Set additional args
    AT_ADDITIONAL_ARGS="-libraries ${path}"

    # Extract library name from path
    local arr
    IFS='/' read -ra arr <<< "$1"
    local lib_name="${arr[-1]}"
    echo "Library: $lib_name"

    local count_total=0
    local count_ok=0
    local count_fail=0

    for obj in $path/examples/*; do
        # Ensure we get only directories
        [ -d "$obj" ] || continue

        # Fact that sketch name must be same as folder name
        local arr1
        IFS='/' read -ra arr1 <<< "$obj"
        [ -f "$obj/${arr1[-1]}.ino" ] || continue
        
        count_total=$((count_total+1))
        
        if [ $# -ge 2 ]; then
            at_build_sketch $obj/${arr1[-1]}.ino $2
        else
            at_build_sketch $obj/${arr1[-1]}.ino
        fi

        if [ $? -eq 0 ]; then
            count_ok=$((count_ok+1))
        else
            count_fail=$((count_fail+1))
        fi
    done
    echo "Total: $count_total, Success: $count_ok, Fail: $count_fail"

    # Remove additional args
    AT_ADDITIONAL_ARGS=""

    if [ $count_fail -eq 0 ]; then return 0; else return 1; fi
}

# Build Arduino sketches (more sketches in folder) TODO
function at_build_sketches() {
    if [ $# -lt 1 ]; then
        echo "Usage: arduino_build_sketches {<sketch>|<sketch folder>|<folder with more sketches>} [<platform>[,<platform>]]"
        return 1
    fi

    local count_total=0
    local count_ok=0
    local count_fail=0

    # Check if file was specified
    if [ -f $1 ]; then
        count_total=$((count_total+1))
        
        at_build_sketch $@

        if [ $? -eq 0 ]; then
            count_ok=$((count_ok+1))
        else
            count_fail=$((count_fail+1))
        fi
    elif [ -d $1 ]; then 
        local path=$1
        if [ ${path:${#path}-1:1} = '/' ]; then
            path=${path:0:${#path}-1}
        fi
        # Directory name
        local dir_name
        dir_name="$(get_name_from_url $path)"

        if [ $? -ne 0 ] || [ "$dir_name" = "" ]; then
            echo "Error"
            return 2
        elif [ -f "$path/$dir_name.ino" ]; then
            count_total=$((count_total+1))

            if [ $# -ge 2 ]; then
                at_build_sketch $path/$dir_name.ino $2
            else
                at_build_sketch $path/$dir_name.ino
            fi

            if [ $? -eq 0 ]; then
                count_ok=$((count_ok+1))
            else
                count_fail=$((count_fail+1))
            fi
        else
            # Go through whole directory
            for obj in $path/*; do  
                # Skip files because they are irrelevant
                [ -d "$obj" ] || continue

                dir_name="$(get_name_from_url $obj)"
                if [ $? -ne 0 ] || [ -f "$obj/$dir_name.ino" ]; then
                    count_total=$((count_total+1))

                    if [ $# -ge 2 ]; then
                        at_build_sketch $obj/$dir_name.ino $2
                    else
                        at_build_sketch $obj/$dir_name.ino
                    fi

                    if [ $? -eq 0 ]; then
                        count_ok=$((count_ok+1))
                    else
                        count_fail=$((count_fail+1))
                    fi
                else
                    # Skipping folder
                    echo -n ""
                fi
            done
        fi
    else
        echo "Not a file or directory"
        return 2
    fi

    echo "Total: $count_total, Success: $count_ok, Fail: $count_fail"

    if [ $count_fail -eq 0 ]; then return 0; else return 1; fi
}

# Add additional board URL to Arduino IDE
function at_add_board_url() {
    if [ $# -lt 1 ]; then
        echo 'Usage: arduino_add_board_url <url>'
        return 1
    fi

    local output=$(arduino --get-pref boardsmanager.additional.urls 2>&1)
    local arr
    readarray -t arr <<< "$output"
    if [ $? -ne 0 ]; then
        echo "Failed to get previous values"
        return 2
    fi

    output=$(arduino --pref "boardsmanager.additional.urls=${arr[-1]},$1" --save-prefs)
     if [ $? -ne 0 ]; then
        echo "Failed to set new values"
        echo "$output"
        return 3
    fi
    return 0
}

# Emulate GUI for Arduino IDE GUI
function at_emulate_gui() {
    /sbin/start-stop-daemon --start --quiet --pidfile /tmp/gui_xvfb_1.pid --make-pidfile --background --exec /usr/bin/Xvfb -- :1 -ac -screen 0 1280x1024x16
    sleep 3
    export DISPLAY=:1.0
}