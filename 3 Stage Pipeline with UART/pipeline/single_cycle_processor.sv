module single_cycle_processor (
    input logic clock,
    input logic reset,
    // UART serial pins
    input  logic serial_in,
    output logic serial_out,
    
    // Debug outputs for FPGA display
    output logic [31:0] debug_pc,
    output logic [31:0] debug_alu_out,
    output logic [31:0] debug_inst,
    output logic [31:0] debug_wb_data
);

    // =========================================================================
    // UART MMIO Address Map
    // =========================================================================
    localparam logic [31:0] UART_TX_ADDR     = 32'h0000_4000;  // Write: send byte
    localparam logic [31:0] UART_RX_ADDR     = 32'h0000_4004;  // Read:  received byte
    localparam logic [31:0] UART_STATUS_ADDR = 32'h0000_4008;  // Read:  {30'b0, rx_valid, tx_ready}

    // =========================================================================
    // Internal signals (original pipeline)
    // =========================================================================
    logic [31:0] pc_out, rdata1, rdata2, Inst, wb_data, alu_out, immediate_out;
    logic [31:0] b_out, bc_pc_out, a_out, pc_plus_4_out;
    logic [31:0] pc_out_1, Inst_1, data1, data2, addr_mem, wdata_mem, Inst_mem, PC_mem, PC_out_mem;
    logic [3:0]  alu_op;
    logic [2:0]  br_type;
    logic [1:0]  wb_sel, wb_sel_mem;
    logic        reg_wr, sel_B, rd_en, wr_en, br_taken, sel_A, reg_wr_mem, rd_en_mem, wr_en_mem, forward_sel_A, forward_sel_B;
    logic        stall;
    logic [31:0] pc_plus_4_mem;

    assign pc_plus_4_mem = PC_mem + 32'd4;

    // =========================================================================
    // UART MMIO signals
    // =========================================================================
    logic        is_uart_addr;
    logic        ram_wr_en, ram_rd_en;
    logic [31:0] ram_rdata;       // data from RAM
    logic [31:0] uart_rdata;      // data from UART registers
    logic [31:0] final_rdata;     // muxed read data

    // UART handshake signals
    logic [7:0]  uart_tx_data;
    logic        uart_tx_valid;
    logic        uart_tx_ready;
    logic [7:0]  uart_rx_data;
    logic        uart_rx_valid;
    logic        uart_rx_ready;

    // =========================================================================
    // Address Decoding: route to RAM or UART
    // =========================================================================
    assign is_uart_addr = (addr_mem == UART_TX_ADDR) ||
                          (addr_mem == UART_RX_ADDR) ||
                          (addr_mem == UART_STATUS_ADDR);

    // RAM only gets write/read when address is NOT in UART range
    assign ram_wr_en = wr_en_mem & ~is_uart_addr;
    assign ram_rd_en = rd_en_mem & ~is_uart_addr;

    // =========================================================================
    // UART TX handshake: CPU writes to UART_TX_ADDR
    // =========================================================================
    assign uart_tx_data  = wdata_mem[7:0];
    assign uart_tx_valid = wr_en_mem & (addr_mem == UART_TX_ADDR);

    // =========================================================================
    // UART RX handshake: CPU reads from UART_RX_ADDR (acknowledges byte)
    // =========================================================================
    assign uart_rx_ready = rd_en_mem & (addr_mem == UART_RX_ADDR);

    // =========================================================================
    // UART Read MUX: select what CPU reads from UART address space
    // =========================================================================
    always_comb begin
        case (addr_mem)
            UART_RX_ADDR:     uart_rdata = {24'b0, uart_rx_data};
            UART_STATUS_ADDR: uart_rdata = {30'b0, uart_rx_valid, uart_tx_ready};
            default:          uart_rdata = 32'b0;
        endcase
    end

    // Final read data: UART or RAM
    assign final_rdata = is_uart_addr ? uart_rdata : ram_rdata;

    // =========================================================================
    // UART Instance
    // =========================================================================
    uart #(
        .CLOCK_FREQ(100_000_000),  // 100 MHz for Nexys A7
        .BAUD_RATE (115_200)
    ) u_uart (
        .clk           (clock),
        .reset         (reset),
        // TX
        .data_in       (uart_tx_data),
        .data_in_valid (uart_tx_valid),
        .data_in_ready (uart_tx_ready),
        // RX
        .data_out      (uart_rx_data),
        .data_out_valid(uart_rx_valid),
        .data_out_ready(uart_rx_ready),
        // Serial pins
        .serial_in     (serial_in),
        .serial_out    (serial_out)
    );

    // =========================================================================
    // Program Counter
    // =========================================================================
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
        .reg_wr_mem(reg_wr_mem),
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

    // Data Memory — uses filtered ram_wr_en / ram_rd_en
    data_memory u_data_memory (
        .clock(clock),
        .reset(reset),
        .addr (addr_mem),
        .wdata(wdata_mem),
        .wr_en(ram_wr_en),
        .rd_en(ram_rd_en),
        .rdata(ram_rdata)
    );

    // Writeback Mux — uses final_rdata (RAM or UART)
    data_memory_mux u_data_memory_mux (
        .alu_out  (addr_mem),
        .rdata    (final_rdata),
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


    // =========================================================================
    // Debug Assignments for FPGA Display
    // =========================================================================
    assign debug_pc = pc_out;
    assign debug_alu_out = alu_out;
    assign debug_inst = Inst;
    assign debug_wb_data = wb_data;

endmodule