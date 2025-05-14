library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

entity Junction_MB_Top is
	port	(
				SYS_CLK		:	in	std_logic;
				SYS_RSTN	:	in	std_logic;

				SCLK_NORTH	:	in	std_logic;
				SS_N_NORTH	:	in	std_logic;
				MOSI_NORTH	:	in	std_logic;
				MISO_NORTH	:	out	std_logic;
				
				SCLK_SOUTH	:	in	std_logic;
				SS_N_SOUTH	:	in	std_logic;
				MOSI_SOUTH	:	in	std_logic;
				MISO_SOUTH	:	out	std_logic;
				
				SCLK_EAST	:	in	std_logic;
				SS_N_EAST	:	in	std_logic;
				MOSI_EAST	:	in	std_logic;
				MISO_EAST	:	out	std_logic;
				
				SCLK_WEST	:	in	std_logic;
				SS_N_WEST	:	in	std_logic;
				MOSI_WEST	:	in	std_logic;
				MISO_WEST	:	out	std_logic;
				
				USER_LEDS	:	out	std_logic_vector(7 downto 0)
			);
end entity Junction_MB_Top;

architecture rtl of Junction_MB_Top is

	constant MAX_COUNT	:   natural	:=	50000000 / 2; -- 50 MHz / 2 = 25 million for 1 second period

	component divider is
	port	(
				denom		:	in	std_logic_vector(15 downto 0);
				numer		:	in	std_logic_vector(15 downto 0);
				quotient	:	out	std_logic_vector(15 downto 0);
				remain		:	out	std_logic_vector(15 downto 0)
			);
	end component divider;
	
	signal	global_resetn	:	std_logic;
	signal	global_reset	:	std_logic;
	
	signal	counter		:	unsigned(25 downto 0)	:=	(others => '0');
	signal	usr_led_drv	:	std_logic				:=	'0';


	signal	spi_north_rxdata	:	std_logic_vector(15 downto 0);
	signal	spi_north_rxvalid	:	std_logic;
	
	signal	spi_north_busy		:	std_logic;

	signal	div_denom			:	std_logic_vector(15 downto 0);
	signal	div_quotient		:	std_logic_vector(15 downto 0);
	signal	div_remain			:	std_logic_vector(15 downto 0);

	attribute preserve : boolean;
	attribute preserve of div_remain	:	signal is true;
	
	attribute noprune : boolean;
	attribute noprune of spi_north_rxvalid	:	signal is true;
	attribute noprune of spi_north_rxdata	:	signal is true;
	attribute noprune of spi_north_busy		:	signal is true;

begin

	SYS_RSTN_Synchronizer: entity work.async_rst_sync
		generic map	(
						polin	=>	'0',	--:	std_logic;	--	Polarity of input reset
						polout	=>	'0',	--:	std_logic;	--	Polarity of input reset
						stages	=>	3		--:	positive;	--	Polarity of output reset
					)
		port map	(
						arst_in		=>	SYS_RSTN,		--:	in	std_logic;
						clk_in		=>	SYS_CLK,		--:	in	std_logic;
		
						arst_out	=>	global_resetn	--:	out	std_logic
					);
	
	SYS_RST_Synchronizer: entity work.async_rst_sync
		generic map	(
						polin	=>	'0',	--:	std_logic;	--	Polarity of input reset
						polout	=>	'1',	--:	std_logic;	--	Polarity of input reset
						stages	=>	3		--:	positive;	--	Polarity of output reset
					)
		port map	(
						arst_in		=>	SYS_RSTN,		--:	in	std_logic;
						clk_in		=>	SYS_CLK,		--:	in	std_logic;
		
						arst_out	=>	global_reset	--:	out	std_logic
					);
	
--	Region WiFi Modules Interface	
	
WiFi_North_Inst: entity work.spi_slave
	generic map	(
					data_width	=>	16		--: integer
				)
	port map	(
					user_clk		=>	SYS_CLK,				--:	in	std_logic;
					user_rstn		=>	global_reset,			--:	in	std_logic;
					
					user_valid_tx	=>	usr_led_drv,			--:	in	std_logic;
					user_data_tx	=>	div_denom,				--:	in	std_logic_vector(data_width-1 downto 0);

					user_valid_rx	=>	spi_north_rxvalid,		--:	in	std_logic;
					user_data_rx	=>	spi_north_rxdata,		--:	out	std_logic_vector(data_width-1 downto 0);

					cpol			=>	'0',					--:	in	std_logic;
					cpha			=>	'0',					--:	in	std_logic;
					busy			=>	spi_north_busy,			--:	out	std_logic;

					sclk			=>	SCLK_NORTH,				--:	in	std_logic;
					ss_n			=>	SS_N_NORTH,				--:	in	std_logic;
					mosi			=>	MOSI_NORTH,				--:	in	std_logic;
					miso			=>	MISO_NORTH				--:	out	std_logic
				);
--	
	
	process(global_reset, SYS_CLK)
	begin
		if (global_reset = '1') then
			counter		<=	(others => '0');
			usr_led_drv	<=	'0';
		elsif (rising_edge(SYS_CLK)) then
			if (counter = MAX_COUNT-1) then
				counter		<=	(others => '0');
				usr_led_drv	<=	not usr_led_drv; -- Toggle LED state
			else
				counter	<=	counter + 1;
			end if;
		end if;
	end process;

	process(global_reset, SYS_CLK)
	begin
		if (global_reset = '1') then
			div_denom	<=	(others => '0');
		elsif (rising_edge(SYS_CLK)) then
			if (counter = MAX_COUNT-1) then
				div_denom	<=	std_logic_vector(unsigned(div_denom) + 1);
			end if;
		end if;
	end process;
	
	
	divider_inst: divider
	port map	(
					denom		=>	div_denom,		--:	in	std_logic_vector(15 downto 0);
					numer		=>	x"0001",		--:	in	std_logic_vector(15 downto 0);
					quotient	=>	div_quotient,	--:	out	std_logic_vector(15 downto 0);
					remain		=>	div_remain		--:	out	std_logic_vector(15 downto 0);
				);

	USER_LEDS	<=	div_quotient(7 downto 0);

end rtl;