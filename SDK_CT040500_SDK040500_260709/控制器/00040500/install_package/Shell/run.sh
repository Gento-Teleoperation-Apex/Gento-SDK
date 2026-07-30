#!/bin/bash

if [ -f /home/FUSION/Tmp/interfaces ]; then
	filesize_a=$(ls -l /home/FUSION/Tmp/interfaces | awk '{print $5}')
	if [ $filesize_a -gt 1 ]; then
		mount -o remount rw /
		sleep 3
		mv /home/FUSION/Tmp/interfaces /etc/network/interfaces
		sleep 1
		sync
		sleep 1
		mount -o remount ro /
		sudo ifdown -a 
		sleep 5
		sudo ifup -a
		sleep 5
	fi
fi

filesize_b=$(ls -l /etc/network/interfaces | awk '{print $5}')
if [ $filesize_b -lt 10 ]; then
	mount -o remount rw /
	echo "auto lo" >/home/FUSION/Tmp/interfaces	
	echo "iface lo inet loopback" >>/home/FUSION/Tmp/interfaces
	echo "auto eth3" >>/home/FUSION/Tmp/interfaces
	echo "iface eth3 inet static" >>/home/FUSION/Tmp/interfaces
	echo "pre-up sleep 70">>/home/FUSION/Tmp/interfaces
	echo "pre-up ip link set eth3 up || true">>/home/FUSION/Tmp/interfaces
	echo "pre-up sleep 5">>/home/FUSION/Tmp/interfaces
	echo "address 6.6.7.190" >>/home/FUSION/Tmp/interfaces
	echo "netmask 255.255.255.0" >>/home/FUSION/Tmp/interfaces
	echo "gateway 6.6.7.1" >>/home/FUSION/Tmp/interfaces
	echo "dns-nameservers 8.8.8.8" >>/home/FUSION/Tmp/interfaces
	echo "post-up ip link set eth3 up " >>/home/FUSION/Tmp/interfaces

	sleep 3
	mv /home/FUSION/Tmp/interfaces /etc/network/interfaces
	sleep 1
	sync
	sleep 1
	mount -o remount ro /
	sudo ifdown -a 
	sleep 5
	sudo ifup -a
	sleep 5
fi

if [ -f /home/FUSION/Tmp/UpdateFlag ]; then
	echo "updating system..."
	mount -o remount rw /
	if [ -f /home/FUSION/Tmp/update_package.UPDATE ]; then
		echo "updating system binary..."
		cd /home/FUSION/Tmp
		rm -rf update_package
		tar xf update_package.UPDATE
		sh update_package/FXAutoRun.sh
	fi
	if [ -f /home/FUSION/Tmp/robot.ini.UPDATE ]; then
		echo "updating system config..."
		mv -f /home/FUSION/Tmp/robot.ini.UPDATE /home/FUSION/Config/cfg/robot.ini
	fi
	rm -f /home/FUSION/Tmp/UpdateFlag
	sync
	mount -o remount ro /
	echo "updating finish"
fi	

sh /home/FUSION/Shell/start.sh
exit

