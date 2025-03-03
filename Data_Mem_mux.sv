// Data Memory Multiplexer
module Data_Mem_mux ( jump_dm_in, ALU_result, rdata, wdata, wb_sel );
input logic  [ 31:0 ] jump_dm_in;
input logic  [ 31:0 ] ALU_result;
input logic  [ 31:0 ] rdata;
input logic  [ 1:0  ] wb_sel;
output logic [ 31:0 ] wdata;
always_comb
begin
        case ( wb_sel )
        2'b00: wdata = jump_dm_in ; 
        2'b01: wdata = ALU_result;
        2'b10: wdata = rdata;
        default: wdata = ALU_result;
        endcase
end
endmodule