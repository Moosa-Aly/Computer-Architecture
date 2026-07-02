// Register with synchronous reset and clock enable
module REGISTER_R_CE #(parameter N = 1) (
    input  clk,
    input  [N-1:0] d,
    input  ce,
    input  rst,
    output reg [N-1:0] q
);
    initial q = {N{1'b0}};
    always @(posedge clk) begin
        if (rst)     q <= {N{1'b0}};
        else if (ce) q <= d;
    end
endmodule
