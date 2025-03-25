module single_cycle_processor_tb;
    logic clk;
    logic reset;

    single_cycle_processor uut(.clk(clk),.reset(reset));
    initial begin
        reset = 1'b1;
        clk = 1'b0;
        #2 reset = 1'b0;
        #30 reset = 1'b1;
        #5 $stop;
    end
    always #1 clk = ~clk;
endmodule