module a5_or_c3 (
	input [7:0] data_to_fifo,
	output logic header
);

always_comb begin if ((data_to_fifo == 8’hA5) || (data_to_fifo == 8’hC3)) header = 1’b1;
	if get A5 or C3 toggle header
	else header = 1’b0;
end
	
endmodule