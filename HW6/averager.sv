module averager (
	input clk_2,
	input reset_n,
	input rd_fifo,
	input rst_ram,
	input [7:0] data_from_fifo,
	output logic [7:0] avg_val,
	output logic [7:0] ram_data
);

reg [9:0] avg_reg;

assign ram_data = avg_reg[9:2]; //take top 8 bits to divide by 4
assign avg_val = ram_data; //data to ctrl_2 for checking in range of 0−127

always_ff @(posedge clk_2, negedge reset_n) begin
	if (!reset_n) avg_reg <= 10’d0;
	else if (rd_fifo) begin
		if (rst_ram) avg_reg <= {2’b0 , data_from_fifo}; //reset after each cycle
		else avg_reg <= (avg_reg + {2’b0 , data_from_fifo}); //add bytes together
	end
	else avg_reg <= avg_reg;
end

endmodule