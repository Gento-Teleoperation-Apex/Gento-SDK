#!/bin/sh
echo "Start to make install package...."
mkdir -p /home/FUSION/Tmp
rm -rf /home/FUSION/Tmp/install_package /home/FUSION/Tmp/install_package.INSTALL

mkdir -p /home/FUSION/Tmp/install_package
echo "#!/bin/sh" >/home/FUSION/Tmp/install_package/FXAutoRun.sh
echo "echo \"Installing system...\"">>/home/FUSION/Tmp/install_package/FXAutoRun.sh
echo "mount -o remount rw /">>/home/FUSION/Tmp/install_package/FXAutoRun.sh
echo "rm -rf /home/FUSION">>/home/FUSION/Tmp/install_package/FXAutoRun.sh
echo "rm -rf /mnt/FUSION">>/home/FUSION/Tmp/install_package/FXAutoRun.sh
echo "update-rc.d -f FXStart.sh remove">>/home/FUSION/Tmp/install_package/FXAutoRun.sh
echo "mkdir -p /home/FUSION">>/home/FUSION/Tmp/install_package/FXAutoRun.sh
echo "mkdir -p /mnt/FUSION">>/home/FUSION/Tmp/install_package/FXAutoRun.sh
echo "cp -rf bin lib Shell /home/FUSION/">>/home/FUSION/Tmp/install_package/FXAutoRun.sh
echo "cp -rf Config /mnt/FUSION/">>/home/FUSION/Tmp/install_package/FXAutoRun.sh
echo "mkdir -p /mnt/FUSION/log">>/home/FUSION/Tmp/install_package/FXAutoRun.sh
echo "mkdir -p /mnt/FUSION/Tmp">>/home/FUSION/Tmp/install_package/FXAutoRun.sh
echo "cp ./install_support/FXStart.sh /etc/init.d/FXStart.sh">>/home/FUSION/Tmp/install_package/FXAutoRun.sh
echo "cp ./install_support/sio_gpio.ko /home/FUSION/bin/sio_gpio.ko">>/home/FUSION/Tmp/install_package/FXAutoRun.sh
echo "cp ./install_support/interfaces /etc/network/interfaces">>/home/FUSION/Tmp/install_package/FXAutoRun.sh
echo "cd /home/FUSION">>/home/FUSION/Tmp/install_package/FXAutoRun.sh
echo "ln -s /mnt/FUSION/Config Config">>/home/FUSION/Tmp/install_package/FXAutoRun.sh
echo "ln -s /mnt/FUSION/log log">>/home/FUSION/Tmp/install_package/FXAutoRun.sh
echo "ln -s /mnt/FUSION/Tmp Tmp">>/home/FUSION/Tmp/install_package/FXAutoRun.sh
echo "chmod -R 755 /home/FUSION/bin">>/home/FUSION/Tmp/install_package/FXAutoRun.sh
echo "chmod -R 755 /home/FUSION/lib">>/home/FUSION/Tmp/install_package/FXAutoRun.sh
echo "chmod -R 755 /home/FUSION/Shell">>/home/FUSION/Tmp/install_package/FXAutoRun.sh
echo "chmod -R 644 /mnt/FUSION/Config">>/home/FUSION/Tmp/install_package/FXAutoRun.sh
echo "chmod -R 644 /mnt/FUSION/log">>/home/FUSION/Tmp/install_package/FXAutoRun.sh
echo "chmod -R 644 /mnt/FUSION/Tmp">>/home/FUSION/Tmp/install_package/FXAutoRun.sh
echo "chmod -R 755 /etc/init.d/FXStart.sh">>/home/FUSION/Tmp/install_package/FXAutoRun.sh
echo "update-rc.d FXStart.sh start 90 2 3 4 5 .">>/home/FUSION/Tmp/install_package/FXAutoRun.sh
echo "sh /home/FUSION/Shell/settags.sh">>/home/FUSION/Tmp/install_package/FXAutoRun.sh
echo "chmod -R 644 /home/FUSION/Tags">>/home/FUSION/Tmp/install_package/FXAutoRun.sh
echo "sync">>/home/FUSION/Tmp/install_package/FXAutoRun.sh
echo "mount -o remount ro /">>/home/FUSION/Tmp/install_package/FXAutoRun.sh
echo "echo \"Install Ctrl finish\"">>/home/FUSION/Tmp/install_package/FXAutoRun.sh
chmod 755 /home/FUSION/Tmp/install_package/FXAutoRun.sh
cd /home/FUSION
cp -rf bin lib Shell Config install_support /home/FUSION/Tmp/install_package/
cd /home/FUSION/Tmp
tar cf install_package.INSTALL install_package
echo "Make install package success under /home/FUSION/Tmp/install_package.INSTALL"

