qcow2_path=$1
find $qcow2_path -type f | sort > os_imgs.txt
lspci | grep 0200 | awk '{print $1}' > gpu_pci.txt
lspci -vvv -d 1f4f:0200 | grep NUMA | awk '{print $3}' > gpu_numa.txt
cat /sys/devices/system/node/node*/meminfo | grep HugePages_Total | awk '{print $4}' > numa_Hugepage.txt
find /dev/ | grep nvme | sort | tail -n 4 > disk_partitions.txt
totalcpu=$(lscpu | grep "CPU(s):" | head -n 1 | awk '{print $2}')
numa_cpu=$((totalcpu / 4))
rm -rf numa_cpu.txt
rm -rf vm_nvram.txt
for i in $(seq 0 3)
do
	echo $numa_cpu >> numa_cpu.txt
	echo "/var/lib/libvirt/qemu/nvram/vm${i}_VARS.fd" >> vm_nvram.txt
done

