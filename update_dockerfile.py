#!/usr/bin/python

#
# Update dockerfile with new arduino version
#
import os
import sys
import urllib2
import re
file = open('Dockerfile','r')
lines = file.readlines()
file.close()

#version = os.system("wget -nv -q -O - https://www.arduino.cc/en/Main/Software | grep -Po '(?!arduino-)([0-9\.]{5,})(?=-linux64\.tar\.xz)'")
response = urllib2.urlopen('https://www.arduino.cc/en/Main/Software')
version = re.search('(?!arduino-)([0-9\.]{5,})(?=-linux64\.tar\.xz)',response.read()).group(0)

file = open('Dockerfile','w')
for i in range(0,len(lines)) :
    if lines[i].startswith('ENV ARDUINO_VERSION'):
        file.write("ENV ARDUINO_VERSION=\"%s\"\n" % (version))
    else:
        file.write(lines[i])
file.close()
sys.exit(0)