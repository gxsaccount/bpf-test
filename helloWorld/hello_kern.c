#include <linux/bpf.h>
//使用SEC属性通知BPF VM。execve 系统调用被检测到时，我们将运行此BPF程序。将看到消息Hello，BPF World！
//clang -O2 -target bpf -c bpf_program.c -o bpf_program.o
#define SEC(NAME) __attribute__((section(NAME), used))
static int (*bpf_trace_printk)(const char *fmt, int fmt_size,
                               ...) = (void *)BPF_FUNC_trace_printk;

SEC("tracepoint/syscalls/sys_enter_execve")
int bpf_prog(void *ctx) {
  char msg[] = "Hello, BPF World!";
  bpf_trace_printk(msg, sizeof(msg));// 打印/sys/kernel/debug/tracing/trace_piped的消息
  return 0;
}

char _license[] SEC("license") = "GPL"; //指定了该程序的许可证。由于Linux内核是根据GPL许可的，因此它也只能加载以GPL许可的程序。


