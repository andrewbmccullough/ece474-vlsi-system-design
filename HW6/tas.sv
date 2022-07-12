module tas (
	input clk_50, // 50Mhz input clock
	input clk_2, // 2Mhz input clock
	input reset_n, // reset async active low
	input serial_data, // serial input data
	input data_ena, // serial data enable
	output logic ram_wr_n, // write strobe to ram
	output logic [7:0] ram_data, // ram data
	output logic [10:0] ram_addr // ram address
);

wire [7:0] data_to_fifo; //shift_reg, a5_or_c3, FIFO
wire header; //a5_or_c3, ctrl_50
wire wr_fifo; //ctrl_50, FIFO
wire rd_fifo; //ctrl_2, FIFO, averager
wire full; //FIFO, ctrl_2
wire empty; //FIFO, ctrl_2
wire [7:0] avg_val; //averager, ctrl_2
wire rst_ram; //ctrl_2, averager
wire [7:0] data_from_fifo; //FIFO, averager
wire wr_ram; //ctrl_2, ram_cnt

assign ram_wr_n = !wr_ram; //set ram_wr_n to invers of wr_ram

shift_reg shift_reg_0 (
	.clk_50 (clk_50),
	.reset_n (reset_n),
	.serial_data (serial_data),
	.data_ena (data_ena),
	.data_to_fifo (data_to_fifo)
);

a5_or_c3 a5_or_c3_0 (
	.data_to_fifo (data_to_fifo),
	.header (header)
);

ctrl_50 ctrl_50_0 (
	.clk_50 (clk_50),
	.reset_n (reset_n),
	.data_ena (data_ena),
	.a5_or_c3 (header),
	.wr_fifo (wr_fifo)
);

fifo fifo_0 (
	.data_in (data_to_fifo),
	.wr (wr_fifo),
	.rd (rd_fifo),
	.wr_clk (clk_50),
	.rd_clk (clk_2),
	.reset_n (reset_n),
	.full (full),
	.empty (empty),
	.data_out (data_from_fifo)
);

ctrl_2 ctrl_2_0 (
	.clk_2 (clk_2),
	.reset_n (reset_n),
	.rd_fifo (rd_fifo),
	.fifo_full (full),
	.fifo_empty (empty),
	.rst_ram (rst_ram),
	.avg_val (avg_val),
	.wr_ram (wr_ram)
);

ram_cnt ram_cnt_0 (
	.wr_ram (wr_ram),
	.clk_2 (clk_2),
	.reset_n (reset_n),
	.ram_addr (ram_addr)
);

averager averager_0 (
	.data_from_fifo (data_from_fifo),
	.clk_2 (clk_2),
	.reset_n (reset_n),
	.rd_fifo (rd_fifo),
	.rst_ram (rst_ram),
	.avg_val (avg_val),
	.ram_data (ram_data)
);

endmodule