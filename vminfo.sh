#!/bin/bash
#Time:2015-3-20
#Note:show the information of all active VMs
#Version:1.5
#Author:lijian
#Update:2015-9-15

#spice
function get_spiceinfo () {
ps aux | grep "qemu-kvm" | grep -v grep | grep " \-spice port" | awk '{ for(i=1;i<=NF;i++){if($i ~ /-name/)Name=$(i+1);else if($i == "-spice")Port=$(i+1)} print Name,$2,$3,$4,"spice:"substr(Port,1,match(Port,/,addr.*/)-1)}' | sed -r "s/(port=|tls-port=)//g" >> /root/vmhost.txt
}

#vnc
function get_vncinfo() {
ps aux | grep "qemu-kvm" | grep -v grep | grep " \-vnc " | awk '{ for(i=1;i<=NF;i++){if($i == "-name")Name=$(i+1);else if($i == "-vnc")Port=$(i+1)} print Name,$2,$3,$4,"vnc:"substr(Port,match(Port,/:.*/)+1)+5900}' >> /root/vmhost.txt
}

#get vhost cpu,memory
function get_vminfo() {
virsh dominfo "$1" | awk '/^CPU\(s\)/{print $2};/^Used memory/{print $3/1024/1024"G"}' | xargs
}

#get vhost block
function get_vmblk() {
	blklist_disk=$(virsh domblklist "$1" | awk 'NR>=3{if($2 != "-" && NF>=1) print $1":"$2}' | xargs)
	blklist_disk_size=`for ii in ${blklist_disk};do qemu-img info $(echo $ii | awk -F '[:]' '{print $2}') | awk -v a=$ii '/^virtual size:/{print a"["$3"]"}';done`
	if [ "${alter}" == "-d" ];then
		echo "${blklist_disk_size}" | awk -F '[/]' 'NR==1{print $0}NR>1{print $1$NF}' | xargs | sed "s/ /|/g"
	else
		echo "${blklist_disk_size}" | head -n 1
	fi
}

#format 
function format_line() {
get_spiceinfo
get_vncinfo
for i in `cat /root/vmhost.txt | awk '{print $1}'`;do
	vminfo="`get_vminfo ${i}`"
	blkinfo_temp="`get_vmblk ${i}`"
	blkinfo=$(echo ${blkinfo_temp} | sed -r 's/\//\\\//g')
	sed -i -r "/^${i} /s/.*/& ${vminfo} ${blkinfo}/g" /root/vmhost.txt
done
}

function format_printf() {
if [ "${alter}" == "-d" ];then
	cat /root/vmhost.txt | awk 'BEGIN{printf "%-15s %-15s\n","VHOSTS","Vdisks";printf"%s\n","--------------------------------------------------------------------------------------------------------------"}{printf "%-15s %-15s\n",$1,$8}'
else
	cat /root/vmhost.txt | awk 'BEGIN{printf "%-15s %-8s %-7s %-7s %-15s %-7s %-7s %-20s\n","VHOSTS","PID","%CPU","%MEM","PORT","Vcpus","Vmems","Vdisks";printf"%s\n","--------------------------------------------------------------------------------------------------------------------------------------"}{printf "%-15s %-8s %-7s %-7s %-15s %-7s %-7s %-20s\n",$1,$2,$3,$4,$5,$6,$7,$8}'
fi
}

function main() {
rm -fr /root/vmhost.txt
format_line
format_printf
}

if [ ! -z $1 ];then
	alter=$1
else
	alter=n
fi

main
