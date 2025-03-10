// ALU
module ALU ( A_Mux_out, B_Mux_out, alu_op, ALU_result );
input  logic [31:0]  A_Mux_out, B_Mux_out;
input  logic [3:0 ]  alu_op;
output logic [31:0]  ALU_result;
always_comb
begin
        case (alu_op)
        4'd0    :ALU_result = A_Mux_out + B_Mux_out;
        4'd1    :ALU_result = A_Mux_out - B_Mux_out;
        4'd2    :ALU_result = A_Mux_out << B_Mux_out;
        4'd3    :ALU_result = ($signed   (A_Mux_out)) < ( $signed(B_Mux_out) );
        4'd4    :ALU_result = ($unsigned (A_Mux_out)) < ($unsigned(B_Mux_out));
        4'd5    :ALU_result = A_Mux_out ^ B_Mux_out; 
        4'd6    :ALU_result = A_Mux_out >>  B_Mux_out[4:0];
        4'd7    :ALU_result = A_Mux_out >>> B_Mux_out[4:0];
        4'd8    :ALU_result = A_Mux_out | B_Mux_out;
        4'd9    :ALU_result = A_Mux_out & B_Mux_out;
        4'd10   :ALU_result = (A_Mux_out < B_Mux_out) ? 1:0 ;
        4'd11   :ALU_result = ($unsigned(A_Mux_out) < $unsigned(B_Mux_out)) ? 1:0 ;
        4'd12   :ALU_result = B_Mux_out;
        default :ALU_result = A_Mux_out + B_Mux_out;
        endcase
end
endmodule