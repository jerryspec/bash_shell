#!/bin/sh
# Author: 
# Date: 2021/11/5 Modify: 2021/11/23
# Desc: 
#     Added network judgment
#     Added judgment of the same kernel version


# 清华源地址：https://mirrors.tuna.tsinghua.edu.cn/elrepo/kernel/el7
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
sleep 3
if [ `echo $?` -eq 0 ]; then	
	newversion=`yum --disablerepo=\* --enablerepo=elrepo-kernel list kernel-lt.x86_64 | \
	grep kernel-lt.x86_64 | awk '{print $2}' | sed 's/-.*//'`	
    pastversion=`uname -r | sed 's/-.*//'`
    if [ ${newversion} != ${pastversion} ]; then
    	yum --disablerepo=\* --enablerepo=elrepo-kernel install -y kernel-lt.x86_64	
		awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg
		sleep 1
		sudo grub2-set-default 0
		sleep 2
		grub2-mkconfig -o /boot/grub2/grub.cfg
		echo -n "The system will restart in 5 seconds";sleep 1
		for i in {1..5}; do echo -n .;sleep 1; done
		reboot
	fi
	echo "The version may already be the latest"
	exit 0
fi
echo "Unable to connect to the external network or the package is incorrect."
