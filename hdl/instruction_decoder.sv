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
    output logic [4:0] o_rs2,

    output logic o_ebreak
);

    assign o_opcode = i_inst[6:0];
    assign o_funct3 = i_inst[14:12];
    assign o_funct7 = i_inst[31:25];

    assign o_rd = i_inst[11:7];
    assign o_rs1 = i_inst[19:15];
    assign o_rs2 = i_inst[24:20];

    logic [31:0] imm_i, imm_s, imm_b, imm_u, imm_j;
    assign imm_i = {{21{i_inst[31]}}, i_inst[30:20]};
    assign imm_s = {{21{i_inst[31]}}, i_inst[30:25], i_inst[11:8], i_inst[7]};
    assign imm_b = {{20{i_inst[31]}}, i_inst[7], i_inst[30:25], i_inst[11:8], 1'b0};
    assign imm_u = {i_inst[31:12], 12'b0};
    assign imm_j = {{12{i_inst[31]}}, i_inst[19:12], i_inst[20], i_inst[30:21], 1'b0};

    always_comb begin
        case (o_opcode)
            OPCODE_LOAD: o_imm = imm_i;
            OPCODE_STORE: o_imm = imm_s;
            OPCODE_BRANCH: o_imm = imm_b;
            OPCODE_JALR: o_imm = imm_i;
            OPCODE_JAL: o_imm = imm_j;
            OPCODE_OP_IMM: o_imm = imm_i;
            OPCODE_AUIPC: o_imm = imm_u;
            OPCODE_LUI: o_imm = imm_u;
            default: o_imm = 0;
        endcase
    end

    assign o_ebreak = i_inst == 32'b00000000000100000000000001110011;

endmodule
