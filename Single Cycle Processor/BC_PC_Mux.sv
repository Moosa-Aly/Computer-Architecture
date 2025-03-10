// Branch Condition and Program Counter Multiplexer
module BC_PC_Mux (ALU_result, PCplus4_out, br_taken, bc_pc_out);
input logic [31:0] ALU_result;
input logic [31:0] PCplus4_out;
input logic br_taken;
output logic [31:0] bc_pc_out;
always_comb
begin
        if ( br_taken ) begin
        bc_pc_out = ALU_result;
        end
        else begin
        bc_pc_out = PCplus4_out;
        end
end
endmodule