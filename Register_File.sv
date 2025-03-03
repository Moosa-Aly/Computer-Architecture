//Register File
module Register_File ( clk, reset, reg_wr, raddr1, raddr2, waddr, wdata, rdata1, rdata2 );
input logic clk, reset, reg_wr;
input logic  [4:0] raddr1, raddr2, waddr;
input logic  [31:0] wdata;
output logic [31:0] rdata1, rdata2;
integer k;
logic [31:0] register_file_reg [31:0];
always_comb
begin
        rdata1 = register_file_reg [raddr1];
        rdata2 = register_file_reg [raddr2];
end
always_ff @( posedge clk ) begin
        if ( reset ) begin
                for ( k=0; k<32; k=k+1 ) begin
                register_file_reg [k] <= 32'h00000000;
                end
        end
        else if ( reg_wr && waddr != 5'b0 ) begin
                register_file_reg [waddr] <= wdata;
        end
end
endmodule