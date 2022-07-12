module gcd(
	input [31:0] a_in, //operand a
	input [31:0] b_in, //operand b
	input start, //validates the input data
	input reset_n, //reset
	input clk, //clock
	output reg [31:0] result, //output of GCD engine
	output reg done //validates output value
);

reg [31:0] reg_a;
reg [31:0] reg_b;

reg a_lt_b; // high if a < b

// state machine
enum logic [1:0] {
	IDLE = 2’b00,
	RUN = 2’b01,
	FINISH = 2’b10
} gcd_ps, gcd_ns;

// reg_a states
enum logic [1:0] {
	HOLD_A = 2’b00,
	LOAD_A = 2’b01,
	SUB_A = 2’b10,
	SWAP_A = 2’b11
} reg_a_sel;

// reg_b states
enum logic [1:0] {
	HOLD_B = 2’b00,
	LOAD_B = 2’b01,
	SWAP_B = 2’b10
} reg_b_sel;

// set states
always_ff @(posedge clk, negedge reset_n) begin
	if (!reset_n) gcd_ps <= IDLE;
	else gcd_ps <= gcd_ns;
end

// reg_a control
always_ff @(posedge clk, negedge reset_n) begin
	if (!reset_n) reg_a <= 32’d0;
	else begin
		unique case (reg_a_sel)
			HOLD_A: reg_a <= reg_a;
			LOAD_A: reg_a <= a_in;
			SUB_A: reg_a <= (reg_a − reg_b); // reg_a gets a − b
			SWAP_A: reg_a <= reg_b; // reg_a gets b
		endcase
	end
end

// reg_b control
always_ff @(posedge clk, negedge reset_n) begin
	if (!reset_n) reg_b <= 32’d0;
	else begin
		unique case (reg_b_sel)
			HOLD_B: reg_b <= reg_b;
			LOAD_B: reg_b <= b_in;
			SWAP_B: reg_b <= reg_a; // reg_b gets a
			default: reg_b <= reg_b;
		endcase
	end
end

// set a_lt_b bit
always_comb begin
	if (reg_a < reg_b) a_lt_b = 1’d1; // if a < b a_lt_b bit is 1
	else a_lt_b = 1’d0; // else a_lt_b bit is 0
end

// gcd state logic
always_comb begin
	if (!reset_n) begin
		done = 1’d0;
		result = 32’dx;
		gcd_ns = IDLE;
		reg_a_sel = HOLD_A;
		reg_b_sel = HOLD_B;
	end
	else begin
		unique case (gcd_ps)
			IDLE: begin
				done = 1’d0;
				result = 32’dx;
				if (start) begin
					gcd_ns = RUN;
					reg_a_sel = LOAD_A;
					reg_b_sel = LOAD_B;
				end // if
				else begin
					gcd_ns = IDLE;
					reg_a_sel = HOLD_A;
					reg_b_sel = HOLD_B;
				end // else
			end // IDLE
			RUN: begin
				if (a_lt_b) begin // if a_lt_b registers must swap
					gcd_ns = RUN;
					reg_a_sel = SWAP_A;
					reg_b_sel = SWAP_B;
				end // if
				else if (reg_b != 0) begin // if b not 0 sub a keep b
					gcd_ns = RUN;
					reg_a_sel = SUB_A;
					reg_b_sel = HOLD_B;
				end // else if
				else begin // else it is done
					gcd_ns = FINISH;
					reg_a_sel = HOLD_A;
					reg_b_sel = HOLD_B;
				end // else
			end // RUN
			FINISH: begin
				result = reg_a; // when done result is a
				done = 1’d1;
				gcd_ns = IDLE;
				reg_a_sel = HOLD_A;
				reg_b_sel = HOLD_B;
			end // FINISH
			default: begin
				gcd_ns = IDLE;
				reg_a_sel = HOLD_A;
				reg_b_sel = HOLD_B;
			end // default
		endcase
	end // else
end // always_comb

endmodule