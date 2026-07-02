module data_memory_mux (

    input  logic [31:0] alu_out,
    input  logic [31:0] rdata,
    input  logic [31:0] pc_plus_4,
    
    input  logic [1:0]  wb_sel,

    output logic [31:0] wdata

);

always_comb begin
    case (wb_sel) 
        2'b00: wdata = alu_out;
        2'b01: wdata = rdata;
        2'b10: wdata = pc_plus_4;
        default: wdata = alu_out;
    endcase
end

endmodule

