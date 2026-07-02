module fpga_top (
    input  logic clk,           // 100MHz clock from Nexys A7
    input  logic reset_btn,     // Reset button (CPU_RESET on Nexys A7 is active-low)
    input  logic [1:0] sw,      // Switches to select what to display
    
    // UART Pins
    input  logic serial_in,
    output logic serial_out,
    
    // 7-Segment Display Pins
    output logic an0, an1, an2, an3, an4, an5, an6, an7,
    output logic segA, segB, segC, segD, segE, segF, segG
);

    // Nexys A7 uses active-low for CPU_RESET button. We invert it for our active-high reset logic.
    // If you use a normal switch/button, remove the ~ symbol.
    logic reset;
    assign reset = ~reset_btn; 

    // Internal wires to catch debug signals from CPU
    logic [31:0] debug_pc;
    logic [31:0] debug_alu_out;
    logic [31:0] debug_inst;
    logic [31:0] debug_wb_data;

    // Instantiate Processor
    single_cycle_processor my_cpu (
        .clock(clk),
        .reset(reset),
        .serial_in(serial_in),
        .serial_out(serial_out),
        .debug_pc(debug_pc),
        .debug_alu_out(debug_alu_out),
        .debug_inst(debug_inst),
        .debug_wb_data(debug_wb_data)
    );

    // Multiplexer to select what to display based on switches
    logic [31:0] display_data;
    always_comb begin
        case (sw)
            2'b00: display_data = debug_pc;        // Switch 00: Show PC
            2'b01: display_data = debug_inst;      // Switch 01: Show Instruction
            2'b10: display_data = debug_alu_out;   // Switch 10: Show ALU Result
            2'b11: display_data = debug_wb_data;   // Switch 11: Show Writeback Data
            default: display_data = debug_pc;
        endcase
    end

    // Map the 32-bit display_data to the 8x4-bit array expected by sim_dis
    logic [3:0] display_num [7:0];
    assign display_num[0] = display_data[3:0];
    assign display_num[1] = display_data[7:4];
    assign display_num[2] = display_data[11:8];
    assign display_num[3] = display_data[15:12];
    assign display_num[4] = display_data[19:16];
    assign display_num[5] = display_data[23:20];
    assign display_num[6] = display_data[27:24];
    assign display_num[7] = display_data[31:28];

    // Instantiate 7-Segment Display Controller
    sim_dis my_display (
        .clk(clk),
        .reset(reset),
        .num(display_num),
        .an0(an0), .an1(an1), .an2(an2), .an3(an3), 
        .an4(an4), .an5(an5), .an6(an6), .an7(an7),
        .segA(segA), .segB(segB), .segC(segC), .segD(segD), 
        .segE(segE), .segF(segF), .segG(segG)
    );

endmodule
