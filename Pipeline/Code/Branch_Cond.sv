// Branch Condition
module Branch_Cond ( rdata1, rdata2, br_type, br_taken );
input  logic [31:0] rdata1;
input  logic [31:0] rdata2;
input  logic [2:0 ] br_type;
output logic br_taken;
always_comb
begin
        case ( br_type )
        3'd0: br_taken = ( rdata1 == rdata2 ) ? 1'b1 : 1'b0 ;
        3'd1: br_taken = ( rdata1 != rdata2 ) ? 1'b1 : 1'b0 ;
        3'd4: br_taken = ( rdata1 <  rdata2 ) ? 1'b1 : 1'b0 ;
        3'd6: br_taken = (($unsigned(rdata1)) < ($unsigned(rdata2))) ? 1'b1 : 1'b0 ;
        3'd5: br_taken = ( rdata1 >= rdata2 ) ? 1'b1 : 1'b0; 
        3'd7: br_taken = (($unsigned(rdata1)) >= ($unsigned(rdata2))) ? 1'b1 :1'b0 ;
        3'd2: br_taken = 3'd0;
        3'd3: br_taken = 1'b1;
        default: br_taken = 1'b0; 
        endcase
end   
endmodule