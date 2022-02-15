#include <stdio.h>
#include <bpf_load.h>

int main(int argc, char **argv){
    if(load_bpf_file("hello_kern.o")!=0){//将hello_kern.o加载到内核中
        printf("The kernel didn't load the BPF program\n");
        return -1;
    }
    read_trace_pipe();

    return 0;
}
