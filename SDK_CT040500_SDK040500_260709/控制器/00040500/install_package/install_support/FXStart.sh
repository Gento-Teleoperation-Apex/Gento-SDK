#!/bin/sh
sudo service ethercat start
sleep 3
ifdown eth3
sleep 1
ifup eth3
sudo sh /home/FUSION/Shell/run.sh


