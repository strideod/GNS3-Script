#!/bin/bash
#
# SCRIPT: gns3_update
# PURPOSE: This script is used to update the GNS3 remote server from esxi to qemu.

read -p 'Please enter URL:' url

read -p 'Please enter VM ID:' gns3_vm_id

read -p 'Please enter storage volume:' storage_volume

vm=GNS3_VM-disk

parse_url=$url
version=${parse_url##*/}

cd /tmp

wget $url

unzip /tmp/$version | sed -n 's/^[[:space:]]*inflating:[[:space:]]*//p'

for f in /tmp/*.ova
do
    ova="${f// /_}"
    if [ "$ova" != "$f" ]
    then
        if [ -e "$ova" ]
        then
            echo not renaming \""$f"\" because \""$ova"\" alread exists
        else
            echo moving "$f" to "$ova"
            mv "$f" "$ova"
        fi
    fi
done

ova_files=$(mkdir /tmp/GNS3_OVA_Files)

tar -xvf $ova -C $ova_files

cd $ova_files

qemu-img convert -f vmdk -O qcow2 ./${vm}1.vmdk ./${vm}1.qcow2
wait

qemu-img convert -f vmdk -O qcow2 ./${vm}2.vmdk ./${vm}2.qcow2
wait

qm importdisk $gns3_vm_id ./${vm}1.qcow2 $storage_volume --format qcow2
wait

qm importdisk $gns3_vm_id ./${vm}2.qcow2 $storage_volume --format qcow2
wait

cd /tmp
rm -rf GNS3*