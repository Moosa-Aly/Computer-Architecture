module uart_tx #(
parameter CLOCKRATE = 100000000,
parameter BAUD = 115200,
parameter WORD_LENGTH = 8
) (
input 		              clk,
input 		              reset,
input [WORD_LENGTH-1:0] tx_data,
input 		              tx_data_valid,
output 		              tx_data_ready,
output 		              UART_TX
);

// internal signals
logic                   tx_data_ready_i;
logic                   uart_tx_i = 1'b1; // Changed from 1'b0 to 1'b1 for idle state
logic [WORD_LENGTH-1:0] tx_data_i;

// store tx_data_i when valid for use later
always @(posedge clk) begin
if(reset) begin
    tx_data_i <= '0;
    end
else begin
if (tx_data_valid & tx_data_ready_i) begin
    tx_data_i <= tx_data;
    end
	end
end

// Define our states
typedef enum { IDLE, START, DATA, PARITY, STOP, WAIT }  my_state;
my_state current_state = IDLE;
my_state next_state    = IDLE;

// Define tx signal constants
localparam TX_IDLE = 1'b1;
localparam TX_START = 1'b0;
localparam TX_STOP = 1'b1;

localparam BAUD_COUNTER_MAX = CLOCKRATE / BAUD;
localparam BAUD_COUNTER_SIZE = $clog2(BAUD_COUNTER_MAX);

localparam DATA_COUNTER_MAX = WORD_LENGTH;
localparam DATA_COUNTER_SIZE = $clog2(DATA_COUNTER_MAX);

logic [BAUD_COUNTER_SIZE-1:0] uart_baud_counter;
logic [DATA_COUNTER_SIZE-1:0] uart_data_counter;
logic                         uart_baud_done;
logic                         uart_data_done;

// buffer to store tx data while shifting
logic [WORD_LENGTH-1:0] 	    uart_data_shift_buffer;

// UART Baud Clock
always @(posedge clk) begin
  if(reset) begin
    uart_baud_counter <= '0;
	end
	else begin
    // Reset at state transition
    if (uart_baud_done) begin
      uart_baud_counter <= '0;
      end
    else begin
    uart_baud_counter <= uart_baud_counter + 'd1;
    end
	end
end

// baud clock is done
assign uart_baud_done = ( uart_baud_counter == BAUD_COUNTER_MAX-1 ) ? 1'b1 : 1'b0;

// data counting and shifting
always @(posedge clk) begin
  if(reset) begin
    uart_data_counter <= '0;
    uart_data_shift_buffer <= '0;
  end
  // note uart_baud_done is clk enable
	else if (uart_baud_done) begin
    // Reset at state transition
    if (current_state != next_state) begin
        uart_data_counter <= '0;
        uart_data_shift_buffer <= tx_data_i;
    end
    else begin
    // otherwise increment counter and shift buffer
    uart_data_counter <= uart_data_counter + 'd1;
    uart_data_shift_buffer <= uart_data_shift_buffer >> 1;
    end
  end
end

// uart_data_done indicates all bits are transmitted
assign uart_data_done = ( uart_data_counter == DATA_COUNTER_MAX-1 ) ? 1'b1 : 1'b0;

// State Machine
always @(*) begin
  case (current_state)
    IDLE : begin
        if (tx_data_valid) begin
            next_state = START;
        end
        else begin
            next_state = current_state;
        end
    end
    START : begin
        if (uart_baud_done) begin
            next_state = DATA;
        end
        else begin
            next_state = current_state;
        end
    end
    DATA : begin
        if (uart_data_done & uart_baud_done) begin
            next_state = PARITY;
        end
        else begin
            next_state = current_state;
        end
    end
    PARITY : begin
        if (uart_baud_done) begin
            next_state = STOP;
        end
        else begin
            next_state = current_state;
        end
    end
    STOP : begin
        if (uart_baud_done) begin
            next_state = WAIT;
        end
        else begin
            next_state = current_state;
        end
    end
    WAIT : begin
        if (uart_baud_done) begin
            next_state = IDLE;
        end
        else begin
            next_state = current_state;
        end
    end
  default:
    next_state = current_state;
  endcase
end

always @(posedge clk) begin
	if(reset) begin
    current_state <= IDLE;
	end
	else begin
    current_state <= next_state;
	end
end

always @(*) begin
  case (current_state)
    IDLE : begin
      uart_tx_i = TX_IDLE;
    end
    START : begin
      uart_tx_i = TX_START;
    end
    DATA : begin
      uart_tx_i = uart_data_shift_buffer[0];
    end
    PARITY : begin
      uart_tx_i = ^tx_data_i;
    end
    STOP : begin
      uart_tx_i = TX_STOP;
    end
    WAIT : begin
      uart_tx_i = TX_IDLE;
    end
  endcase
end

assign tx_data_ready_i = (current_state == IDLE) ? 1'b1 : 1'b0;
assign tx_data_ready = tx_data_ready_i;
assign UART_TX = uart_tx_i;

endmodule