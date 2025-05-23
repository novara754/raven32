`default_nettype none

import defs::*;

module control_unit (
    input [6:0] i_opcode,
    input [2:0] i_funct3,
    input [6:0] i_funct7,

    output logic [3:0] o_alu_op,
    output logic o_reg_wen,
    output logic o_mem_wen,
    // 0 = use rs1 as a
    // 1 = use pc as a
    output logic o_alu_a_src,
    // 0 = use rs2 as b
    // 1 = use imm as b
    output logic o_alu_b_src,
    // 00 = write alu res to rd
    // 01 = write mem data to rd
    // 10 = write pc to rd
    output logic [1:0] o_res_src,

    // 0 = pc + imm
    // 1 = rs1 + imm
    output logic o_branch_addr_src,
    output logic [2:0] o_branch_cond
);

    always_comb begin
        o_branch_cond = BRANCH_NEVER;
        o_alu_op = 0;
        o_reg_wen = 0;
        o_mem_wen = 0;
        o_alu_a_src = 0;
        o_alu_b_src = 0;
        o_res_src = 0;

        case (i_funct3)
            3'b000: o_alu_op = i_funct7[5] ? ALU_SUB : ALU_ADD;
            3'b001: o_alu_op = ALU_SLL;
            3'b101: o_alu_op = i_funct7[5] ? ALU_SRA : ALU_SRL;
            3'b010: o_alu_op = ALU_SLT;
            3'b011: o_alu_op = ALU_SLTU;
            3'b100: o_alu_op = ALU_XOR;
            3'b110: o_alu_op = ALU_OR;
            3'b111: o_alu_op = ALU_AND;
        endcase

        case (i_opcode)
            OPCODE_LOAD: begin
                o_alu_op = ALU_ADD;
                o_reg_wen = 1;
                o_alu_b_src = 1;
                o_res_src = 2'b01;
            end
            OPCODE_STORE: begin
                o_alu_op = ALU_ADD;
                o_mem_wen = 1;
                o_alu_b_src = 1;
            end
            OPCODE_BRANCH: begin
                o_branch_cond = i_funct3;
            end
            OPCODE_JALR: begin
                o_alu_op = ALU_ADD;
                o_branch_cond = BRANCH_ALWAYS;
                o_reg_wen = 1;
                o_res_src = 2'b10;
            end
            OPCODE_JAL: begin
                o_branch_cond = BRANCH_ALWAYS;
                o_reg_wen = 1;
                o_res_src = 2'b10;
            end
            OPCODE_OP_IMM: begin
                o_reg_wen = 1;
                o_alu_b_src = 1;
                o_res_src = 2'b00;
            end
            OPCODE_OP: begin
                o_reg_wen = 1;
                o_alu_b_src = 0;
                o_res_src = 2'b00;
            end
            OPCODE_SYSTEM: begin
                // TODO
            end
            OPCODE_AUIPC: begin
                o_alu_op = ALU_ADD;
                o_reg_wen = 1;
                o_alu_a_src = 1;
                o_alu_b_src = 1;
                o_res_src = 0;
            end
            OPCODE_LUI: begin
                o_alu_op = ALU_PASSTHROUGH_B;
                o_reg_wen = 1;
                o_alu_b_src = 1;
                o_res_src = 0;
            end
            default: begin end
        endcase
    end

endmodule
