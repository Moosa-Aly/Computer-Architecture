// Data Memory PC + 4
module Data_Mem_PCplus4 ( PC_out, jump_dm_in );
input  logic [ 31:0 ] PC_out;
output logic [ 31:0 ] jump_dm_in;
always_comb
begin
        jump_dm_in = PC_out + 4;
end
endmodule