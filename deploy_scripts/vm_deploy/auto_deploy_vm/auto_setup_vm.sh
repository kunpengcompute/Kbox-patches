mapfile -t cpu_num < <(cat numa_resource_dispatch.json | grep "cpu num" | awk '{print $3}' | sed 's/,$//')
mapfile -t numa_node < <(cat numa_resource_dispatch.json | grep "numa node" | awk '{print $3}'| sed 's/,$//')
mapfile -t vm_name < <(cat numa_resource_dispatch.json | grep "vm name" | awk '{print $3}' | sed 's/,$//' | sed 's/"//g')
mapfile -t vm_xml < <(cat numa_resource_dispatch.json | grep "output file" | awk '{print $3}' | sed 's/,$//' | sed 's/"//g')


for i in "${!vm_name[@]}";do
	echo "=================${numa_node[$i]}"
	echo "=================${cpu_num[$i]}"
	echo "virsh define ${vm_xml[i]}"
	virsh define ${vm_xml[i]}
	sleep 2
	cpu_start=$((${numa_node[$i]} * ${cpu_num[$i]}))
	cpu_end=$((${cpu_start} + ${cpu_num[$i]} - 1))
	echo "./setup_vm.sh ${vm_name[$i]} --cputune $cpu_start,$cpu_end"
	./setup_vm.sh ${vm_name[$i]} --cputune $cpu_start,$cpu_end
	echo "./setup_vm.sh ${vm_name[$i]} --numatune ${numa_node[$i]}"
	./setup_vm.sh ${vm_name[$i]} --numatune ${numa_node[$i]}
	echo "./setup_vm.sh ${vm_name[$i]} --emulatorpin $cpu_start-$cpu_end"
	./setup_vm.sh ${vm_name[$i]} --emulatorpin $cpu_start-$cpu_end
	echo "./setup_vm.sh ${vm_name[$i]}  --enable_hugepages"
	./setup_vm.sh ${vm_name[$i]}  --enable_hugepages
done
