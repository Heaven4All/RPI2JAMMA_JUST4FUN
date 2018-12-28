#!/usr/bin/env bash
######################
## RPI2XXXXX aje_fr ##
######################
if [ -f /media/usb/Patch_RPI2XXXXX ]
then
  echo "/opt/RPI2JAMMA/script/04\ -\ Tools/Install\ Update\ Patch.sh_hidden" > /tmp/RPI2X_script
  sudo killall emulationstation
fi
