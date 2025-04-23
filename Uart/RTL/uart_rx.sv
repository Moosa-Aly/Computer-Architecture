module uart_rx #(
parameter CLOCKRATE = 100000000,
parameter BAUD = 115200,
parameter WORD_LENGTH = 8
)
(
input  logic                    clk,
input  logic                    reset,
output logic [WORD_LENGTH-1:0]  rx_data,
output logic                    rx_data_valid,
input  logic                    rx_data_ready,
input  logic                    UART_RX,
output logic [2:0]              current_state_debug
);

// Internal signals
logic                           rx_data_valid_i;
logic [WORD_LENGTH-1:0]         rx_data_i;
logic [WORD_LENGTH-1:0]         rx_shift_buffer;
logic                           received_parity;

// Baud and data counters
localparam BAUD_COUNTER_MAX  = CLOCKRATE / BAUD;
localparam BAUD_COUNTER_SIZE = $clog2(BAUD_COUNTER_MAX);
localparam DATA_COUNTER_MAX  = WORD_LENGTH;
localparam DATA_COUNTER_SIZE = $clog2(DATA_COUNTER_MAX);
localparam HALF_BAUD = BAUD_COUNTER_MAX / 2;

logic [BAUD_COUNTER_SIZE-1:0]   baud_counter;
logic [DATA_COUNTER_SIZE-1:0]   data_counter;
logic                           baud_done;
logic                           half_baud_done;
logic                           data_done;

// State machine
typedef enum logic [2:0] { IDLE = 3'd0, START = 3'd1, DATA = 3'd2, PARITY = 3'd3, STOP = 3'd4, WAIT = 3'd5 } my_state;
my_state current_state = IDLE;
my_state next_state    = IDLE;

// Debug output
assign current_state_debug = current_state;

// Baud counter
always @(posedge clk) begin
    if (reset) begin
        baud_counter <= '0;
    end
    else begin
        if (baud_done || current_state == IDLE) begin
            baud_counter <= '0;
        end
        else begin
            baud_counter <= baud_counter + 'd1;
        end
    end
end

assign baud_done = (baud_counter == BAUD_COUNTER_MAX - 1) ? 1'b1 : 1'b0;
assign half_baud_done = (baud_counter == HALF_BAUD - 1)   ? 1'b1 : 1'b0;

// Data counter, shift buffer, and parity capture
always @(posedge clk) begin
    if (reset) begin
        data_counter    <= '0;
        rx_shift_buffer <= '0;
        rx_data_i       <= '0;
        received_parity <= '0;
    end
    else if (baud_done) begin
        if (current_state != next_state) begin
            data_counter    <= '0;
            rx_shift_buffer <= '0;
        end
        else if (current_state == DATA) begin
            data_counter    <= data_counter + 'd1;
            rx_shift_buffer <= {UART_RX, rx_shift_buffer[WORD_LENGTH-1:1]};
        end
        else if (current_state == PARITY) begin
            received_parity <= UART_RX;
        end
    end
// Capture data at STOP state with corrected parity check
    if (current_state == STOP && baud_done) begin
        if (UART_RX == 1'b1 && (^rx_shift_buffer) == received_parity) begin
            rx_data_i <= rx_shift_buffer;
        end
        else begin
            rx_data_i <= '0;
        end
    end
end

assign data_done = (data_counter == DATA_COUNTER_MAX - 1) ? 1'b1 : 1'b0;

// State machine transitions
always @(*) begin
    next_state = current_state;
    case (current_state)
        IDLE: begin
            if (!UART_RX) begin
                next_state = START;
            end
        end
        START: begin
            if (half_baud_done) begin
                next_state = (UART_RX == 1'b0) ? DATA : IDLE;
            end
        end
        DATA: begin
            if (data_done && baud_done) begin
                next_state = PARITY;
            end
        end
        PARITY: begin
            if (baud_done) begin
                next_state = STOP;
            end
        end
        STOP: begin
            if (baud_done) begin
                next_state = (UART_RX == 1'b1 && (^rx_shift_buffer) == received_parity) ? WAIT : IDLE;
            end
        end
        WAIT: begin
            if (baud_done) begin
                next_state = IDLE;
            end
        end
        default: begin
            next_state = IDLE;
        end
    endcase
end

always @(posedge clk) begin
    if (reset) begin
        current_state <= IDLE;
    end
    else begin
        current_state <= next_state;
    end
end

// Output logic
always @(posedge clk) begin
    if (reset) begin
        rx_data_valid_i <= 1'b0;
    end
    else if (current_state == STOP && baud_done && UART_RX == 1'b1 && (^rx_shift_buffer) == received_parity) begin
        rx_data_valid_i <= 1'b1;
    end
    else if (rx_data_valid_i && rx_data_ready) begin
        rx_data_valid_i <= 1'b0;
    end
end

assign rx_data = rx_data_i;
assign rx_data_valid = rx_data_valid_i;

endmodule