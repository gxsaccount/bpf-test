# bpf-test
<!-- 
编译环境: dockerfile   
编译命令：clang -O2 -target bpf -c bpf_program.c -o bpf_program.o

bpf_trace_printk日志查看:/sys/kernel/debug/tracing/trace_pipe   -->
## 安装编译环境  
sudo apt-get install clang llvm 


$(uname -r) 
查看当前主机版本代号:
lsb_release -a

header -> 头文件，.h的文件
image -> 编译好的内核
source -> 所有Linux内核源码文件

apt-get install linux-image-5.3.0-70-generic
apt-get install linux-headers-5.3.0-70-generic
apt-get install linux-source-5.3.0

更换指定内核版本
https://blog.csdn.net/weixin_42915431/article/details/106614841  

**python前端 optional**  
sudo apt-get install python-bpfcc  

## 安装linux-header ##  

## 下载linux源码  
查看机器版本：uname -r  
下载对应版本源码：
https://www.kernel.org/  
https://mirrors.edge.kernel.org/pub/linux/kernel/
https://github.com/microsoft/WSL2-Linux-Kernel  
https://releases.ubuntu.com/?_ga=2.266111436.2106034982.1638435455-1310506229.1638435455  

apt-get source linux-image-$(uname -r)  

https://blog.csdn.net/sinat_38816924/article/details/115498707  




参考资料：  
https://github.com/torvalds/linux/tree/master/samples/bpf  
https://github.com/bpftools/linux-observability-with-bpf  
https://github.com/learnre/Linux-Observability-with-BPF  
https://github.com/nevermosby/linux-bpf-learning/tree/master/bpf

https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.4.173.tar.xz  

https://blog.csdn.net/Longyu_wlz/article/details/109900096  
https://blog.csdn.net/sinat_38816924/article/details/115556650  

wsl2 linux-header:
https://github.com/microsoft/WSL2-Linux-Kernel/releases/
https://github.com/microsoft/WSL2-Linux-Kernel/archive/refs/tags/linux-msft-5.4.72.tar.gz


