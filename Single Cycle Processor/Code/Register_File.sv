//Register File
module Register_File ( clk, reset, reg_wr, raddr1, raddr2, waddr, wb_data, rdata1, rdata2 );
input logic clk, reset, reg_wr;
input logic  [4:0] raddr1, raddr2, waddr;
input logic  [31:0] wb_data;
output logic [31:0] rdata1, rdata2;
integer k;
logic [31:0] instruction_memory_reg [31:0];
always_comb
begin
        rdata1 = instruction_memory_reg [raddr1];
        rdata2 = instruction_memory_reg [raddr2];
end
always_ff @( posedge clk ) begin
        if ( reset ) begin
                for ( k=0; k<32; k=k+1 ) begin
                instruction_memory_reg [k] <= 32'h00000000;
                end
        end
        else if ( reg_wr && waddr != 5'b0 ) begin
                instruction_memory_reg [waddr] <= wb_data;
        end
end
endmodule