`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/21 20:26:04
// Design Name: 
// Module Name: br_pre_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// Author: XHuiWang
//////////////////////////////////////////////////////////////////////////////////


//顶层模块例化三张表 BTB 1024  PHT PTAB 
//模块内部还会给出pc_mux的选择信号


module br_pre_top(

    input  clk,
    input  rstn,
    //预测端
    input  [29:0] pc,
    output logic [29:0]  pred0_br_target,
    output logic [1 :0]  pred0_br_type,
    output logic [29:0]  pred1_br_target,
    output logic [1 :0]  pred1_br_type,

    output logic [29:0]  predict_br_target,

    //来自分支单元的信号
    input  [29:0] branch_pc,
    input  [1:0]  branch_br_type,
    input  [29:0] branch_br_target,
    input  branch_jump //分支确定跳转 或者内部判断beq类指令跳转了 用于更新pht而不是btb

    );

    //待实现 根据传入的pc最后一位产生输出结果
    //待实现 两路btb 一张记录pc_2 为0的情况 一张记录pc_2 为1的情况 
    //待实现 两路pht 一张记录pc_2 为0的情况 一张记录pc_2 为1的情况
    //例化两张单路的BTB和PHT
    //待实现 参数化

    logic branch_valid;
    always @(*) begin
        if(branch_br_type != 2'b00) begin
            branch_valid = 1;
        end
        else begin
            branch_valid = 0;
        end
    end

    logic [29:0] btb0_br_target;
    logic [1 :0]  btb0_br_type;
    logic [29:0] btb0_pc;
    logic [29:0] btb1_br_target;
    logic [1 :0]  btb1_br_type;
    logic [29:0] btb1_pc;

    //例化BTB
    BTB0 btb_inst_0(
        .clk(clk),
        .rstn(rstn),
        //预测端,1input 2output 直接由btb给出 miss项会给00 已在btb内部处理
        .pc(btb0_pc),
        .br_target(btb0_br_target),
        .br_type(btb0_br_type),
        //更新端,4input 来自分支单元
        .update(branch_valid),
        .update_pc(branch_pc),
        .update_br_type(branch_br_type),
        .update_br_target(branch_br_target)
    );

    BTB1 btb_inst_1 (
        .clk(clk),
        .rstn(rstn),
        //预测端,1input 2output 直接由btb给出 miss项会给00 已在btb内部处理
        .pc(btb1_pc),
        .br_target(btb1_br_target),
        .br_type(btb1_br_type),
        //更新端,4input 来自分支单元
        .update(branch_valid),
        .update_pc(branch_pc),
        .update_br_type(branch_br_type),
        .update_br_target(branch_br_target)
    );`timescale 1ns / 1ps
    //////////////////////////////////////////////////////////////////////////////////
    // Company: 
    // Engineer: 
    // 
    // Create Date: 2024/07/21 20:26:04
    // Design Name: 
    // Module Name: br_pre_top
    // Project Name: 
    // Target Devices: 
    // Tool Versions: 
    // Description: 
    // 
    // Dependencies: 
    // 
    // Revision:
    // Revision 0.01 - File Created
    // Additional Comments:
    // Author: XHuiWang
    //////////////////////////////////////////////////////////////////////////////////
    
    
    //顶层模块例化三张表 BTB 1024  PHT PTAB 
    //模块内部还会给出pc_mux的选择信号
    
    
    module br_pre_top(
    
        input  clk,
        input  rstn,
        //预测端
        input  [29:0] pc,
        output logic [29:0]  pred0_br_target,
        output logic [1 :0]  pred0_br_type,
        output logic [29:0]  pred1_br_target,
        output logic [1 :0]  pred1_br_type,
    
        output logic [29:0]  predict_br_target,
    
        //来自分支单元的信号
        input  [29:0] branch_pc,
        input  [1:0]  branch_br_type,
        input  [29:0] branch_br_target,
        input  branch_jump //分支确定跳转 或者内部判断beq类指令跳转了 用于更新pht而不是btb
    
        );
    
        //待实现 根据传入的pc最后一位产生输出结果
        //待实现 两路btb 一张记录pc_2 为0的情况 一张记录pc_2 为1的情况 
        //待实现 两路pht 一张记录pc_2 为0的情况 一张记录pc_2 为1的情况
        //例化两张单路的BTB和PHT
        //待实现 参数化
    
        logic branch_valid;
        always @(*) begin
            if(branch_br_type != 2'b00) begin
                branch_valid = 1;
            end
            else begin
                branch_valid = 0;
            end
        end
    
        logic [29:0] btb0_br_target;
        logic [1 :0]  btb0_br_type;
        logic [29:0] btb0_pc;
        logic [29:0] btb1_br_target;
        logic [1 :0]  btb1_br_type;
        logic [29:0] btb1_pc;
    
        //例化BTB
        BTB0 btb_inst_0(
            .clk(clk),
            .rstn(rstn),
            //预测端,1input 2output 直接由btb给出 miss项会给00 已在btb内部处理
            .pc(btb0_pc),
            .br_target(btb0_br_target),
            .br_type(btb0_br_type),
            //更新端,4input 来自分支单元
            .update(branch_valid),
            .update_pc(branch_pc),
            .update_br_type(branch_br_type),
            .update_br_target(branch_br_target)
        );
    
        BTB1 btb_inst_1 (
            .clk(clk),
            .rstn(rstn),
            //预测端,1input 2output 直接由btb给出 miss项会给00 已在btb内部处理
            .pc(btb1_pc),
            .br_target(btb1_br_target),
            .br_type(btb1_br_type),
            //更新端,4input 来自分支单元
            .update(branch_valid),
            .update_pc(branch_pc),
            .update_br_type(branch_br_type),
            .update_br_target(branch_br_target)
        );
    
    
        //例化PHT
        logic btb0_pht_jump;
        logic btb1_pht_jump;
        // PHT pht_inst(
        //     .clk(clk),
        //     .rstn(rstn),
        //     //预测端,1input 1output 直接由pht给出
        //     .pc(pc),
        //     .pht_jump(pht_jump),
        //     //更新端,4input 来自分支单元
        //     .update(branch_valid),
        //     .update_type(branch_br_type),
        //     .update_pc(branch_pc),
        //     .update_pht_jump(branch_jump)
        // );
    
        PHT pht0_inst(
            .clk(clk),
            .rstn(rstn),
            //预测端,1input 1output 直接由pht给出
            .pc(btb0_pc),
            .pht_jump(btb0_pht_jump),
            //更新端,4input 来自分支单元
            .update(branch_valid),
            .update_type(branch_br_type),
            .update_pc(branch_pc),
            .update_pht_jump(branch_jump)
        );
    
        PHT pht1_inst(
            .clk(clk),
            .rstn(rstn),
            //预测端,1input 1output 直接由pht给出
            .pc(btb1_pc),
            .pht_jump(btb1_pht_jump),
            //更新端,4input 来自分支单元
            .update(branch_valid),
            .update_type(branch_br_type),
            .update_pc(branch_pc),
            .update_pht_jump(branch_jump)
        );
    
        //生成访问btb的pc，如果输入pc的pc_2为0则使用传入pc和pc+4访问btb0和btb1
        //如果输入pc的pc_2为1则使用传入pc和pc+4访问btb1和btb0
        //这里的pc_2是指传入的30位pc的最后一位 pc_2=0 btb0给出预测0 btb1给出预测1
        //pc_2=1 btb0给出预测1 btb1给出预测0
    
        always @(*) begin
            if(pc[0] == 0) begin
                btb0_pc = pc;
                btb1_pc = pc + 1;
            end
            else begin
                btb0_pc = pc + 1;
                btb1_pc = pc;
            end 
        end
    
    
        always @(*) begin
            if ((pc[0] == 0 && btb0_pht_jump == 1) || (pc[0] == 1 && btb1_pht_jump == 1)) begin
                predict_br_target = (pc[0] == 0) ? btb0_br_target : btb1_br_target;
                // pred_br_type = (pc[0] == 0) ? btb0_br_type : btb1_br_type;
    
            end
            else begin
                predict_br_target = {(pc + 2)[29:1], 1'b0};
                // pred_br_type = 2'b00;
            end
        end
    
        always @(*) begin
            //最后一位为0，同时pht0给出跳转，目标给到pred0，pred1置00
            if(pc[0] == 0 && btb0_pht_jump == 1) begin
                pred0_br_target = btb0_br_target;
                pred0_br_type = btb0_br_type;
                pred1_br_target = 30'b0;
                pred1_br_type = 2'b00;
            end
            //最后一位为0，同时pht0不给出跳转，pht1给出跳转，目标给到pred1，pred0置00
            else if(pc[0] == 0 && btb0_pht_jump == 0 && btb1_pht_jump == 1) begin
                pred1_br_target = btb1_br_target;
                pred1_br_type = btb1_br_type;
                pred0_br_target = 30'b0;
                pred0_br_type = 2'b00;
            end
            //最后一位为1，同时pht1给出跳转，目标给到pred1，pred0置00
            else if(pc[0] == 1 && btb1_pht_jump == 1) begin
                pred1_br_target = btb1_br_target;
                pred1_br_type = btb1_br_type;
                pred0_br_target = 30'b0;
                pred0_br_type = 2'b00;
            end
            //其余情况，pred0和pred1都置00
            else begin
                pred0_br_target = {(pc + 2)[29:1], 1'b0};
                pred0_br_type = 2'b00;
                pred1_br_target = 30'b0;
                pred1_br_type = 2'b00;
            end
        end
    
    
    endmodule
    


    //例化PHT
    logic btb0_pht_jump;
    logic btb1_pht_jump;
    // PHT pht_inst(
    //     .clk(clk),
    //     .rstn(rstn),
    //     //预测端,1input 1output 直接由pht给出
    //     .pc(pc),
    //     .pht_jump(pht_jump),
    //     //更新端,4input 来自分支单元
    //     .update(branch_valid),
    //     .update_type(branch_br_type),
    //     .update_pc(branch_pc),
    //     .update_pht_jump(branch_jump)
    // );

    PHT pht0_inst(
        .clk(clk),
        .rstn(rstn),
        //预测端,1input 1output 直接由pht给出
        .pc(btb0_pc),
        .pht_jump(btb0_pht_jump),
        //更新端,4input 来自分支单元
        .update(branch_valid),
        .update_type(branch_br_type),
        .update_pc(branch_pc),
        .update_pht_jump(branch_jump)
    );

    PHT pht1_inst(
        .clk(clk),
        .rstn(rstn),
        //预测端,1input 1output 直接由pht给出
        .pc(btb1_pc),
        .pht_jump(btb1_pht_jump),
        //更新端,4input 来自分支单元
        .update(branch_valid),
        .update_type(branch_br_type),
        .update_pc(branch_pc),
        .update_pht_jump(branch_jump)
    );

    //生成访问btb的pc，如果输入pc的pc_2为0则使用传入pc和pc+4访问btb0和btb1
    //如果输入pc的pc_2为1则使用传入pc和pc+4访问btb1和btb0
    //这里的pc_2是指传入的30位pc的最后一位 pc_2=0 btb0给出预测0 btb1给出预测1
    //pc_2=1 btb0给出预测1 btb1给出预测0

    always @(*) begin
        if(pc[0] == 0) begin
            btb0_pc = pc;
            btb1_pc = pc + 1;
        end
        else begin
            btb0_pc = pc + 1;
            btb1_pc = pc;
        end 
    end


    always @(*) begin
        if ((pc[0] == 0 && btb0_pht_jump == 1) || (pc[0] == 1 && btb1_pht_jump == 1)) begin
            predict_br_target = (pc[0] == 0) ? btb0_br_target : btb1_br_target;
            // pred_br_type = (pc[0] == 0) ? btb0_br_type : btb1_br_type;

        end
        else begin
            predict_br_target = {(pc + 2)[29:1], 1'b0};
            // pred_br_type = 2'b00;
        end
    end

    always @(*) begin
        //最后一位为0，同时pht0给出跳转，目标给到pred0，pred1置00
        if(pc[0] == 0 && btb0_pht_jump == 1) begin
            pred0_br_target = btb0_br_target;
            pred0_br_type = btb0_br_type;
            pred1_br_target = 30'b0;
            pred1_br_type = 2'b00;
        end
        //最后一位为0，同时pht0不给出跳转，pht1给出跳转，目标给到pred1，pred0置00
        else if(pc[0] == 0 && btb0_pht_jump == 0 && btb1_pht_jump == 1) begin
            pred1_br_target = btb1_br_target;
            pred1_br_type = btb1_br_type;
            pred0_br_target = 30'b0;
            pred0_br_type = 2'b00;
        end
        //最后一位为1，同时pht1给出跳转，目标给到pred1，pred0置00
        else if(pc[0] == 1 && btb1_pht_jump == 1) begin
            pred1_br_target = btb1_br_target;
            pred1_br_type = btb1_br_type;
            pred0_br_target = 30'b0;
            pred0_br_type = 2'b00;
        end
        //其余情况，pred0和pred1都置00
        else begin
            pred0_br_target = {(pc + 2)[29:1], 1'b0};
            pred0_br_type = 2'b00;
            pred1_br_target = 30'b0;
            pred1_br_type = 2'b00;
        end
    end


endmodule
