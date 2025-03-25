// Data Memory PC + 4
module Data_Mem_PCplus4 ( PC_out_mem, PC_mem );
input  logic [ 31:0 ] PC_mem;
output logic [ 31:0 ] PC_out_mem;
always_comb
begin
        PC_out_mem = PC_mem + 32'h4;
end
endmodule