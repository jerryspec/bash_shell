#!/usr/bin/bash
# Date：2021/9/17
# Author：jerry.jin
# DESC：
#        Decide out health.For the memory overflow problem, you need to restart the service,
#        use the grep method to determine whether the file has the specified keyword.
#
# cron: */5 * * * * /usr/bin/sh $HOME/op/autojrs.sh

. ${HOME}/op/bin/EnVariable_simplify.sh

if [[ `ps -ef|egrep "jrs|jrss|jdp|jdpp|rl" | grep -v grep` == '' ]];then
    # On the 1st of the month, 24 clock status log and add #.
    if [[ "010005" == ${_LOGS} ]];then
        mv ${_FILELOG} ${_FILELOG}.`date +%F`
        true > ${_FILELOG}
        find ${_FILELOG}.* -mtime +30 -exec rm -rf {} \;
    fi
    # End identifier
    IFS=$'\n'
    #
    for i in ${_JARFILE};do
    #Cycle to achieve status monitoring of each project.
    #Obtain the PID number and restart the project.
        _name=`echo  $i|awk '{print $(NF-1)}'`
        _port=`echo $i|awk '{print $NF}'`
        _pid=`ps -ef|grep -v grep |grep ${_name}|grep java | awk '{print $2}'`
        _url=`curl -I -m 30 -o /dev/null -s -w %{http_code} http://127.0.0.1:${_port}/${_name}/health`
        # For the memory overflow problem,
        # you need to restart the service, use the grep method to
        # determine whether the file has the specified keyword.
        # Cycle to achieve status monitoring of each project.
        # Obtain the PID number and restart the project.
        _num=`grep 'java.lang.OutOfMemoryError: Metaspace' ${_JARLOGS}/${_name}0.log | wc -l`
        if [[ ${_num} -gt 0 || ${_url} -ne 200 ]];then
	        cd ${HOME}/simplify;sh ./autojrss ${_name} > /dev/null 2>&1
	        echo "`date +%F\ %r` is restart \"cr-${_name}-1.0.0.jar\".PID number is "${_pid}".status code ${_url}." >> ${_FILELOG}
        #sleep 60
        fi
        sleep 1
    done
    # cometnew add.
    # sh ${HOME}/op/bin/cometnew.sh
    # newin add.
    # sh $HOME/op/bin/newin_simplify.sh
else
    echo "`date +%F\ %r` A program is occupied." >> ${_FILELOG}
    exit 0
fi


# EnVariable_simplify.sh
#!/bin/sh
# Date：2021/9/17
# Author： jerry.jin
# DES:All call environment variables are displayed in this file. Cannot be used without calling.

# Designation JAVA_HOME and HOME
HOME=/home/credit
JAVA_HOME=${HOME}/apps/jdk1.8.0_121
# Environmental variable
# jrs and jdp use Parameters.
_ONE=$1
_JAVAPATH=${JAVA_HOME}/bin
_JARBAK=${HOME}/jarbak
_JARDEPLOY=${HOME}/deploy
_JARGC=${HOME}/simplify
_DATE=`date +%Y%m%d%H%M%S`
_FILEJARSTART=${HOME}/op/config/filejarstartsimplify.txt
_FORNUM=10
_STARTJARFILE=${HOME}/op/bin/startjar.sh
_JARPIDFILE=${HOME}/op/bin/jarpid.sh
# rollback Use parameters.
_JARBAKPATH=${HOME}/jarbak
_TWO=$2
_FOUNDFILE=`find ${_JARBAKPATH}/ -name "cr-${_ONE}*" | sort`
#out.sh
_JARLOGS=${_JARGC}/logs
_JARFILE=`cat ${HOME}/op/config/outSimplifyWebapp.txt`
_LOGS=`date +%d%H%M`
_FILELOG=${HOME}/op/logs/outSimplify.lst
