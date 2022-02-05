FROM 447653585/ubantu-llvm:latest AS llvm  
RUN apt update
RUN apt install -y build-essential git make libelf-dev clang strace tar bpfcc-tools gcc-multilib
# RUN apt install -y linux-headers-$(uname -r)
RUN ln -s /usr/include/asm-generic/ /usr/include/asm  