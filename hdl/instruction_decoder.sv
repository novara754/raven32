`default_nettype none

import defs::*;

module instruction_decoder (
    input [31:0] i_inst,

    output logic [6:0] o_opcode,
    output logic [2:0] o_funct3,
    output logic [6:0] o_funct7,

    output logic [31:0] o_imm,

    output logic [4:0] o_rd,
    output logic [4:0] o_rs1,
    output logic [4:0] o_rs2
);

    assign o_opcode = i_inst[6:0];
    assign o_funct3 = i_inst[14:12];
    assign o_funct7 = i_inst[31:25];

    assign o_rd = i_inst[11:7];
    assign o_rs1 = i_inst[19:15];
    assign o_rs2 = i_inst[24:20];

    logic [31:0] imm_i;
    assign imm_i = {{21{i_inst[31]}}, i_inst[30:20]};

    always_comb begin
        case (o_opcode)
            OPCODE_STORE: o_imm = 0;
            OPCODE_BRANCH: o_imm = 0;
            OPCODE_JALR: o_imm = 0;
            OPCODE_JAL: o_imm = 0;
            OPCODE_OP_IMM: o_imm = imm_i;
            OPCODE_OP: o_imm = 0;
            OPCODE_SYSTEM: o_imm = 0;
            OPCODE_AUIPC: o_imm = 0;
            OPCODE_LUI: o_imm = 0;
            default: o_imm = 0;
        endcase
    end

endmodule
