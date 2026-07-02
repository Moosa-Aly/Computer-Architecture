module pc_plus_4 (
    input  logic [31:0] pc_out,
    output logic [31:0] pc_plus_4
);

always_comb begin
    pc_plus_4 = pc_out + 32'h4;
end

endmodule
    