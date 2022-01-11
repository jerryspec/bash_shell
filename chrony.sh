#!/bin/sh
# Author:
# Date: 2021/11/15
# Desc:
#     sysmtem: CentOS Linux release 7.9.2009 (Core)
#     kernel：5.4.157-1.el7.elrepo.x86_64


# environment
# Local variables
_PATH=/root/pkg/images
#_FILEPATH=https://mirrors.tuna.tsinghua.edu.cn/centos/7.9.2009/os/x86_64/Packages/chrony-3.4-1.el7.x86_64.rpm
_FILEPATH=${_PATH}/{libseccomp-2.3.1-4.el7.x86_64.rpm,chrony-3.4-1.el7.x86_64.rpm}

# Turn on this variable when downloading from the Internet
#_FILECHRONY=https://mirrors.tuna.tsinghua.edu.cn/centos/7.9.2009/os/x86_64/Packages/chrony-3.4-1.el7.x86_64.rpm

# 7.9 When the mini environment is installed, it prompts that a dependent package is required, and it must be installed here
_FILEDEPEND=https://mirrors.tuna.tsinghua.edu.cn/centos/7.9.2009/os/x86_64/Packages/libseccomp-2.3.1-4.el7.x86_64.rpm
# Determine whether the synchronization is complete
loop(){
	echo -n "Please Waiting"
	while true; do
		_para=`timedatectl | grep "NTP synchronized" | awk '{print $3}'`
		if [ ${_para} == 'yes' ]; then
			echo
			timedatectl
			exit 0
		fi
		echo -n "."
		sleep 1
	done
}
errors(){
    echo "\"${_FILECHRONY} or ${_FILEDEPEND}\" is not found."
    echo "Please check environment \"_FILECHRONY\""
}

# Server端
chronyserver(){
	# download chrony-3.4-1.el7.x86_64.rpm
	rpm -ivh ${_FILEDEPEND} ${_FILECHRONY} > /dev/null 2>&1
	if [[ `echo $?` -eq 0 ]]; then
		cp -a /etc/chrony.conf /etc/chrony.conf.`date +%s`
		cat > /etc/chrony.conf << EOF
#
server ntp.aliyun.com iburst
server ntp1.aliyun.com iburst
server ntp2.aliyun.com iburst
server ntp3.aliyun.com iburst
server ntp4.aliyun.com iburst
server ntp5.aliyun.com iburst
server ntp6.aliyun.com iburst
server ntp7.aliyun.com iburst
#
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
allow 192.168.15.0/24
logdir /var/log/chrony
EOF
		systemctl enable --now chronyd
		loop
	fi
}

# Client端
chronyclient(){
	# download chrony-3.4-1.el7.x86_64.rpm
	rpm -ivh ${_FILEDEPEND} ${_FILECHRONY} > /dev/null 2>&1
    if [[ `echo $?` -eq 0 ]]; then
		cp -a /etc/chrony.conf /etc/chrony.conf.`date +%s`
		cat > /etc/chrony.conf << EOF
#
server 192.168.15.7 iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
logdir /var/log/chrony
EOF
		systemctl enable --now chronyd
		loop
	fi
}

uninstall(){	
	rpm -e chrony libseccomp
}

# main
case $1 in 
	server)
	chronyserver
	errors
    ;;
    client)
    chronyclient
    errors
    ;;
    uninstall)
    uninstall
    ;;
    *)
    echo "EXP:
    chrony.sh [server/client/uninstall]"
    ;;
esac
