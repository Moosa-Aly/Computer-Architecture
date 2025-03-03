// ALU
module ALU ( a, b, alu_op, ALU_result );
input  logic [31:0]  a, b;
input  logic [3:0 ]  alu_op;
output logic [31:0]  ALU_result;
always_comb
begin
        case (alu_op)
        4'd0    :ALU_result = a + b;
        4'd1    :ALU_result = a - b;
        4'd2    :ALU_result = a << b;
        4'd3    :ALU_result = ($signed   (a)) < ( $signed(b) );
        4'd4    :ALU_result = ($unsigned (a)) < ($unsigned(b));
        4'd5    :ALU_result = a ^ b; 
        4'd6    :ALU_result = a >>  b[4:0];
        4'd7    :ALU_result = a >>> b[4:0];
        4'd8    :ALU_result = a | b;
        4'd9    :ALU_result = a & b;
        4'd10   :ALU_result = (a < b) ? 1:0 ;
        4'd11   :ALU_result = ($unsigned(a) < $unsigned(b)) ? 1:0 ;
        4'd12   :ALU_result = b;
        default :ALU_result = a + b;
        endcase
end
endmodule