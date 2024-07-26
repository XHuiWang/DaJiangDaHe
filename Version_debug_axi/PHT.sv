`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Author: XHuiWang
//////////////////////////////////////////////////////////////////////////////////

//1024项，用10位索引pc 3-12
//目标（暂时不要）：4张表，entry 2位，entry00表示过去是00，entry01表示过去是01，entry10表示过去是10，entry11表示过去是11。后面一位表示最新的是否跳转
//每项2位，00 强untaken，01 弱untaken，10 弱taken，11 强taken。全部初始化为弱untaken
//理论上我希望pht对01类型的指令起效果
//在执行段返回的时候训练pht，非跳转类型的指令不训练

//两位饱和计数，需要两个读口，一个用于预测，一个用于更新

module PHT(

    input  clk,
    input  rstn,
    //预测端
    input  [29:0] pc,
    output logic  pht_jump,
    //更新端
    input  update, //跳转有效信号
    input  [1:0]  update_type,
    input  [29:0] update_pc,
    input         update_pht_jump

    );

    logic [1:0] pht_out1;//读口1
    logic [1:0] pht_out2;
    logic       pht_in;  //pht更新数据
    logic       pht_wen; //phtr更新使能

    assign pht_jump = pht_out1[1]; //预测跳转
    assign pht_wen = (update_type != 2'b00 && update); //更新使能

    //例化pht_table
    pht_table pht_table_inst(
        .clk(clk),
        .rstn(rstn),
        //读口1，用于预测
        .addrb1(pc[10:1]),
        .doutb1(pht_out1),
        //读口2，用于更新，读出后组合给出pht_in
        .addrb2(update_pc[10:1]),
        .doutb2(pht_out2),
        //写口
        .wea(pht_wen),
        .addra(update_pc[10:1]),
        .dina(pht_in)
    );

    //更新01，10直接更新；11加1 00减1 不更新
    always @(*)
        //01+1
        if(pht_out2 == 2'b01 && update_pht_jump)
            pht_in = 2'b10;
        //01-1
        else if(pht_out2 == 2'b01 && !update_pht_jump)
            pht_in = 2'b00;
        //10+1
        else if(pht_out2 == 2'b10 && update_pht_jump)
            pht_in = 2'b11;
        //10-1
        else if(pht_out2 == 2'b10 && !update_pht_jump)
            pht_in = 2'b01;
        //11-1
        else if(pht_out2 == 2'b11 && !update_pht_jump)
            pht_in = 2'b10;
        //11+1
        else if(pht_out2 == 2'b11 && update_pht_jump)
            pht_in = 2'b11;
        //00-1
        else if(pht_out2 == 2'b00 && !update_pht_jump)
            pht_in = 2'b00;
        //00+1
        else if(pht_out2 == 2'b00 && update_pht_jump)
            pht_in = 2'b01;
        //其他情况不更新
        else
            pht_in = pht_out2;


endmodule
