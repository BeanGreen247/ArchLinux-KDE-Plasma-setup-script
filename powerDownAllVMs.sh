#!/bin/bash
#
# How to use
#
# bash scripts/powerDownAllVMs.sh <vm_name_from_virsh>
#
# to get current vm names run the following command
#   sudo virsh list --all
#
# and edit this script according to the result
#
# usage example
#   bash scripts/powerDownAllVMs.sh win11
#

#VAR
pass="somepasswordhere"
username="usernamehere"
echo $pass | sudo -S systemctl kill libvirtd
echo $pass | sudo -S systemctl kill libvirtd-ro.socket
echo $pass | sudo -S systemctl kill libvirtd-admin.socket
echo $pass | sudo -S systemctl kill libvirtd.socket
echo $pass | sudo -S systemctl --signal=TERM libvirtd
echo $pass | sudo -S systemctl --signal=TERM libvirtd-ro.socket
echo $pass | sudo -S systemctl --signal=TERM libvirtd-admin.socket
echo $pass | sudo -S systemctl --signal=TERM libvirtd.socket
echo $pass | sudo -S systemctl restart libvirtd
echo $pass | sudo -S virsh list --all
if [ "$1" == "win11-no-gpu" ]; then
    echo $pass | sudo -S virsh shutdown win11-no-gpu
    echo "Waiting 120s before VM shuts down"
    sleep 120
elif [ "$1" == "win11" ]; then
    echo $pass | sudo -S virsh shutdown win11
    echo "Waiting 120s before VM shuts down"
    sleep 120
elif [ "$1" == "ubuntu22.04" ]; then
    echo $pass | sudo -S virsh shutdown ubuntu22.04
    echo "Waiting 120s before VM shuts down"
    sleep 120
fi
echo $pass | sudo -S kill --signal TERM /usr/bin/qemu-system-x86_64
echo $pass | sudo -S killall /usr/bin/qemu-system-x86_64
echo $pass | sudo -S systemctl kill libvirtd
echo $pass | sudo -S systemctl kill libvirtd-ro.socket
echo $pass | sudo -S systemctl kill libvirtd-admin.socket
echo $pass | sudo -S systemctl kill libvirtd.socket
echo $pass | sudo -S systemctl --signal=TERM libvirtd
echo $pass | sudo -S systemctl --signal=TERM libvirtd-ro.socket
echo $pass | sudo -S systemctl --signal=TERM libvirtd-admin.socket
echo $pass | sudo -S systemctl --signal=TERM libvirtd.socket
echo $pass | sudo -S systemctl restart libvirtd
echo $pass | sudo -S bash /home/$username/scripts/freeMem.sh
xdotool key Q | systemctl status libvirtd
exit 1
