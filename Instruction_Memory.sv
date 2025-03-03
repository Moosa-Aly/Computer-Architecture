// Instruction Memory
module Instruction_Memory ( Addr, Inst );
input  logic [ 31:0 ] Addr;
output logic [ 31:0 ] Inst;
integer k;
logic [ 31:0 ] Instruction_Memory_Reg [31:0];
always_comb
begin
        Inst = Instruction_Memory_Reg [Addr>>2];
end
initial
begin
        for ( k=0; k<32; k=k+1) begin
        Instruction_Memory_Reg [k ] = 32'h00000000;
        end
        Instruction_Memory_Reg [1 ] = 32'h123450b7;
        Instruction_Memory_Reg [2 ] = 32'h12345117;
        Instruction_Memory_Reg [3 ] = 32'h00a00113;
        Instruction_Memory_Reg [4 ] = 32'h01400093;
        Instruction_Memory_Reg [5 ] = 32'h0080006f;
        Instruction_Memory_Reg [6 ] = 32'h01e00113;
        Instruction_Memory_Reg [7 ] = 32'h001101b3;
        Instruction_Memory_Reg [8 ] = 32'h003022a3;
        Instruction_Memory_Reg [9 ] = 32'h00502303;
        Instruction_Memory_Reg [10] = 32'h00008067;
        Instruction_Memory_Reg [11] = 32'h00000013;
        Instruction_Memory_Reg [12] = 32'h0;
        Instruction_Memory_Reg [13] = 32'h0;
        Instruction_Memory_Reg [14] = 32'h0;
        Instruction_Memory_Reg [15] = 32'h0;
end
endmodule
