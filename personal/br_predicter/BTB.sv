`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: XHuiWang
//////////////////////////////////////////////////////////////////////////////////

//1024项，每项有btb_valid, btb_tag, btb_br_type, btb_br_target, btb_pc_2


module BTB(
    // 
    input  clk,
    input  rstn, //复位将所有valid位清零
    //预测端
    input  [29:0] pc, //输入的pc
    output logic [29:0] br_target, //预测的目标地址
    output logic [1 :0]  br_type, //预测的类型，出现miss时为00
    output logic        pc_2, //指示对指令组中的哪个指令进行预测
    //更新端
    input  update, //更新信号，分支单元的有效信号，分支有效就修改btb，预译码阶段暂定只纠正预测结果不更新btb表
    input  [29:0] update_pc, //分支的pc
    input  [1:0]  update_br_type, //分支的类型
    input  [29:0] update_br_target //分支的目标地址

    );

    //定义btb表，5张表，每张表1024项
    
    reg      [1023:0]  btb_valid ; //有效位


    //从表中读取出的数据
    logic [29:0]  btb_br_target;
    logic [1 :0]  btb_br_type;
    logic         btb_pc_2;
    logic [18:0]  btb_tag;

    //复位
    always @(posedge clk or negedge rstn)
        if(~rstn)
            btb_valid <= 0;
        else
            btb_valid <= 0;


    //例化ram，a是写口，b是读口，pc3到pc12是index
    
    //btb_tag
    ram #(
        .RAM_WIDTH(19),
        .RAM_DEPTH(1024),
        .INIT_FILE("")
    ) btb_tag_ram (
        .clka(clk),
        //读口
        .addrb(pc[10:1]),
        .doutb(btb_tag),
        //写口
        .addra(update_pc[10:1]),
        .dina(update_pc[29:11]),
        .wea(update)
    );

    //btb_br_type
    ram #(
        .RAM_WIDTH(2),
        .RAM_DEPTH(1024),
        .INIT_FILE("")
    ) btb_br_type_ram (
        .clka(clk),
        //读口
        .addrb(pc[10:1]),
        .doutb(btb_br_type),
        //写口
        .addra(update_pc[10:1]),
        .dina(update_br_type),
        .wea(update)
    );

    //btb_br_target
    ram #(
        .RAM_WIDTH(30),
        .RAM_DEPTH(1024),
        .INIT_FILE("")
    ) btb_br_target_ram (
        .clka(clk),
        //读口
        .addrb(pc[10:1]),
        .doutb(btb_br_target),
        //写口
        .addra(update_pc[10:1]),
        .dina(update_br_target),
        .wea(update)
    );

    //btb_pc_2
    ram #(
        .RAM_WIDTH(1),
        .RAM_DEPTH(1024),
        .INIT_FILE("")
    ) btb_pc_2_ram (
        .clka(clk),
        //读口
        .addrb(pc[10:1]),
        .doutb(btb_pc_2),
        //写口
        .addra(update_pc[10:1]),
        .dina(update_pc[0]),
        .wea(update)
    );


    //读取,将输入tag和btb_tag比较，相同则输出
    always @(*)
        if(pc[29:11] == btb_tag && btb_valid[$unsigned(pc[10:1])])
        begin
            br_target = btb_br_target;
            br_type = btb_br_type;
            pc_2 = btb_pc_2;
        end
        else
        begin
            br_type = 0; //miss,
            pc_2 = 0;
            br_target = 0;
        end




endmodule
