module forward_B_mux (
    input  logic clock,
    input  logic reset,
    input  logic [31:0] rdata2,
    input  logic [31:0] wb_data,
    input  logic        forward_sel_B,
    output logic [31:0] data2
);

always_comb begin
    if (forward_sel_B) begin
        data2 = wb_data;
    end
    else begin
        data2 = rdata2;
    end
end

endmodule