`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/09/2025 05:04:46 PM
// Design Name: 
// Module Name: ControlUnit
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


module ControlUnit(
    input [5:0] opcode,
    input [5:0] func,
    output reg shift,
    output reg RegDst, ALUSrc, MemtoReg, RegWrite, MemWrite, Branch, Jump,
    output reg[3:0] ALUOp
    );
    

    always @(*) begin
        // Initialize control signals to nop:
        RegDst = 1'b0;
        ALUSrc = 1'b0;
        MemtoReg = 1'b0;
        RegWrite = 1'b0;
        MemWrite = 1'b0;
        Branch = 1'b0;
        Jump = 1'b0;
        shift = 1'b0;
        ALUOp = 4'b1111;
        
        casez(opcode)
		6'b000000:	// R-type: ADD, SUB, AND, OR, SLT, XOR, NOR, [Added]: SLL, SRL, SRA, ROR, ROL
                    // Look at func[5:0]
            begin
		     RegWrite = 1'b1;
		     RegDst = 1'b1;
		     ALUSrc = 1'b0;
		     Branch = 1'b0;
		     MemWrite = 1'b0;
		     MemtoReg = 1'b0;
		     
		     
		     case(func)
                    6'b100000: begin ALUOp = 4'b0000; shift = 1'b0; end // add
                    6'b100010: begin ALUOp = 4'b0001; shift = 1'b0; end // sub
                    6'b011000: begin ALUOp = 4'b0010; shift = 1'b0; end // mul
                    6'b100100: begin ALUOp = 4'b0011; shift = 1'b0; end // and
                    6'b100101: begin ALUOp = 4'b0100; shift = 1'b0; end // or
                    6'b100110: begin ALUOp = 4'b0101; shift = 1'b0; end // xor
                    6'b000000: begin ALUOp = 4'b0110; shift = 1'b1; end // sll, Shift Left Logical
                    6'b000010: begin ALUOp = 4'b0111; shift = 1'b1; end // srl, Shift Right Logical
                    6'b000011: begin ALUOp = 4'b1000; shift = 1'b1; end // sal, Shift Left Arithmetic
		            6'b000100: begin ALUOp = 4'b1001; shift = 1'b1; end // sar, Shift Right Arithmetic
		            6'b000101: begin ALUOp = 4'b1010; shift = 1'b1; end // rol, Rotate Left
		            6'b000110: begin ALUOp = 4'b1011; shift = 1'b1; end // ror, Rotate Right
		            6'b001000: begin ALUOp = 4'b0101; shift = 1'b0; end // enc, Encrypt - Performing XOR
		            6'b001001: begin ALUOp = 4'b0101; shift = 1'b0; end // dec, Decrypt - Performing XOR
		            default: ALUOp = 4'b1111; // illegal funct ? NOP 
		     endcase
		     
            end
            
         6'b000001:   // addi instruction
            begin
             RegWrite = 1'b1;
		     RegDst = 1'b0;
		     ALUSrc = 1'b1;
		     Branch = 1'b0;
		     MemWrite = 1'b0;
		     MemtoReg = 1'b0;
		     ALUOp = 4'b0000;
            end
            
         6'b000011: //subi instruction
         begin  
             RegWrite = 1'b1;
		     RegDst = 1'b0;
		     ALUSrc = 1'b1;
		     Branch = 1'b0;
		     MemWrite = 1'b0;
		     MemtoReg = 1'b0;
		     ALUOp = 4'b0001;
		 end
            
         6'b100011: // lw instruction
            begin
             RegWrite = 1'b1;
		     RegDst = 1'b0;
		     ALUSrc = 1'b1;
		     Branch = 1'b0;
		     MemWrite = 1'b0;
		     MemtoReg = 1'b1;
		     ALUOp = 4'b0000;
            end
         6'b101011: // sw instruction
            begin
             RegWrite = 1'b0;
		     RegDst = 1'bX;
		     ALUSrc = 1'b1;
		     Branch = 1'b0;
		     MemWrite = 1'b1;
		     MemtoReg = 1'bX;
		     ALUOp = 4'b0000;
            end
         6'b000100: // beq instruction
            begin
             RegWrite = 1'b0;
		     RegDst = 1'bX;
		     ALUSrc = 1'b0;
		     Branch = 1'b1;
		     MemWrite = 1'b0;
		     MemtoReg = 1'bX;
		     ALUOp = 4'b0001;
            end
            
        6'b000010:  // j instruction
            begin
             RegWrite = 1'b0;
		     RegDst = 1'bX;
		     ALUSrc = 1'bX;
		     Branch = 1'b0;
		     MemWrite = 1'b0;
		     MemtoReg = 1'bX;
		     Jump = 1'b1;
		     ALUOp = 4'b1111;
            end
        default: begin
                // leave defaults -> NOP
        end
        endcase
    end
endmodule
