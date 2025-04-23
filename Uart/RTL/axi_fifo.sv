module axi_fifo #(
parameter DATA_WIDTH = 8,
parameter FIFO_DEPTH = 16,
parameter ADDR_WIDTH = $clog2(FIFO_DEPTH)
)
(
input  logic                  s_aclk,
input  logic                  s_aresetn,
input  logic [DATA_WIDTH-1:0] s_axis_tdata,
input  logic                  s_axis_tvalid,
output logic                  s_axis_tready,
input  logic                  s_axis_tlast,
output logic [DATA_WIDTH-1:0] m_axis_tdata,
output logic                  m_axis_tvalid,
input  logic                  m_axis_tready,
output logic                  m_axis_tlast,
output logic                  wr_reset_busy,
output logic                  rd_reset_busy
);

// FIFO memory
logic [DATA_WIDTH:0] mem [0:FIFO_DEPTH-1]; // Stores data + tlast
logic [ADDR_WIDTH-1:0] wr_ptr, rd_ptr;
logic [ADDR_WIDTH:0] count;
logic full, empty;

// Status flags
assign full = (count == FIFO_DEPTH);
assign empty = (count == 0);
assign s_axis_tready = !full;
assign m_axis_tvalid = !empty;

assign wr_reset_busy = 1'b0;
assign rd_reset_busy = 1'b0;

// Initialize memory during reset
integer i;
always @(posedge s_aclk) begin
    if (!s_aresetn) begin
        for (i = 0; i < FIFO_DEPTH; i = i + 1) begin
            mem[i] <= '0; // Initialize memory to 0
        end
        wr_ptr <= '0;
        count <= '0;
    end
    else begin
        if (s_axis_tvalid && s_axis_tready) begin
            mem[wr_ptr] <= {s_axis_tlast, s_axis_tdata};
            wr_ptr <= wr_ptr + 1;
            if (!(m_axis_tvalid && m_axis_tready)) begin
                count <= count + 1;
            end
        end
        else if (m_axis_tvalid && m_axis_tready && !empty) begin
            count <= count - 1;
        end
    end
end

// Read logic
always @(posedge s_aclk) begin
    if (!s_aresetn) begin
        rd_ptr <= '0;
    end
    else if (m_axis_tvalid && m_axis_tready) begin
        rd_ptr <= rd_ptr + 1;
    end
end

// Output data
assign m_axis_tdata = mem[rd_ptr][DATA_WIDTH-1:0];
assign m_axis_tlast = mem[rd_ptr][DATA_WIDTH];

endmodule