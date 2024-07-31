module Forward(
    input           [31: 0]     EX_rf_rdata_a1,     //A指令的第一个寄存器的值
    input           [31: 0]     EX_rf_rdata_a2,     //A指令的第二个寄存器的值
    input           [31: 0]     EX_rf_rdata_b1,     //B指令的第一个寄存器的值
    input           [31: 0]     EX_rf_rdata_b2,     //B指令的第二个寄存器的值

    input           [ 4: 0]     MEM_rf_waddr_a,     //A指令的写寄存器的地址
    input           [ 4: 0]     MEM_rf_waddr_b,     //B指令的写寄存器的地址
    input                       MEM_rf_we_a,        //A指令的写使能
    input                       MEM_rf_we_b,        //B指令的写使能
    input           [ 8: 0]     MEM_wb_mux_select_b,//B指令的多选器选择信号

    //此处屏蔽的为多选器选择后的信号，多选器包含MUL2/DIV2/Dache的输出，为了防止过长的通路，前递不使用此信号
    // input           [31: 0]     MEM_rf_wdata_a,     //A指令的写寄存器的数据
    // input           [31: 0]     MEM_rf_wdata_b,     //B指令的写寄存器的数据

    input           [31: 0]     MEM_alu_result_a,   //A指令的运算结果
    input           [31: 0]     MEM_alu_result_b,   //B指令的运算结果

    input           [ 4: 0]     WB_rf_waddr_a,      //A指令的写寄存器的地址
    input           [ 4: 0]     WB_rf_waddr_b,      //B指令的写寄存器的地址
    input                       WB_rf_we_a,         //A指令的写使能
    input                       WB_rf_we_b,         //B指令的写使能
    input           [31: 0]     WB_rf_wdata_a,      //A指令的写寄存器的数据
    input           [31: 0]     WB_rf_wdata_b,      //B指令的写寄存器的数据

    input           [ 4: 0]     EX_rf_raddr_a1,     //A指令的第一个寄存器的地址
    input           [ 4: 0]     EX_rf_raddr_a2,     //A指令的第二个寄存器的地址
    input           [ 4: 0]     EX_rf_raddr_b1,     //B指令的第一个寄存器的地址
    input           [ 4: 0]     EX_rf_raddr_b2,     //B指令的第二个寄存器的地址

    output  reg     [31: 0]     EX_rf_rdata_a1_f,   //A指令的第一个寄存器的值
    output  reg     [31: 0]     EX_rf_rdata_a2_f,   //A指令的第二个寄存器的值
    output  reg     [31: 0]     EX_rf_rdata_b1_f,   //B指令的第一个寄存器的值
    output  reg     [31: 0]     EX_rf_rdata_b2_f    //B指令的第二个寄存器的值
);
//rd为0时译码段会使we为0
always @(*) begin
    if      (~|(EX_rf_raddr_a1^MEM_rf_waddr_b) && (MEM_rf_we_b&&MEM_wb_mux_select_b[0])) begin
        EX_rf_rdata_a1_f=MEM_alu_result_b;
    end
    else if (~|(EX_rf_raddr_a1^MEM_rf_waddr_a) && MEM_rf_we_a) begin
        EX_rf_rdata_a1_f=MEM_alu_result_a;
    end
    else if (~|(EX_rf_raddr_a1^WB_rf_waddr_b) &&  WB_rf_we_b) begin
        EX_rf_rdata_a1_f=WB_rf_wdata_b;
    end
    else if (~|(EX_rf_raddr_a1^WB_rf_waddr_a) &&  WB_rf_we_a) begin
        EX_rf_rdata_a1_f=WB_rf_wdata_a;
    end
    else begin
        EX_rf_rdata_a1_f=EX_rf_rdata_a1;
    end
end

always @(*)begin
    if     (~|(EX_rf_raddr_a2^MEM_rf_waddr_b) && (MEM_rf_we_b &&MEM_wb_mux_select_b[0])) begin
        EX_rf_rdata_a2_f=MEM_alu_result_b;
    end
    else if (~|(EX_rf_raddr_a2^MEM_rf_waddr_a) && MEM_rf_we_a) begin
        EX_rf_rdata_a2_f=MEM_alu_result_a;
    end
    else if (~|(EX_rf_raddr_a2^ WB_rf_waddr_b) &&  WB_rf_we_b) begin
        EX_rf_rdata_a2_f=WB_rf_wdata_b;
    end
    else if (~|(EX_rf_raddr_a2^ WB_rf_waddr_a) &&  WB_rf_we_a) begin
        EX_rf_rdata_a2_f=WB_rf_wdata_a;
    end
    else begin
        EX_rf_rdata_a2_f=EX_rf_rdata_a2;
    end
end

always @(*)begin
    if      (~|(EX_rf_raddr_b1^MEM_rf_waddr_b) && (MEM_rf_we_b &&MEM_wb_mux_select_b[0])) begin
        EX_rf_rdata_b1_f=MEM_alu_result_b;
    end
    else if (~|(EX_rf_raddr_b1^MEM_rf_waddr_a) && MEM_rf_we_a) begin
        EX_rf_rdata_b1_f=MEM_alu_result_a;
    end
    else if (~|(EX_rf_raddr_b1^ WB_rf_waddr_b) &&  WB_rf_we_b) begin
        EX_rf_rdata_b1_f=WB_rf_wdata_b;
    end
    else if (~|(EX_rf_raddr_b1^ WB_rf_waddr_a) &&  WB_rf_we_a) begin
        EX_rf_rdata_b1_f=WB_rf_wdata_a;
    end
    else begin
        EX_rf_rdata_b1_f=EX_rf_rdata_b1;
    end
end

always @(*)begin
    if      (~|(EX_rf_raddr_b2^MEM_rf_waddr_b) && (MEM_rf_we_b &&MEM_wb_mux_select_b[0])) begin
        EX_rf_rdata_b2_f=MEM_alu_result_b;
    end
    else if (~|(EX_rf_raddr_b2^MEM_rf_waddr_a) && MEM_rf_we_a) begin
        EX_rf_rdata_b2_f=MEM_alu_result_a;
    end
    else if (~|(EX_rf_raddr_b2^ WB_rf_waddr_b) &&  WB_rf_we_b) begin
        EX_rf_rdata_b2_f=WB_rf_wdata_b;
    end
    else if (~|(EX_rf_raddr_b2^ WB_rf_waddr_a) &&  WB_rf_we_a) begin
        EX_rf_rdata_b2_f=WB_rf_wdata_a;
    end
    else begin
        EX_rf_rdata_b2_f=EX_rf_rdata_b2;
    end
end
endmodule