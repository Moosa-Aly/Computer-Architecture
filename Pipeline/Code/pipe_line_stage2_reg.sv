module pipe_line_stage2_reg ( clk, reset, rd_en, wr_en, reg_wr, stall, wb_sel, data2, ALU_result, pl_Inst, PC_ex, rd_wr_mem_mem, mem_wr_mem, reg_wr_mem, wb_sel_mem, addr_mem, wdata_mem, Inst_mem, PC_mem );
input logic clk, reset, rd_en, wr_en, reg_wr, stall;
input logic [1:0] wb_sel;
input logic [31:0] data2, ALU_result, pl_Inst, PC_ex;
output logic rd_wr_mem_mem, mem_wr_mem, reg_wr_mem;
output logic [1:0] wb_sel_mem;
output logic [31:0] addr_mem, wdata_mem, Inst_mem, PC_mem;
always_ff @( posedge clk ) begin 
    if ( reset | stall  )
        begin
        Inst_mem <= 32'h00000013;
        addr_mem <= 32'b0;
        wdata_mem <= 32'b0;
        wb_sel_mem <= 2'b0;
        rd_wr_mem_mem <= 1'b0;
        mem_wr_mem <= 1'b0;
        reg_wr_mem <= 1'b0;
        PC_mem <= 32'b0;
        end

    else begin
        Inst_mem <= pl_Inst;
        addr_mem <= ALU_result;
        wdata_mem <= data2;
        wb_sel_mem <= wb_sel;
        rd_wr_mem_mem <= rd_en;
        mem_wr_mem <= wr_en;
        reg_wr_mem <= reg_wr;
        PC_mem <= PC_ex;

    end
    
end
    
endmodule