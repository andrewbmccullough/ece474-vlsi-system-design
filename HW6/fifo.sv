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

logic [2:0] rd_ptr; //location of read
logic [2:0] wr_ptr; //location of write

logic rd_tog; //toggles when ptr reaches 7 and starts at 0
logic wr_tog; //toggles when ptr reaches 7 and starts at 0

assign empty = ((rd_tog == wr_tog) && (rd_ptr == wr_ptr));
assign full = ((rd_tog != wr_tog) && (rd_ptr == wr_ptr));

//read clock operation
always_comb begin
	data_out = 8’dx;
	unique case (rd_ptr)
		3’d0: data_out = word_0;
		3’d1: data_out = word_1;
		3’d2: data_out = word_2;
		3’d3: data_out = word_3;
	endcase
end

//write clock operation
always_ff @(posedge wr_clk, negedge reset_n) begin
	if (!reset_n) begin
		word_0 <= 8’d0;
		word_1 <= 8’d0;
		word_2 <= 8’d0;
		word_3 <= 8’d0;
	end
	else if (wr) begin
		unique case (wr_ptr)
			3’d0: word_0 <= data_in;
			3’d1: word_1 <= data_in;
			3’d2: word_2 <= data_in;
			3’d3: word_3 <= data_in;
		endcase
	end
	else begin
		word_0 <= word_0;
		word_1 <= word_1;
		word_2 <= word_2;
		word_3 <= word_3;
	end
end

//read pointer operation
always_ff @(posedge rd_clk, negedge reset_n) begin
	if (!reset_n) begin
		rd_ptr <= 3’d0;
		rd_tog <= 1’d0;
	end
	else if (rd) begin
		if (rd_ptr == 3’d3) begin
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
		if (wr_ptr == 3’d3) begin
			wr_ptr <= 3’d0;
			wr_tog <= ~wr_tog;
		end
		else begin
			wr_ptr <= wr_ptr + 1;
		end
	end
	else wr_ptr <= wr_ptr;
end

endmodule