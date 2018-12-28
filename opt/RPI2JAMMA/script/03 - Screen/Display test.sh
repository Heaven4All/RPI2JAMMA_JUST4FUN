#!/usr/bin/env bash
######################
## RPI2XXXXX aje_fr ##
######################
clear
echo 5 >/dev/rpi2x-intf

rotation_config=$(cat /boot/config.txt | grep "display_rotate" | cut -d'=' -f2)

if [ "$rotation_config" -eq "1" ]; then
 sudo fbi --once -a -d /dev/fb0 -noverbose /opt/RPI2JAMMA/script/03\ -\ Screen/mire1_tate.png /opt/RPI2JAMMA/script/03\ -\ Screen/mire2_tate.png /opt/RPI2JAMMA/script/03\ -\ Screen/mire3_tate.png /opt/RPI2JAMMA/script/03\ -\ Screen/mire4_tate.png /opt/RPI2JAMMA/script/03\ -\ Screen/mire5_tate.png /opt/RPI2JAMMA/script/03\ -\ Screen/mire6_tate.png /opt/RPI2JAMMA/script/03\ -\ Screen/mire7_tate.png /opt/RPI2JAMMA/script/03\ -\ Screen/mire8_tate.png /opt/RPI2JAMMA/script/03\ -\ Screen/mire9_tate.png > /dev/null 2>&1
 elif [ "$rotation_config" -eq "3" ]; then
  sudo fbi --once -a -d /dev/fb0 -noverbose /opt/RPI2JAMMA/script/03\ -\ Screen/mire1_tate_r.png /opt/RPI2JAMMA/script/03\ -\ Screen/mire2_tate_r.png /opt/RPI2JAMMA/script/03\ -\ Screen/mire3_tate_r.png /opt/RPI2JAMMA/script/03\ -\ Screen/mire4_tate_r.png /opt/RPI2JAMMA/script/03\ -\ Screen/mire5_tate_r.png /opt/RPI2JAMMA/script/03\ -\ Screen/mire6_tate_r.png /opt/RPI2JAMMA/script/03\ -\ Screen/mire7_tate_r.png /opt/RPI2JAMMA/script/03\ -\ Screen/mire8_tate_r.png /opt/RPI2JAMMA/script/03\ -\ Screen/mire9_tate_r.png > /dev/null 2>&1
 else
  sudo fbi --once -a -d /dev/fb0 -noverbose /opt/RPI2JAMMA/script/03\ -\ Screen/mire1_yoko.png /opt/RPI2JAMMA/script/03\ -\ Screen/mire2_yoko.png /opt/RPI2JAMMA/script/03\ -\ Screen/mire3_yoko.png /opt/RPI2JAMMA/script/03\ -\ Screen/mire4_yoko.png /opt/RPI2JAMMA/script/03\ -\ Screen/mire5_yoko.png /opt/RPI2JAMMA/script/03\ -\ Screen/mire6_yoko.png /opt/RPI2JAMMA/script/03\ -\ Screen/mire7_yoko.png /opt/RPI2JAMMA/script/03\ -\ Screen/mire8_yoko.png /opt/RPI2JAMMA/script/03\ -\ Screen/mire9_yoko.png /opt/RPI2JAMMA/script/03\ -\ Screen/mire_tv.jpg /opt/RPI2JAMMA/script/03\ -\ Screen/mire_rgb.png > /dev/null 2>&1 
fi

echo 0 >/dev/rpi2x-intf
sync
clear
