# Python script to generate Verilog testbench for MIPS inner product
# User inputs vectors A and B (4 integers each), and BASE_A, BASE_B (decimal byte addresses, multiples of 4), script outputs the testbench code

def main():
    # Prompt for vector A
    a_input = input("Enter 4 integers for vector A separated by spaces (e.g., 1 2 3 4): ")
    a_values = list(map(int, a_input.strip().split()))
    if len(a_values) != 4:
        print("Error: Please enter exactly 4 integers for A.")
        return

    # Prompt for vector B
    b_input = input("Enter 4 integers for vector B separated by spaces (e.g., 5 6 7 8): ")
    b_values = list(map(int, b_input.strip().split()))
    if len(b_values) != 4:
        print("Error: Please enter exactly 4 integers for B.")
        return

    # Prompt for BASE_A (decimal)
    base_a_input = input("Enter BASE_A as decimal byte address (e.g., 0, must be multiple of 4 and small enough for memory): ")
    try:
        base_a = int(base_a_input)
        if base_a % 4 != 0 or base_a < 0:
            print("Error: BASE_A must be a non-negative multiple of 4.")
            return
    except ValueError:
        print("Error: Invalid input for BASE_A.")
        return

    # Prompt for BASE_B (decimal)
    base_b_input = input("Enter BASE_B as decimal byte address (e.g., 32, must be multiple of 4 and small enough for memory): ")
    try:
        base_b = int(base_b_input)
        if base_b % 4 != 0 or base_b < 0:
            print("Error: BASE_B must be a non-negative multiple of 4.")
            return
    except ValueError:
        print("Error: Invalid input for BASE_B.")
        return

    # Check for potential overlap or out-of-bounds (memory up to index 127)
    if base_a + 12 > 127 or base_b + 12 > 127:
        print("Warning: Bases may exceed memory size (max index 127), simulation may fail.")

    # Calculate expected dot product
    expected = sum(a * b for a, b in zip(a_values, b_values))

    # Generate machine code for addi instructions
    instr_a = (1 << 26) | (0 << 21) | (16 << 16) | (base_a & 0xFFFF)
    instr_b = (1 << 26) | (0 << 21) | (17 << 16) | (base_b & 0xFFFF)

    # Generate the testbench code as a string
    testbench = f"""`timescale 1ns / 1ps

module tb_SingleCycleMIPS;

    reg clk;
    reg rst;

    SingleCycleMIPS dut (
        .clk(clk),
        .rst(rst)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10ns period
    end

    // Reset sequence
    initial begin
        rst = 1;
        #15 rst = 0;  // Assert reset for a bit longer than one cycle
    end

    // Initialize Instruction Memory with machine code for inner product
    initial begin
        // Program: Computes dot product of A and B (length 4)
        // BASE_A = {base_a} (0x{base_a:08x}), BASE_B = {base_b} (0x{base_b:08x})
        // Vectors pre-loaded in Data Memory via testbench
        dut.IMem.mem[0]  = 32'h{instr_a:08x};  // addi $s0, $zero, {base_a}     # BASE_A
        dut.IMem.mem[1]  = 32'h{instr_b:08x};  // addi $s1, $zero, {base_b}     # BASE_B
        dut.IMem.mem[2]  = 32'h04120004;  // addi $s2, $zero, 4     # n=4
        dut.IMem.mem[3]  = 32'h04130000;  // addi $s3, $zero, 0     # i=0
        dut.IMem.mem[4]  = 32'h04160000;  // addi $s6, $zero, 0     # sum=0
        dut.IMem.mem[5]  = 32'h06680000;  // addi $t0, $s3, 0       # $t0 = i
        dut.IMem.mem[6]  = 32'h01084020;  // add  $t0, $t0, $t0     # *2
        dut.IMem.mem[7]  = 32'h01084020;  // add  $t0, $t0, $t0     # *4 offset = i*4
        dut.IMem.mem[8]  = 32'h02084820;  // add  $t1, $s0, $t0     # addrA = BASE_A + offset
        dut.IMem.mem[9]  = 32'h8d340000;  // lw   $s4, 0($t1)       # load A[i]
        dut.IMem.mem[10] = 32'h02285020;  // add  $t2, $s1, $t0     # addrB = BASE_B + offset
        dut.IMem.mem[11] = 32'h8d550000;  // lw   $s5, 0($t2)       # load B[i]
        dut.IMem.mem[12] = 32'h02955818;  // mul  $t3, $s4, $s5     # prod = A[i] * B[i]
        dut.IMem.mem[13] = 32'h02cbb020;  // add  $s6, $s6, $t3     # sum += prod
        dut.IMem.mem[14] = 32'h06730001;  // addi $s3, $s3, 1       # i++
        dut.IMem.mem[15] = 32'h12720001;  // beq  $s3, $s2, END     # if i==4, goto END
        dut.IMem.mem[16] = 32'h08000005;  // j    LOOP               # jump back to LOOP (word 5)
        dut.IMem.mem[17] = 32'h08000011;  // END: j END             # infinite loop
    end

    // Initialize Data Memory with user-provided vectors
    // A = [{a_values[0]}, {a_values[1]}, {a_values[2]}, {a_values[3]}] at addresses {base_a}, {base_a+4}, {base_a+8}, {base_a+12}
    // B = [{b_values[0]}, {b_values[1]}, {b_values[2]}, {b_values[3]}] at addresses {base_b}, {base_b+4}, {base_b+8}, {base_b+12}
    // Expected inner product: {expected}
    initial begin
        dut.DMEM.memData[{base_a}]  = 32'd{a_values[0]};
        dut.DMEM.memData[{base_a + 4}]  = 32'd{a_values[1]};
        dut.DMEM.memData[{base_a + 8}]  = 32'd{a_values[2]};
        dut.DMEM.memData[{base_a + 12}] = 32'd{a_values[3]};
        dut.DMEM.memData[{base_b}] = 32'd{b_values[0]};
        dut.DMEM.memData[{base_b + 4}] = 32'd{b_values[1]};
        dut.DMEM.memData[{base_b + 8}] = 32'd{b_values[2]};
        dut.DMEM.memData[{base_b + 12}] = 32'd{b_values[3]};
    end

    // Helpful displays for debugging: print on each clock cycle after reset
    always @(posedge clk) begin
        if (~rst) begin
            $display("Time=%0t ns | PC=0x%08h | Instr=0x%08h | i($s3)=%0d | sum($s6)=%0d | ALU_result=0x%08h | RegWrite=%b | MemWrite=%b",
                     $time/10, dut.pc_curr, dut.instr, dut.RF.regs[19], dut.RF.regs[22], dut.alu_result, dut.RegWrite, dut.MemWrite);
        end
    end

    // Run simulation for sufficient cycles (about 60 cycles to complete 4 iterations + init)
    initial begin
        #600;  // 60 cycles (10ns each)
        $display("Simulation ended. Final inner product in $s6: %0d (expected {expected})", dut.RF.regs[22]);
        $finish;
    end

endmodule
"""

    # Output the generated testbench code
    print(testbench)

if __name__ == "__main__":
    main()