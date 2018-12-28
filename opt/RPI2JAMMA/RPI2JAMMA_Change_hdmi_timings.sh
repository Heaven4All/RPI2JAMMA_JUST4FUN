#!/usr/bin/env bash
#RPI2JAMMA (c)aje_fr
clear
if [ -z "$1" ]
then
exit
fi

Mode_video_cga=$(cat /media/usb/Config_RPI2XXXXX/Video_output_cga.txt | grep "^$1" | cut -d'=' -f2)
Largeur_cga=$(echo $Mode_video_cga | cut -d' ' -f1)
Hauteur_cga=$(echo $Mode_video_cga | cut -d' ' -f6)
Mode_video_vga=$(cat /media/usb/Config_RPI2XXXXX/Video_output_vga.txt | grep "^$1" | cut -d'=' -f2)
Largeur_vga=$(echo $Mode_video_vga | cut -d' ' -f1)
Hauteur_vga=$(echo $Mode_video_vga | cut -d' ' -f6)

#On efface l'ecran
setterm -term linux -back black -fore black -clear all
tput civis
tput reset
clear

reso="cga"
if grep -q "RPI2NUC" /proc/bus/input/devices
then
 if [ ! -f "/media/usb/Config_RPI2XXXXX/rpi2nuc_video.txt" ]
 then
   reso="vga"
 else
  force_15k=$(cat "/media/usb/Config_RPI2XXXXX/rpi2nuc_video.txt" | grep "^run_in_15khz" | cut -d'=' -f2)
  if [ "$force_15k" == "true" ]
   then
    reso="cga"
   else
    reso="vga"
   fi
 fi
fi
if [ "$reso" == "vga" ]
then
 if [ -z "$Mode_video_vga" ]
 then
 exit
 fi
 /opt/vc/bin/vcgencmd hdmi_timings $Mode_video_vga
 tvservice -e "DMT 87"
 fbset -depth 8 && fbset -depth 16 -xres $Largeur_vga -yres $Hauteur_vga
else
 if [ -z "$Mode_video_cga" ]
 then
 exit
 fi
 /opt/vc/bin/vcgencmd hdmi_timings $Mode_video_cga
 tvservice -e "DMT 87"
 fbset -depth 8 && fbset -depth 16 -xres $Largeur_cga -yres $Hauteur_cga
fi
