module ctrl_2 (
	input clk_2,
	input reset_n,
	input fifo_empty,
	input fifo_full,
	input [7:0] avg_val,
	output logic rd_fifo,
	output logic rst_ram,
	output logic wr_ram
);

//fifo_sm
enum logic {
	NO_READ = 1’b0,
	READ = 1’b1,
	FIFO_X = 1’bx
} fifo_ps, fifo_ns;

//ctrl_sm
enum logic [1:0] {
	ADD_1 = 2’b00,
	ADD_2 = 2’b01,
	ADD_3 = 2’b10,
	ADD_4 = 2’b11,
	CTRL_X = 2’bxx
} ctrl_ps, ctrl_ns;

//ram_sm
enum logic {
	WRITE = 1’b0,
	NO_WRITE = 1’b1,
	RAM_X = 1’bx
} ram_ps, ram_ns;

//fifo_sm ff
always_ff @(posedge clk_2, negedge reset_n) begin
	if (!reset_n) fifo_ps <= NO_READ;
	else fifo_ps <= fifo_ns;
end

//ctrl_sm ff
always_ff @(posedge clk_2, negedge reset_n) begin
	if (!reset_n) ctrl_ps <= ADD_1;
	else ctrl_ps <= ctrl_ns;
end

//ram_sm ff
always_ff @(posedge clk_2, negedge reset_n) begin
	if (!reset_n) ram_ps <= NO_WRITE;
	else ram_ps <= ram_ns;
end

//fifo_sm comb
always_comb begin
	fifo_ns = FIFO_X;
	rd_fifo = 1’bx;
	case (fifo_ps)
		NO_READ: begin
			rd_fifo = 1’b0;
			if (!fifo_empty) fifo_ns = READ; //if FIFO not empty go to READ state
			else fifo_ns = NO_READ;
		end
		READ: begin
			rd_fifo = 1’b1; //toggle read bit in READ state
			fifo_ns = NO_READ;
		end
	endcase
end

//ctrl_sm comb
always_comb begin
	ctrl_ns = CTRL_X;
	case (ctrl_ps) //if rd_fifo signal then cycle through bytes
		ADD_1: begin
			if (rd_fifo) ctrl_ns = ADD_2;
			else ctrl_ns = ADD_1;
		end
		ADD_2: begin
			if (rd_fifo) ctrl_ns = ADD_3;
			else ctrl_ns = ADD_2;
		end
		ADD_3: begin
			if (rd_fifo) ctrl_ns = ADD_4;
			else ctrl_ns = ADD_3;
		end
		ADD_4: begin
			if (rd_fifo) ctrl_ns = ADD_1;
			else ctrl_ns = ADD_4;
		end
	endcase
end

//ram_sm comb
always_comb begin
	ram_ns = RAM_X;
	wr_ram = 1’bx;
	case (ram_ps)
		NO_WRITE: begin
			wr_ram = 1’b0;
			if ((ctrl_ps == ADD_4) && (rd_fifo) && (avg_val <= 8’d127)) ram_ns = WRITE; //if on last byte, rd_fifo, and value in range of 0−127 go to WRITE state
			else ram_ns = NO_WRITE;
		end
		WRITE: begin
			wr_ram = 1’b1; //toggle wr_ram bit
			ram_ns = NO_WRITE;
		end
	endcase
end

//resetting ram
always_comb begin
	if (ctrl_ps == ADD_1) rst_ram = 1’b1; //if on first byte, reset ram to just take FIFO
	else rst_ram = 1’b0;
end
	
endmodule