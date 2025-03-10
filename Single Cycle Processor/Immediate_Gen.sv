//Immediate Generator
module Immediate_Gen ( Inst, immediate_out );
input logic  [31:0] Inst;
output logic [31:0] immediate_out;
logic [6:0 ] opcode;
logic signed [31:0] immediate;
always_comb
begin
        opcode = Inst [6:0];
        immediate = 32'b0;
        case ( opcode )
// I-Type   (load)      (ALU immediate)     (JALR)
          7'b0000011,     7'b0010011,     7'b1100111:
          immediate = {{20{Inst[31]}}, Inst[31:20]};
// S-Type   (store)
          7'b0100011:
          immediate = {{20{Inst[31]}}, Inst[31:25], Inst[11:7]};
// B-Type  (branch)
          7'b1100011:
          immediate = {{19{Inst[31]}}, Inst[31], Inst[7], Inst[30:25], Inst[11:8], 1'b0};
// U-Type   (LUI)        (AUIPC)
          7'b0110111,   7'b0010111:
          immediate = {Inst[31:12], 12'b0};
// J-Type   (JAL)
          7'b1101111:
          immediate = {{11{Inst[31]}}, Inst[31], Inst[19:12], Inst[20], Inst[30:21], 1'b0};

          default:
          immediate = 32'b0;
        endcase
        
        immediate_out = immediate;
end
endmodule
