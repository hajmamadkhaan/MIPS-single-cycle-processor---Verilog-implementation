`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/08/2025 09:40:24 AM
// Design Name: 
// Module Name: tb_regfile
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


module tb_regfile;

    reg        clk;   // clock
    reg        rst;   // synchronous reset (active high) - clears all regs to 0
    reg        we;    // write enable
    reg [4:0]  rs;    // read register 1
    reg [4:0]  rt;    // read register 2
    reg [4:0]  rd;    // write register
    reg [31:0] wd;    // write data
    wire [31:0] rd1;   // read data 1
    wire [31:0] rd2;   // read data 2

    parameter PERIOD = 10;
    
    regfile uut (
        .clk(clk),
        .rst(rst),
        .we(we),
        .rs(rs),
        .rt(rt),
        .rd(rd),
        .wd(wd),
        .rd1(rd1),
        .rd2(rd2)
    );
    
//    initial begin
//        $display($time, "<< Starting the simulation >>");
//        clk = 0;
//        forever #PERIOD clk = ~clk;
//    end
    initial clk = 0;
    always clk = #PERIOD ~clk;
    
    initial begin

        $display($time, "<< Starting the simulation >>");
    
        rst = 1; we = 0; rs = 0; rt = 0; rd = 0; wd = 0;
        #12;
        rst = 0;
        #10;
        
        $display("<< Register file test >>");
        
        // 1) Basic write and read
       // Test: Write in cycle 1, read in cycle 2
        // ---------------------------------------------------------
        @(posedge clk);
        we = 1; rd = 3; wd = 32'h12345678;  // Write into register 3
        rs = 3; rt = 0;                     // Prepare to read reg 3 next cycle
        $display("[%0t] Cycle 1: Writing 0x%h into reg %0d", $time, wd, rd);
        if (rd1 !== 32'h00000000)
            $display("[%0t] FAIL : Read-after-write expected 0x00000000, got %h", $time, rd1);
        else if(rd1 == 32'h00000000)
            $display("[%0t] PASS: Read-after-write matches 0x00000000", $time, rd1);

        @(posedge clk);                     // Advance to next cycle
        we = 0;                             // Disable write
        #1;                                 // Small delay to let read settle

        if (rd1 !== 32'h12345678)
            $display("[%0t] FAIL: Read-after-write expected 0x12345678, got %h", $time, rd1);
        else
            $display("[%0t] PASS: Read-after-write matches 0x12345678", $time, rd1);

        // 2) Zero register protection (writes ignored)
        we = 1; rd = 0; wd = 32'hFFFFFFFF; rs = 0; rt = 0;
        #1;
        if (rd1 !== 32'h0) $display("FAIL: reg0 should remain 0 after attempted write, got %h", rd1);
        else $display("PASS: reg0 remains 0 after attempted write");
        @(posedge clk); we = 0; #1;

        // 3) Simultaneous reads
        // Write two registers first
        @(posedge clk);
        we = 1; rd = 10; wd = 32'h11111111; #1;
        @(posedge clk);
        we = 1; rd = 11; wd = 32'h22222222; #1;
        @(posedge clk);
        we = 0; rs = 10; rt = 11; #1;
        if (rd1 !== 32'h11111111 || rd2 !== 32'h22222222)
            $display("FAIL: Simultaneous reads incorrect rd1=%h rd2=%h", rd1, rd2);
        else
            $display("PASS: Simultaneous reads rd1=%h rd2=%h", rd1, rd2);

        // 4) Read/Write same register in same cycle (behavior with forwarding)
        we = 1; rd = 7; wd = 32'hCAFEBABE; rs = 7; rt = 0;
        #1;
        if (rd1 === 32'hCAFEBABE) $display("PASS: Read/Write same-reg forwarding shows %h", rd1);
        else $display("INFO: No forwarding: read shows %h (expected either new or old value)", rd1);
        @(posedge clk);
        we = 0; #1;

        $display("<< Test completed >>");
        $finish;
    end
endmodule
