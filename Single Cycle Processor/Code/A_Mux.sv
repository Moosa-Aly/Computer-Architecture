// ALU Input A Mux
module A_Mux ( PC_out, rdata1, sel_A, A_Mux_out );
input logic [31:0] PC_out;
input logic [31:0] rdata1;
input logic sel_A;
output logic [31:0] A_Mux_out;
always_comb
begin
        if ( sel_A ) begin
        A_Mux_out = rdata1;
        end
        else begin
        A_Mux_out = PC_out;
        end
end
endmodule