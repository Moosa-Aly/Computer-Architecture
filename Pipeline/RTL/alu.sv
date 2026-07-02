module alu (

    input  logic [31:0]  a_out,
    input  logic [31:0]  b_out,
    input  logic [3:0]   alu_op,

    output logic [31:0]  alu_out
);

always_comb begin
    case (alu_op)
        4'd0    :alu_out = a_out + b_out;
        4'd1    :alu_out = a_out - b_out;
        4'd2    :alu_out = a_out << b_out[4:0];
        4'd3    :alu_out = ($signed   (a_out)) < ( $signed(b_out) );
        4'd4    :alu_out = ($unsigned (a_out)) < ($unsigned(b_out));
        4'd5    :alu_out = a_out ^ b_out; 
        4'd6    :alu_out = a_out >>  b_out[4:0];
        4'd7    :alu_out = $signed(a_out) >>> b_out[4:0];
        4'd8    :alu_out = a_out | b_out;
        4'd9    :alu_out = a_out & b_out;
        4'd10   :alu_out = (a_out < b_out) ? 1:0 ;
        4'd11   :alu_out = ($unsigned(a_out) < $unsigned(b_out)) ? 1:0 ;
        4'd12   :alu_out = b_out;
        default :alu_out = a_out + b_out;
        endcase
end
endmodule

