mapfile -t vm_name < <(cat numa_resource_dispatch.json | grep "vm name" | awk '{print $3}' | sed 's/,$//' | sed 's/"//g')


for i in "${!vm_name[@]}";do
	echo "virsh start ${vm_name[i]}"
	virsh start ${vm_name[i]}
done
