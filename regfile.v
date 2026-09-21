`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/08/2025 09:24:33 AM
// Design Name: 
// Module Name: regfile
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


module regfile(
    input  wire        clk,   // clock
    input  wire        rst,   // synchronous reset (active high) - clears all regs to 0
    input  wire        we,    // write enable
    input  wire [4:0]  rs,    // read register 1
    input  wire [4:0]  rt,    // read register 2
    input  wire [4:0]  rd,    // write register
    input  wire [31:0] wd,    // write data
    output wire [31:0] rd1,   // read data 1
    output wire [31:0] rd2    // read data 2
    );
    
    // Register storage
    reg [31:0] regs [31:0];
    integer i;
    
    initial begin
        for (i = 0; i < 32; i = i + 1)
            regs[i] = 32'b0;
    end

    // Synchronous write and reset
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'b0;
        end else begin
            // Writes to register $zero are ignored
            if (we && (rd != 5'd0))
                regs[rd] <= wd;
        end
    end

    // $zero ragister behavior handled
    assign rd1 = (rs == 5'd0) ? 32'b0 : regs[rs];
    assign rd2 = (rt == 5'd0) ? 32'b0 : regs[rt];

   
endmodule
