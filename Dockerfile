FROM 447653585/ubantu-llvm:latest AS llvm  
RUN ln -s /usr/include/asm-generic/ /usr/include/asm  