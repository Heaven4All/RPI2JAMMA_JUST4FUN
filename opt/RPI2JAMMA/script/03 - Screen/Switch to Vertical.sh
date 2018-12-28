#!/usr/bin/env bash
######################
## RPI2XXXXX aje_fr ##
######################

sudo sed -i 's/display_rotate=0/display_rotate=1/g' /boot/config.txt
sudo sed -i 's/display_rotate=3/display_rotate=1/g' /boot/config.txt
if grep -q "RPI2SCART" /proc/bus/input/devices
then
sudo plymouth-set-default-theme RPI2SCART_tate > /dev/null 2>&1
fi
if grep -q "RPI2JAMMA" /proc/bus/input/devices
then
sudo plymouth-set-default-theme RPI2JAMMA_tate > /dev/null 2>&1
fi
if grep -q "RPI2NUC" /proc/bus/input/devices
then
sudo plymouth-set-default-theme RPI2NUC_tate > /dev/null 2>&1
fi
sudo ln -fs /home/pi/.emulationstation/es_systems.cfg.tate /home/pi/.emulationstation/es_systems.cfg
#
# Switch ES themes
# search 
# <string name="ThemeSet" value="rpi2x_yokoXX" />
# replace yoko with tate and vice-versa
es_settings_file="/home/pi/.emulationstation/es_settings.cfg"
mode=$(awk '/value="rpi2x_/,/" \/>/' $es_settings_file | rev | cut -d'"' -f2 | rev | cut -d'_' -f2)
prev_mode="value=\"rpi2x_$mode\""
# vertical to horizontal
if [ $mode = 'yoko43' ]
then
new_mode="value=\"rpi2x_tate43\""
sudo sed -i 's/'$prev_mode'/'$new_mode'/' $es_settings_file
fi
if [ $mode = 'yoko' ]
then
new_mode="value=\"rpi2x_tate\""
sudo sed -i 's/'$prev_mode'/'$new_mode'/' $es_settings_file
fi
sync
sudo reboot
