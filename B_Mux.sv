// ALU Input B Mux
module B_Mux (rdata2, Immediate_out, sel_B, B_Mux_Out);
input logic [31:0] rdata2;
input logic [31:0] Immediate_out;
input logic sel_B;
output  logic [31:0] B_Mux_Out;
always_comb
begin
        if ( sel_B ) begin
        B_Mux_Out = Immediate_out;
        end
        else begin
        B_Mux_Out = rdata2;
        end
end
endmodule
