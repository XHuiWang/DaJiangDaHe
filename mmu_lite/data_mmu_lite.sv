`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////


module data_mmu_lite(

input       [31:0]   addr,
input        [1:0]    plv,
input        [1:0]    translate_mode, //01: direct, 10: paged
input        [1:0]    direct_d_mat,
input                 dmw0_plv0,
input                 dmw0_plv3,
input        [1:0]    dmw0_mat,
input        [2:0]    dmw0_vseg,dmw0_pseg,
input                 dmw1_plv0,
input                 dmw1_plv3,
input        [1:0]    dmw1_mat,
input        [2:0]    dmw1_vseg,dmw1_pseg,


output logic [31:0]   paddr,
output logic          uncache
);

logic  dmw0_en;
assign dmw0_en =  (plv == 2'b11 && dmw0_plv3) || (plv == 2'b00 && dmw0_plv0);
logic  dmw1_en;
assign dmw1_en =  (plv == 2'b11 && dmw1_plv3) || (plv == 2'b00 && dmw1_plv0);


always @(*) begin
    if(translate_mode == 2'b10 && dmw0_en && addr[31:29] == dmw0_vseg) begin
        paddr   = {dmw0_pseg, addr[28:0]};
        uncache = ~dmw0_mat[0];
    end
    else if(translate_mode == 2'b10 && dmw1_en && addr[31:29] == dmw1_vseg) begin
        paddr   = {dmw1_pseg, addr[28:0]};
        uncache = ~dmw1_mat[0];
    end
    else begin
        paddr   = addr;
        uncache = ~direct_d_mat[0];
    end
end


endmodule
