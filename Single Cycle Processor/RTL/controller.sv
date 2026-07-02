module controller (

    input  logic [31:0] Inst,

    output logic        reg_wr,
    output logic        sel_A,
    output logic        sel_B,
    output logic [3:0]  alu_op,
    output logic [2:0]  br_type,
    output logic        rd_en,
    output logic        wr_en,
    output logic [1:0]  wb_sel

);

logic [6:0] opcode;
logic [2:0] func3;
logic [6:0] func7;

always_comb begin
    opcode  = Inst [6:0];
    func3   = Inst [14:12];
    func7   = Inst [31:25];
    alu_op  = 4'h0;
    reg_wr  = 1'b0;
    sel_A   = 1'b1;
    sel_B   = 1'b0;
    rd_en   = 1'b0;
    wr_en   = 1'b0;
    wb_sel  = 2'b00;
    br_type = 3'd2;

    case (opcode)

// R-Type Instructions
        7'b0110011: begin
            reg_wr  = 1'b1;
            sel_A   = 1'b1;
            sel_B   = 1'b0;
            rd_en   = 1'b0;
            wr_en   = 1'b0;
            wb_sel  = 2'b00;
            br_type = 3'd2;
            
            case (func3)
                3'd0: begin
                    if (func7 == 7'b0100000) begin
                        alu_op = 4'd1;
                    end
                    else begin
                        alu_op = 4'h0;
                    end
                end
                3'd1: alu_op = 4'h2;
                3'd2: alu_op = 4'h3; 
                3'd3: alu_op = 4'h4; 
                3'd4: alu_op = 4'h5;
                3'd5: begin
                    if (func7 == 7'b0100000) begin
                        alu_op = 4'd7;
                    end
                    else begin
                        alu_op = 4'd6;
                    end
                end
                3'd6: alu_op = 4'h8;
                3'd7: alu_op = 4'h9;
                default: alu_op = 4'h0; 
            endcase
        end

// I-Type Instructions
        7'b0010011: begin
            reg_wr  = 1'b1;
            sel_A   = 1'b1;
            sel_B   = 1'b1;
            rd_en   = 1'b0;
            wr_en   = 1'b0;
            wb_sel  = 2'b00;
            br_type = 3'd2;
            
            case (func3)
                3'd0: alu_op = 4'h0;
                3'd1: alu_op = 4'h2;
                3'd2: alu_op = 4'd3; 
                3'd3: alu_op = 4'd4; 
                3'd4: alu_op = 4'h5;
                3'd5: begin
                    if (func7 == 7'b0100000) begin
                        alu_op = 4'd7;
                    end
                    else begin
                        alu_op = 4'd6;
                    end
                end
                3'd6: alu_op = 4'h8;
                3'd7: alu_op = 4'h9;
                default: alu_op = 4'h0; 
            endcase
        end

        // Load type  instructions:
            7'b0000011: begin
                reg_wr  = 1'b1;
                sel_A   = 1'b1;
                sel_B   = 1'b1;
                rd_en   = 1'b1;
                wr_en   = 1'b0;
                wb_sel  = 2'b01;
                br_type = 3'd2;
                alu_op  = 4'h0;
            end

            // Store type  instructions
            7'b0100011: begin
                reg_wr  = 1'b0;
                sel_A   = 1'b1;
                sel_B   = 1'b1;
                rd_en   = 1'b0;
                wr_en   = 1'b1;
                wb_sel  = 2'b01;
                br_type = 3'd2;
                alu_op  = 4'h0;
            end

            // Branch type instructions
            7'b1100011:begin
                reg_wr  = 1'b0;
                sel_A   = 1'b0;
                sel_B   = 1'b1;
                rd_en   = 1'b0;
                wr_en   = 1'b0;
                wb_sel  = 2'b01;
                br_type = func3;
                alu_op  = 4'h0;
            end
            
            // U type instructions (LUI)
            7'b0110111: begin
                reg_wr  = 1'b1;
                sel_A   = 1'b0;
                sel_B   = 1'b1;
                rd_en   = 1'b0;
                wr_en   = 1'b0;
                wb_sel  = 2'b00;
                br_type = 3'd2;
                alu_op  = 4'd12;
            end 

            // U type instructions (AUI)
            7'b0010111:begin
                reg_wr  = 1'b1;
                sel_A   = 0;
                sel_B   = 1;
                rd_en   = 1'b0;
                wr_en   = 1'b0;
                wb_sel  = 2'b00;
                br_type = 3'd2;
                alu_op  = 4'd0;
            end 

            // Jump type instructions   (JAL)
            7'b1101111:begin
                reg_wr  = 1'b1;
                sel_A   = 1'b0;
                sel_B   = 1'b1;
                rd_en   = 1'b0;
                wr_en   = 1'b0;
                wb_sel  = 2'b10;
                br_type = 3'd3;
                alu_op  = 4'd0;
            end

            // JAL type instruction
            7'b1100111 :begin
                reg_wr  = 1'b1;
                sel_A   = 1'b1;
                sel_B   = 1'b1;
                rd_en   = 1'b0;
                wr_en   = 1'b0;
                wb_sel  = 2'b10;
                br_type = 3'd3;
                alu_op  = 4'd0;
            end

            default: begin
                reg_wr  = 1'b0;
                sel_A   = 1'b1;
                sel_B   = 1'b0;
                rd_en   = 1'b0;
                wr_en   = 1'b0;
                wb_sel  = 2'b00;
                br_type = 3'd2;
                alu_op  = 4'h0;
            end
        endcase
    end

endmodule
