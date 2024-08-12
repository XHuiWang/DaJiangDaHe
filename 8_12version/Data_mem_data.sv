`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/20 15:05:41
// Design Name: 
// Module Name: Data_mem_data
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


module Data_mem_data #(
    parameter NB_COL    = 16,                         // Specify number of columns (number of bytes)
    parameter COL_WIDTH = 8,                          // Specify column width (byte width, typically 8 or 9)
    parameter RAM_DEPTH = 256,                         // Specify RAM depth (number of entries)
    parameter INIT_FILE = ""                          // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) (
    input [clogb2(RAM_DEPTH-1)-1:0] addra,            // Write address bus, width determined from RAM_DEPTH
    input [clogb2(RAM_DEPTH-1)-1:0] addrb,            // Read address bus, width determined from RAM_DEPTH
    input [(NB_COL*COL_WIDTH)-1:0] dina,              // RAM input data
    input ena,
    input clka,                                       // Clock
    input [NB_COL-1:0] wea,                           // Byte-write enable
    output [(NB_COL*COL_WIDTH)-1:0] doutb             // RAM output data
  );
  
    reg [(NB_COL*COL_WIDTH)-1:0] BRAM [RAM_DEPTH-1:0];
    reg [clogb2(RAM_DEPTH-1)-1:0] addrb_reg;
  
    // The following code either initializes the memory values to a specified file or to all zeros to match hardware
    generate
      if (INIT_FILE != "") begin: use_init_file
        initial
          $readmemh(INIT_FILE, BRAM, 0, RAM_DEPTH-1);
      end else begin: init_bram_to_zero
        integer ram_index;
        initial
          for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
            BRAM[ram_index] = {(NB_COL*COL_WIDTH){1'b0}};
      end
    endgenerate
  
    generate
    genvar i;
       for (i = 0; i < NB_COL; i = i+1) begin: byte_write
         always @(posedge clka)begin
             if (wea[i]&&ena) begin
               BRAM[addra][(i+1)*COL_WIDTH-1:i*COL_WIDTH] <= dina[(i+1)*COL_WIDTH-1:i*COL_WIDTH];
             end
            end
       end
    endgenerate

    always @(posedge clka) begin
        addrb_reg <= addrb;
    end

    assign doutb = BRAM[addrb_reg];

    //  The following function calculates the address width based on specified RAM depth
    function integer clogb2;
      input integer depth;
        for (clogb2=0; depth>0; clogb2=clogb2+1)
          depth = depth >> 1;
    endfunction
  
  endmodule