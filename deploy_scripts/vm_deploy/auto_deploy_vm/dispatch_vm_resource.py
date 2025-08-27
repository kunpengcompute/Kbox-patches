import numpy as np
import sys
import json
import xml.etree.ElementTree as ET
from collections import defaultdict

# get gpu pci, vf nic pci, cpu nums, numa hugepage size from txt file
data_txt = np.loadtxt("gpu_numa.txt", dtype=int)
data = data_txt.tolist()

print(data)

numa_cpus_txt = np.loadtxt("numa_cpu.txt", dtype=int)
numa_cpus = numa_cpus_txt.tolist()
print("numa cpus:", numa_cpus)

numa_pages_txt = np.loadtxt("numa_Hugepage.txt", dtype=int)
numa_pages = numa_pages_txt.tolist()
print("numa pages:", numa_pages)


with open("vfNic.txt", "r") as file:
	vf_nics = [line.strip().replace('"', '') for line in file]
print(vf_nics)

with open("gpu_pci.txt", "r") as file:
	data1 = [line.strip().replace('"', '') for line in file]
print(data1)

with open("os_imgs.txt", "r") as file:
	os_imgs = [line.strip().replace('"', '') for line in file]
print(os_imgs)

with open("vm_nvram.txt", "r") as file:
	vm_nvram = [line.strip().replace('"', '') for line in file]
print(vm_nvram)

with open("disk_partitions.txt", "r") as file:
	disk_partitions = [line.strip().replace('"', '') for line in file]
print(disk_partitions)

mapping = defaultdict(list)
for i in range(len(data)):
	mapping[data[i]].append(data1[i])

numa_pci = dict(mapping)
print(numa_pci)

input_xml = sys.argv[1]
output_xml = ["Numa0.xml", "Numa1.xml", "Numa2.xml", "Numa3.xml"]
dict_key = ["numa0", "numa1", "numa2", "numa3"]
vm_name = ["vm0", "vm1", "vm2", "vm3"]
source_dict = {}

for index in range(len(vm_name)):
	if index > len(vf_nics):
		print("vf nic is not enough")
		break
	arr = [disk_partitions[index]]
	numa_dict = {"vm name":vm_name[index], "numa node": index, "cpu num": numa_cpus[index], "memory(huge pages)": numa_pages[index], "os img": os_imgs[index], "vm nvram": vm_nvram[index] , "disk partitions": arr, "gpu pci": numa_pci.get(index, ""), "vf_nic pci": vf_nics[index], "input file": str(input_xml), "output file": output_xml[index]}
	source_dict.update({dict_key[index]: numa_dict})	

OutputPath = './numa_resource_dispatch.json'
f = open(OutputPath, 'w', encoding='utf-8')
a = json.dumps(source_dict, sort_keys=False, indent=4, ensure_ascii=False)
f.write(a)
f.close()

