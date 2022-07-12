module shift_reg (
	input clk_50,
	input reset_n,
	input serial_data,
	input data_ena,
	output logic [7:0] data_to_fifo
);

reg [7:0] temp_reg;

always_ff @(posedge clk_50, negedge reset_n) begin
	if (!reset_n) temp_reg <= 8’d0;
	else if (data_ena) temp_reg <= {serial_data, temp_reg[7:1]}; //shift serial data into the register
	else temp_reg <= temp_reg;
end

always_ff @(posedge clk_50, negedge reset_n) begin
	if (!reset_n) data_to_fifo <= 8’d0;
	else if (!data_ena) data_to_fifo <= temp_reg; //after all data in send to data_to_fifo line
end

endmodule