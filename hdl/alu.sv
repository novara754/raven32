`default_nettype none

import defs::*;

module alu (
    input [3:0] i_op,
    input [31:0] i_a,
    input [31:0] i_b,
    output logic [31:0] o_res
);

    always_comb begin
        case (i_op)
            ALU_ADD: o_res = i_a + i_b;
            ALU_SUB: o_res = i_a - i_b;
            ALU_XOR: o_res = i_a ^ i_b;
            ALU_OR: o_res = i_a | i_b;
            ALU_AND: o_res = i_a & i_b;
            ALU_SLT: o_res = {31'b0, $signed(i_a) < $signed(i_b)};
            ALU_SLTU: o_res = {31'b0, i_a < i_b};
            ALU_SLL: o_res = i_a << i_b;
            ALU_SRL: o_res = i_a >> i_b;
            ALU_SRA: o_res = i_a >>> i_b;
            default: o_res = 0;
        endcase
    end

endmodule
