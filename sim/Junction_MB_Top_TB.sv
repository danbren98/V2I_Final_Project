`timescale 1ns/1ps

`include "interfaces/spi_if.sv"
`include "drivers/spi_driver.sv"

module Junction_MB_Top_TB;

// Clock and Reset
logic sys_clk;
logic sys_rstn;

// SPI
spi_if north_spi (.clk(sys_clk), .rst_n(sys_rstn));
spi_if south_spi (.clk(sys_clk), .rst_n(sys_rstn));
spi_if east_spi  (.clk(sys_clk), .rst_n(sys_rstn));
spi_if west_spi  (.clk(sys_clk), .rst_n(sys_rstn));


// Traffic lights outputs
logic traffic_light_red_north, traffic_light_yellow_north, traffic_light_green_north;
logic traffic_light_red_south, traffic_light_yellow_south, traffic_light_green_south;
logic traffic_light_red_east, traffic_light_yellow_east, traffic_light_green_east;
logic traffic_light_red_west, traffic_light_yellow_west, traffic_light_green_west;

// User leds
logic [1:0] user_leds;

// Driver controls and data
logic start_north, done_north;
logic start_south, done_south;
logic start_east,  done_east;
logic start_west,  done_west;

logic [15:0] rx_north, rx_south, rx_east, rx_west;
logic [15:0] tx_north = 16'hA1A2;
logic [15:0] tx_south = 16'hB2B3;
logic [15:0] tx_east  = 16'hC4C5;
logic [15:0] tx_west  = 16'hD6D7;

// Clock generation (50 MHz)
initial begin
	sys_clk = 0;
	forever #20 sys_clk = ~sys_clk; // 40ns period => 25 MHz
end

// Reset generation
initial begin
	sys_rstn = 1'b1;
	
	#75; // initial deassert after 75ns (not on clock edge)

	// Random toggling before the long low period (~100us)
	repeat (10) begin
		#(50 + $urandom_range(0, 150)); // delay between toggles
		sys_rstn = ~sys_rstn;
		#(10 + $urandom_range(0, 10)); // short pulse width
		sys_rstn = ~sys_rstn;
	end

	// Hold reset low for 500ms (500_000_000ns)
	sys_rstn = 1'b0; #100_000;

	// Random toggling after the long low period (~200us)
	repeat (10) begin
		#(50 + $urandom_range(0, 150)); // delay between toggles
		sys_rstn = ~sys_rstn;
		#(10 + $urandom_range(0, 10)); // short pulse width
		sys_rstn = ~sys_rstn;
	end

	// Deassert reset and keep it high
	sys_rstn = 1'b1;
end

// Stimulus
initial begin
	start_north = 0; start_south = 0; start_east = 0; start_west = 0;
	#150_000; @(posedge sys_clk);

	tx_north = 16'b1000001010101110;
	start_north = 1; @(posedge sys_clk); start_north = 0;
	wait(done_north); repeat (10) @(posedge sys_clk);
	tx_north = 16'b1000001100100011;
	start_north = 1; @(posedge sys_clk); start_north = 0;
	wait(done_north); repeat (10) @(posedge sys_clk);
	tx_north = 16'b1000010000010100;
	start_north = 1; @(posedge sys_clk); start_north = 0;
	wait(done_north); repeat (10) @(posedge sys_clk);

	tx_south = 16'b1000001010101110;
	start_south = 1; @(posedge sys_clk); start_south = 0;
	wait(done_south); repeat (10) @(posedge sys_clk);
	tx_south = 16'b1000001100100011;
	start_south = 1; @(posedge sys_clk); start_south = 0;
	wait(done_south); repeat (10) @(posedge sys_clk);
	tx_south = 16'b1000010000010100;
	start_south = 1; @(posedge sys_clk); start_south = 0;
	wait(done_south); repeat (10) @(posedge sys_clk);

	tx_east = 16'b1000001010101110;
	start_east = 1; @(posedge sys_clk); start_east = 0;
	wait(done_east); repeat (10) @(posedge sys_clk);
	tx_east = 16'b1000001100100011;
	start_east = 1; @(posedge sys_clk); start_east = 0;
	wait(done_east); repeat (10) @(posedge sys_clk);
	tx_east = 16'b1000010000010100;
	start_east = 1; @(posedge sys_clk); start_east = 0;
	wait(done_east); repeat (10) @(posedge sys_clk);

	tx_west = 16'b1000001010101110;
	start_west = 1; @(posedge sys_clk); start_west = 0;
	wait(done_west); repeat (10) @(posedge sys_clk);
	tx_west = 16'b1000001100100011;
	start_west = 1; @(posedge sys_clk); start_west = 0;
	wait(done_west); repeat (10) @(posedge sys_clk);
	tx_west = 16'b1000010000010100;
	start_west = 1; @(posedge sys_clk); start_west = 0;
	wait(done_west); repeat (10) @(posedge sys_clk);
	
end

// SPI Driver Instances
spi_driver #(.DATA_WIDTH(16)) north_driver (
	.clk		(sys_clk),
	.rst_n		(sys_rstn),
	.start		(start_north),
	.tx_data	(tx_north),
	.done		(done_north),
	.rx_data	(rx_north),
	.spi		(north_spi)
);

spi_driver #(.DATA_WIDTH(16)) south_driver (
	.clk		(sys_clk),
	.rst_n		(sys_rstn),
	.start		(start_south),
	.tx_data	(tx_south),
	.done		(done_south),
	.rx_data	(rx_south),
	.spi		(south_spi)
);

spi_driver #(.DATA_WIDTH(16)) east_driver (
	.clk		(sys_clk),
	.rst_n		(sys_rstn),
	.start		(start_east),
	.tx_data	(tx_east),
	.done		(done_east),
	.rx_data	(rx_east),
	.spi		(east_spi)
);

spi_driver #(.DATA_WIDTH(16)) west_driver (
	.clk		(sys_clk),
	.rst_n		(sys_rstn),
	.start		(start_west),
	.tx_data	(tx_west),
	.done		(done_west),
	.rx_data	(rx_west),
	.spi		(west_spi)
);

Junction_MB_Top DUT (
	.SYS_CLK					(sys_clk),						//	input
	.SYS_RSTN					(sys_rstn),						//	input

	.SCLK_NORTH					(north_spi.sclk),				//	input
	.SS_N_NORTH					(north_spi.ssn),				//	input
	.MOSI_NORTH					(north_spi.mosi),				//	input
	.MISO_NORTH					(north_spi.miso),				//	output
	
	.SCLK_SOUTH					(south_spi.sclk),				//	input
	.SS_N_SOUTH					(south_spi.ssn),				//	input
	.MOSI_SOUTH					(south_spi.mosi),				//	input
	.MISO_SOUTH					(south_spi.miso),				//	output
	
	.SCLK_EAST					(east_spi.sclk),				//	input
	.SS_N_EAST					(east_spi.ssn),					//	input
	.MOSI_EAST					(east_spi.mosi),				//	input
	.MISO_EAST					(east_spi.miso),				//	output
	
	.SCLK_WEST					(west_spi.sclk),				//	input
	.SS_N_WEST					(west_spi.ssn),					//	input
	.MOSI_WEST					(west_spi.mosi),				//	input
	.MISO_WEST					(west_spi.miso),				//	output
	
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
	
	.USER_LEDS					(user_leds)						//	output	[1 downto 0]
);


endmodule
