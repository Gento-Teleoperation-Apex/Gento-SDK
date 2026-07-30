#!/bin/sh
echo "Installing system..."
mount -o remount rw /
rm -rf /home/FUSION
rm -rf /mnt/FUSION
update-rc.d -f FXStart.sh remove
mkdir -p /home/FUSION
mkdir -p /mnt/FUSION
cp -rf bin lib Shell /home/FUSION/
cp -rf Config /mnt/FUSION/
mkdir -p /mnt/FUSION/log
mkdir -p /mnt/FUSION/Tmp
cp ./install_support/FXStart.sh /etc/init.d/FXStart.sh
cp ./install_support/sio_gpio.ko /home/FUSION/bin/sio_gpio.ko
cp ./install_support/interfaces /etc/network/interfaces
cd /home/FUSION
ln -s /mnt/FUSION/Config Config
ln -s /mnt/FUSION/log log
ln -s /mnt/FUSION/Tmp Tmp
chmod -R 755 /home/FUSION/bin
chmod -R 755 /home/FUSION/lib
chmod -R 755 /home/FUSION/Shell
chmod -R 644 /mnt/FUSION/Config
chmod -R 644 /mnt/FUSION/log
chmod -R 644 /mnt/FUSION/Tmp
chmod -R 755 /etc/init.d/FXStart.sh
update-rc.d FXStart.sh start 90 2 3 4 5 .
sh /home/FUSION/Shell/settags.sh
chmod -R 644 /home/FUSION/Tags
sync
mount -o remount ro /
echo "Install Ctrl finish"
