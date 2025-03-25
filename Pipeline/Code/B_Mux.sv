// ALU Input B Mux
module B_Mux ( data2, immediate_out, sel_B, B_Mux_out);
input logic [31:0] data2;
input logic [31:0] immediate_out;
input logic sel_B;
output  logic [31:0] B_Mux_out;
always_comb
begin
        if ( sel_B ) begin
        B_Mux_out = immediate_out;
        end
        else begin
        B_Mux_out = data2;
        end
end
endmodule
