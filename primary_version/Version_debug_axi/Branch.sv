module Branch                   //用于判断跳转指令是否本应跳转
(
    input           [ 3:0]      br_type,//对应instruction[29:26]
                                        //0000:无跳转   0011:JIRL
                                        //0100:B        0101:BL
                                        //0110:BEQ      0111:BNE
                                        //1000:BLT      1001:BGE
                                        //1010:BLTU     1011:BGEU
    input           [31:0]      pc_orig,//跳转在EX阶段，对应跳转指令原本的pc
    input           [31:0]      imm,
    input           [31:0]      rf_rdata1,
    input           [31:0]      rf_rdata2,
    output  reg                 br,     //跳转指令是否本应跳转
    output  reg     [31:0]      pc_br   //分支预测不跳转，预测失败，应跳转到的地址
);
always @(*) begin

    pc_br=pc_orig+imm;//默认值 不跳转
    br=1'b0;
    case(br_type)
        4'b0000:br=1'b0;
        4'b0011:begin             //JIRL
            br=1'b1;
            pc_br=rf_rdata1+imm;
        end
        4'b0100:begin             //B
            br=1'b1;
            pc_br=pc_orig+imm;
        end
        4'b0101:begin             //BL
            br=1'b1;
            pc_br=pc_orig+imm;
        end
        4'b0110:begin             //BEQ
            if(~|(rf_rdata1^rf_rdata2))begin
                br=1'b1;
                pc_br=pc_orig+imm;
            end    
        end
        4'b0111:begin               //BNE
            if(|(rf_rdata1^rf_rdata2))begin
                br=1'b1;
                pc_br=pc_orig+imm;
            end    
        end
        4'b1000:begin               //BLT
            if($signed(rf_rdata1)<$signed(rf_rdata2))begin
                br=1'b1;
                pc_br=pc_orig+imm;
            end    
        end
        4'b1001:begin               //BGE
            if($signed(rf_rdata1)>=$signed(rf_rdata2))begin
                br=1'b1;
                pc_br=pc_orig+imm;
            end    
        end
        4'b1010:begin               //BLTU
            if(rf_rdata1<rf_rdata2)begin
                br=1'b1;
                pc_br=pc_orig+imm;
            end    
        end
        4'b1011:begin               //BGEU
            if(rf_rdata1>=rf_rdata2)begin
                br=1'b1;
                pc_br=pc_orig+imm;
            end    
        end
        default:begin end
    endcase
end
endmodule