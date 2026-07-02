module pipeline_stage1 (
    input  logic clock,
    input  logic reset,
    input  logic stall,
    input  logic [31:0] pc_out,
    input  logic [31:0] Inst,
    input  logic br_taken,
    
    output logic [31:0] pc_out_1,
    output logic [31:0] Inst_1 
);

always_ff @(posedge clock or posedge reset) begin
    if (reset || stall || br_taken) begin
        pc_out_1 <= 32'b0;
        Inst_1   <= 32'h00000013;
    end
    else begin
        pc_out_1 <= pc_out;
        Inst_1   <= Inst;
    end
end

endmodule