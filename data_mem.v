`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/09/2025 01:36:10 PM
// Design Name: 
// Module Name: data_mem
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


module data_mem(
    input wire          clk,    // clock
    input wire          we,     // write enable signal
    input wire[31:0]    addr,   // comes from alu result (for lw and sw)
    input wire[31:0]    writeData,
    output wire [31:0]  readData
    );
    
    // Holds 128 words, 512 bytes in total
    reg [31:0] memData [127:0];
    
    // Combinational read (word-aligned)
    assign readData = (addr[1:0] == 2'b00) ? memData[addr] : memData[addr & 32'hfffffffC];
    
    // Synchronous write (word-aligned)
    always @(posedge clk) begin
        if (we && (addr[1:0]==2'b00)) begin
            memData[addr] <= writeData;
        end else if(we) begin
            $display("WARNING: Misaligned store at time %t, addr=%h", $time, addr);
            memData[addr & 32'hfffffffC] <= writeData; // Force word-aligned write
        end
    end
    
endmodule
