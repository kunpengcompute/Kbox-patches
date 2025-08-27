import numpy as np
import json
import copy
import xml.etree.ElementTree as ET
from collections import defaultdict

#modify gpu_pci, vf_nic in vm xml
def modify_xml(vm_name, input_xml, output_xml, numa_node, numa_cpu, numa_page, os_img, vm_nvram, disk_partitions, gpu_pci, vf_nic):
	print("modify xml", input_xml)
	tree = ET.parse(input_xml)
	root = tree.getroot()
	
	vm_id = root.find(".//name")
	if vm_id is not None:
		vm_id.text = vm_name
	
	memory_elem = root.find(".//memory")
	memValue = str(numa_page * 1024 * 1024)
	if memory_elem is not None:
		memory_elem.text = memValue

	devices_element = root.find(".//devices")
	disk_index = 0;
	os_img_used = 0;
	for disk in root.findall(".//disk"):
		print("len of disk_partition:", len(disk_partitions))
		if disk_index >= len(disk_partitions) and os_img_used == 1:
			devices_element.remove(disk)
			continue
		driver = disk.find("driver")
		boot = disk.find("boot")
		source = disk.find("source")
		if driver is not None and driver.get("type") == "qcow2":
			print("config os_img")
			source.set("file", os_img)
			os_img_used = 1
		if disk.get("type") == "block":
			source.set("dev", disk_partitions[disk_index])
			disk_index += 1

	
	numatune = root.find(".//numatune")
	if numatune is not None:
		memory = numatune.find("memory")
		if memory is not None:
			memory.set("nodeset", numa_node) 	

	cur_memory_elem = root.find(".//currentMemory")
	if cur_memory_elem is not None:
		cur_memory_elem.text = memValue

	vcpu_elem = root.find(".//vcpu")
	if vcpu_elem is not None:
		vcpu_elem.text = str(numa_cpu)

	nvram = root.find(".//nvram")
	if nvram is not None:
		nvram.text = vm_nvram	

	hostdev_elements = root.findall(".//hostdev")
	for i, hostdev in enumerate(hostdev_elements):
		source = hostdev.find("source")
		if source is not None:
			address = source.find("address")
			if i < len(gpu_pci):
				pci = gpu_pci[i]
			elif i == len(gpu_pci):
				pci = vf_nic
			elif i > len(gpu_pci):
					devices_element.remove(hostdev)
					continue
			parts = pci.replace(".", ":").split(":")
			hex_values = [f"0x{part.zfill(2)}" for part in parts]
			bus_value = address.get("bus")
			print("bus_value is ", address.get("bus"), "; change to ", hex_values[0])
			print("slot_value is ", address.get("slot"), "; change to ", hex_values[1])
			print("function_value is ", address.get("function"), "; change to ", hex_values[2])
			address.set("bus", hex_values[0])
			address.set("slot", hex_values[1])
			address.set("function", hex_values[2])
	
	tree.write(output_xml)


with open("numa_resource_dispatch.json", "r", encoding="utf-8") as file:
	data = json.load(file)

for key, value in data.items():
	vm_name = value["vm name"]
	numa_node = str(value["numa node"])
	cpu_num = value["cpu num"]
	huge_pages = value["memory(huge pages)"]
	os_img = value["os img"]
	vm_nvram = value["vm nvram"]
	disk_partitions = value["disk partitions"]
	print(disk_partitions)
	numa_gpu_pci = value["gpu pci"]
	vf_nic_pci = value["vf_nic pci"]
	input_file = value["input file"]
	output_file = value["output file"]
	modify_xml(vm_name, input_file, output_file, numa_node, cpu_num, huge_pages, os_img, vm_nvram, disk_partitions, numa_gpu_pci, vf_nic_pci)	

