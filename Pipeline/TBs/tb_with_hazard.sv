module tb_with_hazard;
    logic clock;
    logic reset;

    single_cycle_processor uut(.clock(clock),.reset(reset));

    initial begin
        clock = 1'b0;
        forever #10 clock = ~clock; // Period 20
    end

    initial begin
        $display("=================================================");
        $display("Starting Simulation for with_hazard.hex");
        // Load the memory
        for (integer i=0; i<32; i=i+1) begin
            uut.u_instruction_memory.instruction_memory_reg[i] = 32'h0;
        end
        $readmemh("c:/Users/Moosa/Desktop/3 Stage Pipeline/with_hazard.hex", uut.u_instruction_memory.instruction_memory_reg);
        
        reset = 1'b1;
        #30;
        reset = 1'b0;
        
        #500;
        
        // Print registers that were modified
        $display("x1  = %0d", uut.u_register_file.register_file_reg[1]);
        $display("x2  = %0d", uut.u_register_file.register_file_reg[2]);
        $display("x3  = %0d", uut.u_register_file.register_file_reg[3]);
        $display("x4  = %0d", uut.u_register_file.register_file_reg[4]);
        $display("x5  = %0d", uut.u_register_file.register_file_reg[5]);
        $display("x6  = %0d", uut.u_register_file.register_file_reg[6]);
        $display("x8  = %0d", uut.u_register_file.register_file_reg[8]);
        $display("x9  = %0d", uut.u_register_file.register_file_reg[9]);
        $display("x11 = %0d", uut.u_register_file.register_file_reg[11]);
        $display("Memory[0x10] = %0d", uut.u_data_memory.data_memory_reg[16]);
        $display("Memory[0x20] = %0d", uut.u_data_memory.data_memory_reg[32]);
        $display("=================================================");
        $stop;
    end
endmodule
