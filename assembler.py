# Custom MIPS Assembler for the given processor implementation
# Supports the instructions from the ControlUnit: add, sub, mul, and, or, xor, sll, srl, sal, sar, rol, ror, enc, dec,
# addi, subi, lw, sw, beq, j
# Handles labels for branches and jumps
# Outputs in format: dut.IMem.mem[index] = 32'hXXXXXXX;  // assembly instruction # comment
# Usage: python assembler.py input.asm > output.v

import sys
import re

# Register name to number mapping (standard MIPS)
REG_MAP = {
    '$zero': 0, '$0': 0,
    '$at': 1, '$1': 1,
    '$v0': 2, '$v1': 3,
    '$a0': 4, '$a1': 5, '$a2': 6, '$a3': 7,
    '$t0': 8, '$t1': 9, '$t2': 10, '$t3': 11, '$t4': 12, '$t5': 13, '$t6': 14, '$t7': 15,
    '$s0': 16, '$s1': 17, '$s2': 18, '$s3': 19, '$s4': 20, '$s5': 21, '$s6': 22, '$s7': 23,
    '$t8': 24, '$t9': 25,
    '$k0': 26, '$k1': 27,
    '$gp': 28,
    '$sp': 29,
    '$fp': 30,
    '$ra': 31
}

# Opcode mapping
OPCODES = {
    'r-type': 0b000000,  # R-type
    'addi': 0b000001,
    'subi': 0b000011,
    'lw': 0b100011,
    'sw': 0b101011,
    'beq': 0b000100,
    'j': 0b000010
}

# Function codes for R-type
FUNC_CODES = {
    'add': 0b100000,
    'sub': 0b100010,
    'mul': 0b011000,
    'and': 0b100100,
    'or': 0b100101,
    'xor': 0b100110,
    'sll': 0b000000,
    'srl': 0b000010,
    'sal': 0b000011,  # Assuming sal is sll, as arithmetic left is same as logical
    'sar': 0b000100,  # Wait, in code it's 000100 for sar, but standard sra is 000011
    'rol': 0b000101,
    'ror': 0b000110,
    'enc': 0b001000,  # XOR
    'dec': 0b001001   # XOR
}

# Check if a string is a valid register
def is_register(token):
    return token in REG_MAP

# Parse immediate value (decimal, hex, binary)
def parse_imm(imm_str):
    imm_str = imm_str.strip()
    if imm_str.startswith('0x'):
        return int(imm_str[2:], 16)
    elif imm_str.startswith('0b'):
        return int(imm_str[2:], 2)
    else:
        return int(imm_str)

# Assemble R-type: mnemonic $rd, $rs, $rt  or for shifts: mnemonic $rd, $rt, shamt
def assemble_r_type(mnemonic, parts, pc, labels):
    func = FUNC_CODES.get(mnemonic)
    if func is None:
        raise ValueError(f"Unknown R-type instruction: {mnemonic}")
    
    if mnemonic in ['sll', 'srl', 'sal', 'sar', 'rol', 'ror']:  # Shift instructions
        if len(parts) != 3:
            raise ValueError(f"Invalid format for {mnemonic}: expected $rd, $rt, shamt")
        rd_str, rt_str, shamt_str = parts
        rs = 0  # rs is unused for shifts
        rt = REG_MAP[rt_str]
        rd = REG_MAP[rd_str]
        shamt = parse_imm(shamt_str)
        if shamt < 0 or shamt > 31:
            raise ValueError(f"Shamt out of range: {shamt}")
    else:  # Regular R-type
        if len(parts) != 3:
            raise ValueError(f"Invalid format for {mnemonic}: expected $rd, $rs, $rt")
        rd_str, rs_str, rt_str = parts
        rs = REG_MAP[rs_str]
        rt = REG_MAP[rt_str]
        rd = REG_MAP[rd_str]
        shamt = 0  # No shamt for non-shifts
    
    opcode = OPCODES['r-type']
    instr = (opcode << 26) | (rs << 21) | (rt << 16) | (rd << 11) | (shamt << 6) | func
    return instr

# Assemble I-type: mnemonic $rt, $rs, imm  or for lw/sw: $rt, imm($rs)
def assemble_i_type(mnemonic, parts, pc, labels):
    opcode = OPCODES.get(mnemonic)
    if opcode is None:
        raise ValueError(f"Unknown I-type instruction: {mnemonic}")
    
    if mnemonic in ['lw', 'sw']:
        if len(parts) != 2:
            raise ValueError(f"Invalid format for {mnemonic}: expected $rt, imm($rs)")
        rt_str, offset_rs = parts
        rt = REG_MAP[rt_str]
        match = re.match(r'(-?\d+)\((.+)\)', offset_rs)
        if not match:
            raise ValueError(f"Invalid address format: {offset_rs}")
        imm = parse_imm(match.group(1))
        rs = REG_MAP[match.group(2)]
    else:  # addi, subi, beq
        if len(parts) != 3:
            raise ValueError(f"Invalid format for {mnemonic}: expected $rt, $rs, imm/label")
        rt_str, rs_str, imm_str = parts
        rs = REG_MAP[rs_str]
        rt = REG_MAP[rt_str]
        if mnemonic == 'beq':
            # imm is offset, calculate from label
            if imm_str in labels:
                target_pc = labels[imm_str]
                imm = (target_pc - (pc + 1))  # Offset in words, since PC+4 already
            else:
                imm = parse_imm(imm_str)
        else:
            imm = parse_imm(imm_str)
    
    if imm < -32768 or imm > 32767:
        raise ValueError(f"Immediate out of range: {imm}")
    imm = imm & 0xFFFF  # Sign-extend in hardware, but store as 16-bit
    
    instr = (opcode << 26) | (rs << 21) | (rt << 16) | imm
    return instr

# Assemble J-type: j label
def assemble_j_type(mnemonic, parts, pc, labels):
    if mnemonic != 'j':
        raise ValueError(f"Unknown J-type instruction: {mnemonic}")
    if len(parts) != 1:
        raise ValueError("Invalid format for j: expected label")
    label = parts[0]
    if label not in labels:
        raise ValueError(f"Unknown label: {label}")
    target = labels[label]
    jaddr = target << 2  # Byte address, but since mem is word-addressed, but in instr it's /4
    jaddr = jaddr >> 2  # 26-bit address
    if jaddr > 0x3FFFFFF:
        raise ValueError(f"Jump target out of range: {target}")
    
    opcode = OPCODES['j']
    instr = (opcode << 26) | jaddr
    return instr

# Main assembler function
def assemble(asm_lines):
    # First pass: collect labels and count instructions
    labels = {}
    pc = 0
    cleaned_lines = []
    for line in asm_lines:
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        # Remove comments
        if '#' in line:
            line = line[:line.index('#')].strip()
        # Check for label
        if ':' in line:
            label, instr = line.split(':', 1)
            labels[label.strip()] = pc
            if instr.strip():
                cleaned_lines.append(instr.strip())
                pc += 1
        else:
            cleaned_lines.append(line)
            pc += 1
    
    # Second pass: assemble instructions
    instructions = []
    pc = 0
    for line in cleaned_lines:
        tokens = re.split(r'\s*,\s*|\s+', line)
        mnemonic = tokens[0].lower()
        parts = [t.strip() for t in tokens[1:] if t.strip()]
        
        if mnemonic in FUNC_CODES:  # R-type
            instr = assemble_r_type(mnemonic, parts, pc, labels)
        elif mnemonic in ['addi', 'subi', 'lw', 'sw', 'beq']:  # I-type
            instr = assemble_i_type(mnemonic, parts, pc, labels)
        elif mnemonic == 'j':  # J-type
            instr = assemble_j_type(mnemonic, parts, pc, labels)
        else:
            raise ValueError(f"Unknown instruction: {mnemonic}")
        
        instructions.append((instr, line))
        pc += 1
    
    return instructions

# Output in Verilog format
def output_verilog(instructions):
    for idx, (instr, asm) in enumerate(instructions):
        hex_str = f"{instr:08X}"
        print(f"uut.IMem.mem[{idx}] = 32'h{hex_str};  // {asm}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python assembler.py input.asm")
        sys.exit(1)
    
    with open(sys.argv[1], 'r') as f:
        asm_lines = f.readlines()
    
    try:
        instructions = assemble(asm_lines)
        output_verilog(instructions)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)