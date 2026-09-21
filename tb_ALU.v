module tb_ALU;

    // Clock is not needed (purely combinational ALU)
    reg [31:0] a, b;
    reg [4:0]  shamt;
    reg [3:0]  alu_ctrl;
    wire [31:0] result;
    wire zero;
    reg signed [31:0] signed_result;
    
    // Instantiate ALU
    ALU uut (
        .a(a),
        .b(b),
        .shamt(shamt),
        .alu_ctrl(alu_ctrl),
        .result(result),
        .zero(zero)
    );

    initial begin
        $display("\n=== ALU Testbench ===");

        // ADD
        a = 32'd10; b = 32'd5; alu_ctrl = 4'b0000; shamt = 0; #5;
        $display("ADD: %d + %d = %d", a, b, result);

        // SUB
        a = 32'd15; b = 32'd20; alu_ctrl = 4'b0001; #5;
        signed_result = $signed(result);
        $display("SUB: %d - %d = %d", a, b, signed_result);

        // MUL
        a = 32'd7; b = 32'd6; alu_ctrl = 4'b0010; #5;
        $display("MUL: %d * %d = %d", a, b, result);

        // Boundary value (0x7FFFFFFF + 1)
        a = 32'h7FFFFFFF; b = 32'd1; alu_ctrl = 4'b0000; #5;
        $display("Boundary ADD: 0x%h + 0x%h = 0x%h", 32'h7FFFFFFF, b, result);

        // SLL edge case: shift by 0
        b = 32'h0000_0001; shamt = 0; alu_ctrl = 4'b0110; #5;
        $display("SLL (shift=0): %h", result);

        // SLL edge case: shift by 31
        b = 32'h0000_0001; shamt = 31; alu_ctrl = 4'b0110; #5;
        $display("SLL (shift=31): %h", result);

        // SRL edge case: shift by 31
        b = 32'h8000_0000; shamt = 31; alu_ctrl = 4'b0111; #5;
        $display("SRL (shift=31): %h", result);

        // SAR edge case: negative number >> 31
        b = 32'h8000_0000; shamt = 31; alu_ctrl = 4'b1001; #5;
        $display("SAR (shift=31): %h", result);

        // ROL edge case: rotate by 0
        b = 32'h1234_ABCD; shamt = 0; alu_ctrl = 4'b1010; #5;
        $display("ROL (rotate=0): %h", result);

        // ROR edge case: rotate by 32
        b = 32'h1234_ABCD; shamt = 32; alu_ctrl = 4'b1011; #5;
        $display("ROR (rotate=32): %h", result);

        $display("=== Tests Done ===\n");
        $finish;
    end
endmodule