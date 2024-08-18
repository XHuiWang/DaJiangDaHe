- [分支预测说明](#分支预测说明)
- [预译码部分](#预译码部分)
- [预测部分](#预测部分)
  - [BHR (branch history register)](#bhr-branch-history-register)
  - [PHT](#pht)
  - [PHT的更新 pht\_updater](#pht的更新-pht_updater)
  - [btb](#btb)
  - [ras](#ras)
- [反馈修正部分](#反馈修正部分)
  - [ptab (prediction target address buffer)](#ptab-prediction-target-address-buffer)
  - [对pht和btb的反馈](#对pht和btb的反馈)
  - [对ras的修正](#对ras的修正)
- [和流水线的交互](#和流水线的交互)
  - [超标量相关部分](#超标量相关部分)


# 分支预测说明
- premature optimization is the root of all evil
- 在开始阶段，各个表的大小以及整体的时序都是不重要的，重要的是完整以及正确性。

# 预译码部分
1. 预译码在取值完成后立刻进行，组合逻辑，给出指令类型和跳转目标，类型定义如下：
- 00 非跳转指令
- 01 条件跳转 如 beq
- 10 无条件跳转 直接跳转(目标地址和寄存器无关) 如 bl
- 11 无条件跳转 间接跳转(目标地址和寄存器有关) 如jirl

2. 预译码部分还要在分支预测出错时或缺失时给出预测的目标地址，以及预测的类型：
方案：译码单元可以进行指令的静态预测：
- 对于 01 型指令，如果分支预测器没有这条指令的信息，那么如果指令是向低地址分支的，则将 PC 置为分支 PC；对于高地址的则不做分支。
- 对于 10 型指令，如果分支预测器没有其记录，则取指单元在此做出补救，进行分支。
-  最后，执行单元一旦发现分支指令的预测行为与指令严格执行的结果不一致，则执行单元对于 PC 做出修改且享有最高权限。

# 预测部分
## BHR (branch history register)
1. 用于记录最近的分支指令的结果，用于pht的索引 2位

## PHT
1. 如果读出的btb表项是无条件跳转，则不需要pht的结果
2. 大小： 1024项 10位index 2位counter 20位tag 
3. 每一项是一个2位的计数器，00为强untaken，01为弱untaken，10为强taken，11为弱taken (相邻的状态转换符合格雷码) 根据首位判断是否跳转，初始化为01
4. 对于无条件跳转指令和非跳转指令，不需要pht的结果，但我们仍然更新对应pht的状态
5. pht如何从流水线获得信息？
对于条件跳转指令，预译码段是无法给出结果的，而无条件跳转指令在预译码段就反馈并训练pht的意义似乎不大。因此，我们需要在译码段给出pht的反馈。译码段给出的信息是decoder_pc, decoder_type, decoder_target。我们需要在译码段给出pht的反馈，即pht的index和counter的更新。

## PHT的更新 pht_updater
1. 读取pht表项
2. 修改后写入pht表项

## btb 
1. 存储br_type和br_target，两路组相连
2. 大小 ：1024项 10位index 32-10-2=20位tag 32位的目标地址bta 1位valid
3. 逻辑
    - 读取取指pc
    - 读取btb表项
    - 判断是否命中
    - 若命中，取出目标地址和类型
    - 若未命中，转到4

4. btb miss的处理：**顺序执行**并在出错后冲刷流水线，为什么这样做，一开始并不知道指令类型，并不知道是否是分支指令，因此无法提前预测，只能顺序执行。并且大部分指令都是非分支指令，因此顺序执行的代价并不大。
5. 对于有条件跳转指令，需要2位感知机的结果，否则不需要
6. btb还要记录pc[2],使用2*4字节边界对齐之内的地址做预测
7. 预测端 输入：取指pc 输出：br_type, br_target
8. 反馈端 输入：decoder_pc, decoder_type, decoder_target 输出：btb的更新
9. btb表项：valid, tag, target, type , pc_2

## ras
1. bl指令是call，jirl指令是ret
2. call指令使用btb预测，ret指令使用ras预测  为什么这样做？因为call指令的目标地址是固定的，而ret指令的目标地址是不固定的，因此需要ras来预测
3. 识别到call指令时，将pc+4入栈，识别到ret指令时，将栈顶元素出栈
4. 大小：16项 30位返回地址 1位valid


# 反馈修正部分

## ptab (prediction target address buffer)
1. 只保留预测跳转的指令的pc和目标地址
2. 大小：16项 存下全部30位pc，30位目标地址 1位valid
3. 一旦给出预测，就存入ptab，当该条指令执行完毕后，将存储位置释放
4. 一旦

##  对pht和btb的反馈
1. 预译码段就可以给出类型以及01，10类型指令的目标地址。对于11类型指令，需要在译码段给出目标地址
2. 预译码段给出pre_decoder_pc, pre_decoder_type, pre_decoder_target
3. 译码段给出decoder_pc, decoder_type, decoder_target

## 对ras的修正

# 和流水线的交互
## 超标量相关部分
