`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/08/2025 02:37:17 PM
// Design Name: 
// Module Name: PC
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


module PC(clk, rst, pc_next, pc_curr);

    input wire clk, rst; // Clock, Synchronous reset
    input wire [31:0] pc_next; // next PC value
    output reg [31:0] pc_curr; // current PC value
    
    initial begin 
    pc_curr = 32'b0;
    end;
    
    always @(posedge clk) begin
        if (rst)
            pc_curr <= 32'b0; // Start PC from 0
        else
            pc_curr <= pc_next; // Update PC
    end
endmodule