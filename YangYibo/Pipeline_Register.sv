module Pipeline_Register(
    input                       clk,
    input                       rstn,

    input                       stall_ex,
    input                       stall_ex_buf,
    input                       stall_dcache,
    input                       stall_dcache_buf,

    input           [ 6: 0]     MEM_ecode_in_a, //A指令的异常码
    input           [ 6: 0]     MEM_ecode_in_b, //B指令的异常码
    input                       WB_flush_csr,
    
    //BR 跳转在MEM段生效
    input                       EX_br_a,        //A指令是否需要修正预测的结果
    input                       EX_br,          //分支指令是否需要修正预测的结果
    input           [31: 0]     EX_pc_br,       //分支指令需要修正预测结果时，PC的修正值
    input           [31: 0]     EX_pc_of_br,    //分支指令的PC
    input           [ 1: 0]     EX_pd_type,     //分支指令的分支类型（与分支预测交互）
    input           [31: 0]     EX_br_target,   //分支指令原本的目标地址
    input                       EX_br_jump,     //分支指令原本是否跳转
    output  wire                MEM_br,         //作为EX->MEM段的flush信号
    output  reg     [31: 0]     MEM_pc_br,
    output  reg     [31: 0]     MEM_pc_of_br,
    output  wire    [ 1: 0]     MEM_pd_type,
    output  reg     [31: 0]     MEM_br_target,
    output  reg                 MEM_br_jump,
    

    input           [31: 0]     EX_pc_a,            //A指令的PC
    input           [31: 0]     EX_pc_b,            //B指令的PC
    output  reg     [31: 0]     MEM_pc_a,
    output  reg     [31: 0]     MEM_pc_b,
    output  reg     [31: 0]     WB_pc_a,            
    output  reg     [31: 0]     WB_pc_b,

    input           [31: 0]     EX_alu_result_a,    //A指令的运算结果
    input           [31: 0]     EX_alu_result_b,    //B指令的运算结果
    output  reg     [31: 0]     MEM_alu_result_a,
    output  reg     [31: 0]     MEM_alu_result_b,

    input           [63: 0]     EX_mul_tmp1,        //乘法器临时结果1
    input           [63: 0]     EX_mul_tmp2,        //乘法器临时结果2
    output  reg     [63: 0]     MEM_mul_tmp1,
    output  reg     [63: 0]     MEM_mul_tmp2,

    input                       EX_rf_we_a,         //A指令寄存器写使能
    input                       EX_rf_we_b,         //B指令寄存器写使能
    input           [ 4: 0]     EX_rf_waddr_a,      //A指令寄存器写地址
    input           [ 4: 0]     EX_rf_waddr_b,      //B指令寄存器写地址
    input           [ 8: 0]     EX_wb_mux_select_b,
    output  reg     [ 8: 0]     MEM_wb_mux_select_b,

    output  reg                 MEM_rf_we_a,
    output  reg                 MEM_rf_we_b,
    output  reg     [ 4: 0]     MEM_rf_waddr_a,
    output  reg     [ 4: 0]     MEM_rf_waddr_b,
    input           [31: 0]     MEM_rf_wdata_a,
    input           [31: 0]     MEM_rf_wdata_b,


    output  reg                 WB_rf_we_a,
    output  reg                 WB_rf_we_b,
    output  reg     [ 4: 0]     WB_rf_waddr_a,
    output  reg     [ 4: 0]     WB_rf_waddr_b,
    output  reg     [31: 0]     WB_rf_wdata_a,
    output  reg     [31: 0]     WB_rf_wdata_b
);
always@(posedge clk)
begin
    if(!rstn | WB_flush_csr | MEM_br)
    begin
        MEM_alu_result_a<=32'h0000_0000;
        MEM_alu_result_b<=32'h0000_0000;
        MEM_rf_we_a<=1'b0;
        MEM_rf_we_b<=1'b0;
        MEM_rf_waddr_a<=5'b00000;
        MEM_rf_waddr_b<=5'b00000;
        MEM_wb_mux_select_b<=9'b000000;
        MEM_mul_tmp1<=64'h0000_0000;
        MEM_mul_tmp2<=64'h0000_0000;
        MEM_pc_a<=32'h0000_0000;
        MEM_pc_b<=32'h0000_0000;
    end
    else if(!stall_dcache&&!stall_ex)begin //考虑到前递，stall_dcache应阻塞所有段间寄存器
        //EX->MEM
        //不需要修正分支预测
        if(!EX_br_a) begin 
            MEM_alu_result_b<=EX_alu_result_b;
            MEM_rf_we_b<=EX_rf_we_b;
            MEM_wb_mux_select_b<=EX_wb_mux_select_b;
            MEM_mul_tmp1<=EX_mul_tmp1;
            MEM_mul_tmp2<=EX_mul_tmp2;
            MEM_pc_b<=EX_pc_b;
        end
        //需要修正分支预测
        else begin 
            MEM_alu_result_b<=32'h0000_0000;
            MEM_rf_we_b<=1'b0;
            MEM_wb_mux_select_b<=9'b000000;
            MEM_mul_tmp1<=64'h0000_0000;
            MEM_mul_tmp2<=64'h0000_0000;
            MEM_pc_b<=32'h0000_0000;
        end 
        MEM_alu_result_a<=EX_alu_result_a;
        MEM_rf_we_a<=EX_rf_we_a;
        MEM_rf_waddr_a<=EX_rf_waddr_a;
        MEM_rf_waddr_b<=EX_rf_waddr_b;
        MEM_pc_a<=EX_pc_a;
    end
    else begin end
end

//BR
logic               MEM_br_orig;        //分支指令是否需要修正，尚未考虑stall
logic   [31: 0]     MEM_pd_type_orig;   //分支指令的类型，尚未考虑stall
assign MEM_br = MEM_br_orig & (~stall_dcache_buf) & (~stall_ex_buf);
assign MEM_pd_type = MEM_pd_type_orig & {2{~stall_dcache_buf}}&{2{~stall_ex_buf}};
//stall流水线时，若MEM段为BR指令，在stall的整个期间（stall为1以及其后的第一个为0的周期）
//因stall造成的MEM_br_orig等信号连续置1的多个周期中，MEM_br等信号仅在第一个周期可以被置1
//stall_div/stall_dcache/flush的产生是同时的，均用buf来抑制，flush的再次产生前stall置零，再次产生时buf置零，不会有多余干涉
always@(posedge clk)begin
    if(!rstn | WB_flush_csr | MEM_br)begin
        MEM_br_orig<=1'b0;
        MEM_pc_br<=32'h0000_0000;
        MEM_pc_of_br<=32'h0000_0000;
        MEM_pd_type_orig<=2'b00;
        MEM_br_target<=32'h0000_0000;
        MEM_br_jump<=1'b0;
    end
    else if(!stall_dcache&&!stall_ex)begin
        MEM_br_orig <= EX_br;
        MEM_pc_br <= EX_pc_br;
        MEM_pc_of_br <= EX_pc_of_br;
        MEM_pd_type_orig <= EX_pd_type; 
        MEM_br_target <= EX_br_target;
        MEM_br_jump <= EX_br_jump;
    end
    else begin end
end

//MEM->WB
always@(posedge clk)begin
    if(!rstn | WB_flush_csr) begin
        WB_rf_we_a<=1'b0;
        WB_rf_we_b<=1'b0;
        WB_rf_waddr_a<=5'b00000;
        WB_rf_waddr_b<=5'b00000;
        WB_rf_wdata_a<=32'h0000_0000;
        WB_rf_wdata_b<=32'h0000_0000;
        WB_pc_a<=32'h0000_0000;
        WB_pc_b<=32'h0000_0000;
    end
    else if(!stall_dcache&&!stall_ex) begin
        WB_rf_we_a<=|MEM_ecode_in_a ? 1'b0 : MEM_rf_we_a;    //A指令有无非中断例外
        WB_rf_we_b<=((|MEM_ecode_in_a) | (|MEM_ecode_in_b)) ? 1'b0 : MEM_rf_we_b; //AB指令有无非中断例外
        WB_rf_waddr_a<=MEM_rf_waddr_a;
        WB_rf_waddr_b<=MEM_rf_waddr_b;
        WB_rf_wdata_a<=MEM_rf_wdata_a;
        WB_rf_wdata_b<=MEM_rf_wdata_b;
        WB_pc_a<=MEM_pc_a;
        WB_pc_b<=MEM_pc_b;
    end
    else begin end
end
endmodule