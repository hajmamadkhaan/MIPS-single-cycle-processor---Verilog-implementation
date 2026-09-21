`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 09/13/2025 09:31:14 AM
// Design Name: ControlUnit Testbench
// Module Name: ControlUnit_tb
// Project Name: MIPS Single Cycle Processor
// Target Devices:
// Tool Versions:
// Description: An enhanced testbench to verify the functionality of the
//              ControlUnit module. It automatically checks signal values for
//              each instruction and reports PASS/FAIL status.
//
// Dependencies: ControlUnit.v
//
//////////////////////////////////////////////////////////////////////////////////

module ControlUnit_tb;

    // Inputs to the DUT (Device Under Test)
    reg [5:0] opcode;
    reg [5:0] func;

    // Outputs from the DUT
    wire shift;
    wire RegDst;
    wire ALUSrc;
    wire MemtoReg;
    wire RegWrite;
    wire MemWrite;
    wire Branch;
    wire Jump;
    wire [3:0] ALUOp;

    // Counters for test results
    integer tests_passed = 0;
    integer tests_failed = 0;
    integer total_tests = 0;

    // Instantiate the ControlUnit
    // This testbench assumes your ControlUnit has a MemRead output port
    ControlUnit dut (
        .opcode(opcode),
        .func(func),
        .shift(shift),
        .RegDst(RegDst),
        .ALUSrc(ALUSrc),
        .MemtoReg(MemtoReg),
        .RegWrite(RegWrite),
        .MemWrite(MemWrite),
        .Branch(Branch),
        .Jump(Jump),
        .ALUOp(ALUOp)
    );
    
    // --- Verification Task ---
    // This task compares the DUT's outputs with expected values.
    task check_signals;
        input [100:0] test_name;
        input expected_RegDst;
        input expected_ALUSrc;
        input expected_MemtoReg;
        input expected_RegWrite;
        input expected_MemWrite;
        input expected_Branch;
        input expected_Jump;
        input expected_shift;
        input [3:0] expected_ALUOp;

        reg has_failed;

        begin
            #1; // Wait a moment for signals to propagate
            has_failed = 1'b0;
            total_tests = total_tests + 1;

            $display("-----------------------------------------");
            $display("Checking: %s", test_name);

            // Compare each signal, ignoring 'X' (don't care) expected values
            if (expected_RegDst !== 1'bx && RegDst !== expected_RegDst) begin $display("  -> FAIL: RegDst is %b, expected %b", RegDst, expected_RegDst); has_failed = 1'b1; end
            if (expected_ALUSrc !== 1'bx && ALUSrc !== expected_ALUSrc) begin $display("  -> FAIL: ALUSrc is %b, expected %b", ALUSrc, expected_ALUSrc); has_failed = 1'b1; end
            if (expected_MemtoReg !== 1'bx && MemtoReg !== expected_MemtoReg) begin $display("  -> FAIL: MemtoReg is %b, expected %b", MemtoReg, expected_MemtoReg); has_failed = 1'b1; end
            if (expected_RegWrite !== 1'bx && RegWrite !== expected_RegWrite) begin $display("  -> FAIL: RegWrite is %b, expected %b", RegWrite, expected_RegWrite); has_failed = 1'b1; end
            if (expected_MemWrite !== 1'bx && MemWrite !== expected_MemWrite) begin $display("  -> FAIL: MemWrite is %b, expected %b", MemWrite, expected_MemWrite); has_failed = 1'b1; end
            if (expected_Branch !== 1'bx && Branch !== expected_Branch) begin $display("  -> FAIL: Branch is %b, expected %b", Branch, expected_Branch); has_failed = 1'b1; end
            if (expected_Jump !== 1'bx && Jump !== expected_Jump) begin $display("  -> FAIL: Jump is %b, expected %b", Jump, expected_Jump); has_failed = 1'b1; end
            if (expected_shift !== 1'bx && shift !== expected_shift) begin $display("  -> FAIL: shift is %b, expected %b", shift, expected_shift); has_failed = 1'b1; end
            if (expected_ALUOp !== 4'bxxxx && ALUOp !== expected_ALUOp) begin $display("  -> FAIL: ALUOp is %b, expected %b", ALUOp, expected_ALUOp); has_failed = 1'b1; end
            
            if (has_failed) begin
                tests_failed = tests_failed + 1;
                $display("Status: FAIL");
            end else begin
                tests_passed = tests_passed + 1;
                $display("Status: PASS");
            end
        end
    endtask


    // --- Test Sequence ---
    initial begin
        $display("Starting Control Unit Testbench...");
        $monitor("Time: %2t | Opcode=%b Func=%b | RegDst=%b ALUSrc=%b MemToReg=%b RegWrite=%b MemWrite=%b Branch=%b Jump=%b shift=%b ALUOp=%b",
                 $time, opcode, func, RegDst, ALUSrc, MemtoReg, RegWrite, MemWrite, Branch, Jump, shift, ALUOp);

        // --- R-Type Instructions ---
        opcode = 6'b000000;
        func = 6'b100000; #10; check_signals("R-Type ADD",    1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 4'b0000);
        func = 6'b100010; #10; check_signals("R-Type SUB",    1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 4'b0001);
        func = 6'b011000; #10; check_signals("R-Type MUL",    1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 4'b0010);
        func = 6'b100100; #10; check_signals("R-Type AND",    1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 4'b0011);
        func = 6'b100101; #10; check_signals("R-Type OR",     1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 4'b0100);
        func = 6'b100110; #10; check_signals("R-Type XOR",    1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 4'b0101);
        func = 6'b000000; #10; check_signals("R-Type SLL",    1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1, 4'b0110);
        func = 6'b000010; #10; check_signals("R-Type SRL",    1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1, 4'b0111);
        func = 6'b000011; #10; check_signals("R-Type SAL",    1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1, 4'b1000);
        func = 6'b000100; #10; check_signals("R-Type SAR",    1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1, 4'b1001);
        func = 6'b000101; #10; check_signals("R-Type ROL",    1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1, 4'b1010);
        func = 6'b000110; #10; check_signals("R-Type ROR",    1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1, 4'b1011);
        func = 6'b001000; #10; check_signals("R-Type ENC",    1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 4'b0101);
        func = 6'b001001; #10; check_signals("R-Type DEC",    1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 4'b0101);
        
        // --- I-Type, J-Type, and Illegal Instructions ---
        func = 6'bxxxxxx; // func is don't-care for these
        opcode = 6'b100011; #10; check_signals("I-Type LW",   1'b0, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 4'b0000);
        opcode = 6'b101011; #10; check_signals("I-Type SW",   1'bx, 1'b1, 1'bx, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 4'b0000);
        opcode = 6'b000100; #10; check_signals("I-Type BEQ",  1'bx, 1'b0, 1'bx, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 4'b0001);
        opcode = 6'b000010; #10; check_signals("J-Type JUMP", 1'bx, 1'bx, 1'bx, 1'b0, 1'b0, 1'b0, 1'b1, 1'bx, 4'bxxxx);
        
        // --- Test Illegal Opcode (should default to NOP) ---
        opcode = 6'b111111; #10; check_signals("Illegal Opcode (NOP)", 1'bx, 1'bx, 1'bx, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 4'bxxxx);
        
        // --- Final Summary ---
        $display("\n-----------------------------------------");
        $display("---           Test Summary            ---");
        $display("---     Total tests run: %0d            ---", total_tests);
        $display("---     Tests PASSED:    %0d            ---", tests_passed);
        $display("---     Tests FAILED:    %0d            ---", tests_failed);
        $display("-----------------------------------------\n");

        $finish;
    end

endmodule

