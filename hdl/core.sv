`default_nettype none

module core #(
    parameter MEM_DEPTH = 1024
) (
    input i_clk,
    input i_rst,

    output logic o_ebreak
);
    logic stall_f;
    logic stall_d;
    logic flush_d;
    logic flush_e;

    hazard_unit hazard_unit_inst (
        .i_e_rs1(e_rs1),
        .i_e_rs2(e_rs2),
        .i_m_rd(m_rd),
        .i_m_reg_wen(m_reg_wen),
        .i_w_rd(w_rd),
        .i_w_reg_wen(w_reg_wen),
        .o_rs1_fwd(e_rs1_fwd),
        .o_rs2_fwd(e_rs2_fwd),

        .i_e_jmp_en(e_jmp_en),
        .i_e_has_load(e_res_src == 2'b01),
        .i_e_rd(e_rd),
        .i_d_rs1(d_rs1),
        .i_d_rs2(d_rs2),

        .o_stall_f(stall_f),
        .o_stall_d(stall_d),
        .o_flush_d(flush_d),
        .o_flush_e(flush_e)
    );

    /* -- FETCH -- */

    logic [31:0] f_pc;
    logic [31:0] f_pc_plus_4;
    logic [31:0] f_inst;

    program_counter pc (
        .i_clk,
        .i_rst,
        .i_en(!stall_f),
        .i_jmp_en(e_jmp_en),
        .i_jmp_addr(e_jmp_addr),
        .o_pc(f_pc),
        .o_pc_plus_4(f_pc_plus_4)
    );

    word_memory #(
        .DEPTH(MEM_DEPTH)
    ) inst_mem (
        .i_clk,
        .i_rst(1'b0),
        .i_wen(1'b0),
        .i_waddr(32'b0),
        .i_wdata(32'b0),
        .i_raddr(f_pc),
        .o_rdata(f_inst)
    );

    always_ff @(posedge i_clk) begin
        if (i_rst || flush_d) begin
            d_pc <= 0;
            d_pc_plus_4 <= 0;
            d_inst <= 0;
        end
        else if (stall_d) begin
            d_pc <= d_pc;
            d_pc_plus_4 <= d_pc_plus_4;
            d_inst <= d_inst;
        end
        else begin
            d_pc <= f_pc;
            d_pc_plus_4 <= f_pc_plus_4;
            d_inst <= f_inst;
        end
    end

    /* -- DECODE -- */

    logic [31:0] d_pc;
    logic [31:0] d_pc_plus_4;
    logic [31:0] d_inst;

    logic [6:0] d_opcode;
    logic [2:0] d_funct3;
    logic [6:0] d_funct7;
    logic [31:0] d_imm;
    logic [4:0] d_rd;
    logic [4:0] d_rs1;
    logic [4:0] d_rs2;
    logic d_ebreak;

    logic [3:0] d_alu_op;
    logic d_reg_wen;
    logic d_mem_rwidth;
    logic d_mem_wen;
    logic d_alu_a_src;
    logic d_alu_b_src;
    logic [1:0] d_res_src;
    logic d_branch_addr_src;
    logic [2:0] d_branch_cond;

    logic [31:0] d_rs1_data;
    logic [31:0] d_rs2_data;

    instruction_decoder inst_decoder (
        .i_inst(d_inst),
        .o_opcode(d_opcode),
        .o_funct3(d_funct3),
        .o_funct7(d_funct7),
        .o_imm(d_imm),
        .o_rd(d_rd),
        .o_rs1(d_rs1),
        .o_rs2(d_rs2),
        .o_ebreak(d_ebreak)
    );

    control_unit ctrl_unit (
        .i_opcode(d_opcode),
        .i_funct3(d_funct3),
        .i_funct7(d_funct7),
        .o_alu_op(d_alu_op),
        .o_reg_wen(d_reg_wen),
        .o_mem_rwidth(d_mem_rwidth),
        .o_mem_wen(d_mem_wen),
        .o_alu_a_src(d_alu_a_src),
        .o_alu_b_src(d_alu_b_src),
        .o_res_src(d_res_src),
        .o_branch_addr_src(d_branch_addr_src),
        .o_branch_cond(d_branch_cond)
    );

    register_file regs (
        .i_clk,
        .i_rst,
        .i_wen(w_reg_wen),
        .i_waddr(w_rd),
        .i_wdata(w_result),
        .i_raddr1(d_rs1),
        .i_raddr2(d_rs2),
        .o_rdata1(d_rs1_data),
        .o_rdata2(d_rs2_data)
    );

    always_ff @(posedge i_clk) begin
        if (i_rst || flush_e) begin
            e_pc <= 0;
            e_pc_plus_4 <= d_pc_plus_4;
            e_alu_op <= 0;
            e_reg_wen <= 0;
            e_mem_rwidth <= 0;
            e_mem_wen <= 0;
            e_alu_a_src <= 0;
            e_alu_b_src <= 0;
            e_res_src <= 0;
            e_branch_addr_src <= 0;
            e_branch_cond <= BRANCH_NEVER;
            e_rs1 <= 0;
            e_rs2 <= 0;
            e_ebreak <= 0;
            e_rd <= 0;
            e_imm <= 0;
            e_rs1_data <= 0;
            e_rs2_data <= 0;
        end
        else begin
            e_pc <= d_pc;
            e_pc_plus_4 <= d_pc_plus_4;
            e_alu_op <= d_alu_op;
            e_reg_wen <= d_reg_wen;
            e_mem_rwidth <= d_mem_rwidth;
            e_mem_wen <= d_mem_wen;
            e_alu_a_src <= d_alu_a_src;
            e_alu_b_src <= d_alu_b_src;
            e_res_src <= d_res_src;
            e_branch_addr_src <= d_branch_addr_src;
            e_branch_cond <= d_branch_cond;
            e_rs1 <= d_rs1;
            e_rs2 <= d_rs2;
            e_ebreak <= d_ebreak;
            e_rd <= d_rd;
            e_imm <= d_imm;
            e_rs1_data <= d_rs1_data;
            e_rs2_data <= d_rs2_data;
        end
    end

    /* -- EXECUTE -- */

    logic e_stall;
    logic e_jmp_flush;

    logic [31:0] e_pc;
    logic [31:0] e_pc_plus_4;

    logic [3:0] e_alu_op;
    logic e_reg_wen;
    logic e_mem_rwidth;
    logic e_mem_wen;
    logic e_alu_a_src;
    logic e_alu_b_src;
    logic [1:0] e_res_src;
    logic e_branch_addr_src;
    logic [2:0] e_branch_cond;
    logic [4:0] e_rd;
    logic [4:0] e_rs1;
    logic [4:0] e_rs2;
    logic e_ebreak;
    logic [31:0] e_imm;
    logic [31:0] e_rs1_data;
    logic [31:0] e_rs2_data;

    logic [1:0] e_rs1_fwd;
    logic [1:0] e_rs2_fwd;
    logic [31:0] e_real_rs1_data;
    logic [31:0] e_real_rs2_data;

    logic [31:0] e_alu_a;
    logic [31:0] e_alu_b;
    logic [31:0] e_alu_res;
    logic e_alu_eq;
    logic e_alu_lt;
    logic e_alu_ltu;

    logic e_jmp_en;
    logic [31:0] e_jmp_addr;

    always_comb begin
        case (e_rs1_fwd)
            2'b01: e_real_rs1_data = m_alu_res;
            2'b10: e_real_rs1_data = w_result;
            default: e_real_rs1_data = e_rs1_data;
        endcase

        case (e_rs2_fwd)
            2'b01: e_real_rs2_data = m_alu_res;
            2'b10: e_real_rs2_data = w_result;
            default: e_real_rs2_data = e_rs2_data;
        endcase
    end

    assign e_alu_a = e_alu_a_src ? e_pc : e_real_rs1_data;
    assign e_alu_b = e_alu_b_src ? e_imm : e_real_rs2_data;

    alu alu_inst (
        .i_op(e_alu_op),
        .i_a(e_alu_a),
        .i_b(e_alu_b),
        .o_res(e_alu_res),
        .o_eq(e_alu_eq),
        .o_lt(e_alu_lt),
        .o_ltu(e_alu_ltu)
    );

    always_comb begin
        case (e_branch_cond)
            BRANCH_NEVER: e_jmp_en = 0;
            BRANCH_ALWAYS: e_jmp_en = 1;
            BRANCH_EQ: e_jmp_en = e_alu_eq;
            BRANCH_NE: e_jmp_en = !e_alu_eq;
            BRANCH_LT: e_jmp_en = e_alu_lt;
            BRANCH_GE: e_jmp_en = !e_alu_lt;
            BRANCH_LTU: e_jmp_en = e_alu_ltu;
            BRANCH_GEU: e_jmp_en = !e_alu_ltu;
        endcase
    end

    assign e_jmp_addr = e_branch_addr_src ? e_alu_res : (e_pc + e_imm);

    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            m_pc_plus_4 <= 0;
            m_reg_wen <= 0;
            m_mem_wen <= 0;
            m_mem_rwidth <= 0;
            m_res_src <= 0;
            m_rd <= 0;
            m_alu_res <= 0;
            m_mem_wdata <= 0;
            m_ebreak <= 0;
        end
        else begin
            m_pc_plus_4 <= e_pc_plus_4;
            m_reg_wen <= e_reg_wen;
            m_mem_rwidth <= e_mem_rwidth;
            m_mem_wen <= e_mem_wen;
            m_res_src <= e_res_src;
            m_rd <= e_rd;
            m_alu_res <= e_alu_res;
            m_mem_wdata <= e_real_rs2_data;
            m_ebreak <= e_ebreak;
        end
    end

    /* -- MEMORY -- */

    logic [31:0] m_pc_plus_4;
    logic m_reg_wen;
    logic m_mem_wen;
    logic m_mem_rwidth;
    logic [1:0] m_res_src;
    logic [4:0] m_rd;
    logic [31:0] m_alu_res;
    logic [31:0] m_mem_wdata;
    logic m_ebreak;

    logic [31:0] m_mem_rdata;

    ram #(
        .DEPTH(MEM_DEPTH)
    ) data_mem (
        .i_clk,
        .i_rst(1'b0),
        .i_wen(m_mem_wen),
        .i_waddr(m_alu_res),
        .i_wdata(m_mem_wdata),
        .i_raddr(m_alu_res),
        .i_rwidth(m_mem_rwidth),
        .o_rdata(m_mem_rdata)
    );

    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            w_reg_wen <= 0;
            w_res_src <= 0;
            w_rd <= 0;
            w_alu_res <= 0;
            w_mem_rdata <= 0;
            w_ebreak <= 0;
            w_pc_plus_4 <= 0;
        end
        else begin
            w_reg_wen <= m_reg_wen;
            w_res_src <= m_res_src;
            w_rd <= m_rd;
            w_alu_res <= m_alu_res;
            w_mem_rdata <= m_mem_rdata;
            w_ebreak <= m_ebreak;
            w_pc_plus_4 <= m_pc_plus_4;
        end
    end

    /* -- WRITEBACK -- */

    logic [31:0] w_pc_plus_4;
    logic w_reg_wen;
    logic [1:0] w_res_src;
    logic [4:0] w_rd;
    logic [31:0] w_alu_res;
    logic [31:0] w_mem_rdata;
    logic w_ebreak;

    logic [31:0] w_result;

    always_comb begin
        case (w_res_src)
            2'b00: w_result = w_alu_res;
            2'b01: w_result = w_mem_rdata;
            2'b10: w_result = w_pc_plus_4;
            2'b11: w_result = 0;
        endcase
    end

    assign o_ebreak = w_ebreak;

endmodule
