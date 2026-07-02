module uart_rx #(
    parameter DATA_BITS = 8,
    parameter PARITY    = 0,
    parameter STOP_BITS = 1
)(
    input  logic                 clock,
    input  logic                 reset_n,
    input  logic                 tick_16x,
    input  logic                 rx_in,
    output logic [DATA_BITS-1:0] rx_data,
    output logic                 rx_done,
    output logic                 frame_error,
    output logic                 parity_error
);

typedef enum logic [2:0] {
    RX_IDLE   = 3'b000,
    RX_START  = 3'b001,
    RX_DATA   = 3'b010,
    RX_PARITY = 3'b011,
    RX_STOP   = 3'b100
} rx_state_t;

rx_state_t state;

logic [DATA_BITS-1:0] rx_shift_reg;
logic [3:0]           tick_counter;
logic [3:0]           bit_counter;
logic                 parity_calculation;
logic                 stop_counter;

logic sync_stage1, sync_stage2;
logic rx_synced;

always_ff @(posedge clock or negedge reset_n) begin
    if (!reset_n) begin
        sync_stage1 <= 1'b1;
        sync_stage2 <= 1'b1;
    end
    else begin
        sync_stage1 <= rx_in;
        sync_stage2 <= sync_stage1;
    end
end

assign rx_synced = sync_stage2;

always_comb begin
    case (PARITY)
        1: parity_calculation = ^rx_shift_reg;
        2: parity_calculation = ~(^rx_shift_reg);
        default: parity_calculation = 1'b0;
    endcase
end

always_ff @(posedge clock or negedge reset_n) begin
    if (!reset_n) begin
        state        <= RX_IDLE;
        rx_shift_reg <= '0;
        tick_counter <= '0;
        bit_counter  <= '0;
        stop_counter <= 1'b0;
        rx_data      <= '0;
        rx_done      <= 1'b0;
        frame_error  <= 1'b0;
        parity_error <= 1'b0;
    end
    else begin
        rx_done      <= 1'b0;
        frame_error  <= 1'b0;
        parity_error <= 1'b0;

        case (state)
            RX_IDLE: begin
                tick_counter <= '0;
                bit_counter  <= '0;
                if (rx_synced == 1'b0) begin
                    state <= RX_START;
                end
            end

            RX_START: begin
                if (tick_16x) begin
                    if (tick_counter == 4'd7) begin
                        tick_counter <= '0;
                        if (rx_synced == 1'b0)
                            state <= RX_DATA;
                        else
                            state <= RX_IDLE;
                    end
                    else begin
                        tick_counter <= tick_counter + 1'b1;
                    end
                end
            end

            RX_DATA: begin
                if (tick_16x) begin
                    if (tick_counter == 4'd15) begin
                        tick_counter <= '0;
                        rx_shift_reg <= {rx_synced, rx_shift_reg[DATA_BITS-1:1]};
                        bit_counter  <= bit_counter + 1'b1;
                        if (bit_counter == DATA_BITS - 1) begin
                            if (PARITY != 0)
                                state <= RX_PARITY;
                            else begin
                                stop_counter <= 1'b0;
                                state        <= RX_STOP;
                            end
                        end
                    end
                    else begin
                        tick_counter <= tick_counter + 1'b1;
                    end
                end
            end

            RX_PARITY: begin
                if (tick_16x) begin
                    if (tick_counter == 4'd15) begin
                        tick_counter <= '0;
                        stop_counter <= 1'b0;
                        if (rx_synced != parity_calculation)
                            parity_error <= 1'b1;
                        state <= RX_STOP;
                    end
                    else begin
                        tick_counter <= tick_counter + 1'b1;
                    end
                end
            end

            RX_STOP: begin
                if (tick_16x) begin
                    if (tick_counter == 4'd15) begin
                        tick_counter <= '0;
                        if (rx_synced != 1'b1)
                            frame_error <= 1'b1;
                        if (STOP_BITS == 2 && stop_counter == 1'b0) begin
                            stop_counter <= 1'b1;
                        end
                        else begin
                            rx_data <= rx_shift_reg;
                            rx_done <= 1'b1;
                            state   <= RX_IDLE;
                        end
                    end
                    else begin
                        tick_counter <= tick_counter + 1'b1;
                    end
                end
            end

            default: state <= RX_IDLE;
        endcase
    end
end

endmodule