module single_cycle_processor_tb;
    logic clock;
    logic reset;

    wire serial_out;

    single_cycle_processor uut(.clock(clock),.reset(reset),.serial_in(1'b1),.serial_out(serial_out));
    initial begin
        reset = 1'b1;
        clock = 1'b0;
        #2 reset = 1'b0;
        #30 reset = 1'b1;
        #5 $stop;
    end
    always #1 clock = ~clock;
endmodule