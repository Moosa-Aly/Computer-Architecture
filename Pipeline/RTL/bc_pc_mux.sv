module bc_pc_mux (

    input  logic [31:0] pc_plus_4,
    input  logic [31:0] alu_out,
    
    input  logic        br_taken,
    
    output logic [31:0] bc_pc_out

);

always_comb begin
    if (br_taken) begin
        bc_pc_out = alu_out;
    end
    else begin
        bc_pc_out = pc_plus_4;
    end
end

endmodule