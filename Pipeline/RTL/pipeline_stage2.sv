module pipeline_stage2 (
    input  logic        clock,
    input  logic        reset,
    input  logic        stall,

    input  logic        rd_en,
    input  logic        wr_en,
    input  logic        reg_wr,

    input  logic [1:0]  wb_sel,
    input  logic [31:0] data2,
    input  logic [31:0] alu_out,
    input  logic [31:0] pc_out_1,
    input  logic [31:0] Inst_1,

    output logic        rd_en_mem,
    output logic        wr_en_mem,
    output logic        reg_wr_mem,
    output logic [1:0]  wb_sel_mem,

    output logic [31:0] addr_mem,
    output logic [31:0] wdata_mem,
    output logic [31:0] Inst_mem,
    output logic [31:0] PC_mem
);

always_ff @(posedge clock or posedge reset) begin
    if (reset || stall) begin
        rd_en_mem  <= 1'b0;
        wr_en_mem  <= 1'b0;
        reg_wr_mem <= 1'b0;
        wb_sel_mem <= 2'b00;
        addr_mem   <= 32'b0;
        wdata_mem  <= 32'b0;
        Inst_mem   <= 32'h00000013;
        PC_mem     <= 32'b0;
    end
    else begin
        rd_en_mem  <= rd_en;
        wr_en_mem  <= wr_en;
        reg_wr_mem <= reg_wr;
        wb_sel_mem <= wb_sel;
        addr_mem   <= alu_out;
        wdata_mem  <= data2;
        Inst_mem   <= Inst_1;
        PC_mem     <= pc_out_1;
    end
end

endmodule