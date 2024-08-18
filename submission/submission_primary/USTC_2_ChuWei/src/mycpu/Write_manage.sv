`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/05 13:35:53
// Design Name: 
// Module Name: Write_manage
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


module Write_manage(
    //
    input            [31:0]     address,
    input            [31:0]     wdata_pipe,
    input            [127:0]    w_data_rbuf,
    input            [2:0]      mem_type_pipe,
    output reg       [127:0]    w_data
    );
    always@(*)begin
        case(mem_type_pipe)
        3'b000:begin//ld.w or others
            w_data = w_data_rbuf;
        end
        3'b001:begin//st.w
            case(address[3:2])
                2'b00: w_data = {w_data_rbuf[127:32], wdata_pipe};
                2'b01: w_data = {w_data_rbuf[127:64], wdata_pipe, w_data_rbuf[31:0]};
                2'b10: w_data = {w_data_rbuf[127:96], wdata_pipe,w_data_rbuf[63:0]};
                2'b11: w_data = {wdata_pipe,w_data_rbuf[95:0]};
            endcase
        end
        3'b010:begin//ld.b
            w_data = w_data_rbuf;
        end
        3'b011:begin//ld.h
            w_data = w_data_rbuf;
        end
        3'b100:begin//ld.bu
            w_data = w_data_rbuf;
        end
        3'b101:begin//ld.hu
            w_data = w_data_rbuf;
        end
        3'b110:begin//st.b
            case(address[3:0])
            4'b0000: w_data = {w_data_rbuf[127:8], wdata_pipe[7:0]};
            4'b0001: w_data = {w_data_rbuf[127:16], wdata_pipe[7:0], w_data_rbuf[7:0]};
            4'b0010: w_data = {w_data_rbuf[127:24], wdata_pipe[7:0], w_data_rbuf[15:0]};
            4'b0011: w_data = {w_data_rbuf[127:32], wdata_pipe[7:0], w_data_rbuf[23:0]};
            4'b0100: w_data = {w_data_rbuf[127:40], wdata_pipe[7:0], w_data_rbuf[31:0]};
            4'b0101: w_data = {w_data_rbuf[127:48], wdata_pipe[7:0], w_data_rbuf[39:0]};
            4'b0110: w_data = {w_data_rbuf[127:56], wdata_pipe[7:0], w_data_rbuf[47:0]};
            4'b0111: w_data = {w_data_rbuf[127:64], wdata_pipe[7:0], w_data_rbuf[55:0]};
            4'b1000: w_data = {w_data_rbuf[127:72], wdata_pipe[7:0], w_data_rbuf[63:0]};
            4'b1001: w_data = {w_data_rbuf[127:80], wdata_pipe[7:0], w_data_rbuf[71:0]};
            4'b1010: w_data = {w_data_rbuf[127:88], wdata_pipe[7:0], w_data_rbuf[79:0]};
            4'b1011: w_data = {w_data_rbuf[127:96], wdata_pipe[7:0], w_data_rbuf[87:0]};
            4'b1100: w_data = {w_data_rbuf[127:104], wdata_pipe[7:0], w_data_rbuf[95:0]};
            4'b1101: w_data = {w_data_rbuf[127:112], wdata_pipe[7:0], w_data_rbuf[103:0]};
            4'b1110: w_data = {w_data_rbuf[127:120], wdata_pipe[7:0], w_data_rbuf[111:0]};
            default: w_data = {wdata_pipe[7:0], w_data_rbuf[119:0]};
            endcase
        end
        default:begin//st.h
            case(address[3:0])
            4'b0000: w_data = {w_data_rbuf[127:16], wdata_pipe[15:0]};
            4'b0010: w_data = {w_data_rbuf[127:32], wdata_pipe[15:0], w_data_rbuf[15:0]};
            4'b0100: w_data = {w_data_rbuf[127:48], wdata_pipe[15:0], w_data_rbuf[31:0]};
            4'b0110: w_data = {w_data_rbuf[127:64], wdata_pipe[15:0], w_data_rbuf[47:0]};
            4'b1000: w_data = {w_data_rbuf[127:80], wdata_pipe[15:0], w_data_rbuf[63:0]};
            4'b1010: w_data = {w_data_rbuf[127:96], wdata_pipe[15:0], w_data_rbuf[79:0]};
            4'b1100: w_data = {w_data_rbuf[127:112], wdata_pipe[15:0], w_data_rbuf[95:0]};
            4'b1110: w_data = {wdata_pipe[15:0], w_data_rbuf[111:0]};

            //exception
            default: w_data = w_data_rbuf;
            endcase
        end
    endcase
    end

endmodule
