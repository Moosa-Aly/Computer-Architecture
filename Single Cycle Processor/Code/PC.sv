//Program Counter
module PC ( clk, reset, bc_pc_out, PC_out );
input  logic clk, reset;
input  logic [ 31:0 ] bc_pc_out;
output logic [ 31:0 ] PC_out;
always_ff @( posedge clk )
begin
        if ( reset ) begin
        PC_out <= 32'b0;
        end
        else begin
        PC_out <= bc_pc_out; 
        end
end
endmodule