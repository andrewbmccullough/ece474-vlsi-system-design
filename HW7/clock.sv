module clock(
	input reset_n, //reset pin
	input clk_1sec, //1 sec clock
	input clk_1ms, //1 mili sec clock
	input mil_time, //mil time pin
	output reg [7:0] segment_data, // output 7 segment data
	output reg [2:0] digit_select // digit select
);

logic [4:0] hour_mil;
logic [3:0] hour_reg;
logic [5:0] min;
logic [5:0] sec;
logic min_tog, hr_tog, day_tog;
logic pm;
logic blink;

logic [3:0] hr_mil_4, hr_mil_3, hr_reg_4, hr_reg_3, min_1, min_0;

assign min_0 = (min % 10);
assign min_1 = ((min) − min_0) / 10;
assign hr_reg_3 = (hour_reg % 10);
assign hr_reg_4 = ((hour_reg) − hr_reg_3) / 10;
assign hr_mil_3 = (hour_mil % 10);
assign hr_mil_4 = ((hour_mil) − hr_mil_3) / 10;

logic [3:0] num_display;

enum logic [2:0] {
	ZERO = 3’b000,
	ONE = 3’b001,
	TWO = 3’b010,
	THREE = 3’b011,
	FOUR = 3’b100,
	SEL_X = 3’bxxx
} sel_ps, sel_ns;

//sel_sm ff
always_ff @(posedge clk_1ms, negedge reset_n) begin
	if (!reset_n) sel_ps <= ZERO;
	else sel_ps <= sel_ns;
end

//sel_sm comb
always_comb begin
	sel_ns = SEL_X;
	case (sel_ps)
		ZERO: begin
			digit_select = 3’d0;
			sel_ns = ONE;
		end
		ONE: begin
			digit_select = 3’d1;
			sel_ns = TWO;
		end
		TWO: begin
			digit_select = 3’d2;
			sel_ns = THREE;
		end
		THREE: begin
			digit_select = 3’d3;
			sel_ns = FOUR;
		end
		FOUR: begin
			digit_select = 3’d4;
			sel_ns = ZERO;
		end
	endcase
end

//count seconds ff
always_ff @(posedge clk_1sec, negedge reset_n) begin
	if (!reset_n) begin
		sec <= 6’d0;
		blink <= 1’b0;
	end
	else begin
		if (min_tog) begin
			sec <= 6’d0;
			blink <= ~blink;
		end
		else begin
			sec <= sec + 1;
			blink <= ~blink;
		end
	end
end

//count seconds comb
always_comb begin
	if (sec == 6’d59) min_tog = 1’b1;
	else min_tog = 1’b0;
end

//count minutes ff
always_ff @(posedge clk_1sec, negedge reset_n) begin
	if (!reset_n) min <= 6’d0;
	else begin
		if (hr_tog && min_tog) min <= 6’d0;
		else if (min_tog) min <= min + 1;
		else min <= min;
	end
end

//count minutes comb
always_comb begin
	if ((min == 6’d59) && min_tog) hr_tog = 1’b1;
	else hr_tog = 1’b0;
end

//count mil hours ff
always_ff @(posedge clk_1sec, negedge reset_n) begin
	if (!reset_n) hour_mil <= 5’d0;
	else begin
		if (day_tog && hr_tog) hour_mil <= 5’d0;
		else if (hr_tog) hour_mil <= hour_mil + 1;
		else hour_mil <= hour_mil;
	end
end

//count mil hours comb
always_comb begin
	if ((hour_mil == 5’d23) && hr_tog) day_tog = 1’b1;
	else day_tog = 1’b0;
end

//set reg hours
always_comb begin if ((hour_mil == 0) || (hour_mil == 12)) hour_reg = 4’d12;
	else hour_reg = (hour_mil % 12);
end

//set pm
always_comb begin
	if (hour_mil >= 12) pm = 1’b1;
	else pm = 1’b0;
end

//7−seg choose number to display
always_comb begin
	if (sel_ps == ZERO) num_display = min_0;
	else if (sel_ps == ONE) num_display = min_1;
	else if (sel_ps == TWO) begin
		if (blink) num_display = 4’d10;
		else num_display = 4’d11;
	end
	else if (sel_ps == THREE) begin
		if (mil_time) num_display = hr_mil_3;
		else num_display = hr_reg_3;
	end
	else if (sel_ps == FOUR) begin
		if (mil_time) num_display = hr_mil_4;
		else num_display = hr_reg_4;
	end
	else num_display = 4’d12;
end

//7−seg send number to segment_data
always_comb begin
	case (num_display)
		4’d0: segment_data = 8’b11000000; //0
		4’d1: segment_data = 8’b11111001; //1
		4’d2: segment_data = 8’b10100100; //2
		4’d3: segment_data = 8’b10110000; //3
		4’d4: segment_data = 8’b10011001; //4
		4’d5: segment_data = 8’b10010010; //5
		4’d6: segment_data = 8’b10000010; //6
		4’d7: segment_data = 8’b11111000; //7
		4’d8: segment_data = 8’b10000000; //8
		4’d9: segment_data = 8’b10010000; //9
		4’d10: segment_data = 8’b11111100; //colon on
		4’d11: segment_data = 8’b11111111; //all off
	endcase
	if (pm && (sel_ps == ZERO)) segment_data = (segment_data & 8’b01111111);
end

endmodule