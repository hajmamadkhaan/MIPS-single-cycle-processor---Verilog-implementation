`timescale 1ns / 1ps

// SingleCycleMIPS project by Seyed Ehsan Mousavi & Mohammad Baghaei

module SingleCycleMIPS(
    input wire clk,
    input wire rst
    );
    
    
    wire [31:0] pc_curr, pc_next, pc_plus4;
    
    PC programCounter(
        .clk(clk),
        .rst(rst),
        .pc_next(pc_next),
        .pc_curr(pc_curr)
    );
    
    assign pc_plus4 = pc_curr + 4;
    
    // Instruction Memory
    wire [31:0] instr;

    instr_mem IMem(
        .addr(pc_curr),
        .instr(instr)
    );
    
    // Instruction Fields
    wire [5:0] opcode = instr[31:26];
    wire [4:0] rs     = instr[25:21];
    wire [4:0] rt     = instr[20:16];
    wire [4:0] rd     = instr[15:11];
    wire [4:0] shamt_field = instr[10:6];  // shift amount
    wire [5:0] funct  = instr[5:0];
    wire [15:0] imm   = instr[15:0];
    wire [25:0] jaddr = instr[25:0];
    
    // Control Unit
    wire RegDst, ALUSrc, MemtoReg, RegWrite, MemWrite, Branch, Jump;
    wire [3:0] alu_ctrl;
    wire shift_signal; // shift flag - sets if instruction is shift/rotate
    
    ControlUnit CU(
        .opcode(opcode),
        .func(funct),
        .shift(shift_signal),
        .RegDst(RegDst),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .MemtoReg(MemtoReg),
        .MemWrite(MemWrite),
        .Branch(Branch),
        .Jump(Jump),
        .ALUOp(alu_ctrl)
    );
    
    // Register File
    wire [31:0] rd1, rd2, wd;
    wire [4:0]  dest = (RegDst) ? rd : rt;
    
    regfile RF (
        .clk(clk),
        .rst(rst),
        .we(RegWrite),
        .rs(rs),
        .rt(rt),
        .rd(dest),
        .wd(wd),
        .rd1(rd1),
        .rd2(rd2)
    );
    
    // Sign Extend Immidiate
    wire [31:0] imm_ext;
    
    signExtend SE (
        .dataIn(imm),
        .dataOut(imm_ext)
    );
    
    // ALU
    wire [31:0] alu_in2, alu_result;
    wire alu_zero;
    
    assign alu_in2 = (ALUSrc) ? imm_ext : rd2;
    
    ALU alu_inst (
        .a(rd1),
        .b(alu_in2),
        .shamt(shamt_field),
        .alu_ctrl(alu_ctrl),
        .result(alu_result),
        .zero(alu_zero)
    );
    
    // Data Memory
    wire [31:0] dmem_out;
    
    data_mem DMEM (
    .clk(clk),
    .we(MemWrite),
    .addr(alu_result),
    .writeData(rd2),
    .readData(dmem_out)
    );

    
    // WriteBack MUX
    assign wd = (MemtoReg) ? dmem_out : alu_result;
    
    // Branch & Jump (PC Update)
    wire [31:0] imm_shifted;
    
    ShiftByTwo sh2(
        .dataIn(imm_ext),
        .dataOut(imm_shifted)
    );
    
    // Branch target address
    wire [31:0] branch_addr;
    assign branch_addr = pc_plus4 + imm_shifted;
    
    // Jump target address
    wire [31:0] jump_addr;
    assign jump_addr = {pc_plus4[31:28], jaddr, 2'b00};

    // PC selection with 2:1 Muxes
    wire [31:0] pc_branch_sel;
    // First mux: choose between PC+4 and branch
    Mux32 branch_mux (
        .i0(pc_plus4),
        .i1(branch_addr),
        .Sel(Branch & alu_zero),
        .O(pc_branch_sel)
    );
    // Second mux: choose between branch-selected result and jump
    Mux32 jump_mux (
        .i0(pc_branch_sel),
        .i1(jump_addr),
        .Sel(Jump),
        .O(pc_next)
    );
    
    
//    wire [31:0] branch_addr = pc_plus4 + ({{14{imm[15]}}, imm, 2'b00});
//    wire [31:0] jump_addr   = {pc_plus4[31:28], jaddr, 2'b00};

//    assign pc_next =
//        Jump              ? jump_addr :
//        (Branch & alu_zero) ? branch_addr :
//        pc_plus4;
    
endmodule
