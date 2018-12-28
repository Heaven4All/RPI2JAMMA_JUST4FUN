#!/usr/bin/env bash
######################
## RPI2XXXXX aje_fr ##
######################
tput reset
clear
cd /opt/RPI2JAMMA/emulateurs/amiberry/adf_scanner/
echo 5 >/dev/rpi2x-intf
setterm -foreground white
sudo ./adf_scanner.sh -v
#>/dev/tty
setterm -foreground black && clear
echo 0 >/dev/rpi2x-intf
sync
clear
