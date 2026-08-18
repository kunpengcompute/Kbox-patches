#!/bin/bash

function cputune()
{
	local domain="$1"
        local start="$2"
        local end="$3"

        local vcpu_idx=0
        for i in $(seq $start $end); do
                virsh vcpupin $domain $vcpu_idx $i --config
                vcpu_idx=$((vcpu_idx + 1))
        done

        virsh vcpupin $domain
}

function numatune()
{
	local domain="$1"
        local nodeset="$2"
        virsh numatune $domain --mode strict --nodeset $nodeset --config
        virsh numatune $domain
}

function emulatorpin()
{
	local domain="$1"
        local cpulist="$2"
        virsh emulatorpin $domain --cpulist "$cpulist" --config
        virsh emulatorpin $domain
}

function enable_hugepages()
{
	local domain="$1"
	virt-xml $1 --edit --memorybacking hugepages=on
}

function usage()
{
cat <<EOF
usage: $0 domain_name --cputune start,end --numatune nodeset --emulatorpin cpulist --enable_hugepages
EOF
}

function main()
{
	if [ $# -lt 2 ]; then
		usage
		exit 1
	fi

	local domain_name="$1"
	local domain
	domain="$(virsh domuuid "$domain_name")"
	if [ $? -ne 0 ] || [ -z "$domain" ]; then
                echo "no such vm $domain_name"
                exit 1
        fi
	shift

	local args="$(getopt -o h -l help,cputune:,numatune:,emulatorpin:,enable_hugepages -n "$0" -- "$@")"
	eval set -- "$args"
	
	while true; do
		case "$1" in
			-h|--help)
				usage
				exit 0
				;;
			--cputune)
				local start="$(echo "$2" | cut -d , -f 1)"
				local end="$(echo "$2" | cut -d , -f 2)"
				cputune "$domain" "$start" "$end"
				shift 2
				;;
			--numatune)
				local nodeset="$2"
				numatune "$domain" "$nodeset"
				shift 2
				;;
			--emulatorpin)
				local cpulist="$2"
				emulatorpin "$domain" "$cpulist"
				shift 2
				;;
			--enable_hugepages)
				enable_hugepages "$domain"
				shift
				;;
			--)
				shift
				break
				;;
			*)
				usage
				exit 1
				;;
		esac
	done
}

main "$@"
