module forward_B_Mux ( wb_data, rdata2, clk, reset, forward_sel_B, data2 );
input logic [31:0] wb_data, rdata2;
input logic clk, reset, forward_sel_B;
output logic [31:0] data2;

always_ff @( posedge clk )
begin
        if (forward_sel_B) begin
        data2 <= wb_data;
        end
        
        else begin
        data2 <= rdata2;
        end
end
endmodule