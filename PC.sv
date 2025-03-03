//Program Counter
module PC ( clk, reset, PC_in, PC_out );
input  logic clk, reset;
input  logic [ 31:0 ] PC_in;
output logic [ 31:0 ] PC_out;
always_ff @( posedge clk )
begin
        if ( reset ) begin
        PC_out <= 32'b0;
        end
        else begin
        PC_out <= PC_in; 
        end
end
endmodule