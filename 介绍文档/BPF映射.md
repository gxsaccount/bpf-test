**BPF映射**是驻留在内核中的键/值存储。  
任何BPF程序都可以访问它们。  
在用户态中运行的程序也可以使用文件描述符访问这些映射。  
只要事先正确指定数据大小，就可以在映射中存储任何类型的数据。  
内核将键和值视为二进制 blobs，它并不关心您在映射中保留的内容。  

# 创建BPF映射 #  

## 调用bpf系统调用  

### 法一  
    int fd = bpf(BPF_MAP_CREATE, &my_map, sizeof(my_map));  

    BPF_MAP_CREATE：告诉内核您要创建一个新映射  
    my_map：  
        union bpf_attr my_map { 
            .map_type = BPF_MAP_TYPE_HASH, 
            .key_size = sizeof(int), 
            .value_size = sizeof(int), 
            .max_entries = 100,
            .map_flags = BPF_F_NO_PREALLOC,
        };

        bpf_attr：
        union bpf_attr {
            struct {
                __u32 map_type;     /* one of the values from bpf_map_type */
                __u32 key_size;     /* size of the keys, in bytes */
                __u32 value_size;   /* size of the values, in bytes */
                __u32 max_entries;  /* maximum number of entries in the map */ 
                __u32 map_flags;    /* flags to modify how we create the map */
            };
        }
如果调用失败，则内核返回值-1。  
失败的原因可能有三个。  
* 如果其中一个属性无效，则内核将errno变量设置为EINVAL。  
* 如果执行该操作的用户没有足够的特权，则内核将errno变量设置为EPERM。  
* 最后，如果没有足够的内存来存储映射，则内核将errno变量设置为ENOMEM。  

### 法二  

还可以使用如下代码进行创建映射，**省去my_map的定义**：  

        int fd;
        fd = bpf_create_map(BPF_MAP_TYPE_HASH, sizeof(int), sizeof(int), 100,
                BPF_F_NO_PREALOC);

### 法三  
如果知道程序中需要哪种映射，也可以预先定义。这对于增加程序中使用的映射的可见性有很大帮助：  

        struct bpf_map_def SEC("maps") my_map = { 
            .type = BPF_MAP_TYPE_HASH, 
            .key_size = sizeof(int), 
            .value_size = sizeof(int), 
            .max_entries = 100,
            .map_flags =BPF_F_NO_PREALLOC, 
        };

以这种方式定义映射时，您使用的是 "section" 属性，在本例中为SEC("maps")。  
**该宏告诉内核此结构是BPF映射，应该相应地创建它。**  

在这种情况下，内核使用名为map_data的全局变量将有关映射的信息存储在程序中。  
此变量是一个结构数组，根据您在代码中指定每个映射的方式进行排序。  
例如，如果先前的映射是代码中指定的第一个映射，则可以从数组的第一个元素获取文件描述符标识符：  

        fd = map_data[0].fd;  


# 使用 BPF 映射 #  
内核于用户态访问方式区别：  
1. 在内核中工作时可以直接访问映射，但是在用户态中工作时可以使用文件描述符来引用它们    
2. 在内核上运行的代码可以直接访问内存中的映射，并且将能够**原子**地就地更新元素。但是，在用户态中运行的代码必须将消息发送到内核，内核会在更新映射之前复制提供的值；这使得更新操作不**是原子**的。  

## 更新 BPF 映射中的元素 ##  

### 内核 ###  
bpf/bpf_helpers.h提供bpf_map_update_elem  
该函数在操作成功时返回0，在操作失败时返回负数。如果发生失败，则用失败原因填充全局变量errno  

    int key, value, result; 
    key = 1, value = 1234;

    /*
    参数一：指向已经定义的映射的指针  
    参数二：指向我们要更新的元素的Key的指针  
    参数三：要插入的值  
    参数四：映射的更新方式  
    */
    result = bpf_map_update_elem(&my_map, &key, &value, BPF_ANY); if (result == 0)
        printf("Map updated with new element\n"); 
    else
        printf("Failed to update map with new value: %d (%s)\n", result, strerror(errno));

**映射的更新方式**  
* 如果您传递0/BPF_ANY，则表示内核要更新元素（如果存在），或者如果不存在则应在映射中创建该元素。  
* 如果传递1/BPF_NOEXIST，则告诉内核仅在元素不存在时才创建它。  
* 如果传递2/BPF_EXIST，则内核仅在元素存在时才对其进行更新。  

### 用户态 ###  
使用文件描述符，例如map_data[0].fd  

    int key, value, result; 
    key = 1, value = 5678;

    result = bpf_map_update_elem(map_data[0].fd, &key, &value, BPF_ANY)); if (result == 0)
        printf("Map updated with new element\n"); 
    else
        printf("Failed to update map with new value: %d (%s)\n", result, strerror(errno));

## 读取BPF的值 ##  

### 内核 ###  

    int key, value, result; 
    key = 1;

    result = bpf_map_lookup_elem(&my_map, &key, &value); 
    if (result == 0)
        printf("Value read from the map: '%d'\n", value);
    else
        printf("Failed to read value from the map: %d (%s)\n", result, strerror(errno));  

### 用户态 ###  

    int key, value, result; 
    key = 1;

    result = bpf_map_lookup_elem(map_data[0].fd, &key, &value); 
    if (result == 0)
        printf("Value read from the map: '%d'\n", value);
    else
        printf("Failed to read value from the map: %d (%s)\n", result, strerror(errno));  

## 删除元素 ##  
### 内核 ###  

    int key, result; 
    key=1;

    result = bpf_map_delete_element(&my_map, &key); 
    if (result == 0)
        printf("Element deleted from the map\n"); 
        else
        printf("Failed to delete element from the map: %d (%s)\n", result, strerror(errno));  

### 用户态 ###  

    int key, result; 
    key=1;

    result = bpf_map_delete_element(map_data[0].fd, &key); 
    if (result == 0)
        printf("Element deleted from the map\n"); 
        else
        printf("Failed to delete element from the map: %d (%s)\n", result, strerror(errno));


## 迭代BPF映射中的元素 ##  

    int next_key, lookup_key; 
    lookup_key = -1;


    /*
    参数一：映射的文件描述符标识符
    参数二：key是您要查找的标识符，
    参数三：next_key是映射中的下一个键
    */
    while(bpf_map_get_next_key(map_data[0].fd, &lookup_key, &next_key) == 0) { 
        printf("The next key in the map is: '%d'\n", next_key);
        lookup_key = next_key;
    }

当bpf_map_get_next_key 到达映射的末尾时，返回的值为负数，并且errno变量设置为ENOENT。这将中止循环执行。  
BPF不会在使用 bpf_map_get_next_key 对其进行循环之前拷贝映射中的值。  
如果程序的另一部分在遍历值时从映射上删除了一个元素，则bpf_map_get_next_key将在尝试为已删除的元素键找到下一个值时重新开始。  

## 查找并删除元素 ##  

在映射中搜索给定键，并从中删除元素  

    int key, value, result, it; 
    key=1;

    for(it=0;it<2;it++){
        result = bpf_map_lookup_and_delete_element(map_data[0].fd, &key, &value); 
        if (result == 0)
            printf("Value read from the map: '%d'\n", value); 
        else
            printf("Failed to read value from the map: %d (%s)\n", result, strerror(errno));
    }
第一次迭代也会删除 映射中的元素。循环第二次尝试获取元素时，此代码将失败，并将使用“not found”错误ENOENT填充errno变量。  

## 并发的访问元素 ##  
BPF引入了BPF自旋锁的概念。自旋锁只对数组，散列，和cgroup中存储映射有效。    
bpf_spin_lock 锁定元素，而bpf_spin_unlock 解锁该元素  

BPF自旋锁引入了一个新的标志，用户态程序可以使用该标志来更改该锁的状态。该标志称为BPF_F_LOCK  

要使用自旋锁，我们需要做的第一件事是创建要锁定访问的元素，然后添加信号量：  
    
    struct concurrent_element { 
        struct bpf_spin_lock semaphore; 
        int count;
    }

我们将此结构存储在BPF映射中，并在元素中使用信号量来防止对其进行不必要的访问。  
现在，我们可以声明将包含这些元素的映射。  
该映射必须使用BPF类型格式（BTF）进行注释，以便验证者知道如何解释该结构。  
此代码将在内核中运行，所以我们可以使用libbpf提供的内核宏来注​​释此并发映射：  

    struct bpf_map_def SEC("maps") concurrent_map = { 
        .type = BPF_MAP_TYPE_HASH,
        .key_size = sizeof(int),
        .value_size = sizeof(struct concurrent_element), 
        .max_entries = 100,
    };

    BPF_ANNOTATE_KV_PAIR(concurrent_map, int, struct concurrent_element);  

在BPF程序中，我们可以使用两个锁定帮助程序来防止这些元素出现竞态。  

    int bpf_program(struct pt_regs *ctx) { 
        intkey=0;
        struct concurrent_element init_value = {}; 
        struct concurrent_element *read_value;

        bpf_map_create_elem(&concurrent_map, &key, &init_value, BPF_NOEXIST);

        read_value = bpf_map_lookup_elem(&concurrent_map, &key);
        //
        bpf_spin_lock(&read_value->semaphore);
        read_value->count += 100;
        //
        bpf_spin_unlock(&read_value->semaphore);
    }


# BPF映射类型 #  

Linux文档将映射定义为通用数据结构，您可以在其中存储不同类型的数据。  



在更新哈希映射以及更新数组和cgroup存储映射时，BPF_F_LOCK 的行为略有不同。对于后两者，更新就位，并且要执行更新的元素必须在映射中存在。对于哈希映射，如果该元素尚不存在，则程序会将该元素的存储桶锁定在该映射中，并插入一个新元素。  

