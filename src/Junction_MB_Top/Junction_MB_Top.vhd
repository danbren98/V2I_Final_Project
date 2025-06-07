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

	signal	sys_rstn_deb		:	std_logic;
	signal	global_reset		:	std_logic;

	signal	spi_north_valid		:	std_logic;
	signal	spi_north_speed		:	std_logic_vector(8-1 downto 0);
	signal	spi_north_power		:	std_logic_vector(8-1 downto 0);
	
	signal	spi_south_valid		:	std_logic;
	signal	spi_south_speed		:	std_logic_vector(8-1 downto 0);
	signal	spi_south_power		:	std_logic_vector(8-1 downto 0);
	
	signal	spi_east_valid		:	std_logic;
	signal	spi_east_speed		:	std_logic_vector(8-1 downto 0);
	signal	spi_east_power		:	std_logic_vector(8-1 downto 0);

	signal	spi_west_valid		:	std_logic;
	signal	spi_west_speed		:	std_logic_vector(8-1 downto 0);
	signal	spi_west_power		:	std_logic_vector(8-1 downto 0);

	signal	north_time_valid	:	std_logic;
	signal	north_time			:	std_logic_vector(8-1 downto 0);
	
	signal	south_time_valid	:	std_logic;
	signal	south_time			:	std_logic_vector(8-1 downto 0);
	
	signal	east_time_valid		:	std_logic;
	signal	east_time			:	std_logic_vector(8-1 downto 0);
	
	signal	west_time_valid		:	std_logic;
	signal	west_time			:	std_logic_vector(8-1 downto 0);
	
	signal	mctrl_valid_in		:	std_logic_vector(4-1 downto 0);
	signal	mctrl_time_in		:	std_logic_vector(4*8-1 downto 0);
	signal	mctrl_trflt_r		:	std_logic_vector(4-1 downto 0);
	signal	mctrl_trflt_y		:	std_logic_vector(4-1 downto 0);
	signal	mctrl_trflt_g		:	std_logic_vector(4-1 downto 0);

begin
	
	SYS_RSTN_Debouncer: entity work.debouncer
		generic map	(
						polarity	=>	'0',	--:	std_logic;
						time_out_w	=>	16,		--:	positive;
						timeout		=>	50_000	--:	natural
					)
		port map	(
						clk_in		=>	SYS_CLK,		--:	in	std_logic;

						sig_in		=>	SYS_RSTN,		--:	in	std_logic;
						sig_out		=>	sys_rstn_deb	--:	out	std_logic
					);
	
	SYS_RST_Synchronizer: entity work.async_rst_sync
		generic map	(
						polin	=>	'0',	--:	std_logic;	--	Polarity of input reset
						polout	=>	'1',	--:	std_logic;	--	Polarity of output reset
						stages	=>	3		--:	positive;	--	Number of reset stages
					)
		port map	(
						arst_in		=>	sys_rstn_deb,	--:	in	std_logic;
						clk_in		=>	SYS_CLK,		--:	in	std_logic;
		
						arst_out	=>	global_reset	--:	out	std_logic
					);
	
--	Region WiFi Modules Interface	
	
	WiFi_North_Inst: entity work.spi_interface
		generic map	(
						speed_bw	=>	8,	--:	positive;
						power_bw	=>	8	--:	positive;
					)
		port map	(
						app_clk		=>	SYS_CLK,			--:	in	std_logic;
						app_rst		=>	global_reset,		--:	in	std_logic;

						valid_out	=>	spi_north_valid,	--:	out	std_logic;
						speed_out	=>	spi_north_speed,	--:	out	std_logic_vector(speed_bw-1 downto 0);
						power_out	=>	spi_north_power,	--:	out	std_logic_vector(power_bw-1 downto 0);

						sclk		=>	SCLK_NORTH,			--:	in	std_logic;
						ss_n		=>	SS_N_NORTH,			--:	in	std_logic;
						mosi		=>	MOSI_NORTH,			--:	in	std_logic;
						miso		=>	MISO_NORTH			--:	out	std_logic;
					);

	WiFi_South_Inst: entity work.spi_interface
		generic map	(
						speed_bw	=>	8,	--:	positive;
						power_bw	=>	8	--:	positive;
					)
		port map	(
						app_clk		=>	SYS_CLK,			--:	in	std_logic;
						app_rst		=>	global_reset,		--:	in	std_logic;

						valid_out	=>	spi_south_valid,	--:	out	std_logic;
						speed_out	=>	spi_south_speed,	--:	out	std_logic_vector(speed_bw-1 downto 0);
						power_out	=>	spi_south_power,	--:	out	std_logic_vector(power_bw-1 downto 0);

						sclk		=>	SCLK_SOUTH,			--:	in	std_logic;
						ss_n		=>	SS_N_SOUTH,			--:	in	std_logic;
						mosi		=>	MOSI_SOUTH,			--:	in	std_logic;
						miso		=>	MISO_SOUTH			--:	out	std_logic;
					);

	WiFi_East_Inst: entity work.spi_interface
		generic map	(
						speed_bw	=>	8,	--:	positive;
						power_bw	=>	8	--:	positive;
					)
		port map	(
						app_clk		=>	SYS_CLK,		--:	in	std_logic;
						app_rst		=>	global_reset,	--:	in	std_logic;
						
						valid_out	=>	spi_east_valid,	--:	out	std_logic;
						speed_out	=>	spi_east_speed,	--:	out	std_logic_vector(speed_bw-1 downto 0);
						power_out	=>	spi_east_power,	--:	out	std_logic_vector(power_bw-1 downto 0);

						sclk		=>	SCLK_EAST,		--:	in	std_logic;
						ss_n		=>	SS_N_EAST,		--:	in	std_logic;
						mosi		=>	MOSI_EAST,		--:	in	std_logic;
						miso		=>	MISO_EAST		--:	out	std_logic;
					);

	WiFi_West_Inst: entity work.spi_interface
		generic map	(
						speed_bw	=>	8,	--:	positive;
						power_bw	=>	8	--:	positive;
					)
		port map	(
						app_clk		=>	SYS_CLK,		--:	in	std_logic;
						app_rst		=>	global_reset,	--:	in	std_logic;
						
						valid_out	=>	spi_west_valid,	--:	out	std_logic;
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
						speed_bw	=>	8,	--:	positive;
						power_bw	=>	8,	--:	positive;
						time_bw		=>	8	--:	positive;
					)
		port map	(
						app_clk			=>	SYS_CLK,			--:	in	std_logic;
						app_rst			=>	global_reset,		--:	in	std_logic;

						valid_in		=>	spi_north_valid,	--:	in	std_logic;
						speed_in		=>	spi_north_speed,	--:	in	std_logic_vector(speed_bw-1 downto 0);
						power_in		=>	spi_north_power,	--:	in	std_logic_vector(power_bw-1 downto 0);
						
						valid_out		=>	north_time_valid,	--:	out	std_logic;
						arrival_time	=>	north_time			--:	out	std_logic_vector(time_bw-1 downto 0);
					);

	arrival_time_calc_south: entity work.arrival_time_calc
		generic map	(
						speed_bw	=>	8,	--:	positive;
						power_bw	=>	8,	--:	positive;
						time_bw		=>	8	--:	positive;
					)
		port map	(
						app_clk			=>	SYS_CLK,			--:	in	std_logic;
						app_rst			=>	global_reset,		--:	in	std_logic;

						valid_in		=>	spi_south_valid,	--:	in	std_logic;
						speed_in		=>	spi_south_speed,	--:	in	std_logic_vector(speed_bw-1 downto 0);
						power_in		=>	spi_south_power,	--:	in	std_logic_vector(power_bw-1 downto 0);
						
						valid_out		=>	south_time_valid,	--:	out	std_logic;
						arrival_time	=>	south_time			--:	out	std_logic_vector(time_bw-1 downto 0);
					);
	
	arrival_time_calc_east: entity work.arrival_time_calc
		generic map	(
						speed_bw	=>	8,	--:	positive;
						power_bw	=>	8,	--:	positive;
						time_bw		=>	8	--:	positive;
					)
		port map	(
						app_clk			=>	SYS_CLK,			--:	in	std_logic;
						app_rst			=>	global_reset,		--:	in	std_logic;

						valid_in		=>	spi_east_valid,		--:	in	std_logic;
						speed_in		=>	spi_east_speed,		--:	in	std_logic_vector(speed_bw-1 downto 0);
						power_in		=>	spi_east_power,		--:	in	std_logic_vector(power_bw-1 downto 0);
						
						valid_out		=>	east_time_valid,	--:	out	std_logic;
						arrival_time	=>	east_time			--:	out	std_logic_vector(time_bw-1 downto 0);
				);
	
	arrival_time_calc_west: entity work.arrival_time_calc
		generic map	(
						speed_bw	=>	8,	--:	positive;
						power_bw	=>	8,	--:	positive;
						time_bw		=>	8	--:	positive;
					)
		port map	(
						app_clk			=>	SYS_CLK,			--:	in	std_logic;
						app_rst			=>	global_reset,		--:	in	std_logic;

						valid_in		=>	spi_west_valid,		--:	in	std_logic;
						speed_in		=>	spi_west_speed,		--:	in	std_logic_vector(speed_bw-1 downto 0);
						power_in		=>	spi_west_power,		--:	in	std_logic_vector(power_bw-1 downto 0);
						
						valid_out		=>	west_time_valid,	--:	out	std_logic;
						arrival_time	=>	west_time			--:	out	std_logic_vector(time_bw-1 downto 0);
					);
--

--	Region Main Controller

mctrl_valid_in	<=	west_time_valid & east_time_valid & south_time_valid & north_time_valid;
mctrl_time_in	<=	west_time & east_time & south_time & north_time;

main_controller_ist: entity work.main_controller
	generic map	(
					time_bw		=>	8	--:	positive;
				)
	port map	(
					app_clk						=>	SYS_CLK,		--:	in	std_logic;
					app_rst						=>	global_reset,	--:	in	std_logic;

					valid_in					=>	mctrl_valid_in,	--:	in	std_logic_vector(4-1 downto 0);
					time_in						=>	mctrl_time_in,	--:	in	std_logic_vector(4*time_bw-1 downto 0);
					
					traffic_light_out_red		=>	mctrl_trflt_r,	--:	out	std_logic_vector(4-1 downto 0);
					traffic_light_out_yellow	=>	mctrl_trflt_y,	--:	out	std_logic_vector(4-1 downto 0);
					traffic_light_out_green		=>	mctrl_trflt_g	--:	out	std_logic_vector(4-1 downto 0);
				);

	TRAFFIC_LIGHT_RED_NORTH		<=	mctrl_trflt_r(0);
	TRAFFIC_LIGHT_YELLOW_NORTH	<=	mctrl_trflt_y(0);
	TRAFFIC_LIGHT_GREEN_NORTH	<=	mctrl_trflt_g(0);

	TRAFFIC_LIGHT_RED_SOUTH		<=	mctrl_trflt_r(1);
	TRAFFIC_LIGHT_YELLOW_SOUTH	<=	mctrl_trflt_y(1);
	TRAFFIC_LIGHT_GREEN_SOUTH	<=	mctrl_trflt_g(1);

	TRAFFIC_LIGHT_RED_EAST		<=	mctrl_trflt_r(2);
	TRAFFIC_LIGHT_YELLOW_EAST	<=	mctrl_trflt_y(2);
	TRAFFIC_LIGHT_GREEN_EAST	<=	mctrl_trflt_g(2);

	TRAFFIC_LIGHT_RED_WEST		<=	mctrl_trflt_r(3);
	TRAFFIC_LIGHT_YELLOW_WEST	<=	mctrl_trflt_y(3);
	TRAFFIC_LIGHT_GREEN_WEST	<=	mctrl_trflt_g(3);
--

	User_LEDs_Driver_p: process(global_reset, SYS_CLK)
	begin
		if (global_reset = '1') then
			USER_LEDS	<=	(others => '0');
		elsif (rising_edge(SYS_CLK)) then
			USER_LEDS	<=	(others => '1');
		end if;
	end process User_LEDs_Driver_p;

end rtl;
