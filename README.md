# bpf-test
<!-- 
编译环境: dockerfile   
编译命令：clang -O2 -target bpf -c bpf_program.c -o bpf_program.o

bpf_trace_printk日志查看:/sys/kernel/debug/tracing/trace_pipe   -->
## 安装编译环境  
sudo apt-get install clang llvm 

**python前端 optional**  
sudo apt-get install python-bpfcc  

## 安装linux-header ##  

## 下载linux源码  
查看机器版本：uname -r  
下载对应版本源码：
https://www.kernel.org/  
https://github.com/microsoft/WSL2-Linux-Kernel  




参考资料：  
https://github.com/torvalds/linux/tree/master/samples/bpf  
https://github.com/bpftools/linux-observability-with-bpf  
https://github.com/learnre/Linux-Observability-with-BPF  

https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.4.173.tar.xz  

https://blog.csdn.net/Longyu_wlz/article/details/109900096  
https://blog.csdn.net/sinat_38816924/article/details/115556650  

linux-header:
https://github.com/microsoft/WSL2-Linux-Kernel/releases/
https://github.com/microsoft/WSL2-Linux-Kernel/archive/refs/tags/linux-msft-5.4.72.tar.gz

