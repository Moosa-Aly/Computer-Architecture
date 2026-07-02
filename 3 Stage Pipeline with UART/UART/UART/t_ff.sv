module t_ff (
    input  logic clk,
    input  logic reset,
    output logic clk_out
);
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_out <= 1'b0;
        end else begin
            clk_out <= ~clk_out;
        end
    end
endmodule
