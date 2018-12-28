#!/usr/bin/env bash
######################
## RPI2XXXXX aje_fr ##
######################

sed -i 's/genesis_plus_gx_region_detect = "ntsc-u"/genesis_plus_gx_region_detect = "auto"/g' /opt/RPI2JAMMA/retroarch/retroarch-core-options.cfg
sed -i 's/genesis_plus_gx_region_detect = "ntsc-j"/genesis_plus_gx_region_detect = "auto"/g' /opt/RPI2JAMMA/retroarch/retroarch-core-options.cfg
sed -i 's/genesis_plus_gx_region_detect = "pal"/genesis_plus_gx_region_detect = "auto"/g' /opt/RPI2JAMMA/retroarch/retroarch-core-options.cfg
