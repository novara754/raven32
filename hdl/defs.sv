`default_nettype none

package defs;

enum logic [6:0] {
    OPCODE_LOAD = 7'b0000011,
    OPCODE_STORE = 7'b0100011,
    OPCODE_BRANCH = 7'b1100011,
    OPCODE_JALR = 7'b1100111,
    OPCODE_JAL = 7'b1101111,
    OPCODE_OP_IMM = 7'b0010011,
    OPCODE_OP = 7'b0110011,
    OPCODE_SYSTEM = 7'b1110011,
    OPCODE_AUIPC = 7'b0010111,
    OPCODE_LUI = 7'b0110111
} t_opcode;

enum logic [3:0] {
    ALU_ADD,
    ALU_SUB,
    ALU_XOR,
    ALU_OR,
    ALU_AND,
    ALU_SLT,
    ALU_SLTU,
    ALU_SLL,
    ALU_SRL,
    ALU_SRA
} t_alu_op;

enum logic [2:0] {
    BRANCH_NEVER = 3'b011,
    BRANCH_ALWAYS = 3'b010,
    BRANCH_EQ = 3'b000,
    BRANCH_NE = 3'b001,
    BRANCH_LT = 3'b100,
    BRANCH_GE = 3'b101,
    BRANCH_LTU = 3'b110,
    BRANCH_GEU = 3'b111
} t_branch_cond;

endpackage
