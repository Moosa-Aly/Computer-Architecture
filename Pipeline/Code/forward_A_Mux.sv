module forward_A_Mux ( wb_data, rdata1, clk, reset, forward_sel_A, data1 );
input logic [31:0] wb_data, rdata1;
input logic clk, reset, forward_sel_A;
output logic[31:0] data1;

always_ff @( posedge clk )
begin
        if (forward_sel_A)
        begin
        data1 <= wb_data;
        end

        else begin
        data1 <= rdata1;
        end
end  
endmodule