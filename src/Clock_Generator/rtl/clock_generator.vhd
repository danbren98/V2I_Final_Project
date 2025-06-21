library IEEE;
	use IEEE.std_logic_1164.all;


entity clock_generator is
	port	(
				arst		:	in	std_logic;
				refclk		:	in	std_logic;

				locked		:	out	std_logic;

				clk_200		:	out	std_logic;
				reset_200	:	out	std_logic
			);
end clock_generator;

architecture rtl of clock_generator is
	
	component main_pll
		port	(
					areset	: in std_logic	:=	'0';
					inclk0	: in std_logic	:=	'0';
					c0		: out std_logic;
					locked	: out std_logic
				);
	end component;

	signal	pll_rst		:	std_logic;
	signal	arst_deb	:	std_logic;
	signal	clk_200_s	:	std_logic;

begin

	SYS_RSTN_Debouncer: entity work.debouncer
		generic map	(
						polarity	=>	'0',	--:	std_logic;
						time_out_w	=>	15,		--:	positive;
						timeout		=>	500	--:	natural
					)
		port map	(
						clk_in		=>	refclk,		--:	in	std_logic;

						sig_in		=>	arst,		--:	in	std_logic;
						sig_out		=>	arst_deb	--:	out	std_logic
					);
	
	pll_rst	<=	not arst_deb;
	
	main_pll_inst: main_pll
		port map	(
						areset	=>	pll_rst,	--: in std_logic	:=	'0';
						inclk0	=>	refclk,		--: in std_logic	:=	'0';
						c0		=>	clk_200_s,	--: out std_logic;
						locked	=>	locked		--: out std_logic
					);

	reset_200_sync: entity work.async_rst_sync
		generic map	(
						polin	=>	'0',	--:	std_logic;	--	Polarity of input reset
						polout	=>	'1',	--:	std_logic;	--	Polarity of output reset
						stages	=>	3		--:	positive;	--	Number of reset stages
					)
		port map	(
						arst_in		=>	locked,		--:	in	std_logic;
						clk_in		=>	clk_200_s,	--:	in	std_logic;
		
						arst_out	=>	reset_200	--:	out	std_logic
					);


	clk_200	<=	clk_200_s;
	
end rtl;