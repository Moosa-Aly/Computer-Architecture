//Immediate Generator
module Immediate_Gen ( Inst, Immediate_out );
input logic  [31:0] Inst;
output logic [31:0] Immediate_out;
logic [6:0 ] Opcode;
logic signed [31:0] Immediate;
always_comb
begin
        Opcode = Inst [6:0];
        Immediate = 32'b0;
        case ( Opcode )
// I-Type   (load)      (ALU immediate)     (JALR)
          7'b0000011,     7'b0010011,     7'b1100111:
          Immediate = {{20{Inst[31]}}, Inst[31:20]};
// S-Type   (store)
          7'b0100011:
          Immediate = {{20{Inst[31]}}, Inst[31:25], Inst[11:7]};
// B-Type  (branch)
          7'b1100011:
          Immediate = {{19{Inst[31]}}, Inst[31], Inst[7], Inst[30:25], Inst[11:8], 1'b0};
// U-Type   (LUI)        (AUIPC)
          7'b0110111,   7'b0010111:
          Immediate = {Inst[31:12], 12'b0};
// J-Type   (JAL)
          7'b1101111:
          Immediate = {{11{Inst[31]}}, Inst[31], Inst[19:12], Inst[20], Inst[30:21], 1'b0};

          default:
          Immediate = 32'b0;
        endcase
        
        Immediate_out = Immediate;
end
endmodule
