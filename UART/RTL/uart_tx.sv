module uart_tx #(
    parameter DATA_BITS = 8,
    parameter PARITY    = 0,
    parameter STOP_BITS = 1
)(
    input  logic                 clock,
    input  logic                 reset_n,
    input  logic                 tick_1x,
    input  logic [DATA_BITS-1:0] tx_data,
    input  logic                 tx_start,

    output logic                 tx_out,
    output logic                 tx_busy,
    output logic                 tx_done
);

typedef enum logic [2:0] {
    TX_IDLE   = 3'b000,
    TX_START  = 3'b001,
    TX_DATA   = 3'b010,
    TX_PARITY = 3'b011,
    TX_STOP   = 3'b100
} tx_state_t;

tx_state_t state;

logic [DATA_BITS-1:0] tx_shift_register;
logic [3:0]           bit_counter;
logic                 parity_bit;
logic                 stop_counter;

always_comb begin
    case (PARITY)
        1: parity_bit = ^tx_shift_register;
        2: parity_bit = ~(^tx_shift_register);
        default: parity_bit = 1'b0;
    endcase
end

always_ff @(posedge clock or negedge reset_n) begin
    if (!reset_n) begin
        state             <= TX_IDLE;
        tx_shift_register <= '0;
        bit_counter       <= '0;
        stop_counter      <= 1'b0;
        tx_out            <= 1'b1;
        tx_busy           <= 1'b0;
        tx_done           <= 1'b0;
    end
    else begin
        tx_done <= 1'b0;

        case (state)
            TX_IDLE: begin
                tx_out  <= 1'b1;
                tx_busy <= 1'b0;
                if (tx_start) begin
                    tx_shift_register <= tx_data;
                    tx_busy           <= 1'b1;
                    state             <= TX_START;
                end
            end

            TX_START: begin
                tx_out <= 1'b0;
                if (tick_1x) begin
                    bit_counter <= '0;
                    state       <= TX_DATA;
                end
            end

            TX_DATA: begin
                tx_out <= tx_shift_register[0];
                if (tick_1x) begin
                    tx_shift_register <= tx_shift_register >> 1;
                    bit_counter       <= bit_counter + 1'b1;
                    if (bit_counter == DATA_BITS - 1) begin
                        if (PARITY != 0)
                            state <= TX_PARITY;
                        else begin
                            stop_counter <= 1'b0;
                            state        <= TX_STOP;
                        end
                    end
                end
            end

            TX_PARITY: begin
                tx_out <= parity_bit;
                if (tick_1x) begin
                    stop_counter <= 1'b0;
                    state        <= TX_STOP;
                end
            end

            TX_STOP: begin
                tx_out <= 1'b1;
                if (tick_1x) begin
                    if (STOP_BITS == 2 && stop_counter == 1'b0) begin
                        stop_counter <= 1'b1;
                    end
                    else begin
                        tx_done <= 1'b1;
                        tx_busy <= 1'b0;
                        state   <= TX_IDLE;
                    end
                end
            end

            default: state <= TX_IDLE;
        endcase
    end
end

endmodule