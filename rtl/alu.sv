`default_nettype none

import defs::*;

module alu (
    input wire [3:0] i_op,
    input wire [31:0] i_a,
    input wire [31:0] i_b,
    output logic [31:0] o_res,

    output logic o_eq,
    output logic o_lt,
    output logic o_ltu
);

    always_comb begin
        case (i_op)
            ALU_PASSTHROUGH_B: o_res = i_b;
            ALU_ADD: o_res = i_a + i_b;
            ALU_SUB: o_res = i_a - i_b;
            ALU_XOR: o_res = i_a ^ i_b;
            ALU_OR: o_res = i_a | i_b;
            ALU_AND: o_res = i_a & i_b;
            ALU_SLT: o_res = {31'b0, $signed(i_a) < $signed(i_b)};
            ALU_SLTU: o_res = {31'b0, i_a < i_b};
            ALU_SLL: o_res = i_a << {27'b0, i_b[4:0]};
            ALU_SRL: o_res = i_a >> {27'b0, i_b[4:0]};
            ALU_SRA: o_res = $signed(i_a) >>> {27'b0, i_b[4:0]};
            default: o_res = 0;
        endcase
    end

    assign o_eq = i_a == i_b;
    assign o_lt = $signed(i_a) < $signed(i_b);
    assign o_ltu = i_a < i_b;

endmodule
