‘timescale 1ps/1ps

module tb;

reg reset_n;
reg clk_1sec;
reg clk_1ms;
reg mil_time;
reg [7:0] segment_data;
reg [2:0] digit_select;

parameter CYCLE_1MS = 10;
parameter CYCLE_1SEC = 10000;

//generate clk_1ms
initial begin
	clk_1ms <= 0;
	forever #(CYCLE_1MS / 2) clk_1ms = ~clk_1ms;
end

//generate clk_1sec
initial begin
	clk_1sec <= 0;
	forever #(CYCLE_1SEC / 2) clk_1sec = ~clk_1sec;
end

//set initial states and reset_n
initial begin
	reset_n <= 0;
	#(CYCLE_1SEC * 1.5) reset_n = 1’b1; //reset for 1.5, 2 mhz clock cycles
end

initial begin
	mil_time <= ’1;
	forever #(CYCLE_1SEC * 120 + 100) mil_time = ~mil_time;
end

clock clock_0(.*); //instantiate clock module

initial begin
	while(1) #(CYCLE_1SEC);
end

endmodule