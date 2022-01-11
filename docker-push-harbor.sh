#!/bin/sh
# Author:
# Date: 2022/1/11
# DESC:


_PARA_ONE=$1
_URL=www.harbor.jj
_DOCKER_URL=${_URL}/database
_DOCKER_PATH=/etc/docker
_IP=192.168.89.11

main(){
    # Determine if the mirror exists
    docker images | grep ^${_PARA_ONE}
    if [[ $(echo $?) -ne 0 ]]; then
            echo "Images is not found."
            exit $?
    fi
    # Determine whether the host is not added host
    grep 'www.harbor.jj' /etc/hosts
    if [[ $(echo $?) -ne 0  ]]; then
            echo "It's not found \"www.harbor.jj\" hosts,Please check /etc/hosts!!!"
            exit $?
    fi
    # Because harbor enables https, you need to copy the key and restart docker
    # Determine if docker has harbor key
    if [[ ! -d "${_DOCKER_PATH}/certs.d/${_URL}/" ]]; then
            scp -r root@${_IP}:/etc/docker/certs.d /etc/docker/
            systemctl daemon-reload && systemctl restart docker
            docker login www.harbor.jj
    fi

    # tag---push---rmi
    echo
    read -p "<Input tag name>: " tagname
    docker tag ${_PARA_ONE}:${tagname} ${_DOCKER_URL}/${_PARA_ONE}:${tagname}
    [[ -z $(echo $?) ]] && exit $?
    docker push ${_DOCKER_URL}/${_PARA_ONE}:${tagname}
    sleep 1
    docker rmi ${_DOCKER_URL}/${_PARA_ONE}:${tagname}
    echo "${_DOCKER_URL}/${_PARA_ONE}:${tagname} is delete."
}

if [[ ! -z ${_PARA_ONE} ]]; then
    main
else
    echo "Input parameter."
fi
