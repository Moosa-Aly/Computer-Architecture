// Data Memory
module Data_Mem ( clk, reset, wr_en, rd_en, addr, wdata, rdata);
input  logic clk, reset, wr_en, rd_en;
input  logic [31:0] addr, wdata;
output logic [31:0] rdata;
integer k;
logic [31:0] Data_Mem_reg [31:0];
always @(posedge clk)
begin
        if ( reset ) begin
        for ( k=0; k<32; k=k+1 ) begin
                Data_Mem_reg[k] <= 32'h00000000;
        end      
        end
        else if ( wr_en && addr != 32'h0 ) begin
        Data_Mem_reg[addr] <= wdata;
        end
end
always_comb
begin
        if ( rd_en ) begin
        rdata = Data_Mem_reg[addr];
        end
        else begin
        rdata = 32'h00000000;
        end
end
endmodule