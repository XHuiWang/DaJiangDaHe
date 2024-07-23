`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/21 20:26:49
// Author: XHuiWang
// 
//////////////////////////////////////////////////////////////////////////////////

//后续更新：两个预译码器都需要读取


//16项 30位pc 和 1位ptab_valid 30位ptab_target_pc
//复位将全部valid置0
//为了及时清除指令，我需要知道表内指令在流水线中的位置 在执行段查表后清除相关指令
//预测跳转或不跳转的指令 都要通过pc查表 在预译码段以及执行段查表 可能需要两个读口
//在执行段可以得到的分支相关信息 beq是否相等 j类型指令的目标地址
//一张表 两个读口（用两张表实现） 一个写口
//更新由预测结果决定



module PTAB(
    //
    input clk,
    input rstn,
    //读口
    input [29:0] pre_decode_pc, //预译码段的pc
    input [29:0]        exe_pc, //执行段的pc，在执行段结果返回同时清除相关指令
    //读结果返回，即两个pc的查表结果
    output logic [0:0] pre_decode_pc_valid, //pre_decode_pc是否查到
    output logic [0:0]        exe_pc_valid, //exe_pc是否查到
    output logic [29:0] pre_decode_pc_target_pc, //pre_decode_pc的目标pc
    output logic [29:0]        exe_pc_target_pc, //exe_pc的目标pc

    //更新端
    //预译码段是否出错，出错则清除预测结果
    input   pre_decode_error, //预译码段是否出错

    //写口
    input ptab_update, //由顶层模块给出，由分支预测的结果决定
    input [29:0] update_ptab_pc, //更新的pc
    input [29:0] update_ptab_target_pc //更新的目标pc

    // //清除的valid和pc
    // input [0:0] update_remove_ptab_valid //更新的valid

    );

    //定义valid表
    reg [15:0] ptab_valid;

    //pre_decode_pc 和 exe_pc的查表对应的地址要记录下来，以便清除
    logic [3:0] pre_decode_pc_find_addr;
    logic [3:0] exe_pc_find_addr;


    //复位
    always @(posedge clk )
    begin
        if(!rstn)
        begin
            ptab_valid <= 16'b0;
        end
    end

    //定义信号
    logic [29:0] pc0;
    logic [29:0] pc0_target_pc;
    logic [29:0] pc1;
    logic [29:0] pc1_target_pc;
    logic [29:0] pc2;
    logic [29:0] pc2_target_pc;
    logic [29:0] pc3;
    logic [29:0] pc3_target_pc;
    logic [29:0] pc4;
    logic [29:0] pc4_target_pc;
    logic [29:0] pc5;
    logic [29:0] pc5_target_pc;
    logic [29:0] pc6;
    logic [29:0] pc6_target_pc;
    logic [29:0] pc7;
    logic [29:0] pc7_target_pc;
    logic [29:0] pc8;
    logic [29:0] pc8_target_pc;
    logic [29:0] pc9;
    logic [29:0] pc9_target_pc;
    logic [29:0] pc10;
    logic [29:0] pc10_target_pc;
    logic [29:0] pc11;
    logic [29:0] pc11_target_pc;
    logic [29:0] pc12;
    logic [29:0] pc12_target_pc;
    logic [29:0] pc13;
    logic [29:0] pc13_target_pc;
    logic [29:0] pc14;
    logic [29:0] pc14_target_pc;
    logic [29:0] pc15;
    logic [29:0] pc15_target_pc;

    //定义信号：更新的地址，顺序查找第一个valid为0的地址即可
    logic [3:0] update_ptab_addr;
    always@(*)
    begin
        if(ptab_valid[0] == 1'b0)
        begin
            update_ptab_addr = 4'b0000;
        end
        else if(ptab_valid[1] == 1'b0)
        begin
            update_ptab_addr = 4'b0001;
        end
        else if(ptab_valid[2] == 1'b0)
        begin
            update_ptab_addr = 4'b0010;
        end
        else if(ptab_valid[3] == 1'b0)
        begin
            update_ptab_addr = 4'b0011;
        end
        else if(ptab_valid[4] == 1'b0)
        begin
            update_ptab_addr = 4'b0100;
        end
        else if(ptab_valid[5] == 1'b0)
        begin
            update_ptab_addr = 4'b0101;
        end
        else if(ptab_valid[6] == 1'b0)
        begin
            update_ptab_addr = 4'b0110;
        end
        else if(ptab_valid[7] == 1'b0)
        begin
            update_ptab_addr = 4'b0111;
        end
        else if(ptab_valid[8] == 1'b0)
        begin
            update_ptab_addr = 4'b1000;
        end
        else if(ptab_valid[9] == 1'b0)
        begin
            update_ptab_addr = 4'b1001;
        end
        else if(ptab_valid[10] == 1'b0)
        begin
            update_ptab_addr = 4'b1010;
        end
        else if(ptab_valid[11] == 1'b0)
        begin
            update_ptab_addr = 4'b1011;
        end
        else if(ptab_valid[12] == 1'b0)
        begin
            update_ptab_addr = 4'b1100;
        end
        else if(ptab_valid[13] == 1'b0)
        begin
            update_ptab_addr = 4'b1101;
        end
        else if(ptab_valid[14] == 1'b0)
        begin
            update_ptab_addr = 4'b1110;
        end
        else if(ptab_valid[15] == 1'b0)
        begin
            update_ptab_addr = 4'b1111;
        end
        else 
        begin
            update_ptab_addr = 4'b0000;
        end
    end


    //定义第一张 ptab表，16项 30位pc 30位target_pc 
    ptab_table ptab_table_inst(
        .clk(clk),
        .ptab_update(ptab_update),
        .update_ptab_pc(update_ptab_pc),
        .update_ptab_target_pc(update_ptab_target_pc),
        .update_ptab_addr(update_ptab_addr), //更新的地址,这个信号由本层模块给出
        .pc0(pc0),
        .pc0_target_pc(pc0_target_pc),
        .pc1(pc1),
        .pc1_target_pc(pc1_target_pc),
        .pc2(pc2),
        .pc2_target_pc(pc2_target_pc),
        .pc3(pc3),
        .pc3_target_pc(pc3_target_pc),
        .pc4(pc4),
        .pc4_target_pc(pc4_target_pc),
        .pc5(pc5),
        .pc5_target_pc(pc5_target_pc),
        .pc6(pc6),
        .pc6_target_pc(pc6_target_pc),
        .pc7(pc7),
        .pc7_target_pc(pc7_target_pc),
        .pc8(pc8),
        .pc8_target_pc(pc8_target_pc),
        .pc9(pc9),
        .pc9_target_pc(pc9_target_pc),
        .pc10(pc10),
        .pc10_target_pc(pc10_target_pc),
        .pc11(pc11),
        .pc11_target_pc(pc11_target_pc),
        .pc12(pc12),
        .pc12_target_pc(pc12_target_pc),
        .pc13(pc13),
        .pc13_target_pc(pc13_target_pc),
        .pc14(pc14),
        .pc14_target_pc(pc14_target_pc),
        .pc15(pc15),
        .pc15_target_pc(pc15_target_pc)
    );


    //生成pre_decode_pc_target_pc 如果预译码段的pc查到了与任何一个pc相等且valid为1
    //则将对应输出
    always @(*) begin
        if(ptab_valid[0] && pre_decode_pc == pc0)
        begin
            pre_decode_pc_valid = 1'b1;
            pre_decode_pc_find_addr = 4'b0000;
            pre_decode_pc_target_pc = pc0_target_pc;
        end
        else if(ptab_valid[1] && pre_decode_pc == pc1)
        begin
            pre_decode_pc_valid = 1'b1;
            pre_decode_pc_find_addr = 4'b0001;
            pre_decode_pc_target_pc = pc1_target_pc;
        end
        else if(ptab_valid[2] && pre_decode_pc == pc2)
        begin
            pre_decode_pc_valid = 1'b1;
            pre_decode_pc_find_addr = 4'b0010;
            pre_decode_pc_target_pc = pc2_target_pc;
        end
        else if(ptab_valid[3] && pre_decode_pc == pc3)
        begin
            pre_decode_pc_valid = 1'b1;
            pre_decode_pc_find_addr = 4'b0011;
            pre_decode_pc_target_pc = pc3_target_pc;
        end
        else if(ptab_valid[4] && pre_decode_pc == pc4)
        begin
            pre_decode_pc_valid = 1'b1;
            pre_decode_pc_find_addr = 4'b0100;
            pre_decode_pc_target_pc = pc4_target_pc;
        end
        else if(ptab_valid[5] && pre_decode_pc == pc5)
        begin
            pre_decode_pc_valid = 1'b1;
            pre_decode_pc_find_addr = 4'b0101;
            pre_decode_pc_target_pc = pc5_target_pc;
        end
        else if(ptab_valid[6] && pre_decode_pc == pc6)
        begin
            pre_decode_pc_valid = 1'b1;
            pre_decode_pc_find_addr = 4'b0110;
            pre_decode_pc_target_pc = pc6_target_pc;
        end
        else if(ptab_valid[7] && pre_decode_pc == pc7)
        begin
            pre_decode_pc_valid = 1'b1;
            pre_decode_pc_find_addr = 4'b0111;
            pre_decode_pc_target_pc = pc7_target_pc;
        end
        else if(ptab_valid[8] && pre_decode_pc == pc8)
        begin
            pre_decode_pc_valid = 1'b1;
            pre_decode_pc_find_addr = 4'b1000;
            pre_decode_pc_target_pc = pc8_target_pc;
        end
        else if(ptab_valid[9] && pre_decode_pc == pc9)
        begin
            pre_decode_pc_valid = 1'b1;
            pre_decode_pc_find_addr = 4'b1001;
            pre_decode_pc_target_pc = pc9_target_pc;
        end
        else if(ptab_valid[10] && pre_decode_pc == pc10)
        begin
            pre_decode_pc_valid = 1'b1;
            pre_decode_pc_find_addr = 4'b1010;
            pre_decode_pc_target_pc = pc10_target_pc;
        end
        else if(ptab_valid[11] && pre_decode_pc == pc11)
        begin
            pre_decode_pc_valid = 1'b1;
            pre_decode_pc_find_addr = 4'b1011;
            pre_decode_pc_target_pc = pc11_target_pc;
        end
        else if(ptab_valid[12] && pre_decode_pc == pc12)

        begin
            pre_decode_pc_valid = 1'b1;
            pre_decode_pc_find_addr = 4'b1100;
            pre_decode_pc_target_pc = pc12_target_pc;
        end
        else if(ptab_valid[13] && pre_decode_pc == pc13)
        begin
            pre_decode_pc_valid = 1'b1;
            pre_decode_pc_find_addr = 4'b1101;
            pre_decode_pc_target_pc = pc13_target_pc;
        end
        else if(ptab_valid[14] && pre_decode_pc == pc14)
        begin
            pre_decode_pc_valid = 1'b1;
            pre_decode_pc_find_addr = 4'b1110;
            pre_decode_pc_target_pc = pc14_target_pc;
        end
        else if(ptab_valid[15] && pre_decode_pc == pc15)
        begin
            pre_decode_pc_valid = 1'b1;
            pre_decode_pc_find_addr = 4'b1111;
            pre_decode_pc_target_pc = pc15_target_pc;
        end
        else
        begin
            pre_decode_pc_valid = 1'b0;
            pre_decode_pc_find_addr = 4'b0000;
            pre_decode_pc_target_pc = 30'b0;
        end

    end


    //生成exe_pc_target_pc 如果执行段的pc查到了与任何一个pc相等且valid为1
    //则将对应输出
    always @(*) begin
        if(ptab_valid[0] && exe_pc == pc0)
        begin
            exe_pc_valid = 1'b1;
            exe_pc_find_addr = 4'b0000;
            exe_pc_target_pc = pc0_target_pc;
        end
        else if(ptab_valid[1] && exe_pc == pc1)
        begin
            exe_pc_valid = 1'b1;
            exe_pc_find_addr = 4'b0001;
            exe_pc_target_pc = pc1_target_pc;
        end
        else if(ptab_valid[2] && exe_pc == pc2)
        begin
            exe_pc_valid = 1'b1;
            exe_pc_find_addr = 4'b0010;
            exe_pc_target_pc = pc2_target_pc;
        end
        else if(ptab_valid[3] && exe_pc == pc3)
        begin
            exe_pc_valid = 1'b1;
            exe_pc_find_addr = 4'b0011;
            exe_pc_target_pc = pc3_target_pc;
        end
        else if(ptab_valid[4] && exe_pc == pc4)
        begin
            exe_pc_valid = 1'b1;
            exe_pc_find_addr = 4'b0100;
            exe_pc_target_pc = pc4_target_pc;
        end
        else if(ptab_valid[5] && exe_pc == pc5)
        begin
            exe_pc_valid = 1'b1;
            exe_pc_find_addr = 4'b0101;
            exe_pc_target_pc = pc5_target_pc;
        end
        else if(ptab_valid[6] && exe_pc == pc6)
        begin
            exe_pc_valid = 1'b1;
            exe_pc_find_addr = 4'b0110;
            exe_pc_target_pc = pc6_target_pc;
        end
        else if(ptab_valid[7] && exe_pc == pc7)
        begin
            exe_pc_valid = 1'b1;
            exe_pc_find_addr = 4'b0111;
            exe_pc_target_pc = pc7_target_pc;
        end
        else if(ptab_valid[8] && exe_pc == pc8)
        begin
            exe_pc_valid = 1'b1;
            exe_pc_find_addr = 4'b1000;
            exe_pc_target_pc = pc8_target_pc;
        end
        else if(ptab_valid[9] && exe_pc == pc9)
        begin
            exe_pc_valid = 1'b1;
            exe_pc_find_addr = 4'b1001;
            exe_pc_target_pc = pc9_target_pc;
        end
        else if(ptab_valid[10] && exe_pc == pc10)
        begin
            exe_pc_valid = 1'b1;
            exe_pc_find_addr = 4'b1010;
            exe_pc_target_pc = pc10_target_pc;
        end
        else if(ptab_valid[11] && exe_pc == pc11)
        begin
            exe_pc_valid = 1'b1;
            exe_pc_find_addr = 4'b1011;
            exe_pc_target_pc = pc11_target_pc;
        end
        else if(ptab_valid[12] && exe_pc == pc12)
        begin
            exe_pc_valid = 1'b1;
            exe_pc_find_addr = 4'b1100;
            exe_pc_target_pc = pc12_target_pc;
        end
        else if(ptab_valid[13] && exe_pc == pc13)
        begin
            exe_pc_valid = 1'b1;
            exe_pc_find_addr = 4'b1101;
            exe_pc_target_pc = pc13_target_pc;
        end
        else if(ptab_valid[14] && exe_pc == pc14)
        begin
            exe_pc_valid = 1'b1;
            exe_pc_find_addr = 4'b1110;
            exe_pc_target_pc = pc14_target_pc;
        end
        else if(ptab_valid[15] && exe_pc == pc15)
        begin
            exe_pc_valid = 1'b1;
            exe_pc_find_addr = 4'b1111;
            exe_pc_target_pc = pc15_target_pc;
        end
        else
        begin
            exe_pc_valid = 1'b0;
            exe_pc_find_addr = 4'b0000;
            exe_pc_target_pc = 30'b0;
        end

    end

    //更新valid 预译码段一旦出错回清除预测结果 执行段不管是否出错都清除预测结果
    //清除即将对应的valid置0 如果存在的话
    always @(posedge clk)
    begin
        if(ptab_update)
        begin
            ptab_valid[update_ptab_addr] <= 1'b1;
        end
    end

    //清除valid
    always @(posedge clk)
    begin
        if(pre_decode_error)
        begin
            //清除pre_decode_pc的对应的valid 即pre_decode_pc_find_addr
            ptab_valid[pre_decode_pc_find_addr] <= 1'b0;
        end
        //清除exe_pc的对应的valid 即exe_pc_find_addr
        ptab_valid[exe_pc_find_addr] <= 1'b0;
    end




endmodule


