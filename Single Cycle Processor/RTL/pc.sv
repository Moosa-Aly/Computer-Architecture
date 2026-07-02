module pc (

    input logic  clock,
    input logic  reset,
    input logic  [31:0] bc_pc_out,

    output logic [31:0] pc_out

);

always_ff @(posedge clock) begin
    if (reset) begin
        pc_out <= 32'b0;
    end
    else begin
        pc_out <= bc_pc_out;
    end
end

endmodule