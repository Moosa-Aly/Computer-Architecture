// PC + 4
module PCplus4 ( PC_out, PCplus4_out );
input  logic [ 31:0 ] PC_out;
output logic [ 31:0 ] PCplus4_out;
always_comb
begin
        PCplus4_out = PC_out + 32'h4;
end
endmodule