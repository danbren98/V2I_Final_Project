library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

entity Junction_MB_Top is
	port	(
				SYS_CLK		:	in	std_logic;
				SYS_RSTN	:	in	std_logic;

				USER_LEDS	:	out	std_logic_vector(7 downto 0)
			);
end entity Junction_MB_Top;

architecture rtl of Junction_MB_Top is

	constant MAX_COUNT	:   natural	:=	50000000 / 2; -- 50 MHz / 2 = 25 million for 1 second period

	signal	global_reset	:	std_logic;
	
	signal	counter		:	unsigned(25 downto 0)	:=	(others => '0');
	signal	usr_led_drv	:	std_logic						:=	'0';


begin

	SYS_RSTN_Synchronizer: entity work.async_rst_sync
		generic map	(
						polin	=>	'0',	--:	std_logic;	--	Polarity of input reset
						polout	=>	'1',	--:	std_logic;	--	Polarity of input reset
						stages	=>	3		--:	positive;	--	Polarity of output reset
					)
		port map	(
						arst_in		=>	SYS_RSTN,	--:	in	std_logic;
						clk_in		=>	SYS_CLK,	--:	in	std_logic;
		
						arst_out	=>	global_reset	--:	out	std_logic
					);
	
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

	LED_Routing_gen:
		for i in 0 to 7 generate
			USER_LEDS(i)	<=	usr_led_drv;
		end generate;

end rtl;