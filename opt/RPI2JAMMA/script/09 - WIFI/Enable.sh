#!/usr/bin/env bash
######################
## RPI2XXXXX aje_fr ##
######################

sudo sed -i 's/dtoverlay=pi3-disable-wifi/#_toverlay=pi3-disable-wifi/g' /boot/config.txt
sudo mv Enable.sh Enable.sh_
sudo mv Disable.sh_ Disable.sh
sync
sudo reboot
