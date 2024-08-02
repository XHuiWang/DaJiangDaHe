module Branch                   //用于判断跳转指令是否本应跳转
(
    input           [ 9:0]      br_type,
        //br_type使用独热码
        //00_0000_0001:无跳转   00_0000_0010:JIRL
        //00_0000_0100:B        00_0000_1000:BL
        //00_0001_0000:BEQ      00_0010_0000:BNE
        //00_0100_0000:BLT      00_1000_0000:BGE
        //01_0000_0000:BLTU     10_0000_0000:BGEU
    input           [31:0]      pc_orig,//跳转在EX阶段，对应跳转指令原本的pc
    input           [31:0]      imm,
    input           [31:0]      rf_rdata1,
    input           [31:0]      rf_rdata2,
    output  logic               br,     //跳转指令是否本应跳转
    output  logic   [31:0]      pc_br   //分支预测不跳转，预测失败，应跳转到的地址
);
logic       br_JIRL;    //是JIRL，且本应跳转，目标地址为R1+imm
logic       br_Branch;  //是B/BL/BEQ/BNE/BLT/BGE/BLTU/BGEU，且本应跳转，目标地址为PC+imm
assign br_JIRL   =    br_type[1];
assign br_Branch =  ( br_type[2] | br_type[3] ) | 
                    ( br_type[4]&!(rf_rdata1^rf_rdata2) | br_type[5]&|(rf_rdata1^rf_rdata2)  )| 
                    ( br_type[6]&($signed(rf_rdata1)<$signed(rf_rdata2)) | br_type[7]&($signed(rf_rdata1)>=$signed(rf_rdata2)) )|
                    ( br_type[8]&rf_rdata1<rf_rdata2 | br_type[9]&rf_rdata1>=rf_rdata2 );

assign br        =  ( br_type[1] | br_type[2] | br_type[3] ) | 
                    ( br_type[4]&!(rf_rdata1^rf_rdata2) | br_type[5]&|(rf_rdata1^rf_rdata2)  )| 
                    ( br_type[6]&($signed(rf_rdata1)<$signed(rf_rdata2)) | br_type[7]&($signed(rf_rdata1)>=$signed(rf_rdata2)) )|
                    ( br_type[8]&rf_rdata1<rf_rdata2 | br_type[9]&rf_rdata1>=rf_rdata2 );
assign pc_br     =    br_Branch ? pc_orig+imm : ( br_JIRL ? rf_rdata1+imm : pc_orig+32'h4 );
// always @(*) begin

//     pc_br=pc_orig+32'h4;//默认值 不跳转 要求上游在非跳转指令或预测不跳转时将预测跳转地址置为pc+4
//     br=1'b0;
//     case(br_type)
//         4'b0000:br=1'b0;
//         4'b0011:begin             //JIRL
//             br=1'b1;
//             pc_br=rf_rdata1+imm;
//         end
//         4'b0100:begin             //B
//             br=1'b1;
//             pc_br=pc_orig+imm;
//         end
//         4'b0101:begin             //BL
//             br=1'b1;
//             pc_br=pc_orig+imm;
//         end
//         4'b0110:begin             //BEQ
//             if(~|(rf_rdata1^rf_rdata2))begin
//                 br=1'b1;
//                 pc_br=pc_orig+imm;
//             end    
//         end
//         4'b0111:begin               //BNE
//             if(|(rf_rdata1^rf_rdata2))begin
//                 br=1'b1;
//                 pc_br=pc_orig+imm;
//             end    
//         end
//         4'b1000:begin               //BLT
//             if($signed(rf_rdata1)<$signed(rf_rdata2))begin
//                 br=1'b1;
//                 pc_br=pc_orig+imm;
//             end    
//         end
//         4'b1001:begin               //BGE
//             if($signed(rf_rdata1)>=$signed(rf_rdata2))begin
//                 br=1'b1;
//                 pc_br=pc_orig+imm;
//             end    
//         end
//         4'b1010:begin               //BLTU
//             if(rf_rdata1<rf_rdata2)begin
//                 br=1'b1;
//                 pc_br=pc_orig+imm;
//             end    
//         end
//         4'b1011:begin               //BGEU
//             if(rf_rdata1>=rf_rdata2)begin
//                 br=1'b1;
//                 pc_br=pc_orig+imm;
//             end    
//         end
//         default:begin end
//     endcase
// end
endmodule