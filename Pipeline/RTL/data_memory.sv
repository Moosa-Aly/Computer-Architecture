module data_memory (

    input  logic        clock,
    input  logic        reset,
    input  logic [31:0] addr,
    input  logic [31:0] wdata,

    input  logic        wr_en,
    input  logic        rd_en,

    output logic [31:0] rdata

);

integer i;
logic [31:0] data_memory_reg [63:0];

always_ff @(posedge clock) begin
    if (reset) begin
        for (i=0; i<64; i=i+1) begin
            data_memory_reg[i] <= 32'b0;
        end
    end
    else if (wr_en && addr != 32'h0 ) begin
        data_memory_reg[addr] <= wdata;
    end
end

always_comb begin
    if (rd_en) begin
        rdata = data_memory_reg[addr];
    end
    else begin
        rdata = 32'b0;
    end
end

endmodule