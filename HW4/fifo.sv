module fifo (
	input rd_clk, //read clock
	input wr_clk, //write clock
	input reset_n, //reset async active low
	input rd, //read enable
	input wr, //write enable
	input [7:0] data_in, //data in
	output reg [7:0] data_out, //data out
	output logic empty, //empty flag
	output logic full //full flag
);

//Eight 8bit registers for data
reg [7:0] word_0;
reg [7:0] word_1;
reg [7:0] word_2;
reg [7:0] word_3;
reg [7:0] word_4;
reg [7:0] word_5;
reg [7:0] word_6;
reg [7:0] word_7;

logic [2:0] rd_ptr; //location of read
logic [2:0] wr_ptr; //location of write

logic rd_tog; //toggles when ptr reaches 7 and starts at 0
logic wr_tog; //toggles when ptr reaches 7 and starts at 0

//2 assign, rd_clk, wr_clk, rd_ptr, wr_ptr, rd_sync, wr_sync
logic temp_empty;
logic temp_full;
assign temp_empty = ((rd_tog == wr_tog) && (rd_ptr == wr_ptr));
assign temp_full = ((rd_tog != wr_tog) && (rd_ptr == wr_ptr));

//read clock operation
always_ff @(posedge rd_clk, negedge reset_n) begin
	if (!reset_n) data_out <= 8’bx;
	else if (rd) begin
		unique case (rd_ptr)
			3’d0: data_out <= word_0;
			3’d1: data_out <= word_1;
			3’d2: data_out <= word_2;
			3’d3: data_out <= word_3;
			3’d4: data_out <= word_4;
			3’d5: data_out <= word_5;
			3’d6: data_out <= word_6;
			3’d7: data_out <= word_7;
		endcase
	end
	else data_out <= data_out;
end

//write clock operation
always_ff @(posedge wr_clk, negedge reset_n) begin
	if (!reset_n) begin
		word_0 <= 8’d0;
		word_1 <= 8’d0;
		word_2 <= 8’d0;
		word_3 <= 8’d0;
		word_4 <= 8’d0;
		word_5 <= 8’d0;
		word_6 <= 8’d0;
		word_7 <= 8’d0;
	end
	else if (wr) begin
		unique case (wr_ptr)
			3’d0: word_0 <= data_in;
			3’d1: word_1 <= data_in;
			3’d2: word_2 <= data_in;
			3’d3: word_3 <= data_in;
			3’d4: word_4 <= data_in;
			3’d5: word_5 <= data_in;
			3’d6: word_6 <= data_in;
			3’d7: word_7 <= data_in;
		endcase
	end
	else begin
		word_0 <= word_0;
		word_1 <= word_1;
		word_2 <= word_2;
		word_3 <= word_3;
		word_4 <= word_4;
		word_5 <= word_5;
		word_6 <= word_6;
		word_7 <= word_7;
	end
end

//read pointer operation
always_ff @(posedge rd_clk, negedge reset_n) begin
	if (!reset_n) begin
		rd_ptr <= 3’d0;
		rd_tog <= 1’d0;
	end
	else if (rd) begin
		if (rd_ptr == 3’d7) begin
			rd_ptr <= 3’d0;
			rd_tog <= ~rd_tog;
		end
		else begin
			rd_ptr <= rd_ptr + 1;
		end
	end
	else rd_ptr <= rd_ptr;
end

//write pointer operation
always_ff @(posedge wr_clk, negedge reset_n) begin
	if (!reset_n) begin
		wr_ptr <= 3’d0;
		wr_tog <= 1’d0;
	end
	else if (wr) begin
		if (wr_ptr == 3’d7) begin
			wr_ptr <= 3’d0;
			wr_tog <= ~wr_tog;
		end
		else begin
			wr_ptr <= wr_ptr + 1;
		end
	end
	else wr_ptr <= wr_ptr;
end

//read sync
always_ff @(posedge rd_clk, negedge reset_n) begin
	if (!reset_n) empty <= 1’d1;
	else empty <= temp_empty;
end

//write sync
always_ff @(posedge wr_clk, negedge reset_n) begin
	if (!reset_n) full <= 1’d0;
	else full <= temp_full;
end

endmodule