#!/bin/bash

export PATH=$PATH:${HOME}/path/to/crc-linux-amd64:

CRC_INSTALL_DIR=$(dirname $(which crc))/..

# PREFERRED CRC OPTIONS
# MINIMUM VALUES ARE 6 vCPUs and 49152M MEMORY
# PREFERRED VALUES ARE 12 CORES AND 65536M MEMORY
# 100G DISK IS SUFFICIENT, BUT 250G DOESN'T HURT

CRC_V_CPU=12
# CRC_V_CPU=6
CRC_MEMORY=65536
# CRC_MEMORY=49152
CRC_DISK=250
# CRC_DISK=100

CRC_SHELL=bash
#CRC_SHELL=zsh

function eval-oc-env() {
    eval $(crc oc-env)
    source <(oc completion ${CRC_SHELL})
}

if [[ -f ~/.crc/machines/crc/crc.qcow2 ]]
then
    eval-oc-env
fi

function crc-start() {
    echo "Starting CRC with ${CRC_V_CPU} vCPUs, ${CRC_MEMORY}M memory, and ${CRC_DISK}G disk"
    echo "If you want to change the above values, run 'crc delete' and recreate the VM from scratch."
    echo ''

    crc config set cpus ${CRC_V_CPU}
    crc config set memory ${CRC_MEMORY}
    crc config set disk-size ${CRC_DISK}
    # crc config set enable-cluster-monitoring true
    crc config set pull-secret-file ${CRC_INSTALL_DIR}/pull-secret
    crc start

    crc-admin-login
}


function crc-pwd-admin {
    echo "copy kubeadmin secret to system clipboard"
    CRC_TEMP_PWD=$(crc console --credentials | sed -n 2p | sed -e "s/.*'\(.*\)'/\1/" | awk '{print $6}' )
    echo ${CRC_TEMP_PWD} | xclipc
    echo "${CRC_TEMP_PWD} copied to clipboard for use"
    CRC_TEMP_PWD=
}

function crc-admin-login {
    crc-pwd-admin
    echo
    echo "crc login as kubeadmin"
    CRC_LOGIN=$(crc console --credentials | sed -n 2p | sed -e "s/.*'\(.*\)'/\1/")
    eval ${CRC_LOGIN}
    CRC_LOGIN=
}