module uart_transmitter #(
    parameter CLOCK_FREQ = 125_000_000,
    parameter BAUD_RATE = 115_200)
(
    input clk,
    input reset,

    input [7:0] data_in,
    input data_in_valid,
    output reg data_in_ready,

    output reg serial_out
);
    localparam integer SYMBOL_EDGE_TIME = CLOCK_FREQ / BAUD_RATE;
    localparam integer CLOCK_COUNTER_WIDTH = $clog2(SYMBOL_EDGE_TIME);

    // States
    localparam [1:0] STATE_IDLE  = 2'b00;
    localparam [1:0] STATE_START = 2'b01;
    localparam [1:0] STATE_DATA  = 2'b10;
    localparam [1:0] STATE_STOP  = 2'b11;

    reg [1:0] state;
    reg [2:0] bit_index;
    reg [CLOCK_COUNTER_WIDTH-1:0] clock_counter;
    reg [7:0] tx_data;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state         <= STATE_IDLE;
            bit_index     <= 3'b0;
            clock_counter <= 0;
            tx_data       <= 8'b0;
            serial_out    <= 1'b1; // Idle high
            data_in_ready <= 1'b1; // Ready for data
        end else begin
            case (state)
                STATE_IDLE: begin
                    serial_out    <= 1'b1;
                    data_in_ready <= 1'b1;
                    clock_counter <= 0;
                    bit_index     <= 3'b0;
                    if (data_in_valid) begin
                        tx_data       <= data_in;
                        state         <= STATE_START;
                        data_in_ready <= 1'b0;
                    end
                end

                STATE_START: begin
                    serial_out <= 1'b0; // Start bit (low)
                    data_in_ready <= 1'b0;
                    if (clock_counter == SYMBOL_EDGE_TIME - 1) begin
                        clock_counter <= 0;
                        state         <= STATE_DATA;
                    end else begin
                        clock_counter <= clock_counter + 1;
                    end
                end

                STATE_DATA: begin
                    serial_out <= tx_data[bit_index]; // Send bits LSB first
                    data_in_ready <= 1'b0;
                    if (clock_counter == SYMBOL_EDGE_TIME - 1) begin
                        clock_counter <= 0;
                        if (bit_index == 3'd7) begin
                            state <= STATE_STOP;
                        end else begin
                            bit_index <= bit_index + 1;
                        end
                    end else begin
                        clock_counter <= clock_counter + 1;
                    end
                end

                STATE_STOP: begin
                    serial_out <= 1'b1; // Stop bit (high)
                    data_in_ready <= 1'b0;
                    if (clock_counter == SYMBOL_EDGE_TIME - 1) begin
                        clock_counter <= 0;
                        state         <= STATE_IDLE;
                    end else begin
                        clock_counter <= clock_counter + 1;
                    end
                end
                
                default: state <= STATE_IDLE;
            endcase
        end
    end
endmodule