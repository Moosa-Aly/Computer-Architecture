module baud_rate #(
    parameter CLOCK_FREQUENCY = 50_000_000,
    parameter BAUD_RATE = 9600
)(
    input  logic clock,
    input  logic reset_n,
    output logic tick_1x,
    output logic tick_16x
);

localparam integer DIVISOR_16X = CLOCK_FREQUENCY / (BAUD_RATE * 16);
localparam integer COUNTER_WIDTH_16X = $clog2(DIVISOR_16X);

logic [COUNTER_WIDTH_16X-1:0] counter_16x;
logic [3:0] counter_1x;

always_ff @(posedge clock or negedge reset_n) begin
    if (!reset_n) begin
        counter_16x <= '0;
        tick_16x    <= 1'b0;
    end
    else begin
        if (counter_16x == DIVISOR_16X - 1) begin
            counter_16x <= '0;
            tick_16x    <= 1'b1;
        end
        else begin
            counter_16x <= counter_16x + 1'b1;
            tick_16x    <= 1'b0;
        end
    end
end

always_ff @(posedge clock or negedge reset_n) begin
    if (!reset_n) begin
        counter_1x <= '0;
        tick_1x    <= 1'b0;
    end
    else begin
        if (tick_16x) begin
            counter_1x <= counter_1x + 1'b1;
            if (counter_1x == 4'd15) begin
                tick_1x <= 1'b1;
            end else begin
                tick_1x <= 1'b0;
            end
        end
        else begin
            tick_1x <= 1'b0;
        end
    end
end

endmodule