module mult(
	input reset,
	input clk,
	input start,
	input [31:0] a_in,
	input [31:0] b_in,
	output logic done,
	output logic [63:0] product
);

logic [31:0] prod_reg_high;
logic [31:0] prod_reg_low;
logic [31:0] reg_a;
logic prod_reg_shift_rt;
logic prod_reg_ld_high;

//reg_a
always_ff @(posedge clk, posedge reset) begin
	if (reset) reg_a <= 32’b0; //if reset, set reg_a to 0
	else if (start) reg_a <= a_in; //if start, set reg_a to a_in
	else reg_a <= reg_a;
end

//prod_reg_high & prod_reg_ld_high & prod_reg_shift_rt
always_ff @(posedge clk, posedge reset) begin
	if (reset) prod_reg_high <= 32’b0; //if reset, set prod_reg_high to 0
	else if (start) prod_reg_high <= 32’b0; //if start, set prod_reg_high to 0
	else if (prod_reg_shift_rt) prod_reg_high <= {1’b0, prod_reg_high[31:1]};
//if shift, shift prod_reg_high to the right by 1 and bring in a 0.
	else if (prod_reg_ld_high) prod_reg_high <= (prod_reg_high + reg_a); //if
	load, add reg_a to prod_reg_high
	else prod_reg_high <= prod_reg_high; //else keep prod_reg_high the same
end

//prod_reg_low & prod_reg_shift_rt
always_ff @(posedge clk, posedge reset) begin
	if (reset) prod_reg_low <= 32’b0; //if reset, set prod_reg_low to 0
	else if (start) prod_reg_low <= b_in; //if start, set prod_reg_low to b_in
	else if (prod_reg_shift_rt) prod_reg_low <= {prod_reg_high[0], prod_reg_lo
	w[31:1]}; //if shift, shift prod_reg_low to the right and bring in LSB of prod_r
	eg_high
	else prod_reg_low <= prod_reg_low; //else keep prod_reg_low the same
end

//concatenate prod_reg_high & prod_reg_low
assign product = {prod_reg_high, prod_reg_low};

//instantiate mult_ctrl
mult_ctrl mult_ctrl_0(
	. reset ( reset ),
	. clk ( clk ),
	. start ( start ),
	. multiplier_bit0 ( prod_reg_low [0] ),
	. prod_reg_ld_high ( prod_reg_ld_high ),
	. prod_reg_shift_rt ( prod_reg_shift_rt ),
	. done ( done ));

endmodule