module mult_ctrl(
	input multiplier_bit0,
	input start,
	input clk,
	input reset,
	output logic done,
	output logic prod_reg_shift_rt,
	output logic prod_reg_ld_high
);

//6 bit register to store amount of shifts
reg [5:0] cnt;

//mult state machine
enum logic [1:0] {
	IDLE = 2’b00,
	TEST = 2’b01,
	SHIFT = 2’b10,
	ADD = 2’b11
} mult_ps, mult_ns;

//set present state flip flops
always_ff @(posedge clk, posedge reset) begin
	if (reset) begin
		mult_ps <= IDLE;
	end
	else begin
		mult_ps <= mult_ns;
	end
end //always_ff

//increments count on SHIFT and resets count on IDLE
always_ff @(posedge clk, posedge reset) begin
	if (mult_ps == SHIFT) cnt <= cnt + 1;
	else if (mult_ps == IDLE) cnt <= 6’b0;
end

//state machine logic
always_comb begin

	//logic for mult state machine
	unique case (mult_ps)

		//if start is 1 go to TEST, else if start is 0 go to IDLE
		IDLE: begin
			done = 1’b1;
			prod_reg_shift_rt = 1’b0;
			prod_reg_ld_high = 1’b0;
			if (start) mult_ns = TEST;
			else mult_ns = IDLE;
		end
		//if LSB is 1 go to ADD, else if LSB is 0 go to SHIFT
		TEST: begin
			done = 0;
			prod_reg_shift_rt = 1’b0;
			prod_reg_ld_high = 1’b0;
			if (multiplier_bit0) mult_ns = ADD;
			else mult_ns = SHIFT;
		end
		//if cnt is 32 go to IDLE, else if cnt not 32 go to TEST
		SHIFT: begin
			done = 0;
			prod_reg_ld_high = 1’b0;
			prod_reg_shift_rt = 1’b1; //shift registers
			if (cnt != 6’d31) mult_ns = TEST;
			else mult_ns = IDLE;
		end
		//go to SHIFT
		ADD: begin
			done = 0;
			prod_reg_shift_rt = 1’b0;
			prod_reg_ld_high = 1’b1; //load high register
			mult_ns = SHIFT;
		end
	endcase //mult_ps

end //always_comb

endmodule