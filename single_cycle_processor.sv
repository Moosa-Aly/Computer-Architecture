module single_cycle_processor (
    input logic clk,
    input logic reset
);
    // Internal signals
    logic [31:0]  PC_out, rdata1, rdata2, Inst, wdata, ALU_result, Immediate_out, B_Mux_Out, rdata, bc_pc_out, A_Mux_out, PCplus4_out, jump_dm_in;
    logic [3:0]   alu_op;
    logic [2:0]   br_type;
    logic [1:0]   wb_sel;
    logic reg_wr, sel_B, rd_en, wr_en, br_taken, sel_A;

    
    PC PC (
        .clk(clk),
        .reset(reset),
        .pc(bc_pc_out),
        .pc_next(PC_out)
    );

    
    Instruction_Memory Instruction_Memory (
        .Addr(PC_out), 
        .Inst(Inst)
    );

    
    Register_File Register_File (
        .clk(clk),
        .reset(reset),
        .raddr1(Inst[19:15]),
        .raddr2(Inst[24:20]),
        .waddr(Inst[11:7]),
        .wdata(wdata),
        .reg_wr(reg_wr),
        .rdata1(rdata1),
        .rdata2(rdata2)
    );

    
    Immediate_Gen imm_gen (
        .Inst(Inst),
        .Immediate_out(Immediate_out)
    );

    
    B_Mux B_Mux(
        .Immediate_out(Immediate_out),
        .rdata2(rdata2),
        .sel_B(sel_B),
        .B_Mux_Out(B_Mux_Out)
    );

  
    Controller Controller(
        .Inst(Inst),
        .reg_wr(reg_wr),
        .sel_B(sel_B),
        .alu_op(alu_op),
        .rd_en(rd_en),
        .wr_en(wr_en),
        .wb_sel(wb_sel),
        .sel_A(sel_A),
        .br_type(br_type)
        
    );

 
    ALU ALU(
        .A_Mux_out(A_Mux_out),
        .B_Mux_out(B_Mux_out),
        .alu_op(alu_op),
        .ALU_result(ALU_result)
    );

    Data_Mem Data_Mem (
        .addr(ALU_result), // Address to access
        .wdata(rdata2), // Data to be written
        .clk(clk),
        .reset(reset),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .rdata(rdata) // Data to be read
    );

    Data_Mem_mux Data_Mem_mux(
        .rdata(rdata),
        .wb_sel(wb_sel),
        .ALU_result(ALU_result),
        .jump_dm_in(jump_dm_in),
        .wdata(wdata)
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

    A_mux A_mux(
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
        .PC_out(PC_out),
        .jump_dm_in(jump_dm_in)

    );
endmodule