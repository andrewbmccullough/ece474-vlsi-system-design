module ram_cnt (
	input clk_2,
	input reset_n,
	input wr_ram,
	output logic [10:0] ram_addr
);

logic [11:0] temp_ram;
assign ram_addr = temp_ram[10:0];

always_ff @(posedge clk_2, negedge reset_n) begin
	if (!reset_n) temp_ram <= 12’h800; //start 1 above to write on 7FF
	else if (wr_ram) begin
		if (temp_ram == 12’h0) temp_ram <= 12’h800; //if hit zero roll over
		else temp_ram <= (temp_ram − 1);
		end
	else temp_ram <= temp_ram;
end

endmodule