module a_mux (

    input  logic [31:0]  pc_out,
    input  logic [31:0]  rdata1,
    input  logic         sel_A,

    output logic [31:0]  a_out
);

always_comb begin
    if (sel_A) begin
        a_out = rdata1;
    end
    else begin
        a_out = pc_out;
    end
end
endmodule