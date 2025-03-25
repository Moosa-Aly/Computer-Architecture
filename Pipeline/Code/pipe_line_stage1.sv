module pipe_line_stage1 ( PC_out, Inst, stall, clk, reset, br_taken, PC_ex, pl_Inst );
input logic [31:0] PC_out;
input logic [31:0] Inst;
input logic stall, clk, reset;
input logic br_taken;
output logic[31:0] PC_ex;
output logic[31:0] pl_Inst;
always_ff @( posedge clk )
begin
        if (reset | stall | br_taken )
        begin
        PC_ex <= 32'b0;
        pl_Inst <= 32'h00000013;
        end

        else begin
        pl_Inst = Inst;
        PC_ex = PC_out;
        end
end  
endmodule