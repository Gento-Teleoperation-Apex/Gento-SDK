#!/bin/bash	

export LD_LIBRARY_PATH=/home/FUSION/lib:/usr/xenomai/lib:/opt/etherlab/lib
sleep 3
mknod /dev/FXSysInfo c 256 0
mknod /dev/FXCfgConfig c 257 0
mknod /dev/FXMac       c 258 0
mknod /dev/FXUdp       c 259 0
mknod /dev/FXSysDbg    c 260 0
mknod /dev/FXLog       c 261 0
mknod /dev/FXPsi2Si    c 262 0
mknod /dev/FXTerminal  c 263 0

cd /home/FUSION/bin
insmod sio_gpio.ko
insmod FXKMemory.ko
sleep 1
insmod FXSI.ko &
#sleep 1
./FXNULL &
./FXPSI &
./FXFileServer &
./FXUDP &
./FXNULL &




