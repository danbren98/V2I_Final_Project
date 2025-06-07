`timescale 1ns/1ps

module Junction_MB_Top_TB;

// Clock and Reset
logic sys_clk;
logic sys_rstn;

// SPI
logic sclk_north, ss_n_north, miso_north, mosi_north;
logic sclk_south, ss_n_south, miso_south, mosi_south;
logic sclk_east, ss_n_east, miso_east, mosi_east;
logic sclk_west, ss_n_west, miso_west, mosi_west;

// Traffic lights outputs
logic traffic_light_red_north, traffic_light_yellow_north, traffic_light_green_north;
logic traffic_light_red_south, traffic_light_yellow_south, traffic_light_green_south;
logic traffic_light_red_east, traffic_light_yellow_east, traffic_light_green_east;
logic traffic_light_red_west, traffic_light_yellow_west, traffic_light_green_west;

// User leds
logic [1:0] user_leds;


// Clock generation (50 MHz)
initial begin
	sys_clk = 0;
	forever #10 sys_clk = ~sys_clk; // 20ns period => 50 MHz
end

// Reset generation
initial begin
	sys_rstn = 1'b1;

	// Toggling reset for 100us (100_000ns)
	repeat (100_000 / 20) begin // toggle every 10ns => 20ns full cycle
	#10 sys_rstn = ~sys_rstn;
	end

	// Hold reset low for 500ms (500_000_000ns)
	sys_rstn = 1'b0;
	#500_000_000;

	// Toggling reset for 200us (200_000ns)
	repeat (200_000 / 20) begin
	#10 sys_rstn = ~sys_rstn;
	end

	// Deassert reset and keep it high
	sys_rstn = 1'b1;
end


Junction_MB_Top DUT (
	.SYS_CLK					(sys_clk),						//	input
	.SYS_RSTN					(sys_rstn),						//	input

	.SCLK_NORTH					(sclk_north),					//	input
	.SS_N_NORTH					(ss_n_north),					//	input
	.MOSI_NORTH					(mosi_north),					//	input
	.MISO_NORTH					(miso_north),					//	output
	
	.SCLK_SOUTH					(sclk_south),					//	input
	.SS_N_SOUTH					(ss_n_south),					//	input
	.MOSI_SOUTH					(mosi_south),					//	input
	.MISO_SOUTH					(miso_south),					//	output
	
	.SCLK_EAST					(sclk_east),					//	input
	.SS_N_EAST					(ss_n_east),					//	input
	.MOSI_EAST					(mosi_east),					//	input
	.MISO_EAST					(miso_east),					//	output
	
	.SCLK_WEST					(sclk_west),					//	input
	.SS_N_WEST					(ss_n_west),					//	input
	.MOSI_WEST					(mosi_west),					//	input
	.MISO_WEST					(miso_west),					//	output
	
	.TRAFFIC_LIGHT_RED_NORTH	(traffic_light_red_north),		//	output
	.TRAFFIC_LIGHT_YELLOW_NORTH	(traffic_light_yellow_north),	//	output
	.TRAFFIC_LIGHT_GREEN_NORTH	(traffic_light_green_north),	//	output
	
	.TRAFFIC_LIGHT_RED_SOUTH	(traffic_light_red_south),		//	output
	.TRAFFIC_LIGHT_YELLOW_SOUTH	(traffic_light_yellow_south),	//	output
	.TRAFFIC_LIGHT_GREEN_SOUTH	(traffic_light_green_south),	//	output
	
	.TRAFFIC_LIGHT_RED_EAST		(traffic_light_red_east),		//	output
	.TRAFFIC_LIGHT_YELLOW_EAST	(traffic_light_yellow_east),	//	output
	.TRAFFIC_LIGHT_GREEN_EAST	(traffic_light_green_east),		//	output
	
	.TRAFFIC_LIGHT_RED_WEST		(traffic_light_red_west),		//	output
	.TRAFFIC_LIGHT_YELLOW_WEST	(traffic_light_yellow_west),	//	output
	.TRAFFIC_LIGHT_GREEN_WEST	(traffic_light_green_west),		//	output
	
	.USER_LEDS					(user_leds),					//	output	[1 downto 0]
);


endmodule
