library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

entity Junction_MB_Top_TB is
end entity Junction_MB_Top_TB;

architecture sim of Junction_MB_Top_TB is

	
	
	signal	sys_clk		:	std_logic	:=	'0';
	signal	sys_rstn	:	std_logic	:=	'0';

	signal	sclk		:	std_logic;
	signal	ssn			:	std_logic;
	signal	mosi		:	std_logic;
	signal	miso		:	std_logic;

	begin

	sys_clk		<=	'0', '1' after 10 ns;
	sys_rstn	<=	'0', '1' after 100 ns;
	

	DUT: entity work.Junction_MB_Top
		port map	(
						SYS_CLK		=>	sys_clk,	--:	in	std_logic;
						SYS_RSTN	=>	sys_rstn,	--:	in	std_logic;

						SCLK_NORTH	=>	sclk,		--:	in	std_logic;
						SS_N_NORTH	=>	ssn,		--:	in	std_logic;
						MOSI_NORTH	=>	mosi,		--:	in	std_logic;
						MISO_NORTH	=>	miso,		--:	out	std_logic;
						
						SCLK_SOUTH	=>	'0',		--:	in	std_logic;
						SS_N_SOUTH	=>	'1',		--:	in	std_logic;
						MOSI_SOUTH	=>	'0',		--:	in	std_logic;
						MISO_SOUTH	=>	open,		--:	out	std_logic;
						
						SCLK_EAST	=>	'0',		--:	in	std_logic;
						SS_N_EAST	=>	'1',		--:	in	std_logic;
						MOSI_EAST	=>	'0',		--:	in	std_logic;
						MISO_EAST	=>	open,		--:	out	std_logic;
						
						SCLK_WEST	=>	'0',		--:	in	std_logic;
						SS_N_WEST	=>	'1',		--:	in	std_logic;
						MOSI_WEST	=>	'0',		--:	in	std_logic;
						MISO_WEST	=>	open,		--:	out	std_logic;
					);
				
	
	spi_master_p:
		process(sys_rstn, sys_clk) is
		begin
			if (sys_rstn = '0') then
				sclk	<=	'0';
				ssn		<=	'1';
				mosi	<=	'0';
			elsif (rising_edge(sys_clk)) then
				
				if (spi_)
				
				
				
				case spi_transation_sm is
					when write_op =>

			end if;
		end process;




end sim;