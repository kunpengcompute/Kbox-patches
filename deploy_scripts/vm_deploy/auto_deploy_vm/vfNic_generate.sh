nic=$(ip a | grep 192 | head -n 1 | awk '{print $NF}')
echo "nic: $nic"
pci=$(lshw -c network -businfo | grep -w ${nic} | awk '{print $1}' | cut -d'@' -f2)
echo "pci: $pci"

vfs_max=$(cat /sys/bus/pci/devices/${pci}/sriov_totalvfs)
echo "max vfs : $vfs_max"

echo $vfs_max > /sys/bus/pci/devices/${pci}/sriov_numvfs

lshw -c network -businfo | grep -w "Virtual Function" | awk '{print $1}' | cut -d':' -f2- > vfNic.txt
