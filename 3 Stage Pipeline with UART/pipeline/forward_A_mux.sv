module forward_A_mux (
    input  logic clock,
    input  logic reset,
    input  logic [31:0] rdata1,
    input  logic [31:0] wb_data,
    input  logic        forward_sel_A,
    output logic [31:0] data1
);

always_comb begin
    if (forward_sel_A) begin
        data1 = wb_data;
    end
    else begin
        data1 = rdata1;
    end
end

endmodule