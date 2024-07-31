`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: XHuiWang
//////////////////////////////////////////////////////////////////////////////////

//1024项，每项有btb_valid, btb_tag, btb_br_type, btb_br_target, btb_pc_2


module BTB1 #(    //参数化 btb_depth 
    parameter btb_depth = 128 )

(
    // 
    input  clk,
    input  rstn, //复位将所有valid位清零
    //预测端
    input  [29:0] pc, //输入的pc
    output logic [29:0] br_target, //预测的目标地址
    output logic [1 :0]  br_type, //预测的类型，出现miss时为00
    //更新端
    input  update, //更新信号，分支单元的有效信号，分支有效就修改btb，预译码阶段暂定只纠正预测结果不更新btb表
    input  [29:0] update_pc, //分支的pc
    input  [1:0]  update_br_type, //分支的类型
    input  [29:0] update_br_target //分支的目标地址

    );

    //定义btb表，5张表，每张表1024项

    //计算tag和index的位数
    parameter btb_index_wid = $clog2(btb_depth); //10
    parameter btb_tag_wid   = 29 - btb_index_wid; //19
     
    
    reg      [ btb_depth -1 : 0 ]  btb_valid ; //有效位


    //从表中读取出的数据
    logic [29:0]  btb_br_target;
    logic [1 :0]  btb_br_type;
    // logic         btb_pc_2;
    logic [btb_tag_wid-1:0]  btb_tag;

    //复位
    always @(posedge clk)
        if(~rstn)
            btb_valid <= 0;
        else if(update && update_pc[0] == 1'b1)
            btb_valid[$unsigned(update_pc[btb_index_wid:1])] <= 1'b1;


    //例化ram，a是写口，b是读口，pc3到pc12是index
    
    //btb_tag
    ram #(
        .RAM_WIDTH(btb_tag_wid),
        .RAM_DEPTH(btb_depth),
        .INIT_FILE("")
    ) btb_tag_ram (
        .clka(clk),
        //读口
        .addrb(pc[btb_index_wid:1]),
        .doutb(btb_tag),
        //写口
        .addra(update_pc[btb_index_wid:1]),
        .dina(update_pc[29:btb_index_wid+1]),
        .wea(update)
    );

    //btb_br_type
    ram #(
        .RAM_WIDTH(2),
        .RAM_DEPTH(btb_depth),
        .INIT_FILE("")
    ) btb_br_type_ram (
        .clka(clk),
        //读口
        .addrb(pc[btb_index_wid:1]),
        .doutb(btb_br_type),
        //写口
        .addra(update_pc[btb_index_wid:1]),
        .dina(update_br_type),
        .wea(update)
    );

    //btb_br_target
    ram #(
        .RAM_WIDTH(30),
        .RAM_DEPTH(btb_depth),
        .INIT_FILE("")
    ) btb_br_target_ram (
        .clka(clk),
        //读口
        .addrb(pc[btb_index_wid:1]),
        .doutb(btb_br_target),
        //写口
        .addra(update_pc[btb_index_wid:1]),
        .dina(update_br_target),
        .wea(update)
    );


    //读取,将输入tag和btb_tag比较，相同则输出
    always @(*)
        if(pc[29:11] == btb_tag && btb_valid[$unsigned(pc[btb_index_wid:1])])
        begin
            br_target = btb_br_target;
            br_type = btb_br_type;
        end
        else
        begin
            br_type = 0; //miss,
            br_target = pc + 1;
        end




endmodule
