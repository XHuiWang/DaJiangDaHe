`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/16 15:32:31
// Design Name: 
// Module Name: ID_Decode_edi_2
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
// 
//////////////////////////////////////////////////////////////////////////////////


// `include "Public_Info.sv"
import Public_Info::*;

module ID_Decode_edi_2(
    input [31: 0] IF_IR,
    input [31: 0] PC,
    input [33: 0] brtype_pcpre,
    input [ 7: 0] ecode,
    input [ 1: 0] plv,

    input [ 0: 0] ID_status,
    input [ 0: 0] data_valid,
    output PC_set PC_set
    );

    logic [ 0: 0] o_valid;
    logic [ 0: 0] o_inst_lawful;

    logic [ 9: 0] inst_type;
    logic [ 9: 0] br_type; 

    logic [31: 0] imm;
    logic [ 4: 0] rf_rd;
    logic [ 0: 0] rf_we;
  
    logic [ 3: 0] alu_src1_sel;
    logic [ 3: 0] alu_src2_sel;
  
    logic [ 4: 0] rf_raddr1;
    logic [ 4: 0] rf_raddr2;
  
    logic [11: 0] alu_op;
    
    logic [ 0: 0] mem_we;
    logic [ 3: 0] ldst_type;
    // logic [ 0: 0] wb_sel; // TODO: act as mux_sel 
    logic [ 8: 0] mux_sel; // B通道WB来源的选择信号
    logic [ 0: 0] sign_bit; // 符号位,运用于乘除法

    logic [ 2: 0] csr_type; // 用于csr指令的类型
    logic [13: 0] csr_raddr; // 用于csr指令的读csr地址
    logic [ 6: 0] ecode_in; // 用于异常处理的输入
    logic [ 0: 0] ecode_we; // 用于异常处理的写曾经，表示已经修改过ecode_in
    logic [ 6: 0] ecode_out; // 用于异常处理的输出
    logic [ 0: 0] ecode_out_we; // 用于异常处理的输出写曾经，表示已经修改过ecode_out
    logic [ 4: 0] code_for_cacop; // 用于cacop指令的code

    assign ecode_in = ecode[ 6: 0];
    assign ecode_we = ecode[ 7: 7];


    assign PC_set.instruction = IF_IR;
    assign PC_set.PC = PC;
    assign PC_set.o_inst_lawful = o_inst_lawful;
    assign PC_set.o_valid = o_valid;
    assign PC_set.inst_type = inst_type; // TODO: DONE
    assign PC_set.br_type = br_type;
    assign PC_set.imm = imm;
    assign PC_set.rf_rd = rf_rd;
    assign PC_set.rf_we = rf_we;
    assign PC_set.alu_src1_sel = alu_src1_sel;
    assign PC_set.alu_src2_sel = alu_src2_sel;
    assign PC_set.rf_raddr1 = rf_raddr1;
    assign PC_set.rf_raddr2 = rf_raddr2;
    assign PC_set.alu_op = alu_op;
    assign PC_set.mem_we = mem_we;
    assign PC_set.ldst_type = ldst_type;
    // assign PC_set.wb_sel = wb_sel;
    assign PC_set.mux_sel = mux_sel;
    assign PC_set.sign_bit = sign_bit;
    assign PC_set.rf_rdata1 = 32'd0;
    assign PC_set.rf_rdata2 = 32'd0;
    assign PC_set.type_predict = brtype_pcpre[33:32];
    assign PC_set.PC_pre = brtype_pcpre[31: 0];
    assign PC_set.csr_type = csr_type;
    assign PC_set.csr_raddr = csr_raddr;
    assign PC_set.ecode_in = ecode_out;
    assign PC_set.ecode_we = ecode_out_we;
    assign PC_set.code_for_cacop = code_for_cacop;


    // 对每一种指令的存在进行检测
    wire add_inst;
    wire sub_inst;
    wire addi_inst;
    wire lu12i_inst;
    wire pcaddu12i_inst;

    wire slt_inst;
    wire sltu_inst;
    wire slti_inst;
    wire sltui_inst;

    wire and_inst;
    wire or_inst;
    wire nor_inst;
    wire xor_inst;
    wire andi_inst;
    wire ori_inst;
    wire xori_inst;
    
    wire sll_inst;
    wire srl_inst;
    wire sra_inst;
    wire slli_inst;
    wire srli_inst;
    wire srai_inst;

    wire st_inst;
    wire sth_inst;
    wire stb_inst;
    wire ld_inst;
    wire ldh_inst;
    wire ldb_inst;
    wire ldhu_inst;
    wire ldbu_inst;
    
    wire beq_inst;
    wire bne_inst;
    wire blt_inst;
    wire bge_inst;
    wire bltu_inst;
    wire bgeu_inst;
    wire b_inst;
    wire bl_inst;
    wire jirl_inst;

    wire mul_inst;
    wire mulh_inst;
    wire mulhu_inst;
    wire div_inst;
    wire mod_inst;
    wire divu_inst;
    wire modu_inst;

    wire csrrd_inst;
    wire csrwr_inst;
    wire csrxchg_inst;
    wire ertn_inst;

    wire break_inst;
    wire syscall_inst;

    wire rdcntid_inst;
    wire rdcntvl_inst;
    wire rdcntvh_inst;

    wire cacop_inst;


    assign add_inst       = (IF_IR [31:15] == 17'h00020) ? 1'b1 : 1'b0;
    assign sub_inst       = (IF_IR [31:15] == 17'h00022) ? 1'b1 : 1'b0;
    assign addi_inst      = (IF_IR [31:22] == 10'h00a)   ? 1'b1 : 1'b0;
    assign lu12i_inst     = (IF_IR [31:25] == 7'h0a)     ? 1'b1 : 1'b0;
    assign pcaddu12i_inst = (IF_IR [31:25] == 7'h0e)     ? 1'b1 : 1'b0;
    
    assign slt_inst       = (IF_IR [31:15] == 17'h00024) ? 1'b1 : 1'b0;
    assign sltu_inst      = (IF_IR [31:15] == 17'h00025) ? 1'b1 : 1'b0;
    assign slti_inst      = (IF_IR [31:22] == 10'h008)   ? 1'b1 : 1'b0;
    assign sltui_inst     = (IF_IR [31:22] == 10'h009)   ? 1'b1 : 1'b0;
    
    assign and_inst       = (IF_IR [31:15] == 17'h00029) ? 1'b1 : 1'b0;
    assign or_inst        = (IF_IR [31:15] == 17'h0002a) ? 1'b1 : 1'b0;
    assign nor_inst       = (IF_IR [31:15] == 17'h00028) ? 1'b1 : 1'b0;
    assign xor_inst       = (IF_IR [31:15] == 17'h0002b) ? 1'b1 : 1'b0;
    assign andi_inst      = (IF_IR [31:22] == 10'h00d)   ? 1'b1 : 1'b0;
    assign ori_inst       = (IF_IR [31:22] == 10'h00e)   ? 1'b1 : 1'b0;
    assign xori_inst      = (IF_IR [31:22] == 10'h00f)   ? 1'b1 : 1'b0;
  
    assign sll_inst       = (IF_IR [31:15] == 17'h0002e) ? 1'b1 : 1'b0;
    assign srl_inst       = (IF_IR [31:15] == 17'h0002f) ? 1'b1 : 1'b0;
    assign sra_inst       = (IF_IR [31:15] == 17'h00030) ? 1'b1 : 1'b0;
    assign slli_inst      = (IF_IR [31:15] == 17'h00081) ? 1'b1 : 1'b0;
    assign srli_inst      = (IF_IR [31:15] == 17'h00089) ? 1'b1 : 1'b0;
    assign srai_inst      = (IF_IR [31:15] == 17'h00091) ? 1'b1 : 1'b0;
  
    assign st_inst        = (IF_IR [31:22] == 10'h0a6)   ? 1'b1 : 1'b0;
    assign sth_inst       = (IF_IR [31:22] == 10'h0a5)   ? 1'b1 : 1'b0;
    assign stb_inst       = (IF_IR [31:22] == 10'h0a4)   ? 1'b1 : 1'b0;
    assign ld_inst        = (IF_IR [31:22] == 10'h0a2)   ? 1'b1 : 1'b0;
    assign ldh_inst       = (IF_IR [31:22] == 10'h0a1)   ? 1'b1 : 1'b0;
    assign ldb_inst       = (IF_IR [31:22] == 10'h0a0)   ? 1'b1 : 1'b0;
    assign ldbu_inst      = (IF_IR [31:22] == 10'h0a8)   ? 1'b1 : 1'b0;
    assign ldhu_inst      = (IF_IR [31:22] == 10'h0a9)   ? 1'b1 : 1'b0;
  
    assign beq_inst       = (IF_IR [31:26] == 6'h16)     ? 1'b1 : 1'b0;
    assign bne_inst       = (IF_IR [31:26] == 6'h17)     ? 1'b1 : 1'b0;
    assign blt_inst       = (IF_IR [31:26] == 6'h18)     ? 1'b1 : 1'b0;
    assign bge_inst       = (IF_IR [31:26] == 6'h19)     ? 1'b1 : 1'b0;
    assign bltu_inst      = (IF_IR [31:26] == 6'h1a)     ? 1'b1 : 1'b0;
    assign bgeu_inst      = (IF_IR [31:26] == 6'h1b)     ? 1'b1 : 1'b0;
    assign b_inst         = (IF_IR [31:26] == 6'h14)     ? 1'b1 : 1'b0;
    assign bl_inst        = (IF_IR [31:26] == 6'h15)     ? 1'b1 : 1'b0;
    assign jirl_inst      = (IF_IR [31:26] == 6'h13)     ? 1'b1 : 1'b0;

    assign mul_inst       = (IF_IR [31:15] == 17'h00038) ? 1'b1 : 1'b0;
    assign mulh_inst      = (IF_IR [31:15] == 17'h00039) ? 1'b1 : 1'b0;
    assign mulhu_inst     = (IF_IR [31:15] == 17'h0003a) ? 1'b1 : 1'b0;
    assign div_inst       = (IF_IR [31:15] == 17'h00040) ? 1'b1 : 1'b0;
    assign mod_inst       = (IF_IR [31:15] == 17'h00041) ? 1'b1 : 1'b0;
    assign divu_inst      = (IF_IR [31:15] == 17'h00042) ? 1'b1 : 1'b0;
    assign modu_inst      = (IF_IR [31:15] == 17'h00043) ? 1'b1 : 1'b0;

    assign csrrd_inst     = (IF_IR [31:24] == 8'h04 && IF_IR [ 9: 5] == 5'h00) ? 1'b1 : 1'b0;
    assign csrwr_inst     = (IF_IR [31:24] == 8'h04 && IF_IR [ 9: 5] == 5'h01) ? 1'b1 : 1'b0;
    assign csrxchg_inst   = (IF_IR [31:24] == 8'h04 && IF_IR [ 9: 5] != 5'h00 && IF_IR [ 9: 5] != 5'h01) ? 1'b1 : 1'b0;
    assign ertn_inst      = (IF_IR [31: 0] == 32'h06483800) ? 1'b1 : 1'b0;

    assign break_inst     = (IF_IR [31:15] == 17'h00054) ? 1'b1 : 1'b0;
    assign syscall_inst   = (IF_IR [31:15] == 17'h00056) ? 1'b1 : 1'b0;

    assign rdcntid_inst   = (IF_IR [31:10] == 22'h000018 && ~(|IF_IR [ 4: 0])) ? 1'b1 : 1'b0;
    assign rdcntvl_inst   = (IF_IR [31: 5] == 27'h0000300) ? 1'b1 : 1'b0;
    assign rdcntvh_inst   = (IF_IR [31: 5] == 27'h0000320) ? 1'b1 : 1'b0;

    assign cacop_inst     = (IF_IR [31: 0] == 10'h018) ? 1'b1 : 1'b0;


    // assign o_valid = data_valid & (~ ecode_out_we); // 有效的en不能是例外和异常
    assign o_valid = data_valid;
    assign o_inst_lawful = (add_inst | sub_inst | addi_inst | lu12i_inst | pcaddu12i_inst | slt_inst | 
                            sltu_inst | slti_inst | sltui_inst | and_inst | or_inst | nor_inst | 
                            xor_inst | andi_inst | ori_inst | xori_inst | sll_inst | srl_inst | 
                            sra_inst | slli_inst | srli_inst | srai_inst | st_inst | sth_inst | 
                            stb_inst | ld_inst | ldh_inst | ldb_inst | ldhu_inst | ldbu_inst | 
                            beq_inst | bne_inst | blt_inst | bge_inst | bltu_inst | bgeu_inst | 
                            b_inst | bl_inst | jirl_inst | mul_inst | mulh_inst | mulhu_inst | 
                            div_inst | mod_inst | divu_inst | modu_inst | csrrd_inst | csrwr_inst |
                            csrxchg_inst | ertn_inst | break_inst | syscall_inst | rdcntid_inst | 
                            rdcntvl_inst | rdcntvh_inst | cacop_inst) ? 1'b1 : 1'b0;


    
    // sign_bit, 1为有符号数  
    assign sign_bit = (mulhu_inst | divu_inst | modu_inst) ? 1'b0 : 1'b1;
    
    

    // mux_sel
    // MEM段B指令RF写回数据多选器独热码 
    // 9'b0_0000_0001: ALU
    // 9'b0_0000_0010: LD类型指令
    // 9'b0_0000_0100: MUL  取低32位
    // 9'b0_0000_1000: MULH 取高32位
    // 9'b0_0001_0000: DIV 取商
    // 9'b0_0010_0000: MOD 取余
    // 9'b0_0100_0000: RDCNTVL.W 取低32位
    // 9'b0_1000_0000: RDCNTVH.W 取高32位
    // 9'b1_0000_0000: RDCNTID
    assign mux_sel = (ld_inst | ldb_inst | ldh_inst |  ldbu_inst | ldhu_inst) ? 9'b0_0000_0010 :
                     (mul_inst) ? 9'b0_0000_0100 :
                     (mulh_inst | mulhu_inst) ? 9'b0_0000_1000 :
                     (div_inst | divu_inst)   ? 9'b0_0001_0000 :
                     (mod_inst | modu_inst)   ? 9'b0_0010_0000 :
                     (rdcntvl_inst)           ? 9'b0_0100_0000 :
                     (rdcntvh_inst)           ? 9'b0_1000_0000 :
                     (rdcntid_inst)           ? 9'b1_0000_0000 :
                     9'b0_0000_0001;


    // inst_type
    // 10'h001: others(including alu and branch and so on)
    // 10'h002: 5 ld and 3 st
    // 10'h004: 3 mul 
    // 10'h008: 4 div
    // 10'h010: 3 csr
    // 10'h020: 1 ertn
    // 10'h040: 3 rdcnt
    // 10'h080: 1 cacop
    assign inst_type = (ld_inst | ldb_inst | ldh_inst |  ldbu_inst | ldhu_inst | st_inst | sth_inst | stb_inst) ? 10'h002 :
                       (mul_inst | mulh_inst | mulhu_inst) ? 10'h004 :
                       (div_inst | mod_inst | divu_inst | modu_inst) ? 10'h008 : 
                       ((csrrd_inst | csrwr_inst | csrxchg_inst) & ~(|plv)) ? 10'h010 :
                       (ertn_inst & ~(|plv)) ? 10'h020 :
                       (rdcntid_inst | rdcntvl_inst | rdcntvh_inst) ? 10'h040 :
                       (cacop_inst) ? 10'h080 :
                       10'h001;


    // 00 0000 0001:无跳转
    // 00 0000 0010:JIRL
    // 00 0000 0100:B
    // 00 0000 1000:BL
    // 00 0001 0000:BEQ
    // 00 0010 0000:BNE
    // 00 0100 0000:BLT
    // 00 1000 0000:BGE
    // 01 0000 0000:BLTU
    // 10 0000 0000:BGEU
    logic [ 9: 0] br_type_temp;
    assign br_type_temp =   (jirl_inst) ? 10'h002 :
                            (b_inst)    ? 10'h004 :
                            (bl_inst)   ? 10'h008 :
                            (beq_inst)  ? 10'h010 :
                            (bne_inst)  ? 10'h020 :
                            (blt_inst)  ? 10'h040 :
                            (bge_inst)  ? 10'h080 :
                            (bltu_inst) ? 10'h100 :
                            (bgeu_inst) ? 10'h200 :
                            10'h001;
    assign br_type = (data_valid) ? br_type_temp : 10'h001;

    // 0000 ld.w
    // 0001 st.w
    // 0010 ld.b
    // 0011 ld.h
    // 0100 ld.bu
    // 0101 ld.hu
    // 0110 st.b
    // 0111 st.h
    // 1000 others
    assign ldst_type[3] =  ~(ld_inst | st_inst   | ldb_inst  | ldh_inst  | ldbu_inst | ldhu_inst | stb_inst | sth_inst);
    assign ldst_type[2] =  (sth_inst | stb_inst  | ldhu_inst | ldbu_inst);
    assign ldst_type[1] =  (sth_inst | stb_inst  | ldh_inst  | ldb_inst );
    assign ldst_type[0] =  (sth_inst | ldhu_inst | ldh_inst  | st_inst  );

    wire imm_exist ;
    assign imm_exist =  (slli_inst | srli_inst | srai_inst | slti_inst | sltui_inst | addi_inst | andi_inst | ori_inst |
                        xori_inst | lu12i_inst | pcaddu12i_inst | beq_inst | bne_inst | blt_inst | bge_inst | bltu_inst |
                        bgeu_inst | jirl_inst | b_inst | bl_inst | ld_inst | ldb_inst | ldh_inst | stb_inst | sth_inst | st_inst | ldbu_inst | 
                        ldhu_inst | cacop_inst) ? 1'b1 : 1'b0;  

    assign imm =        (beq_inst | bne_inst | blt_inst | bge_inst | bltu_inst | bgeu_inst | jirl_inst) ? ({(IF_IR[25] == 1'b1 ? 14'h3fff: 14'd0), IF_IR[25:10], 2'h0}):
                        (b_inst | bl_inst) ? ({(IF_IR[9] == 1'b1 ? 4'hf : 4'd0), IF_IR[ 9: 0], IF_IR[25:10], 2'h0}) : 
                        (ld_inst | ldb_inst | ldh_inst | stb_inst | sth_inst | st_inst | ldbu_inst | ldhu_inst) ? ({(IF_IR[21] == 1'b1 ? 20'hfffff: 20'd0), IF_IR[21:10]}):
                        // (lu12i_inst ) ? ({(IF_IR[24] == 1'b1 ? 12'hfff: 12'd0),IF_IR[24: 5]}) :
                        (lu12i_inst ) ? ({IF_IR[24: 5], 12'h000}) :
                        (pcaddu12i_inst ) ? ({IF_IR[24: 5], 12'h0}) :
                        (slti_inst | sltui_inst | addi_inst | cacop_inst) ? ({(IF_IR[21] == 1'b1 ? 20'hfffff: 20'd0), IF_IR[21:10]}) :
                        (andi_inst | ori_inst   | xori_inst) ? ({20'd0, IF_IR[21:10]}) : 
                        (slli_inst | srli_inst | srai_inst) ? {27'd0 ,IF_IR[14:10]} : 0;
                        
    assign rf_raddr1 = IF_IR[ 9: 5];
    assign rf_raddr2 =  ( stb_inst | sth_inst | st_inst | beq_inst | bne_inst | 
                        blt_inst | bge_inst | bltu_inst | bgeu_inst | csrrd_inst | 
                        csrwr_inst | csrxchg_inst) ? IF_IR[ 4: 0] : IF_IR[14:10];
    assign rf_rd = (bl_inst) ? 1 : (~rdcntid_inst) ? IF_IR[ 4: 0] : IF_IR[ 9: 5];
    assign rf_we =  ((~br_type_temp[0] & ~bl_inst & ~jirl_inst) | stb_inst | 
                    sth_inst | st_inst |~data_valid | rf_rd == 0 | cacop_inst
                    (plv == 2'b11 && (csrwr_inst | csrxchg_inst | ertn_inst)) |
                    ~o_inst_lawful) ? 1'b0 : 1'b1;
    // TODO: 在Decoder检查目的寄存器是否为0，如果为0则不写回。那么是否可以可以在RF写回和前递的时候不检查相关内容
    // assign rf_we = (((br_type_temp != 0 & ~bl_inst & ~jirl_inst) | stb_inst | sth_inst | st_inst | ~ID_status | rf_rd == 0)) ? 1'b0 : 1'b1;
                                        
    assign alu_src1_sel = (bl_inst | pcaddu12i_inst | jirl_inst) ? 4'h1 ://pc
                          (~(lu12i_inst | csrxchg_inst | csrwr_inst | csrrd_inst)) ? 4'h2 :          //rf 
                          4'h4;                             //0
    assign alu_src2_sel = (imm_exist & ~(bl_inst | jirl_inst | beq_inst | bne_inst | blt_inst | bge_inst | bltu_inst | bgeu_inst)) ? 4'h1 : //imm
                          (add_inst | sub_inst | slt_inst | sltu_inst | nor_inst | and_inst | or_inst | xor_inst | sll_inst | srl_inst |
                           sra_inst | beq_inst | bne_inst | blt_inst | bge_inst | bltu_inst | bgeu_inst | mul_inst | mulh_inst | mulhu_inst |
                           div_inst | divu_inst | mod_inst | modu_inst) ? 4'h2 :                           //rf  
                          ~(csrrd_inst | csrwr_inst | csrxchg_inst) ? 4'h4 :  //4
                          4'h8; // csr_rdata
    assign alu_op = (add_inst | addi_inst | ld_inst | ldb_inst | ldh_inst | stb_inst | pcaddu12i_inst |
                     sth_inst | st_inst | ldbu_inst | ldhu_inst | bl_inst | jirl_inst | lu12i_inst | cacop_inst) ? 12'h001 :
                    (sub_inst | beq_inst | bne_inst) ? 12'h002 :
                    (slt_inst | slti_inst | blt_inst | bge_inst) ? 12'h004 :
                    (sltu_inst | sltui_inst | bltu_inst | bgeu_inst) ? 12'h008 :
                    (and_inst | andi_inst) ? 12'h010 :
                    (or_inst | ori_inst | csrrd_inst | csrwr_inst | csrxchg_inst) ? 12'h020 :
                    (nor_inst) ? 12'h040 :
                    (xor_inst | xori_inst) ? 12'h080 :
                    (sll_inst | slli_inst) ? 12'h100 :
                    (srl_inst | srli_inst) ? 12'h200 :
                    (sra_inst | srai_inst) ? 12'h400 : 12'h800;
    assign mem_we = ((stb_inst | sth_inst | st_inst) & data_valid) ? 1'b1 : 1'b0;
    // assign mem_we = ((stb_inst | sth_inst | st_inst) & ID_status) ? 1'b1 : 1'b0;
    // assign wb_sel = (ld_inst | ldb_inst | ldh_inst | ldbu_inst | ldhu_inst) ? 1'b1 : 1'b0;           

    assign csr_type = {3{~(|plv)}} &
                      (csrrd_inst  )   ? 3'h1 :
                      (csrwr_inst  )   ? 3'h2 :
                      (csrxchg_inst)   ? 3'h4 : 3'h0;
    assign csr_raddr = IF_IR[23:10];
    assign code_for_cacop = IF_IR[ 4: 0];

    always @(*) begin
        if(ecode_we) begin
            ecode_out = ecode_in;
            ecode_out_we = 1'b1;
        end
        else begin
            // 之前还没有例外
            if(~o_inst_lawful) begin
                // INE，非法指令
                ecode_out = 7'h0D;
                ecode_out_we = 1'b1;
            end
            else if(break_inst) begin
                // BRK，断点
                ecode_out = 7'h0C;
                ecode_out_we = 1'b1;
            end
            else if(syscall_inst) begin
                // SYS，系统调用
                ecode_out = 7'h0B;
                ecode_out_we = 1'b1;
            end
            else if(plv == 2'b11 && (csrrd_inst | csrwr_inst | csrxchg_inst | ertn_inst)) begin
                // 指令特权等级错误
                ecode_out = 7'h0E;
                ecode_out_we = 1'b1;
            end
            else begin
                // 其他情况
                ecode_out = 7'h00;
                ecode_out_we = 1'b0;
            end
        end
    end
    
                    
                        


endmodule
