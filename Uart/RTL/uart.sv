module uart #(
    parameter CLOCKRATE = 100000000,
    parameter BAUD = 115200,
    parameter WORD_LENGTH = 8
) (
    input  logic                    clk,
    input  logic                    reset,
    input  logic [WORD_LENGTH-1:0]  tx_data,
    input  logic                    tx_data_valid,
    input  logic                    tx_data_last,
    output logic                    tx_data_ready,
    output logic                    UART_TX,
    input  logic                    UART_RX,
    output logic [WORD_LENGTH-1:0]  rx_data,
    output logic                    rx_data_valid,
    input  logic                    rx_data_ready,
    output logic [2:0]              rx_state_debug // Added for debugging
);

// TX FIFO signals
logic                   tx_data_fifo_m_axis_tlast;
logic                   tx_data_fifo_m_axis_tready;
logic                   tx_data_fifo_m_axis_tvalid;
logic [WORD_LENGTH-1:0] tx_data_fifo_m_axis_tdata;

// RX FIFO signals
logic                   rx_data_fifo_s_axis_tready;
logic                   rx_data_fifo_s_axis_tvalid;
logic [WORD_LENGTH-1:0] rx_data_fifo_s_axis_tdata;
logic                   rx_data_fifo_m_axis_tlast;

// TX FIFO
axi_fifo #(.DATA_WIDTH(WORD_LENGTH), .FIFO_DEPTH(16)) tx_data_fifo_i (
    .s_aclk        (clk),
    .s_aresetn     (~reset),
    .s_axis_tvalid (tx_data_valid),
    .s_axis_tready (tx_data_ready),
    .s_axis_tdata  (tx_data),
    .s_axis_tlast  (tx_data_last),
    .m_axis_tvalid (tx_data_fifo_m_axis_tvalid),
    .m_axis_tready (tx_data_fifo_m_axis_tready),
    .m_axis_tdata  (tx_data_fifo_m_axis_tdata),
    .m_axis_tlast  (tx_data_fifo_m_axis_tlast),
    .wr_reset_busy (),
    .rd_reset_busy ()
);

// RX FIFO
axi_fifo #(.DATA_WIDTH(WORD_LENGTH), .FIFO_DEPTH(16)) rx_data_fifo_i (
    .s_aclk        (clk),
    .s_aresetn     (~reset),
    .s_axis_tvalid (rx_data_fifo_s_axis_tvalid),
    .s_axis_tready (rx_data_fifo_s_axis_tready),
    .s_axis_tdata  (rx_data_fifo_s_axis_tdata),
    .s_axis_tlast  (1'b0),
    .m_axis_tvalid (rx_data_valid),
    .m_axis_tready (rx_data_ready),
    .m_axis_tdata  (rx_data),
    .m_axis_tlast  (rx_data_fifo_m_axis_tlast),
    .wr_reset_busy (),
    .rd_reset_busy ()
);

// UART Transmitter
uart_tx #(
    .CLOCKRATE     (CLOCKRATE),
    .BAUD          (BAUD),
    .WORD_LENGTH   (WORD_LENGTH)
) uart_tx_i (
    .clk           (clk),
    .reset         (reset),
    .tx_data       (tx_data_fifo_m_axis_tdata),
    .tx_data_valid (tx_data_fifo_m_axis_tvalid),
    .tx_data_ready (tx_data_fifo_m_axis_tready),
    .UART_TX       (UART_TX)
);

// UART Receiver
uart_rx #(
    .CLOCKRATE     (CLOCKRATE),
    .BAUD          (BAUD),
    .WORD_LENGTH   (WORD_LENGTH)
) uart_rx_i (
    .clk           (clk),
    .reset         (reset),
    .rx_data       (rx_data_fifo_s_axis_tdata),
    .rx_data_valid (rx_data_fifo_s_axis_tvalid),
    .rx_data_ready (rx_data_fifo_s_axis_tready),
    .UART_RX       (UART_RX),
    .current_state_debug (rx_state_debug) // Connect debug signal
);

endmodule