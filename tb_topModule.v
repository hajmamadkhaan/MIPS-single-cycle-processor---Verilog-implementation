`timescale 1ns/1ps

module tb_topModule();
    reg clk, rst;
    integer i;

    // Instantiate top
    SingleCycleMIPS uut (
        .clk(clk),
        .rst(rst)
    );

    // Clock gen
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period
    end

    // Initialize
    initial begin
        rst = 1;
        #15 rst = 0;
    end

    // Preload instruction memory
    initial begin
        // Clear
        for (i=0; i<256; i=i+1)
            uut.IMem.mem[i] = 32'b0;

        // Program
        uut.IMem.mem[0] = 32'h04120004;  // addi $s2, $zero, 4
uut.IMem.mem[1] = 32'h04130000;  // addi $s3, $zero, 0
uut.IMem.mem[2] = 32'h12530002;  // beq $s3, $s2, end
uut.IMem.mem[3] = 32'h06730001;  // addi $s3, $s3, 1
uut.IMem.mem[4] = 32'h08000002;  // j loop
uut.IMem.mem[5] = 32'h02534020;  // add $t0, $s2, $s3
    end

    // Monitor key signals
    initial begin
        $monitor("Time=%0t | PC=%h | Instr=%h | ALU=%h | WD=%h",
                 $time,
                 uut.pc_curr,
                 uut.instr,
                 uut.alu_result,
                 uut.wd);
    end

    // Run for some cycles
    initial begin
        #300 $finish;
    end
endmodule
