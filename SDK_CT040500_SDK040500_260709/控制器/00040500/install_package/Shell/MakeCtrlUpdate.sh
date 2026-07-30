#!/bin/sh
echo "Start to make update package...."
mkdir -p /home/FUSION/Tmp
rm -rf /home/FUSION/Tmp/update_package /home/FUSION/Tmp/update_package.UPDATE

mkdir -p /home/FUSION/Tmp/update_package
echo "#!/bin/sh" >/home/FUSION/Tmp/update_package/FXAutoRun.sh
echo "echo \"Updating system...\"">>/home/FUSION/Tmp/update_package/FXAutoRun.sh
echo "mount -o remount rw /">>/home/FUSION/Tmp/update_package/FXAutoRun.sh
echo "cd /home/FUSION/Tmp/update_package">>/home/FUSION/Tmp/update_package/FXAutoRun.sh
echo "cp -rf bin lib Shell /home/FUSION/">>/home/FUSION/Tmp/update_package/FXAutoRun.sh
echo "cp -rf cfg_default /home/FUSION/Config/">>/home/FUSION/Tmp/update_package/FXAutoRun.sh
echo "chmod -R 755 /home/FUSION/bin">>/home/FUSION/Tmp/update_package/FXAutoRun.sh
echo "chmod -R 755 /home/FUSION/lib">>/home/FUSION/Tmp/update_package/FXAutoRun.sh
echo "chmod -R 755 /home/FUSION/Shell">>/home/FUSION/Tmp/update_package/FXAutoRun.sh
echo "sh /home/FUSION/Shell/settags.sh">>/home/FUSION/Tmp/update_package/FXAutoRun.sh
echo "chmod -R 644 /home/FUSION/Tags">>/home/FUSION/Tmp/update_package/FXAutoRun.sh
echo "chmod -R 644 /home/FUSION/Config/cfg_default">>/home/FUSION/Tmp/update_package/FXAutoRun.sh
echo "sync">>/home/FUSION/Tmp/update_package/FXAutoRun.sh
echo "mount -o remount ro /">>/home/FUSION/Tmp/update_package/FXAutoRun.sh
echo "echo \"Update system finish\"">>/home/FUSION/Tmp/update_package/FXAutoRun.sh
chmod 755 /home/FUSION/Tmp/update_package/FXAutoRun.sh

cp -rf /home/FUSION/bin /home/FUSION/lib /home/FUSION/Shell /home/FUSION/Config/cfg_default /home/FUSION/Tmp/update_package/
cd /home/FUSION/Tmp
tar cf update_package.UPDATE update_package
echo "Make update package success under /home/FUSION/Tmp/update_package.UPDATE"

