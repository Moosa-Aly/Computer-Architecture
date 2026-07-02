`timescale 1ns/1ps

// ============================================================
// tb_uart_top.sv  —  Questa 2024 Testbench for uart_top
// ============================================================

module tb_uart_top;

    localparam int  CLK_FREQ       = 50_000_000;
    localparam int  BAUD           = 9600;
    localparam int  DATA_BITS      = 8;
    localparam real CLK_PERIOD_NS  = 1_000_000_000.0 / CLK_FREQ;
    localparam int  BIT_CLKS       = CLK_FREQ / BAUD;  // 5208

    // --------------------------------------------------------
    // Default 8N1 DUT
    // --------------------------------------------------------
    logic       clk, rst_n;
    logic [7:0] tx_data;
    logic       tx_start, tx_busy, tx_done;
    logic       tx_out_wire, rx_in;
    logic [7:0] rx_data;
    logic       rx_done, frame_error, parity_error;

    uart_top #(
        .CLOCK_FREQUENCY (CLK_FREQ),
        .BAUD_RATE       (BAUD),
        .DATA_BITS       (DATA_BITS),
        .PARITY          (0),
        .STOP_BITS       (1)
    ) dut (
        .clock(clk), .reset_n(rst_n),
        .rx_in(rx_in), .tx_out(tx_out_wire),
        .tx_data(tx_data), .tx_start(tx_start),
        .tx_busy(tx_busy), .tx_done(tx_done),
        .rx_data(rx_data), .rx_done(rx_done),
        .frame_error(frame_error), .parity_error(parity_error)
    );

    // --------------------------------------------------------
    // Odd-parity instance (TC6)
    // --------------------------------------------------------
    logic       clk_p, rst_n_p;
    logic [7:0] tx_data_p;
    logic       tx_start_p, tx_busy_p, tx_done_p;
    logic       tx_out_p, rx_in_p;
    logic [7:0] rx_data_p;
    logic       rx_done_p, frame_err_p, parity_err_p;

    uart_top #(
        .CLOCK_FREQUENCY(CLK_FREQ), .BAUD_RATE(BAUD),
        .DATA_BITS(DATA_BITS), .PARITY(1), .STOP_BITS(1)
    ) dut_parity (
        .clock(clk_p), .reset_n(rst_n_p),
        .rx_in(rx_in_p), .tx_out(tx_out_p),
        .tx_data(tx_data_p), .tx_start(tx_start_p),
        .tx_busy(tx_busy_p), .tx_done(tx_done_p),
        .rx_data(rx_data_p), .rx_done(rx_done_p),
        .frame_error(frame_err_p), .parity_error(parity_err_p)
    );

    // --------------------------------------------------------
    // 2-stop-bit instance (TC7)
    // --------------------------------------------------------
    logic       clk_s, rst_n_s;
    logic [7:0] tx_data_s;
    logic       tx_start_s, tx_busy_s, tx_done_s;
    logic       tx_out_s, rx_in_s;
    logic [7:0] rx_data_s;
    logic       rx_done_s, frame_err_s, parity_err_s;

    uart_top #(
        .CLOCK_FREQUENCY(CLK_FREQ), .BAUD_RATE(BAUD),
        .DATA_BITS(DATA_BITS), .PARITY(0), .STOP_BITS(2)
    ) dut_2stop (
        .clock(clk_s), .reset_n(rst_n_s),
        .rx_in(rx_in_s), .tx_out(tx_out_s),
        .tx_data(tx_data_s), .tx_start(tx_start_s),
        .tx_busy(tx_busy_s), .tx_done(tx_done_s),
        .rx_data(rx_data_s), .rx_done(rx_done_s),
        .frame_error(frame_err_s), .parity_error(parity_err_s)
    );

    // --------------------------------------------------------
    // Clocks
    // --------------------------------------------------------
    initial clk   = 0; always #(CLK_PERIOD_NS/2.0) clk   = ~clk;
    initial clk_p = 0; always #(CLK_PERIOD_NS/2.0) clk_p = ~clk_p;
    initial clk_s = 0; always #(CLK_PERIOD_NS/2.0) clk_s = ~clk_s;

    // --------------------------------------------------------
    // Scoreboard
    // --------------------------------------------------------
    int pass_cnt = 0, fail_cnt = 0;

    task automatic CHECK(input string label, input logic cond);
        if (cond) begin $display("[PASS] %s", label); pass_cnt++; end
        else      begin $display("[FAIL] %s", label); fail_cnt++; end
    endtask

    // --------------------------------------------------------
    // Reset
    // --------------------------------------------------------
    task automatic apply_reset();
        rst_n = 0; tx_start = 0; tx_data = '0; rx_in = 1'b1;
        repeat(10) @(posedge clk);
        rst_n = 1;
        repeat(5)  @(posedge clk);
    endtask

    // --------------------------------------------------------
    // Inline loopback: TX a byte, mirror tx_out->rx_in,
    // return after rx_done fires.
    // --------------------------------------------------------
    task automatic do_loopback(input logic [7:0] byte_val);
        @(posedge clk);
        tx_data  = byte_val;
        tx_start = 1'b1;
        @(posedge clk);
        tx_start = 1'b0;

        fork
            begin
                fork
                    @(posedge rx_done);
                    @(posedge tx_done);
                join
            end
            begin
                forever begin
                    @(negedge clk);
                    rx_in = tx_out_wire;
                end
            end
        join_any
        disable fork;

        rx_in = 1'b1;
        @(posedge clk);
    endtask

    // --------------------------------------------------------
    // Bit-bang a byte onto any rx_wire (error injection)
    // --------------------------------------------------------
    task automatic drive_rx_byte(
        input logic [7:0] byte_val,
        input int          parity_mode = 0,
        input int          n_stop      = 1,
        input logic        inject_fe   = 0,
        input logic        inject_pe   = 0,
        ref   logic        rx_wire
    );
        logic par_bit;
        case (parity_mode)
            1: par_bit =  ^byte_val;
            2: par_bit = ~(^byte_val);
            default: par_bit = 1'b0;
        endcase
        if (inject_pe) par_bit = ~par_bit;

        rx_wire = 1'b0;                                     // start bit
        repeat(BIT_CLKS) @(posedge clk);

        for (int i = 0; i < DATA_BITS; i++) begin           // data bits
            rx_wire = byte_val[i];
            repeat(BIT_CLKS) @(posedge clk);
        end

        if (parity_mode != 0) begin                         // parity bit
            rx_wire = par_bit;
            repeat(BIT_CLKS) @(posedge clk);
        end

        for (int s = 0; s < n_stop; s++) begin              // stop bit(s)
            rx_wire = inject_fe ? 1'b0 : 1'b1;
            repeat(BIT_CLKS) @(posedge clk);
        end

        rx_wire = 1'b1;
        repeat(BIT_CLKS) @(posedge clk);                   // idle gap
    endtask

    // ============================================================
    // TC1 – Reset / Idle
    // ============================================================
    task automatic tc1_reset_idle();
        $display("\n--- TC1: Reset / Idle ---");
        apply_reset();
        @(posedge clk);
        CHECK("TC1_tx_out_high_after_reset",   tx_out_wire  === 1'b1);
        CHECK("TC1_tx_busy_low_after_reset",   tx_busy      === 1'b0);
        CHECK("TC1_tx_done_low_after_reset",   tx_done      === 1'b0);
        CHECK("TC1_rx_done_low_after_reset",   rx_done      === 1'b0);
        CHECK("TC1_frame_err_low_after_reset", frame_error  === 1'b0);
    endtask

    // ============================================================
    // TC2 – Single byte loopback
    // ============================================================
    task automatic tc2_single_byte_loopback();
        $display("\n--- TC2: Single Byte Loopback (0xA5) ---");
        apply_reset();
        do_loopback(8'hA5);
        CHECK("TC2_data_match",      rx_data      === 8'hA5);
        CHECK("TC2_no_frame_error",  frame_error  === 1'b0);
        CHECK("TC2_no_parity_error", parity_error === 1'b0);
        CHECK("TC2_tx_busy_cleared", tx_busy      === 1'b0);
    endtask

    // ============================================================
    // TC3 – Back-to-back multi-byte loopback
    // ============================================================
    task automatic tc3_multi_byte_loopback();
        logic [7:0] payload [4] = '{8'h00, 8'hFF, 8'h55, 8'hAA};
        $display("\n--- TC3: Multi-byte Back-to-Back ---");
        apply_reset();
        foreach (payload[i]) begin
            do_loopback(payload[i]);
            CHECK($sformatf("TC3_byte%0d_match(0x%02X)", i, payload[i]),
                  rx_data === payload[i]);
            CHECK($sformatf("TC3_byte%0d_no_errors", i),
                  frame_error === 1'b0 && parity_error === 1'b0);
            repeat(BIT_CLKS / 2) @(posedge clk);
        end
    endtask

    // ============================================================
    // TC4 – tx_busy / tx_done handshake
    // ============================================================
    task automatic tc4_tx_handshake();
        $display("\n--- TC4: tx_busy / tx_done Handshake ---");
        apply_reset();

        @(posedge clk); tx_data = 8'h3C; tx_start = 1'b1;
        @(posedge clk); tx_start = 1'b0;
        repeat(3) @(posedge clk);
        CHECK("TC4_tx_busy_asserts", tx_busy === 1'b1);

        fork
            begin
                fork
                    @(posedge rx_done);
                    begin
                        @(posedge tx_done);
                        CHECK("TC4_tx_done_high",         tx_done === 1'b1);
                        repeat(2) @(posedge clk);
                        CHECK("TC4_tx_done_single_cycle", tx_done === 1'b0);
                        CHECK("TC4_tx_busy_cleared",      tx_busy === 1'b0);
                    end
                join
            end
            begin
                forever begin
                    @(negedge clk);
                    rx_in = tx_out_wire;
                end
            end
        join_any
        disable fork;

        rx_in = 1'b1;
        @(posedge clk);
    endtask

    // ============================================================
    // TC5 – Frame error injection
    // ============================================================
    task automatic tc5_frame_error();
        logic captured_fe;
        captured_fe = 0;
        $display("\n--- TC5: Frame Error Injection ---");
        apply_reset();
        fork
            begin
                drive_rx_byte(.byte_val(8'hAB), .inject_fe(1), .rx_wire(rx_in));
            end
            begin
                @(posedge rx_done);
                captured_fe = frame_error;
            end
        join
        CHECK("TC5_frame_error_flag", captured_fe === 1'b1);
    endtask

    // ============================================================
    // TC6 – Parity error injection
    // ============================================================
    task automatic tc6_parity_error();
        logic captured_pe, captured_fe;
        captured_pe = 0;
        captured_fe = 0;
        $display("\n--- TC6: Parity Error Injection ---");
        rst_n_p = 0; tx_start_p = 0; tx_data_p = '0; rx_in_p = 1'b1;
        repeat(10) @(posedge clk_p);
        rst_n_p = 1;
        repeat(5)  @(posedge clk_p);

        fork
            begin
                drive_rx_byte(.byte_val(8'hC3), .parity_mode(1),
                              .inject_pe(1), .rx_wire(rx_in_p));
            end
            begin
                @(posedge parity_err_p);
                captured_pe = 1'b1;
            end
            begin
                @(posedge rx_done_p);
                captured_fe = frame_err_p;
            end
        join
        CHECK("TC6_parity_error_detected", captured_pe === 1'b1);
        CHECK("TC6_no_frame_error",        captured_fe === 1'b0);
    endtask

    // ============================================================
    // TC7 – 2-stop-bit loopback
    // ============================================================
    task automatic tc7_two_stop_bits();
        $display("\n--- TC7: 2-Stop-Bit Loopback ---");
        rst_n_s = 0; tx_start_s = 0; tx_data_s = '0; rx_in_s = 1'b1;
        repeat(10) @(posedge clk_s);
        rst_n_s = 1;
        repeat(5)  @(posedge clk_s);

        @(posedge clk_s); tx_data_s = 8'h69; tx_start_s = 1'b1;
        @(posedge clk_s); tx_start_s = 1'b0;

        fork
            begin
                fork
                    @(posedge rx_done_s);
                    @(posedge tx_done_s);
                join
            end
            begin
                forever begin
                    @(negedge clk_s);
                    rx_in_s = tx_out_s;
                end
            end
        join_any
        disable fork;

        rx_in_s = 1'b1;
        @(posedge clk_s);

        CHECK("TC7_data_match",      rx_data_s    === 8'h69);
        CHECK("TC7_no_frame_error",  frame_err_s  === 1'b0);
        CHECK("TC7_no_parity_error", parity_err_s === 1'b0);
    endtask

    // ============================================================
    // TC8 – False-start rejection
    // ============================================================
    task automatic tc8_false_start();
        $display("\n--- TC8: False-Start Rejection ---");
        apply_reset();
        rx_in = 1'b1;

        // Glitch: only 3 tick_16x periods low — RX_START needs 7 before mid-check
        rx_in = 1'b0;
        repeat(3 * (BIT_CLKS / 16)) @(posedge clk);
        rx_in = 1'b1;

        repeat(BIT_CLKS * 12) @(posedge clk);
        CHECK("TC8_rx_done_stays_low", rx_done     === 1'b0);
        CHECK("TC8_no_frame_error",    frame_error === 1'b0);
    endtask

    // ============================================================
    // TC9 – Full byte sweep 0x00-0xFF
    // ============================================================
    task automatic tc9_full_sweep();
        int errors = 0;
        $display("\n--- TC9: Full Byte Sweep 0x00-0xFF ---");
        apply_reset();

        for (int b = 0; b <= 255; b++) begin
            do_loopback(b[7:0]);
            if (rx_data !== b[7:0]) begin
                $display("  MISMATCH: sent=0x%02X got=0x%02X", b[7:0], rx_data);
                errors++;
            end
            repeat(BIT_CLKS / 4) @(posedge clk);
        end
        CHECK("TC9_sweep_zero_errors", errors === 0);
    endtask

    // ============================================================
    // Main
    // ============================================================
    initial begin
        $display("========================================");
        $display("  UART Top-Level Testbench  (Questa 2024)");
        $display("  CLK=50MHz  BAUD=9600  8N1");
        $display("========================================");

        clk=0; clk_p=0; clk_s=0;
        rst_n=0; rst_n_p=0; rst_n_s=0;
        tx_data='0; tx_data_p='0; tx_data_s='0;
        tx_start=0; tx_start_p=0; tx_start_s=0;
        rx_in=1; rx_in_p=1; rx_in_s=1;

        tc1_reset_idle();
        tc2_single_byte_loopback();
        tc3_multi_byte_loopback();
        tc4_tx_handshake();
        tc5_frame_error();
        tc6_parity_error();
        tc7_two_stop_bits();
        tc8_false_start();
        tc9_full_sweep();

        $display("\n========================================");
        $display("  RESULTS: %0d PASSED | %0d FAILED", pass_cnt, fail_cnt);
        $display("========================================");
        $finish;
    end

    // Watchdog — 500 ms sim time
    initial begin
        #500_000_000;
        $display("[WATCHDOG] Timeout — hanging task detected");
        $finish;
    end

    initial $wlfdumpvars(0, tb_uart_top);

endmodule