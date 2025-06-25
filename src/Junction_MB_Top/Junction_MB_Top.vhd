library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

library work;
	use work.global_package.all;

entity Junction_MB_Top is
	port	(
				SYS_CLK						:	in	std_logic;
				SYS_RSTN					:	in	std_logic;

				SCLK_NORTH					:	in	std_logic;
				SS_N_NORTH					:	in	std_logic;
				MOSI_NORTH					:	in	std_logic;
				MISO_NORTH					:	out	std_logic;
				
				SCLK_SOUTH					:	in	std_logic;
				SS_N_SOUTH					:	in	std_logic;
				MOSI_SOUTH					:	in	std_logic;
				MISO_SOUTH					:	out	std_logic;
				
				SCLK_EAST					:	in	std_logic;
				SS_N_EAST					:	in	std_logic;
				MOSI_EAST					:	in	std_logic;
				MISO_EAST					:	out	std_logic;
				
				SCLK_WEST					:	in	std_logic;
				SS_N_WEST					:	in	std_logic;
				MOSI_WEST					:	in	std_logic;
				MISO_WEST					:	out	std_logic;
				
				TRAFFIC_LIGHT_RED_NORTH		:	out	std_logic;
				TRAFFIC_LIGHT_YELLOW_NORTH	:	out	std_logic;
				TRAFFIC_LIGHT_GREEN_NORTH	:	out	std_logic;
				
				TRAFFIC_LIGHT_RED_SOUTH		:	out	std_logic;
				TRAFFIC_LIGHT_YELLOW_SOUTH	:	out	std_logic;
				TRAFFIC_LIGHT_GREEN_SOUTH	:	out	std_logic;
				
				TRAFFIC_LIGHT_RED_EAST		:	out	std_logic;
				TRAFFIC_LIGHT_YELLOW_EAST	:	out	std_logic;
				TRAFFIC_LIGHT_GREEN_EAST	:	out	std_logic;
				
				TRAFFIC_LIGHT_RED_WEST		:	out	std_logic;
				TRAFFIC_LIGHT_YELLOW_WEST	:	out	std_logic;
				TRAFFIC_LIGHT_GREEN_WEST	:	out	std_logic;
				
				USER_LEDS					:	out	std_logic_vector(1 downto 0)
			);
end entity Junction_MB_Top;

architecture rtl of Junction_MB_Top is

	signal	clk_200				:	std_logic;
	signal	reset_200			:	std_logic;
	signal	main_pll_locked		:	std_logic;

	signal	spi_north_valid		:	std_logic;
	signal	spi_north_carid		:	std_logic_vector(CAR_ID_BUS_WIDTH-1 downto 0);
	signal	spi_north_speed		:	std_logic_vector(CAR_SPEED_BUS_WIDTH-1 downto 0);
	signal	spi_north_power		:	std_logic_vector(RX_POWER_BUS_WIDTH-1 downto 0);
	
	signal	spi_south_valid		:	std_logic;
	signal	spi_south_carid		:	std_logic_vector(CAR_ID_BUS_WIDTH-1 downto 0);
	signal	spi_south_speed		:	std_logic_vector(CAR_SPEED_BUS_WIDTH-1 downto 0);
	signal	spi_south_power		:	std_logic_vector(RX_POWER_BUS_WIDTH-1 downto 0);
	
	signal	spi_east_valid		:	std_logic;
	signal	spi_east_carid		:	std_logic_vector(CAR_ID_BUS_WIDTH-1 downto 0);
	signal	spi_east_speed		:	std_logic_vector(CAR_SPEED_BUS_WIDTH-1 downto 0);
	signal	spi_east_power		:	std_logic_vector(RX_POWER_BUS_WIDTH-1 downto 0);

	signal	spi_west_valid		:	std_logic;
	signal	spi_west_carid		:	std_logic_vector(CAR_ID_BUS_WIDTH-1 downto 0);
	signal	spi_west_speed		:	std_logic_vector(CAR_SPEED_BUS_WIDTH-1 downto 0);
	signal	spi_west_power		:	std_logic_vector(RX_POWER_BUS_WIDTH-1 downto 0);

	signal	north_time_valid	:	std_logic;
	signal	north_carid			:	std_logic_vector(CAR_ID_BUS_WIDTH-1 downto 0);
	signal	north_time			:	std_logic_vector(ARRIVAL_TIME_WIDTH-1 downto 0);
	
	signal	south_time_valid	:	std_logic;
	signal	south_carid			:	std_logic_vector(CAR_ID_BUS_WIDTH-1 downto 0);
	signal	south_time			:	std_logic_vector(ARRIVAL_TIME_WIDTH-1 downto 0);
	
	signal	east_time_valid		:	std_logic;
	signal	east_carid			:	std_logic_vector(CAR_ID_BUS_WIDTH-1 downto 0);
	signal	east_time			:	std_logic_vector(ARRIVAL_TIME_WIDTH-1 downto 0);
	
	signal	west_time_valid		:	std_logic;
	signal	west_carid			:	std_logic_vector(CAR_ID_BUS_WIDTH-1 downto 0);
	signal	west_time			:	std_logic_vector(ARRIVAL_TIME_WIDTH-1 downto 0);
	
	signal	mctrl_valid_in		:	std_logic_vector(4-1 downto 0);
	signal	mctrl_time_in		:	std_logic_vector(4*ARRIVAL_TIME_WIDTH-1 downto 0);
	signal	mctrl_trflt_r		:	std_logic_vector(4-1 downto 0);
	signal	mctrl_trflt_y		:	std_logic_vector(4-1 downto 0);
	signal	mctrl_trflt_g		:	std_logic_vector(4-1 downto 0);

begin
	
	Clock_Generator_Inst: entity work.clock_generator
		port map	(
						arst		=>	SYS_RSTN,			--:	in	std_logic;
						refclk		=>	SYS_CLK,			--:	in	std_logic;

						locked		=>	main_pll_locked,	--:	out	std_logic;

						clk_200		=>	clk_200,			--:	out	std_logic;
						reset_200	=>	reset_200			--:	out	std_logic
					);
	
--	Region WiFi Modules Interface	
	
	WiFi_North_Inst: entity work.spi_interface
		generic map	(
						carid_bw	=>	CAR_ID_BUS_WIDTH,		--:	positive;
						speed_bw	=>	CAR_SPEED_BUS_WIDTH,	--:	positive;
						power_bw	=>	RX_POWER_BUS_WIDTH		--:	positive;
					)
		port map	(
						app_clk		=>	clk_200,			--:	in	std_logic;
						app_rst		=>	reset_200,			--:	in	std_logic;

						valid_out	=>	spi_north_valid,	--:	out	std_logic;
						car_id_out	=>	spi_north_carid,	--:	out	std_logic_vector(carid_bw-1 downto 0);
						speed_out	=>	spi_north_speed,	--:	out	std_logic_vector(speed_bw-1 downto 0);
						power_out	=>	spi_north_power,	--:	out	std_logic_vector(power_bw-1 downto 0);

						sclk		=>	SCLK_NORTH,			--:	in	std_logic;
						ss_n		=>	SS_N_NORTH,			--:	in	std_logic;
						mosi		=>	MOSI_NORTH,			--:	in	std_logic;
						miso		=>	MISO_NORTH			--:	out	std_logic;
					);

	WiFi_South_Inst: entity work.spi_interface
		generic map	(
						carid_bw	=>	CAR_ID_BUS_WIDTH,		--:	positive;
						speed_bw	=>	CAR_SPEED_BUS_WIDTH,	--:	positive;
						power_bw	=>	RX_POWER_BUS_WIDTH		--:	positive;
					)
		port map	(
						app_clk		=>	clk_200,			--:	in	std_logic;
						app_rst		=>	reset_200,			--:	in	std_logic;

						valid_out	=>	spi_south_valid,	--:	out	std_logic;
						car_id_out	=>	spi_south_carid,	--:	out	std_logic_vector(carid_bw-1 downto 0);
						speed_out	=>	spi_south_speed,	--:	out	std_logic_vector(speed_bw-1 downto 0);
						power_out	=>	spi_south_power,	--:	out	std_logic_vector(power_bw-1 downto 0);

						sclk		=>	SCLK_SOUTH,			--:	in	std_logic;
						ss_n		=>	SS_N_SOUTH,			--:	in	std_logic;
						mosi		=>	MOSI_SOUTH,			--:	in	std_logic;
						miso		=>	MISO_SOUTH			--:	out	std_logic;
					);

	WiFi_East_Inst: entity work.spi_interface
		generic map	(
						carid_bw	=>	CAR_ID_BUS_WIDTH,		--:	positive;
						speed_bw	=>	CAR_SPEED_BUS_WIDTH,	--:	positive;
						power_bw	=>	RX_POWER_BUS_WIDTH		--:	positive;
					)
		port map	(
						app_clk		=>	clk_200,		--:	in	std_logic;
						app_rst		=>	reset_200,		--:	in	std_logic;
						
						valid_out	=>	spi_east_valid,	--:	out	std_logic;
						car_id_out	=>	spi_east_carid,	--:	out	std_logic_vector(carid_bw-1 downto 0);
						speed_out	=>	spi_east_speed,	--:	out	std_logic_vector(speed_bw-1 downto 0);
						power_out	=>	spi_east_power,	--:	out	std_logic_vector(power_bw-1 downto 0);

						sclk		=>	SCLK_EAST,		--:	in	std_logic;
						ss_n		=>	SS_N_EAST,		--:	in	std_logic;
						mosi		=>	MOSI_EAST,		--:	in	std_logic;
						miso		=>	MISO_EAST		--:	out	std_logic;
					);

	WiFi_West_Inst: entity work.spi_interface
		generic map	(
						carid_bw	=>	CAR_ID_BUS_WIDTH,		--:	positive;
						speed_bw	=>	CAR_SPEED_BUS_WIDTH,	--:	positive;
						power_bw	=>	RX_POWER_BUS_WIDTH		--:	positive;
					)
		port map	(
						app_clk		=>	clk_200,		--:	in	std_logic;
						app_rst		=>	reset_200,		--:	in	std_logic;
						
						valid_out	=>	spi_west_valid,	--:	out	std_logic;
						car_id_out	=>	spi_west_carid,	--:	out	std_logic_vector(carid_bw-1 downto 0);
						speed_out	=>	spi_west_speed,	--:	out	std_logic_vector(speed_bw-1 downto 0);
						power_out	=>	spi_west_power,	--:	out	std_logic_vector(power_bw-1 downto 0);

						sclk		=>	SCLK_WEST,		--:	in	std_logic;
						ss_n		=>	SS_N_WEST,		--:	in	std_logic;
						mosi		=>	MOSI_WEST,		--:	in	std_logic;
						miso		=>	MISO_WEST		--:	out	std_logic;
					);
--

--	Region Arrival Time Calcilators

	arrival_time_calc_north: entity work.arrival_time_calc
		generic map	(
						carid_bw	=>	CAR_ID_BUS_WIDTH,		--:	positive;
						speed_bw	=>	CAR_SPEED_BUS_WIDTH,	--:	positive;
						power_bw	=>	RX_POWER_BUS_WIDTH,		--:	positive;
						time_bw		=>	ARRIVAL_TIME_WIDTH		--:	positive;
					)
		port map	(
						app_clk			=>	clk_200,			--:	in	std_logic;
						app_rst			=>	reset_200,			--:	in	std_logic;

						valid_in		=>	spi_north_valid,	--:	in	std_logic;
						carid_in		=>	spi_north_carid,	--:	in	std_logic_vector(carid_bw-1 downto 0);
						speed_in		=>	spi_north_speed,	--:	in	std_logic_vector(speed_bw-1 downto 0);
						power_in		=>	spi_north_power,	--:	in	std_logic_vector(power_bw-1 downto 0);
						
						valid_out		=>	north_time_valid,	--:	out	std_logic;
						carid_out		=>	north_carid,		--:	out	std_logic_vector(carid_bw-1 downto 0);
						arrival_time	=>	north_time			--:	out	std_logic_vector(time_bw-1 downto 0);
					);

	arrival_time_calc_south: entity work.arrival_time_calc
		generic map	(
						carid_bw	=>	CAR_ID_BUS_WIDTH,		--:	positive;
						speed_bw	=>	CAR_SPEED_BUS_WIDTH,	--:	positive;
						power_bw	=>	RX_POWER_BUS_WIDTH,		--:	positive;
						time_bw		=>	ARRIVAL_TIME_WIDTH		--:	positive;
					)
		port map	(
						app_clk			=>	clk_200,			--:	in	std_logic;
						app_rst			=>	reset_200,			--:	in	std_logic;

						valid_in		=>	spi_south_valid,	--:	in	std_logic;
						carid_in		=>	spi_south_carid,	--:	in	std_logic_vector(carid_bw-1 downto 0);
						speed_in		=>	spi_south_speed,	--:	in	std_logic_vector(speed_bw-1 downto 0);
						power_in		=>	spi_south_power,	--:	in	std_logic_vector(power_bw-1 downto 0);
						
						valid_out		=>	south_time_valid,	--:	out	std_logic;
						carid_out		=>	south_carid,		--:	out	std_logic_vector(carid_bw-1 downto 0);
						arrival_time	=>	south_time			--:	out	std_logic_vector(time_bw-1 downto 0);
					);
	
	arrival_time_calc_east: entity work.arrival_time_calc
		generic map	(
						carid_bw	=>	CAR_ID_BUS_WIDTH,		--:	positive;
						speed_bw	=>	CAR_SPEED_BUS_WIDTH,	--:	positive;
						power_bw	=>	RX_POWER_BUS_WIDTH,		--:	positive;
						time_bw		=>	ARRIVAL_TIME_WIDTH		--:	positive;
					)
		port map	(
						app_clk			=>	clk_200,			--:	in	std_logic;
						app_rst			=>	reset_200,			--:	in	std_logic;

						valid_in		=>	spi_east_valid,		--:	in	std_logic;
						carid_in		=>	spi_east_carid,		--:	in	std_logic_vector(carid_bw-1 downto 0);
						speed_in		=>	spi_east_speed,		--:	in	std_logic_vector(speed_bw-1 downto 0);
						power_in		=>	spi_east_power,		--:	in	std_logic_vector(power_bw-1 downto 0);
						
						valid_out		=>	east_time_valid,	--:	out	std_logic;
						carid_out		=>	east_carid,			--:	out	std_logic_vector(carid_bw-1 downto 0);
						arrival_time	=>	east_time			--:	out	std_logic_vector(time_bw-1 downto 0);
				);
	
	arrival_time_calc_west: entity work.arrival_time_calc
		generic map	(
						carid_bw	=>	CAR_ID_BUS_WIDTH,		--:	positive;
						speed_bw	=>	CAR_SPEED_BUS_WIDTH,	--:	positive;
						power_bw	=>	RX_POWER_BUS_WIDTH,		--:	positive;
						time_bw		=>	ARRIVAL_TIME_WIDTH		--:	positive;
					)
		port map	(
						app_clk			=>	clk_200,			--:	in	std_logic;
						app_rst			=>	reset_200,			--:	in	std_logic;

						valid_in		=>	spi_west_valid,		--:	in	std_logic;
						carid_in		=>	spi_west_carid,		--:	in	std_logic_vector(carid_bw-1 downto 0);
						speed_in		=>	spi_west_speed,		--:	in	std_logic_vector(speed_bw-1 downto 0);
						power_in		=>	spi_west_power,		--:	in	std_logic_vector(power_bw-1 downto 0);
						
						valid_out		=>	west_time_valid,	--:	out	std_logic;
						carid_out		=>	west_carid,			--:	out	std_logic_vector(carid_bw-1 downto 0);
						arrival_time	=>	west_time			--:	out	std_logic_vector(time_bw-1 downto 0);
					);
--

--	Region Main Controller
main_controller_ist: entity work.main_controller
	generic map	(
					carid_bw	=>	CAR_ID_BUS_WIDTH	--:	positive;
					time_bw		=>	ARRIVAL_TIME_WIDTH	--:	positive;
				)
	port map	(
					app_clk				=>	clk_200,				--:	in	std_logic;
					app_rst				=>	reset_200,				--:	in	std_logic;

					north_valid_in		=>	north_time_valid,		--:	in	std_logic;
					north_carid			=>	north_carid,			--:	in	std_logic_vector(carid_bw-1 downto 0);
					north_time_in		=>	north_time,				--:	in	std_logic_vector(time_bw-1 downto 0);

					south_valid_in		=>	south_time_valid,		--:	in	std_logic;
					south_carid			=>	south_carid,			--:	in	std_logic_vector(carid_bw-1 downto 0);
					south_time_in		=>	south_time,				--:	in	std_logic_vector(time_bw-1 downto 0);

					east_valid_in		=>	east_time_valid,		--:	in	std_logic;
					east_carid			=>	east_carid,				--:	in	std_logic_vector(carid_bw-1 downto 0);
					east_time_in		=>	east_time,				--:	in	std_logic_vector(time_bw-1 downto 0);

					west_valid_in		=>	west_time_valid,		--:	in	std_logic;
					west_carid			=>	west_carid,				--:	in	std_logic_vector(carid_bw-1 downto 0);
					west_time_in		=>	west_time,				--:	in	std_logic_vector(time_bw-1 downto 0);

					north_traffic_light	=>	north_traffic_light,	--:	out	std_logic_vector(3-1 downto 0);
					south_traffic_light	=>	south_traffic_light,	--:	out	std_logic_vector(3-1 downto 0);
					east_traffic_light	=>	east_traffic_light,		--:	out	std_logic_vector(3-1 downto 0);
					west_traffic_light	=>	west_traffic_light		--:	out	std_logic_vector(3-1 downto 0);
				);

	TRAFFIC_LIGHT_RED_NORTH		<=	north_traffic_light(0);
	TRAFFIC_LIGHT_YELLOW_NORTH	<=	north_traffic_light(1);
	TRAFFIC_LIGHT_GREEN_NORTH	<=	north_traffic_light(2);

	TRAFFIC_LIGHT_RED_SOUTH		<=	south_traffic_light(0);
	TRAFFIC_LIGHT_YELLOW_SOUTH	<=	south_traffic_light(1);
	TRAFFIC_LIGHT_GREEN_SOUTH	<=	south_traffic_light(2);

	TRAFFIC_LIGHT_RED_EAST		<=	east_traffic_light(0);
	TRAFFIC_LIGHT_YELLOW_EAST	<=	east_traffic_light(1);
	TRAFFIC_LIGHT_GREEN_EAST	<=	east_traffic_light(2);

	TRAFFIC_LIGHT_RED_WEST		<=	west_traffic_light(0);
	TRAFFIC_LIGHT_YELLOW_WEST	<=	west_traffic_light(1);
	TRAFFIC_LIGHT_GREEN_WEST	<=	west_traffic_light(2);
--

	User_LEDs_Driver_p: process(reset_200, clk_200)
	begin
		if (reset_200 = '1') then
			USER_LEDS	<=	(others => '0');
		elsif (rising_edge(clk_200)) then
			USER_LEDS	<=	(others => main_pll_locked);
		end if;
	end process User_LEDs_Driver_p;

end rtl;
