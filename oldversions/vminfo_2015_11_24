#!/bin/bash
#Time:2015-3-20
#Author:www.isjian.com
#Version:1.6
#Update:2015-11-24

###说明:
#1.在centos6.x平台上测试通过.
#2.列出当前宿主机上所有运行中的虚拟机(KVM)详细信息.

###更新日志
## 2015-11-24
#1.更新版本为1.6.
#2.使用"-i"参数可显示虚拟机ip地址.
#3.无法获取ip地址的虚拟机会用"-"代替.
##2015-9-15
#1.更新版本为1.5
#2.可显示虚机每块磁盘大小.
#3.默认只列出虚机的根磁盘，加上"-d"参数可列出所有磁盘.

#spice
function get_spiceinfo () {
ps aux | grep "qemu-kvm" | grep -v grep | grep " \-spice port" | awk '{ for(i=1;i<=NF;i++){if($i ~ /-name/)Name=$(i+1);else if($i == "-spice")Port=$(i+1)} print Name,$2,$3,$4,"spice:"substr(Port,1,match(Port,/,addr.*/)-1)}' | sed -r "s/(port=|tls-port=)//g" >> /tmp/vmhost.txt
}

#vnc
function get_vncinfo() {
ps aux | grep "qemu-kvm" | grep -v grep | grep " \-vnc " | awk '{ for(i=1;i<=NF;i++){if($i == "-name")Name=$(i+1);else if($i == "-vnc")Port=$(i+1)} print Name,$2,$3,$4,"vnc:"substr(Port,match(Port,/:.*/)+1)+5900}' >> /tmp/vmhost.txt
}

#get arp table
function get_arptable() {
if [ "${alter}" == "-i" ];then
	vm_net="`route -n | grep "^0.0.0.0" |awk '{print $2}' | cut -d. -f 1-3`"
	if [ -z "${vm_net}" ];then
		echo "Error! --The gateway not set!"
		exit 2
	else
		for ij in `seq 1 254`;do
			( ping -c 1 ${vm_net}.${ij} &>/dev/null) &
		done
		wait
	fi
fi
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

#get vmip
function get_vmip() {
	vm_mac="`virsh domiflist "$1" | awk 'NR>2{if($0 != "") print $5}'`"
	if [ -z "${vm_mac}" ];then
		echo "Error! --The VM $1 haven't a interface"
		exit 2
	else
			vm_ip_tmp="`arp -n | grep "${vm_mac}" | awk '{print $1}' | head -n 1`"
			vm_ip=${vm_ip_tmp:-"-"}
	fi

}

#format 
function format_line() {
get_spiceinfo
get_vncinfo
get_arptable
for i in `cat /tmp/vmhost.txt | awk '{print $1}'`;do
	if [ "${alter}" != "-i" ];then
		vminfo="`get_vminfo ${i}`"
		blkinfo_temp="`get_vmblk ${i}`"
		blkinfo=$(echo ${blkinfo_temp} | sed -r 's/\//\\\//g')
		sed -i -r "/^${i} /s/.*/& ${vminfo} ${blkinfo}/g" /tmp/vmhost.txt
	else
		get_vmip "${i}"
		sed -i -r "/^${i} /s/.*/& ${vm_ip}/g" /tmp/vmhost.txt
	fi
done
}

function format_printf() {
if [ "${alter}" == "-d" ];then
	cat /tmp/vmhost.txt | awk 'BEGIN{printf "%-20s %-15s\n","VHOSTS","Vdisks";printf"%s\n","--------------------------------------------------------------------------------------------------------------"}{printf "%-15s %-15s\n",$1,$8}'

elif [ "${alter}" == "-i" ];then
	cat /tmp/vmhost.txt | awk 'BEGIN{printf "%-25s %-15s\n","VHOSTS","Vip";printf"%s\n","--------------------------------------------------------------------------------------------------------------"}{printf "%-25s %-15s\n",$1,$6}'

else
	cat /tmp/vmhost.txt | awk 'BEGIN{printf "%-18s %-8s %-7s %-7s %-15s %-7s %-7s %-20s\n","VHOSTS","PID","%CPU","%MEM","PORT","Vcpus","Vmems","Vdisks";printf"%s\n","--------------------------------------------------------------------------------------------------------------------------------------"}{printf "%-18s %-8s %-7s %-7s %-15s %-7s %-7s %-20s\n",$1,$2,$3,$4,$5,$6,$7,$8}'
fi
}

function main() {
alter="$1"
rm -f /tmp/vmhost.txt
format_line
format_printf
rm -f /tmp/vmhost.txt
}

main "$1"
