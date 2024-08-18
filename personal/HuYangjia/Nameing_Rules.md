# 命名规范

## 前言
本文记载在编程过程中的一些命名规范，以便于小组查阅。

## 文件命名
1. 架构层面分`5`个大的流水段：Fetch(IF)， Decoder(ID)， Execute(EXE)， Memory(MEM)， WriteBack(WB)
2. 每一个小模块的文件名应该以`流水段名`+`模块功能`的方式命名，例如：`IF_PC.sv`，`ID_Decoder1.sv`


## 中间寄存器命名
1. 取前后两个的共同组成:例如IF、ID段间寄存器的PC寄存器命名为`IF_ID.PC`
2. 寄存器的赋值和取值建议：
    - 赋值：`IF_ID.PC <= ID.PC;`
    - 取值：`IF.IR <= IF_ID.PC;`