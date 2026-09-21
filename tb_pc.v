`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/08/2025 03:15:38 PM
// Design Name: 
// Module Name: tb_pc
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


module tb_pc;

    reg clk;
    reg rst;
    reg [31:0] pc_next;
    wire [31:0] pc_curr;

    parameter PERIOD = 10;
    
    PC uut(
        .clk(clk),
        .rst(rst),
        .pc_next(pc_next),
        .pc_curr(pc_curr)
    );
    
    // Clock
    initial clk = 0;
    always clk = #PERIOD ~clk;
    
    initial begin
        rst = 1; pc_next = 0; #10;
        rst = 0;
        
        pc_next = 32'd4; @(posedge clk);
        $display("PC after +4: %d", pc_curr);
    
        pc_next = 32'd8; @(posedge clk);
        $display("PC after +8: %d", pc_curr);
        
        // Simulate a branch (jump to 100)
        pc_next = 32'd100; @(posedge clk);
        $display("PC after branch: %d", pc_curr);

        $finish;
    end
endmodule
