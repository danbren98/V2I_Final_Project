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
				
				USER_LEDS					:	out	std_logic_vector(3 downto 0)
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
	
	signal	north_traffic_light	:	std_logic_vector(3-1 downto 0)	:=	"001";
	signal	south_traffic_light	:	std_logic_vector(3-1 downto 0)	:=	"010";
	signal	east_traffic_light	:	std_logic_vector(3-1 downto 0)	:=	"100";
	signal	west_traffic_light	:	std_logic_vector(3-1 downto 0)	:=	"011";


	signal	north_time_valid_s	:	std_logic;
	signal	north_carid_s		:	std_logic_vector(CAR_ID_BUS_WIDTH-1 downto 0);
	signal	north_time_s		:	std_logic_vector(ARRIVAL_TIME_WIDTH-1 downto 0);
	signal	south_time_valid_s	:	std_logic;
	signal	south_carid_s		:	std_logic_vector(CAR_ID_BUS_WIDTH-1 downto 0);
	signal	south_time_s		:	std_logic_vector(ARRIVAL_TIME_WIDTH-1 downto 0);
	signal	east_time_valid_s	:	std_logic;
	signal	east_carid_s		:	std_logic_vector(CAR_ID_BUS_WIDTH-1 downto 0);
	signal	east_time_s			:	std_logic_vector(ARRIVAL_TIME_WIDTH-1 downto 0);
	signal	west_time_valid_s	:	std_logic;
	signal	west_carid_s		:	std_logic_vector(CAR_ID_BUS_WIDTH-1 downto 0);
	signal	west_time_s			:	std_logic_vector(ARRIVAL_TIME_WIDTH-1 downto 0);

	signal	one_sec_cntr		:	unsigned(9 downto 0)	:=	(others => '0');
	signal	one_ms_cntr			:	unsigned(9 downto 0)	:=	(others => '0');
	signal	one_us_cntr			:	unsigned(9 downto 0)	:=	(others => '0');
	signal	one_sec_pulse		:	std_logic				:=	'0';
	signal	one_ms_pulse		:	std_logic				:=	'0';
	signal	one_us_pulse		:	std_logic				:=	'0';

	attribute noprune : boolean;
	attribute noprune of north_time_valid_s	: signal is false;
	attribute noprune of north_carid_s		: signal is false;
	attribute noprune of north_time_s		: signal is false;
	attribute noprune of south_time_valid_s	: signal is false;
	attribute noprune of south_carid_s		: signal is false;
	attribute noprune of south_time_s		: signal is false;
	attribute noprune of east_time_valid_s	: signal is false;
	attribute noprune of east_carid_s		: signal is false;
	attribute noprune of east_time_s		: signal is false;
	attribute noprune of west_time_valid_s	: signal is false;
	attribute noprune of west_carid_s		: signal is false;
	attribute noprune of west_time_s		: signal is false;

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
					carid_bw	=>	CAR_ID_BUS_WIDTH,	--:	positive;
					time_bw		=>	ARRIVAL_TIME_WIDTH	--:	positive;
				)
	port map	(
					app_clk				=>	clk_200,				--:	in	std_logic;
					app_rst				=>	reset_200,				--:	in	std_logic;

					north_valid			=>	north_time_valid,		--:	in	std_logic;
					north_carid			=>	north_carid,			--:	in	std_logic_vector(carid_bw-1 downto 0);
					north_arrival_time	=>	north_time,				--:	in	std_logic_vector(time_bw-1 downto 0);

					south_valid			=>	south_time_valid,		--:	in	std_logic;
					south_carid			=>	south_carid,			--:	in	std_logic_vector(carid_bw-1 downto 0);
					south_arrival_time	=>	south_time,				--:	in	std_logic_vector(time_bw-1 downto 0);

					east_valid			=>	east_time_valid,		--:	in	std_logic;
					east_carid			=>	east_carid,				--:	in	std_logic_vector(carid_bw-1 downto 0);
					east_arrival_time	=>	east_time,				--:	in	std_logic_vector(time_bw-1 downto 0);

					west_valid			=>	west_time_valid,		--:	in	std_logic;
					west_carid			=>	west_carid,				--:	in	std_logic_vector(carid_bw-1 downto 0);
					west_arrival_time	=>	west_time,				--:	in	std_logic_vector(time_bw-1 downto 0);

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

	
	-- process(clk_200)
	-- begin
	-- 	if (rising_edge(clk_200)) then
	-- 		north_time_valid_s	<=	north_time_valid;
	-- 		north_carid_s		<=	north_carid;
	-- 		north_time_s		<=	north_time;
	-- 		south_time_valid_s	<=	south_time_valid;
	-- 		south_carid_s		<=	south_carid;
	-- 		south_time_s		<=	south_time;
	-- 		east_time_valid_s	<=	east_time_valid;
	-- 		east_carid_s		<=	east_carid;
	-- 		east_time_s			<=	east_time;
	-- 		west_time_valid_s	<=	west_time_valid;
	-- 		west_carid_s		<=	west_carid;
	-- 		west_time_s			<=	west_time;
	-- 	end if;
	-- end process;



	User_LEDs_Driver_p: process(reset_200, clk_200)
	begin
		if (reset_200 = '1') then
			USER_LEDS	<=	(others => '1');
		elsif (rising_edge(clk_200)) then
			USER_LEDS	<=	(others => not main_pll_locked);
		end if;
	end process User_LEDs_Driver_p;





	-- process(clk_200)
	-- begin
	-- 	if (rising_edge(clk_200)) then
	-- 		if (one_sec_pulse = '1') then
	-- 			north_traffic_light	<=	north_traffic_light(north_traffic_light'high-1 downto 0) & north_traffic_light(north_traffic_light'high);
	-- 			south_traffic_light	<=	south_traffic_light(south_traffic_light'high-1 downto 0) & south_traffic_light(south_traffic_light'high);
	-- 			east_traffic_light	<=	east_traffic_light(east_traffic_light'high-1 downto 0) & east_traffic_light(east_traffic_light'high);
	-- 			west_traffic_light	<=	west_traffic_light(west_traffic_light'high-1 downto 0) & west_traffic_light(west_traffic_light'high);
	-- 		end if;
	-- 	end if;
	-- end process;
	
	-- One_Second_Timer_p:
	-- 	process(clk_200)
	-- 	begin
	-- 		if (rising_edge(clk_200)) then
	-- 			if (one_ms_pulse = '1') then
	-- 				if (one_sec_cntr = 1000-1) then
	-- 					one_sec_pulse	<=	'1';
	-- 					one_sec_cntr	<=	(others => '0');
	-- 				else
	-- 					one_sec_pulse	<=	'0';
	-- 					one_sec_cntr	<=	one_sec_cntr + 1;
	-- 				end if;
	-- 			else
	-- 				one_sec_pulse	<=	'0';
	-- 			end if;
				
	-- 			if (one_us_pulse = '1') then
	-- 				if (one_ms_cntr = 1000-1) then
	-- 					one_ms_pulse	<=	'1';
	-- 					one_ms_cntr		<=	(others => '0');
	-- 				else
	-- 					one_ms_pulse	<=	'0';
	-- 					one_ms_cntr		<=	one_ms_cntr + 1;
	-- 				end if;
	-- 			else
	-- 				one_ms_pulse	<=	'0';
	-- 			end if;
				
	-- 			if (one_us_cntr = 200-1) then
	-- 				one_us_pulse	<=	'1';
	-- 				one_us_cntr		<=	(others => '0');
	-- 			else
	-- 				one_us_pulse	<=	'0';
	-- 				one_us_cntr		<=	one_us_cntr + 1;
	-- 			end if;
				
	-- 		end if;
	-- 	end process;

end rtl;
