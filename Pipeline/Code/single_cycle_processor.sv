module single_cycle_processor (
    input logic clk,
    input logic reset
);
    // Internal signals
    logic [31:0]  PC_out, rdata1, rdata2, Inst, wb_data, ALU_result, immediate_output, B_Mux_out, rdata, bc_pc_out, A_Mux_out, PCplus4_out, PC_ex, pl_Inst, data1, data2, addr_mem, wdata_mem, Inst_mem, PC_mem, PC_out_mem;
    logic [3:0]   alu_op;
    logic [2:0]   br_type;
    logic [1:0]   wb_sel, wb_sel_mem;
    logic reg_wr, sel_B, rd_en, wr_en, br_taken, sel_A, reg_wr_mem, stall, rd_wr_mem_mem, mem_wr_mem, forward_sel_A, forward_sel_B;

    
    PC PC (
        .clk(clk),
        .reset(reset),
        .bc_pc_out(bc_pc_out),
        .PC_out(PC_out)
    );

    
    Instruction_Memory Instruction_Memory (
        .Addr(PC_out), 
        .Inst(Inst)
    );

    pipe_line_stage1 pipe_line_stage1 (
        .clk(clk),
        .reset(reset),
        .PC_out(PC_out),
        .Inst(Inst),
        .stall(stall),
        .br_taken(br_taken),
        .PC_ex(PC_ex),
        .pl_Inst(pl_Inst)

    );

    Register_File Register_File (
        .clk(clk),
        .reset(reset),
        .raddr1(pl_Inst[19:15]),
        .raddr2(pl_Inst[24:20]),
        .waddr(pl_Inst[11:7]),
        .wb_data(wb_data),
        .reg_wr(reg_wr_mem),
        .rdata1(rdata1),
        .rdata2(rdata2)
    );

    
    Immediate_Gen imm_gen (
        .Inst(Inst),
        .immediate_out(immediate_output)
    );

    forward_A_Mux forward_A_Mux(
        .wb_data(wb_data),
        .rdata1(rdata1),
        .clk(clk),
        .reset(reset),
        .forward_sel_A(forward_sel_A),
        .data1(data1)

    );

    forward_B_Mux forward_B_Mux(
        .wb_data(wb_data),
        .rdata2(rdata2),
        .clk(clk),
        .reset(reset),
        .forward_sel_B(forward_sel_B),
        .data2(data2)
    );

    B_Mux B_Mux(
        .immediate_out(immediate_output),
        .data2(data2),
        .sel_B(sel_B),
        .B_Mux_out(B_Mux_out)
    );

  
    Controller Controller(
        .Inst(pl_Inst),
        .Inst_mem(Inst_mem),
        .reg_wr(reg_wr),
        .sel_B(sel_B),
        .alu_op(alu_op),
        .rd_en(rd_en),
        .wr_en(wr_en),
        .wb_sel(wb_sel),
        .sel_A(sel_A),
        .br_type(br_type),
        .stall(stall),
        .forward_sel_A(forward_sel_A),
        .forward_sel_B(forward_sel_B) 
    );

 
    ALU ALU(
        .A_Mux_out(A_Mux_out),
        .B_Mux_out(B_Mux_out),
        .alu_op(alu_op),
        .ALU_result(ALU_result)
    );

    pipe_line_stage2_reg pipe_line_stage2_reg(
        .clk(clk),
        .reset(reset),
        .rd_en(rd_en),
        .wr_en(wr_en),
        .reg_wr(reg_wr),
        .wb_sel(wb_sel),
        .data2(data2),
        .ALU_result(ALU_result),
        .pl_Inst(pl_Inst),
        .rd_wr_mem_mem(rd_wr_mem_mem),
        .mem_wr_mem(mem_wr_mem),
        .reg_wr_mem(reg_wr_mem),
        .wb_sel_mem(wb_sel_mem),
        .addr_mem(addr_mem),
        .wdata_mem(wdata_mem),
        .Inst_mem(Inst_mem),
        .PC_ex(PC_ex),
        .PC_mem(PC_mem)
    );

    Data_Mem Data_Mem (
        .addr(addr_mem), // Address to access
        .wdata(wdata_mem), // Data to be written
        .clk(clk),
        .reset(reset),
        .wr_en(mem_wr_mem),
        .rd_en(rd_wr_mem_mem),
        .rdata(rdata) // Data to be read
    );

    Data_Mem_mux Data_Mem_mux(
        .rdata(rdata),
        .wb_sel(wb_sel_mem),
        .ALU_result(addr_mem),
        .PC_out_mem(PC_out_mem),
        .wb_data(wb_data)
    );
     
    Branch_Cond Branch_Cond(
        .rdata1(rdata1),
        .rdata2(rdata2),
        .br_type(br_type),
        .br_taken(br_taken)
    );

    BC_PC_Mux BC_PC_Mux(
        .PCplus4_out(PCplus4_out),
        .ALU_result(ALU_result),
        .bc_pc_out(bc_pc_out),
        .br_taken(br_taken)
    );

    A_Mux A_mux(
        .PC_out(PC_out),
        .rdata1(rdata1),
        .sel_A(sel_A),
        .A_Mux_out(A_Mux_out)
    );

    PCplus4 PCplus4(
        .PC_out(PC_out),
        .PCplus4_out(PCplus4_out)
    );

    Data_Mem_PCplus4 Data_Mem_PCplus4(
        .PC_mem(PC_mem),
        .PC_out_mem(PC_out_mem)

    );
endmodule