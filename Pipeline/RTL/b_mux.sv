module b_mux (

    input  logic [31:0]  rdata2,
    input  logic [31:0]  immediate_out,
    input  logic         sel_B,

    output logic [31:0]  b_out
);

always_comb begin
    if (sel_B) begin
        b_out = immediate_out;
    end
    else begin
        b_out = rdata2;
    end
end
endmodule
