module single_cycle_processor (
    input logic clock,
    input logic reset
);
    // Internal signals
    logic [31:0] pc_out, rdata1, rdata2, Inst, wb_data, alu_out, immediate_out;
    logic [31:0] b_out, rdata, bc_pc_out, a_out, pc_plus_4_out;
    logic [31:0] pc_out_1, Inst_1, data1, data2, addr_mem, wdata_mem, Inst_mem, PC_mem, PC_out_mem;
    logic [3:0]  alu_op;
    logic [2:0]  br_type;
    logic [1:0]  wb_sel, wb_sel_mem;
    logic        reg_wr, sel_B, rd_en, wr_en, br_taken, sel_A, reg_wr_mem, rd_en_mem, wr_en_mem, forward_sel_A, forward_sel_B;
    logic        stall;
    logic [31:0] pc_plus_4_mem;

    assign pc_plus_4_mem = PC_mem + 32'd4;

    // Program Counter
    pc u_pc (
        .clock    (clock),
        .reset    (reset),
        .bc_pc_out(bc_pc_out),
        .pc_out   (pc_out)
    );

    // PC + 4 Adder
    pc_plus_4 u_pc_plus_4 (
        .pc_out   (pc_out),
        .pc_plus_4(pc_plus_4_out)
    );

    // Instruction Memory
    instruction_memory u_instruction_memory (
        .Addr(pc_out),
        .Inst(Inst)
    );

    // Register File
    register_file u_register_file (
        .clock  (clock),
        .reset  (reset),
        .raddr1 (Inst_1[19:15]),
        .raddr2 (Inst_1[24:20]),
        .waddr  (Inst_mem[11:7]),
        .wb_data(wb_data),
        .reg_wr (reg_wr_mem),
        .rdata1 (rdata1),
        .rdata2 (rdata2)
    );

    // Controller
    controller u_controller (
        .Inst   (Inst_1),
        .Inst_mem(Inst_mem),
        .reg_wr (reg_wr),
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

    // Immediate Generator
    immediate_generator u_immediate_generator (
        .Inst         (Inst_1),
        .immediate_out(immediate_out)
    );

    // A Mux (selects between PC and rs1)
    a_mux u_a_mux (
        .pc_out(pc_out_1),
        .rdata1(data1),
        .sel_A (sel_A),
        .a_out (a_out)
    );

    // B Mux (selects between rs2 and immediate)
    b_mux u_b_mux (
        .rdata2       (data2),
        .immediate_out(immediate_out),
        .sel_B        (sel_B),
        .b_out        (b_out)
    );

    // ALU
    alu u_alu (
        .a_out  (a_out),
        .b_out  (b_out),
        .alu_op (alu_op),
        .alu_out(alu_out)
    );

    // Data Memory
    data_memory u_data_memory (
        .clock(clock),
        .reset(reset),
        .addr (addr_mem),
        .wdata(wdata_mem),
        .wr_en(wr_en_mem),
        .rd_en(rd_en_mem),
        .rdata(rdata)
    );

    // Writeback Mux (selects between ALU result, data memory, PC+4)
    data_memory_mux u_data_memory_mux (
        .alu_out  (addr_mem),
        .rdata    (rdata),
        .pc_plus_4(pc_plus_4_mem),
        .wb_sel   (wb_sel_mem),
        .wdata    (wb_data)
    );

    // Branch Condition
    branch_condition u_branch_condition (
        .rdata1  (data1),
        .rdata2  (data2),
        .br_type (br_type),
        .br_taken(br_taken)
    );

    // Branch/PC Mux (selects between PC+4 and ALU result for next PC)
    bc_pc_mux u_bc_pc_mux (
        .pc_plus_4(pc_plus_4_out),
        .alu_out  (alu_out),
        .br_taken (br_taken),
        .bc_pc_out(bc_pc_out)
    );

    forward_A_mux u_forward_A_mux(
        .wb_data(wb_data),
        .rdata1(rdata1),
        .clock(clock),
        .reset(reset),
        .forward_sel_A(forward_sel_A),
        .data1(data1)

    );

    forward_B_mux u_forward_B_mux(
        .wb_data(wb_data),
        .rdata2(rdata2),
        .clock(clock),
        .reset(reset),
        .forward_sel_B(forward_sel_B),
        .data2(data2)
    );
    pipeline_stage1 u_pipeline_stage1 (
        .clock(clock),
        .reset(reset),
        .pc_out(pc_out),
        .Inst(Inst),
        .stall(stall),
        .br_taken(br_taken),
        .pc_out_1(pc_out_1),
        .Inst_1(Inst_1)
    );

    pipeline_stage2 u_pipeline_stage2(
        .clock(clock),
        .reset(reset),
        .stall(stall),
        .rd_en(rd_en),
        .wr_en(wr_en),
        .reg_wr(reg_wr),
        .wb_sel(wb_sel),
        .data2(data2),
        .alu_out(alu_out),
        .pc_out_1(pc_out_1),
        .Inst_1(Inst_1),
        .rd_en_mem(rd_en_mem),
        .wr_en_mem(wr_en_mem),
        .reg_wr_mem(reg_wr_mem),
        .wb_sel_mem(wb_sel_mem),
        .addr_mem(addr_mem),
        .wdata_mem(wdata_mem),
        .Inst_mem(Inst_mem),
        .PC_mem(PC_mem)
    );


endmodule