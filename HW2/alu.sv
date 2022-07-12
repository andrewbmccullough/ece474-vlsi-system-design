module alu(
	input [7:0] in_a , //input a
	input [7:0] in_b , //input b
	input [3:0] opcode , //opcode input
	output reg [7:0] alu_out , //alu output
	output reg alu_zero , //logic ’1’ when alu_output [7:0] is all zeros
	output reg alu_carry //indicates a carry out from ALU
);

reg [8:0] temp_result;

parameter c_add = 4’h1;
parameter c_sub = 4’h2;
parameter c_inc = 4’h3;
parameter c_dec = 4’h4;
parameter c_or = 4’h5;
parameter c_and = 4’h6;
parameter c_xor = 4’h7;
parameter c_shr = 4’h8;
parameter c_shl = 4’h9;
parameter c_onescomp = 4’hA;
parameter c_twoscomp = 4’hB;

always_comb begin

	case (opcode)
		c_add: temp_result = 9’(in_a + in_b);
		c_sub: temp_result = 9’(in_a − in_b);
		c_inc: temp_result = 9’(in_a + 1);
		c_dec: temp_result = 9’(in_a − 1);
		c_or: temp_result = 9’(in_a | in_b);
		c_and: temp_result = 9’(in_a & in_b);
		c_xor: temp_result = 9’(in_a ^ in_b);
		c_shr: temp_result = 9’(in_a >> 1);
		c_shl: temp_result = 9’(in_a << 1);
		c_onescomp: temp_result = 9’(8’(~in_a));
		c_twoscomp: temp_result = 9’(8’(~in_a) + 1);
		default: temp_result = 9’b0xxxxxxxx;
	endcase

	if (temp_result[7:0] == 8’b0) alu_zero = 1; else if ((temp_result[7] || temp_result[6] || temp_result[5] || temp_result[ 4] || temp_result[3] || temp_result[2] || temp_result[1] || temp_result[0]) == 1
’bx) alu_zero = 1’bx;
	else alu_zero = 0;
end

assign alu_out = temp_result[7:0];
assign alu_carry = temp_result[8];

endmodule