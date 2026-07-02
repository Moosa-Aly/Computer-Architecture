module single_cycle_processor (
    input logic clk,
    input logic reset
);
    // Internal signals
    logic [31:0] pc_out, rdata1, rdata2, Inst, wb_data, alu_out, immediate_out;
    logic [31:0] b_out, rdata, bc_pc_out, a_out, pc_plus_4_out;
    logic [3:0]  alu_op;
    logic [2:0]  br_type;
    logic [1:0]  wb_sel;
    logic        reg_wr, sel_B, rd_en, wr_en, br_taken, sel_A;

    // Program Counter
    pc u_pc (
        .clock    (clk),
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
        .clock  (clk),
        .reset  (reset),
        .raddr1 (Inst[19:15]),
        .raddr2 (Inst[24:20]),
        .waddr  (Inst[11:7]),
        .wdata  (wb_data),
        .reg_wr (reg_wr),
        .rdata1 (rdata1),
        .rdata2 (rdata2)
    );

    // Controller
    controller u_controller (
        .Inst   (Inst),
        .reg_wr (reg_wr),
        .sel_A  (sel_A),
        .sel_B  (sel_B),
        .alu_op (alu_op),
        .br_type(br_type),
        .rd_en  (rd_en),
        .wr_en  (wr_en),
        .wb_sel (wb_sel)
    );

    // Immediate Generator
    immediate_generator u_immediate_generator (
        .Inst         (Inst),
        .immediate_out(immediate_out)
    );

    // A Mux (selects between PC and rs1)
    a_mux u_a_mux (
        .pc_out(pc_out),
        .rdata1(rdata1),
        .sel_A (sel_A),
        .a_out (a_out)
    );

    // B Mux (selects between rs2 and immediate)
    b_mux u_b_mux (
        .rdata2       (rdata2),
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
        .clock(clk),
        .reset(reset),
        .addr (alu_out),
        .wdata(rdata2),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .rdata(rdata)
    );

    // Writeback Mux (selects between ALU result, data memory, PC+4)
    data_memory_mux u_data_memory_mux (
        .alu_out  (alu_out),
        .rdata    (rdata),
        .pc_plus_4(pc_plus_4_out),
        .wb_sel   (wb_sel),
        .wdata    (wb_data)
    );

    // Branch Condition
    branch_condition u_branch_condition (
        .rdata1  (rdata1),
        .rdata2  (rdata2),
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

endmodule