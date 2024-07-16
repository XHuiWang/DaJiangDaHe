module ex_mem_wb(
    input                       clk,
    input                       rstn,
    input                       stall,

    input           [31: 0]     EX_pc_a,            //A指令的PC值
    input           [31: 0]     EX_pc_b,            //B指令的PC值
    input           [31: 0]     EX_rf_rdata_a1,     //A指令的第一个寄存器的值
    input           [31: 0]     EX_rf_rdata_a2,     //A指令的第二个寄存器的值
    input           [31: 0]     EX_rf_rdata_b1,     //B指令的第一个寄存器的值
    input           [31: 0]     EX_rf_rdata_b2,     //B指令的第二个寄存器的值
    input           [31: 0]     EX_imm_a,           //A指令的立即数
    input           [31: 0]     EX_imm_b,           //B指令的立即数

    input           [ 1: 0]     EX_alu_src_sel_a1,  //A指令的第一个操作数选择信号
    input           [ 1: 0]     EX_alu_src_sel_a2,  //A指令的第二个操作数选择信号
    input           [ 1: 0]     EX_alu_src_sel_b1,  //B指令的第一个操作数选择信号
    input           [ 1: 0]     EX_alu_src_sel_b2,  //B指令的第二个操作数选择信号
    input           [11: 0]     EX_alu_op_a,        //A指令的运算类型
    input           [11: 0]     EX_alu_op_b,        //B指令的运算类型

    input           [ 3: 0]     EX_br_type_a,       //A指令的分支类型
    input           [ 3: 0]     EX_br_type_b,       //B指令的分支类型
    input                       EX_br_pd_a,         //predict A指令的分支预测，1预测跳转，0预测不跳转                  
    input                       EX_br_pd_b,         //predict B指令的分支预测，1预测跳转，0预测不跳转    
    
    input                       EX_rf_we_a,         //A指令寄存器写使能
    input                       EX_rf_we_b,         //B指令寄存器写使能
    input           [ 4: 0]     EX_rf_waddr_a,      //A指令寄存器写地址
    input           [ 4: 0]     EX_rf_waddr_b,      //B指令寄存器写地址
    
    input                       EX_mem_we_a,        //A指令内存写使能
    input                       EX_mem_we_b,        //B指令内存写使能
    input           [ 2: 0]     EX_mem_type_a,      //A指令内存写类型
    input           [ 2: 0]     EX_mem_type_b,      //B指令内存写类型

    // 双BR的跳转处理在本模块内进行，只输出一组跳转信号
    // output                      EX_br_a,            //A指令是否需要修正预测的结果
    // output                      EX_br_b,            //B指令是否需要修正预测的结果
    // output          [31: 0]     EX_pc_br_a,         //A指令修正时应跳转到的地址
    // output          [31: 0]     EX_pc_br_b,         //B指令修正时应跳转到的地址

    output                      EX_br,              //是否需要修正预测的结果
    output          [31: 0]     EX_pc_br            //修正时应跳转到的地址
);
logic   [31: 0]     EX_rf_rdata_a1_f;               //A指令的第一个寄存器的值，经前递修正后
logic   [31: 0]     EX_rf_rdata_a2_f;               //A指令的第二个寄存器的值，经前递修正后

logic   [31: 0]     EX_alu_result_a;                //A指令的运算结果
logic   [31: 0]     EX_alu_result_b;                //B指令的运算结果
logic   [31: 0]     MEM_alu_result_a;               //A指令的运算结果
logic   [31: 0]     MEM_alu_result_b;               //B指令的运算结果
logic   [31: 0]     WB_alu_result_a;                //A指令的运算结果
logic   [31: 0]     WB_alu_result_b;                //B指令的运算结果

logic               MEM_rf_we_a;                    //A指令寄存器写使能
logic               MEM_rf_we_b;                    //B指令寄存器写使能
logic   [ 4: 0]     MEM_rf_waddr_a;                 //A指令寄存器写地址
logic   [ 4: 0]     MEM_rf_waddr_b;                 //B指令寄存器写地址

logic               WB_rf_we_a;                     //A指令寄存器写使能
logic               WB_rf_we_b;                     //B指令寄存器写使能
logic   [ 4: 0]     WB_rf_waddr_a;                  //A指令寄存器写地址
logic   [ 4: 0]     WB_rf_waddr_b;                  //B指令寄存器写地址

logic               EX_br_a;                        //A指令是否需要修正预测的结果
logic               EX_br_b;                        //B指令是否需要修正预测的结果
logic   [31: 0]     EX_pc_br_a;                     //A指令修正时应跳转到的地址
logic   [31: 0]     EX_pc_br_b;                     //B指令修正时应跳转到的地址

logic               EX_mem_we_orig;                 //内存写使能 尚未考虑STIRE指令的W/H/B分类
logic   [ 3: 0]     EX_mem_we;                      //内存写使能 已经考虑STIRE指令的W/H/B分类
logic               EX_mem_we_bb;                   //考虑A为BR时修正后，B指令内存写使能
logic   [31: 0]     EX_mem_wdata_oirg;              //内存写数据 尚未考虑STORE指令的W/H/B分类
logic   [31: 0]     EX_mem_wdata;                   //内存写数据 已经考虑STORE指令的W/H/B分类
logic   [31: 0]     EX_mem_waddr;                   //内存写地址
logic   [ 2: 0]     EX_mem_type;                    //内存写类型
assign  EX_mem_we_orig    =EX_mem_we_a | EX_mem_we_bb;       //A、B至多有一个为STROE指令
assign  EX_mem_we_bb      =EX_br_a?1'b0:EX_mem_we_b;      //若A指令需要修正预测结果，B指令不能写内存
assign  EX_mem_wdata_oirg =EX_mem_we_a?EX_rf_rdata_a2_f:EX_rf_rdata_b2_f; //不会同时发射两条STORE指令
assign  EX_mem_waddr      =EX_mem_we_a?EX_alu_result_a:EX_alu_result_b;   //不会同时发射两条STORE指令

assign  EX_mem_type= EX_mem_type_a + EX_mem_type_b; //A、B至多有一个为STROE指令
always @(*)begin
  //ST
  case(EX_mem_type)         
    3'b110:begin                                                 //ST.B
      case(EX_mem_waddr[1:0]) //龙芯架构32位精简版采用小尾端的存储方式
        2'b00:begin EX_mem_we={4{EX_mem_we_orig}}&4'b0001;  EX_mem_wdata=EX_mem_wdata_orig;end
        2'b01:begin EX_mem_we={4{EX_mem_we_orig}}&4'b0010;  EX_mem_wdata=EX_mem_wdata_orig<<8;end
        2'b10:begin EX_mem_we={4{EX_mem_we_orig}}&4'b0100;  EX_mem_wdata=EX_mem_wdata_orig<<16;end
        2'b11:begin EX_mem_we={4{EX_mem_we_orig}}&4'b1000;  EX_mem_wdata=EX_mem_wdata_orig<<24;end
        default:begin EX_mem_we=4'b0000;                    EX_mem_wdata=EX_mem_wdata_orig;end
      endcase
    end
    3'b111:begin                                                 //ST.H
      case(EX_mem_waddr[1])
      1'b0:begin EX_mem_we={4{EX_mem_we_orig}}&4'b0011;     EX_mem_wdata=EX_mem_wdata_orig;end
      1'b1:begin EX_mem_we={4{EX_mem_we_orig}}&4'b1100;     EX_mem_wdata=EX_mem_wdata_orig<<16;end
      default:begin EX_mem_we=4'b0000;                      EX_mem_wdata=EX_mem_wdata_orig;end
      endcase
    end
    3'b001:begin EX_mem_we={4{EX_mem_we_orig}};             EX_mem_wdata=EX_mem_wdata_orig;end  //ST.W
    default:begin EX_mem_we=4'b0000;                        EX_mem_wdata=EX_mem_wdata_orig;end
  endcase
  //LD
end
Forward  Forward_inst (
    .EX_rf_rdata_a1(EX_rf_rdata_a1),
    .EX_rf_rdata_a2(EX_rf_rdata_a2),
    .EX_rf_rdata_b1(EX_rf_rdata_b1),
    .EX_rf_rdata_b2(EX_rf_rdata_b2),
    .MEM_rf_waddr_a(MEM_rf_waddr_a),
    .MEM_rf_waddr_b(MEM_rf_waddr_b),
    .MEM_rf_we_a(MEM_rf_we_a),
    .MEM_rf_we_b(MEM_rf_we_b),
    .MEM_alu_result_a(MEM_alu_result_a),
    .MEM_alu_result_b(MEM_alu_result_b),
    .WB_rf_waddr_a(WB_rf_waddr_a),
    .WB_rf_waddr_b(WB_rf_waddr_b),
    .WB_rf_we_a(WB_rf_we_a),
    .WB_rf_we_b(WB_rf_we_b),
    .WB_rf_wdata_a(WB_rf_wdata_a),
    .WB_rf_wdata_b(WB_rf_wdata_b),
    .EX_rf_raddr_a1(EX_rf_raddr_a1),
    .EX_rf_raddr_a2(EX_rf_raddr_a2),
    .EX_rf_raddr_b1(EX_rf_raddr_b1),
    .EX_rf_raddr_b2(EX_rf_raddr_b2),
    .EX_rf_rdata_a1_f(EX_rf_rdata_a1_f),
    .EX_rf_rdata_a2_f(EX_rf_rdata_a2_f),
    .EX_rf_rdata_b1_f(EX_rf_rdata_b1_f),
    .EX_rf_rdata_b2_f(EX_rf_rdata_b2_f)
  );

FU_ALU  FU_ALU_inst (
    .EX_pc_a(EX_pc_a),
    .EX_pc_b(EX_pc_b),
    .EX_rf_rdata_a1(EX_rf_rdata_a1_f),
    .EX_rf_rdata_a2(EX_rf_rdata_a2_f),
    .EX_rf_rdata_b1(EX_rf_rdata_b1_f),
    .EX_rf_rdata_b2(EX_rf_rdata_b2_f),
    .EX_imm_a(EX_imm_a),
    .EX_imm_b(EX_imm_b),
    .EX_alu_src_sel_a1(EX_alu_src_sel_a1),
    .EX_alu_src_sel_a2(EX_alu_src_sel_a2),
    .EX_alu_src_sel_b1(EX_alu_src_sel_b1),
    .EX_alu_src_sel_b2(EX_alu_src_sel_b2),
    .EX_alu_op_a(EX_alu_op_a),
    .EX_alu_op_b(EX_alu_op_b),
    .EX_alu_result_a(EX_alu_result_a),
    .EX_alu_result_b(EX_alu_result_b)
);
FU_BR  FU_BR_inst (
    .clk(clk),
    .rstn(rstn),
    .stall(stall),
    .EX_pc_a(EX_pc_a),
    .EX_pc_b(EX_pc_b),
    .EX_rf_rdata_a1(EX_rf_rdata_a1),
    .EX_rf_rdata_a2(EX_rf_rdata_a2),
    .EX_rf_rdata_b1(EX_rf_rdata_b1),
    .EX_rf_rdata_b2(EX_rf_rdata_b2),
    .EX_imm_a(EX_imm_a),
    .EX_imm_b(EX_imm_b),
    .EX_br_type_a(EX_br_type_a),
    .EX_br_type_b(EX_br_type_b),
    .EX_br_pd_a(EX_br_pd_a),
    .EX_br_pd_b(EX_br_pd_b),
    .EX_br(EX_br),
    .EX_pc_br(EX_pc_br)
  );
Pipeline_Register  Pipeline_Register_inst (
    .clk(clk),
    .rstn(rstn),
    .stall(stall),
    .EX_br_a(EX_br_a),
    .EX_alu_result_a(EX_alu_result_a),
    .EX_alu_result_b(EX_alu_result_b),
    .MEM_alu_result_a(MEM_alu_result_a),
    .MEM_alu_result_b(MEM_alu_result_b),
    .WB_alu_result_a(WB_alu_result_a),
    .WB_alu_result_b(WB_alu_result_b),
    .EX_rf_we_a(EX_rf_we_a),
    .EX_rf_we_b(EX_rf_we_b),
    .EX_rf_waddr_a(EX_rf_waddr_a),
    .EX_rf_waddr_b(EX_rf_waddr_b),
    .MEM_rf_we_a(MEM_rf_we_a),
    .MEM_rf_we_b(MEM_rf_we_b),
    .MEM_rf_waddr_a(MEM_rf_waddr_a),
    .MEM_rf_waddr_b(MEM_rf_waddr_b),
    .WB_rf_we_a(WB_rf_we_a),
    .WB_rf_we_b(WB_rf_we_b),
    .WB_rf_waddr_a(WB_rf_waddr_a),
    .WB_rf_waddr_b(WB_rf_waddr_b)
  );

blk_mem_gen_1 Data_Memory(
              .clka(clk),
              .clkb(clk),
              .ena(icache_rready),//
              .enb(1'b1),
              .wea(EX_mem_we),
              .web(4'b0000),
              .addra(EX_mem_waddr[14:2]),
              .addrb(addr[11:0]),
              .dina(EX_mem_wdata),
              .dinb(32'd0),
              .douta(MEM_mem_rdata),
              .doutb(dout_dm)
             );
endmodule