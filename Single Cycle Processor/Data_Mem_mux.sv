// Data Memory Multiplexer
module Data_Mem_mux ( jump_dm_in, ALU_result, rdata, wb_data, wb_sel );
input logic  [ 31:0 ] jump_dm_in;
input logic  [ 31:0 ] ALU_result;
input logic  [ 31:0 ] rdata;
input logic  [ 1:0  ] wb_sel;
output logic [ 31:0 ] wb_data;
always_comb
begin
        case ( wb_sel )
        2'b00: wb_data = ALU_result; 
        2'b01: wb_data = rdata;
        2'b10: wb_data = jump_dm_in;
        default: wb_data = ALU_result;
        endcase
end
endmodule