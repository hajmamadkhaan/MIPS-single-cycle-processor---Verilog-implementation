`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/09/2025 01:49:23 PM
// Design Name: 
// Module Name: tb_dataMem
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


module tb_dataMem;

    reg         clk;    // clock
    reg         we;     // write enable signal
    reg[31:0]   addr;   // comes from alu result (for lw and sw)
    reg[31:0]   writeData;
    wire [31:0] readData;

    parameter PERIOD = 10;

    data_mem uut(
        .clk(clk),
        .we(we),
        .addr(addr),
        .writeData(writeData),
        .readData(readData)
    );
    
    // Clock
    initial clk = 0;
    always clk = #(PERIOD/2) ~clk;
    
    initial begin
        $display("<< Testing data memory >>\n");
        
        
        // 1) Write to aligned address
        @(posedge clk);
        addr = 32'd4; writeData = 32'hDEADBEEF; we = 1;

        #PERIOD; we = 0;
        if (readData !== 32'hDEADBEEF)
            $display("FAIL: Read after write (aligned) wrong, got %h", readData);
        else
            $display("PASS: Read after write (aligned)");
    
        // 2) Write to another aligned address
        @(posedge clk);
        addr = 32'd8; writeData = 32'hCAFEBABE; we = 1;
        #PERIOD
        we = 0;
        addr = 32'd8; #1;
        if (readData !== 32'hCAFEBABE)
            $display("FAIL: Read from addr=8 wrong, got %h", readData);
        else
            $display("PASS: Read from addr=8");
        
            
        // 3) Misaligned access test
        @(posedge clk);
        addr = 32'd6; writeData = 32'h12345678; we = 1;
        #1;
        
        @(posedge clk);
        addr = 32'd4; we = 0;
        $display("Misaligned read result = %h (expected XXXXXXXX)", readData);

        $display("=== Tests Done ===\n");
        $finish;        
    end
endmodule
