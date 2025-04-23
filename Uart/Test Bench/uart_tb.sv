module uart_tb;
localparam CLOCKRATE = 100000000;
localparam CLOCK_PERIOD = 1_000_000_000 / CLOCKRATE;
localparam BAUD = 115200;
localparam WORD_LENGTH = 8;
localparam PACKET_COUNTER_MAX = 10;
localparam PACKET_COUNTER_SIZE = $clog2(PACKET_COUNTER_MAX);

// Signals
logic clk = 0;
logic reset = 1;
logic [WORD_LENGTH-1:0] tx_data;
logic tx_data_valid;
logic tx_data_ready;
logic tx_data_last;
logic UART_TX;
logic UART_RX;
logic [WORD_LENGTH-1:0] rx_data;
logic rx_data_valid;
logic rx_data_ready;
logic [PACKET_COUNTER_SIZE-1:0] packet_counter;
logic [WORD_LENGTH-1:0] tx_data_sent;
logic [2:0] rx_state_debug; // Added for debugging

// Clock
always #(CLOCK_PERIOD/2) clk = ~clk;

// Reset
localparam RESET_CYCLES = 10;
initial begin
    reset = 1;
    #(RESET_CYCLES * CLOCK_PERIOD);
    @(posedge clk);
    reset = 0;
end

// TX stimulus
always @(posedge clk) begin
    if (reset) begin
        packet_counter <= '0;
        tx_data_valid <= 1'b0;
        tx_data <= 8'h5A;
        tx_data_last <= 1'b0;
        tx_data_sent <= 8'h00;
    end
    else begin
        if (tx_data_valid && tx_data_ready) begin
            tx_data_sent <= tx_data;
            if (packet_counter == PACKET_COUNTER_MAX - 1) begin
                packet_counter <= '0;
                tx_data_last <= 1'b1;
                tx_data_valid <= 1'b0;
                tx_data <= 8'h5A;
            end
            else begin
                packet_counter <= packet_counter + 'd1;
                tx_data <= tx_data + 8'h01;
                tx_data_last <= 1'b0;
            end
        end
        else if (!tx_data_valid && packet_counter == 0) begin
            tx_data_valid <= 1'b1;
        end
    end
end

// RX ready
always @(posedge clk) begin
    if (reset) begin
        rx_data_ready <= 1'b0;
    end
    else begin
        rx_data_ready <= 1'b1;
    end
end

// UUT
uart #(
    .CLOCKRATE(CLOCKRATE),
    .BAUD(BAUD),
    .WORD_LENGTH(WORD_LENGTH)
) uart_i (
    .clk(clk),
    .reset(reset),
    .tx_data(tx_data),
    .tx_data_valid(tx_data_valid),
    .tx_data_ready(tx_data_ready),
    .tx_data_last(tx_data_last),
    .UART_TX(UART_TX),
    .UART_RX(UART_RX),
    .rx_data(rx_data),
    .rx_data_valid(rx_data_valid),
    .rx_data_ready(rx_data_ready),
    .rx_state_debug(rx_state_debug)
);

// Loopback
assign UART_RX = UART_TX;

// Monitor and checker
    logic [WORD_LENGTH-1:0] expected_data;
    logic [PACKET_COUNTER_SIZE-1:0] rx_packet_counter;
    initial begin
        expected_data = 8'h5A;
        rx_packet_counter = '0;
    end

    always @(posedge clk) begin
        if (reset) begin
            expected_data <= 8'h5A;
            rx_packet_counter <= '0;
        end else begin
            if (tx_data_valid && tx_data_ready) begin
                expected_data <= (packet_counter == PACKET_COUNTER_MAX - 1) ? 8'h5A : tx_data_sent + 8'h01;
            end
            if (rx_data_valid && rx_data_ready) begin
                $display("Received data: %h (Expected: %h) at time %t", rx_data, expected_data, $time);
                if (rx_data !== expected_data) begin
                    $display("ERROR: Data mismatch! Expected %h, received %h at %t", expected_data, rx_data, $time);
                end
                rx_packet_counter <= (rx_packet_counter == PACKET_COUNTER_MAX - 1) ? '0 : rx_packet_counter + 1;
            end
        end
    end

    // Stop simulation and check
    initial begin
        #2000000;
        $display("Simulation complete. %0d bytes received.", rx_packet_counter);
        if (rx_packet_counter != PACKET_COUNTER_MAX) begin
            $display("ERROR: Expected %0d bytes, but received %0d.", PACKET_COUNTER_MAX, rx_packet_counter);
        end
        $stop;
    end

endmodule