## 个人问题

### 解码
1. Instruction Buffer的实现
2. 相关性的判断和检测，如有RAW相关，怎么处理
3. MUL和一些不普通的指令的解码
4. BR类型的指令
5. TODO：制定传递参数的接口

### 发射
1. 两个发射端口，A包含BR模块、ALU、LD/SW模块，B包含BR、ALU、LD/SW、MUL、DIV、CACHE、TLB等模块
2. 相关和影响：
   1. 如果有RAW相关（本质），例如两个ALU同时发射，或者ALU后面跟上BR，阻塞后一个的发射。只发射一个
      1. LD 在 ALU 前面，同周期有RAW，阻塞2个周期
         1. ALU在下一个周期有RAW，阻塞1个周期
   2. 两个BR同时发射，目前拒绝双BR发射。
   3. LD/SW单发一个

### 指令Buffer
1. 将left和in组合逻辑视为一个更长的Buffer，总长度为n
2. 情况分类：
   1. n = 0, valid = 00, pointer = 0
   2. n = 1, valid = 10, pointer = 0
   3. n = 2, valid = 11, pointer = 0
   4. n > 2, valid = 11, pointer = n - 2
   5. n >= length - 2, full = 1






### temp PROBLEM
1. alu_src_select的信号的定义不一样
2. TODO: dispatch的问题
3. wb_sel信号的指定

## 马哥的建议
1. head,tail分别放置，head,length附加变量时序处理，后期考虑独热码
2. 交叠法伪双端口，每次发0/2个指令，不会发1个指令
3. ICache出来加一级流水
4. !=优化

1. 取指地址非对齐 00是特权，11是非特权 DONE:
2. 取指错例外（特权等级问题）DONE:
3. decoder中的SYS和BRK例外 DONE:
4. decoder中指令不存在例外
5. decoder中的指令特权等级例外（csr*3+ertn）