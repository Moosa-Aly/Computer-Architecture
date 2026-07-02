module register_file (
    
    input  logic        clock,
    input  logic        reset,
    input  logic [4:0]  raddr1,
    input  logic [4:0]  raddr2,
    input  logic [4:0]  waddr,
    input  logic [31:0] wb_data,

    input logic         reg_wr,

    output logic [31:0] rdata1,
    output logic [31:0] rdata2
);

integer i;

logic [31:0] register_file_reg [31:0];

always_comb begin
    rdata1 = register_file_reg [raddr1];
    rdata2 = register_file_reg [raddr2];
end

always_ff @(posedge clock) begin
    if (reset) begin
        for (i=0; i<32; i=i+1) begin
            register_file_reg[i] <= 32'h00000000;
        end
    end
    else if (reg_wr && waddr!= 5'd0) begin
        register_file_reg [waddr] <= wb_data;
    end
end

endmodule