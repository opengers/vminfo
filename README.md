vminfo
说明:
列出当前宿主机上的虚拟机(KVM)详细信息
在centos6.x平台上测试通过

解释：
VHOSTS: 所有使用libvirt管理的虚拟机名称
PID: 该虚拟机进程的PID
%CPU: 该虚拟机进程所占用宿主机CPU百分比
%MEM: 该虚拟机进程所占用宿主机内存百分比
PORT: 访问该虚拟机的vnc端口,可以通过宿主机的此端口连接虚拟机console

Vcpus: 该虚拟机vcpu个数
Vmems: 该虚拟机虚拟内存大小
Vdisk: 该虚拟机虚拟磁盘(只列出该虚拟机系统盘)
