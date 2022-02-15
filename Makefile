# CLANG = clang

EXECABLE = monitor-exec

CLANG = clang
KERNEL_SRC_PATH = /kernel-src

BPFCODE = ./helloWorld/hello_kern
LOADER = ./helloWorld/hello_user

#### BPFCODE编译参数
BPFINCLUDE += -I/usr/include/x86_64-linux-gnu
BPFCFLAGS += -v -O2 -target bpf -c 

#### LOADER编译参数。

LOADER_TOOLS_HEADER = -I./common/loader/
LOADER_TOOLS_SRC = ./common/loader/bpf_load.c

# LIBRARY_INCLUDE += -I$(KERNEL_SRC_PATH)/samples/bpf
LIBRARY_INCLUDE += -I$(KERNEL_SRC_PATH)/tools/lib
LIBRARY_INCLUDE += -I$(KERNEL_SRC_PATH)/tools/perf
LIBRARY_INCLUDE+= -I$(KERNEL_SRC_PATH)/tools/include

LOADER_LDDIR += -L$(KERNEL_SRC_PATH)/tools/lib/bpf
# LOADER_LDDIR += -L/usr/local/lib64 
LOADER_LDLIBS += -lbpf -lelf

LOADERCFLAGS += -v
# LOADERCFLAGS += $(shell grep -q "define HAVE_ATTR_TEST 1" $(KERNEL_SRC_PATH)/tools/perf/perf-sys.h \
#                   && echo "-DHAVE_ATTR_TEST=0")

all:build bpfload

#### 编译bpf程序
# 使用<linux/bpf.h>头文件在标准位置，不需要考虑
build:$(BPFCODE.c)
	$(CLANG) $(BPFCFLAGS) $(BPFINCLUDE) $(addsuffix .c, $(BPFCODE)) -o $(addsuffix .o, $(BPFCODE))

#### 编译加载程序
# 放一个build依赖在这里。bpf编译失败，对应的加载程序编译成功也没啥作用
bpfload: build 
	$(CLANG) $(LOADERCFLAGS) $(LOADER_TOOLS_HEADER) $(LIBRARY_INCLUDE) $(LOADER_LDDIR) $(LOADER_LDLIBS) -o $(LOADER) \
		$(LOADER_TOOLS_SRC) $(addsuffix .c, $(LOADER))

clean:
	-rm -rf *.o $(LOADER)

.PHONY: all build bpfload
