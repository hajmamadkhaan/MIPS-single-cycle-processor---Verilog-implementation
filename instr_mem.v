`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/08/2025 04:36:37 PM
// Design Name: 
// Module Name: instr_mem
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


module instr_mem(
    input wire [31:0] addr,     // address from PC
    output wire [31:0] instr    // 32-bit instruction
    );
    
    // an array of 256 32-bit words
    reg [31:0] mem[0:255];
    
    // Word address: drop lower 2 bits of addr
    assign instr = mem[addr[31:2]];
     
endmodule
