module ctrl_50 (
	input clk_50,
	input reset_n,
	input data_ena,
	input a5_or_c3,
	output logic wr_fifo
);

reg byte_assembled;

//byte_asm_sm
enum logic {
	ALLOW = 1’b0,
	NOT_ALLOW = 1’b1,
	BYTE_ASM_X = 1’bx
}byte_asm_ps, byte_asm_ns;

//header_sm
enum logic {
	TEMP_PACKET = 1’b0,
	WAITING = 1’b1,
	HEADER_X = 1’bx
}header_ps, header_ns;

//fifo_sm
enum logic {
	WRITE = 1’b0,
	NO_WRITE = 1’b1,
	FIFO_X = 1’bx
}fifo_ps, fifo_ns;

//ctrl_sm
enum logic [2:0] {
	HEADER = 3’b000,
	B1 = 3’b001,
	B2 = 3’b010,
	B3 = 3’b011,
	B4 = 3’b100,
	CTRL_X = 3’bxxx
}ctrl_ps, ctrl_ns;

//byte_asm_sm ff
always_ff @(posedge clk_50, negedge reset_n) begin
	if (!reset_n) byte_asm_ps <= NOT_ALLOW;
	else if (data_ena) byte_asm_ps <= ALLOW;
	else byte_asm_ps <= NOT_ALLOW;
end

//header_sm ff
always_ff @(posedge clk_50, negedge reset_n) begin
	if (!reset_n) header_ps <= WAITING;
	else header_ps <= header_ns;
end

//fifo_sm ff
always_ff @(posedge clk_50, negedge reset_n) begin
	if (!reset_n) fifo_ps <= NO_WRITE;
	else fifo_ps <= fifo_ns;
end

//ctrl_sm ff
always_ff @(posedge clk_50, negedge reset_n) begin
	if (!reset_n) ctrl_ps <= HEADER;
	else ctrl_ps <= ctrl_ns;
end

//set byte_assembled bit
always_comb begin
	byte_assembled = ((!data_ena) && (byte_asm_ps == ALLOW)); //if no data_ena signal and it is a byte, toggle
end

//header_sm comb
always_comb begin
	header_ns = HEADER_X;
	case (header_ps)
		WAITING: begin
			if ((a5_or_c3) && (ctrl_ns == B1)) header_ns = TEMP_PACKET;
			else header_ns = WAITING;
		end
		TEMP_PACKET: begin
			if (ctrl_ns == HEADER) header_ns = WAITING;
			else header_ns = TEMP_PACKET;
		end
	endcase
end

//fifo_sm comb
always_comb begin
	fifo_ns = FIFO_X;
	wr_fifo = 1’b0;
	case (fifo_ps)
		NO_WRITE: begin
			if ((byte_assembled) && (header_ps == TEMP_PACKET) && (ctrl_ps != HEADER)) fifo_ns = WRITE; //if byte assembled, it is a temperature, and it is not a header go to WRITE state
			else fifo_ns = NO_WRITE;
		end
		WRITE: begin
			fifo_ns = NO_WRITE;
			wr_fifo = 1’b1; //toggle wr_fifo bit to write FIFO
		end
	endcase
end

//ctrl_sm comb
always_comb begin
	ctrl_ns = CTRL_X;
	case (ctrl_ps) //cycle through header and 4 bytes
		HEADER: begin
			if (byte_assembled) ctrl_ns = B1;
			else ctrl_ns = HEADER;
		end
		B1: begin
			if (byte_assembled) ctrl_ns = B2;
			else ctrl_ns = B1;
		end
		B2: begin
			if (byte_assembled) ctrl_ns = B3;
			else ctrl_ns = B2;
		end
		B3: begin
			if (byte_assembled) ctrl_ns = B4;
			else ctrl_ns = B3;
		end
		B4: begin
			if (byte_assembled) ctrl_ns = HEADER;
			else ctrl_ns = B4;
		end
	endcase
end

endmodule