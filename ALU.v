`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/08/2025 11:14:35 AM
// Design Name: 
// Module Name: ALU
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


module ALU(
    input wire[31:0] a,       // operand 1
    input wire[31:0] b,      // operand 2
    input wire [4:0] shamt,     // shift amount (for shift/rotate)
    input wire[3:0] alu_ctrl,    // ALU control signal (select operation)
    output reg[31:0] result,    // result of operation
    output wire zero            // zero flag
    );
    
    // Zero flag is high when result == 0
    assign zero = (result == 32'b0);
    
    always @(*) begin
        case(alu_ctrl)
            4'b0000: result = a + b;                 // ADD
            4'b0001: result = a - b;                 // SUB
            4'b0010: result = a * b;                 // MUL
            4'b0011: result = a & b;                 // AND
            4'b0100: result = a | b;                 // OR
            4'b0101: result = a ^ b;                 // XOR
            4'b0110: result = b << shamt;            // SLL (shift left logical)
            4'b0111: result = b >> shamt;            // SRL (shift right logical)
            4'b1000: result = b <<< shamt;           // SAL (shift arithmetic left)
            4'b1001: result = b >>> shamt;           // SAR (shift arithmetic right)
            4'b1010: result = (b << shamt) | (b >> (32 - shamt)); // ROL
            4'b1011: result = (b >> shamt) | (b << (32 - shamt)); // ROR
            default: result = 32'b0;                 // Default = 0
        endcase
    end
endmodule
