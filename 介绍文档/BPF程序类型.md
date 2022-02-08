bpf程序主要分为两类  

第一类跟踪：  

第二类网络：

其他分类：  
套接字过滤器程序（Socket Filter Programs）  
* 类型：BPF_PROG_TYPE_SOCKET_FILTER 是添加到Linux内核的第一个程序类型  
* 作用: 将BPF程序附加到原始套接字时，可以访问该套接字处理的所有数据包(无写权限)。    
Kprobe 程序（Kprobe Programs）  
* 类型：BPF_PROG_TYPE_KPROBE  
* 作用：作为第一或最后一条指令执行  
    * 在内核调用exec syscall时检查参数：在代码段开始处设置SEC（“kprobe/sys_exec”）    
    * 检查调用exec syscall的返回值：在代码段开始处设置SEC（“kr​​etprobe/ sys_exec”）    

跟踪点程序（Tracepoint Programs）  
* 类型：BPF_PROG_TYPE_TRACEPOINT  
* 作用：将BPF程序附加到内核提供的跟踪点处理程序  
    * 系统中的所有跟踪点都在目录 /sys/kernel/debug/tracing/events 中定义   
    * BPF自己的跟踪点在 /sys/kernel/debug/tracing/events/bpf 中定义  
    * 
XDP程序（XDP Programs）  
* 类型：BPF_PROG_TYPE_XDP  
* 作用：编写在网络数据包到达内核的早期就执行的代码，定义了如下但返回值  
    * XDP_PASS：数据包传递到内核中的下一个子系统  
    * XDP_DROP：内核应完全忽略此数据包  
    * XDP_TX：数据包转发回首先接收到数据包的网络接口卡（NIC）  
    * 基于上述功能：实现程序以保护您的网络免受DDoS攻击等  

Perf事件程序（Perf Event Programs）  
* 类型：BPF_PROG_TYPE_PERF_EVENT  
* 作用：将BPF程序附加到Perf事件时，每次Perf生成供您分析的数据时，都将执行您的代码  


Cgroup套接字程序（Cgroup Socket Programs）    
* 类型：BPF_PROG_TYPE_CGROUP_SKB  
* 将BPF逻辑附加到控制组（cgroup）
    * 可以在将网络数据包传递到cgroup中的进程之前决定如何处理它  
    * 内核尝试传递到同一cgroup中任何进程的任何数据包都将通过每一个过滤器  
    * 类似BPF_PROG_TYPE_SOCKET_FILTER，BPF_PROG_TYPE_CGROUP_SKB 程序附加到cgroup内的所有进程，而不是特定进程
    * https://github.com/cilium/cilium    
    
Cgroup打开套接字程序（Cgroup Open Socket Programs）  
套接字选项程序（Socket Option Programs） 
套接字映射程序（Socket Map Programs）
Cgroup 设备程序（Cgroup Device Programs）
原始跟踪点程序（Raw Tracepoint Programs）
Cgroup套接字地址程序（Cgroup Socket Address Programs）
套接字重用程序（Socket Reuseport Programs）
分流器程序（Flow Dissection Programs）

其他 BPF 程序
流量分类程序 （Traffic classifier programs）。
BPF_PROG_TYPE_SCHED_CLS 和BPF_PROG_TYPE_SCHED_ACT 是两种BPF程序，可用于分类网络流量并修改套接字缓冲区中数据包的某些属性。
轻量级隧道程序（Lightweight tunnel programs）。
BPF_PROG_TYPE_LWT_IN，BPF_PROG_TYPE_LWT_OUT，BPF_PROG_TYPE_LWT_XMIT和BPF_PROG_TYPE_LWT_SEG6LOCAL是BPF程序的类型，可用于将代码附加到内核的轻量级隧道基础架构。
红外设备程序（Infrared device programs）
      

参考资料：https://man7.org/linux/man-pages/man2/bpf.2.html  
