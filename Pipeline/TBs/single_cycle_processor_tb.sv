module single_cycle_processor_tb;
    logic clock;
    logic reset;

    single_cycle_processor uut(.clock(clock),.reset(reset));
    initial begin
        reset = 1'b1;
        clock = 1'b0;
        #2 reset = 1'b0;
        #30 reset = 1'b1;
        #5 $stop;
    end
    always #1 clock = ~clock;
endmodule