module uart_tx #(
    parameter CLK_FREQ = 100000000,
    parameter UART_FREQ = 9600
) (
    input wire i_clk,
    input wire i_rst,

    input wire [7:0] i_data,
    input wire i_data_valid,

    output logic o_done,
    output logic o_tx
);

    localparam CLK_DIV = CLK_FREQ / UART_FREQ;
    localparam CLK_DIV_WIDTH = $clog2(CLK_DIV);

    typedef enum logic [1:0] {
        IDLE = 2'b00,
        START = 2'b01,
        DATA = 2'b10,
        STOP = 2'b11
    } t_state;

    logic [CLK_DIV_WIDTH-1:0] clk_div_q, clk_div_d;

    t_state state_q, state_d;
    logic [2:0] bit_idx_q, bit_idx_d;

    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            state_q <= IDLE;
            bit_idx_q <= 0;
        end
        else begin
            clk_div_q <= clk_div_d;
        end

        o_done <= 0;

        /* verilator lint_off WIDTHEXPAND */
        if (clk_div_q == CLK_DIV-1) begin
        /* verilator lint_on WIDTHEXPAND */
            state_q <= state_d;
            bit_idx_q <= bit_idx_d;

            if (state_q != STOP && state_d == STOP)
                o_done <= 1;
        end
    end

    always_comb begin
        /* verilator lint_off WIDTHEXPAND */
        if (clk_div_q < CLK_DIV-1)
        /* verilator lint_on WIDTHEXPAND */
            clk_div_d = clk_div_q + 1;
        else
            clk_div_d = 0;
    end

    always_comb begin
        state_d = state_q;
        bit_idx_d = bit_idx_q;

        case (state_q)
            IDLE: if (i_data_valid) begin
                state_d = START;
            end
            START: begin
                state_d = DATA;
                bit_idx_d = 3'b0;
            end
            DATA: begin
                if (bit_idx_q == 3'd7)
                    state_d = STOP;
                else
                    bit_idx_d = bit_idx_q + 1;
            end
            STOP: begin
                // if (i_data_valid) state_d = START;
                state_d = IDLE;
            end
        endcase
    end

    always_comb begin
        case (state_q)
            IDLE: begin
                o_tx = 1;
            end
            START: begin
                o_tx = 0;
            end
            DATA: begin
                o_tx = i_data[bit_idx_q];
            end
            STOP: begin
                o_tx = 1;
            end
        endcase
    end

endmodule
