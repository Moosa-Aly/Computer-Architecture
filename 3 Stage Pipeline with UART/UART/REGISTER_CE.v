// Simple register with clock enable
module REGISTER_CE #(parameter N = 1) (
    input  clk,
    input  [N-1:0] d,
    input  ce,
    output reg [N-1:0] q
);
    initial q = {N{1'b0}};
    always @(posedge clk) begin
        if (ce) q <= d;
    end
endmodule
