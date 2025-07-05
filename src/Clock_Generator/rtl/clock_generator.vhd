library IEEE;
	use IEEE.std_logic_1164.all;


entity clock_generator is
	port	(
				hard_arst	:	in	std_logic;
				soft_arst	:	in	std_logic;
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

	signal	pll_rst			:	std_logic;
	signal	hard_arst_deb	:	std_logic;
	signal	soft_arst_deb	:	std_logic;
	signal	rst_to_sync		:	std_logic;
	signal	clk_200_s		:	std_logic;
	signal	locked_s		:	std_logic;

begin

	SYS_HARD_RSTN_Debouncer: entity work.debouncer
		generic map	(
						polarity	=>	'0',	--:	std_logic;
						time_out_w	=>	15,		--:	positive;
						timeout		=>	500		--:	natural
					)
		port map	(
						clk_in		=>	refclk,			--:	in	std_logic;

						sig_in		=>	hard_arst,		--:	in	std_logic;
						sig_out		=>	hard_arst_deb	--:	out	std_logic
					);
	
	SYS_SOFT_RST_Debouncer: entity work.debouncer
		generic map	(
						polarity	=>	'0',	--:	std_logic;
						time_out_w	=>	15,		--:	positive;
						timeout		=>	500		--:	natural
					)
		port map	(
						clk_in		=>	refclk,			--:	in	std_logic;

						sig_in		=>	soft_arst,		--:	in	std_logic;
						sig_out		=>	soft_arst_deb	--:	out	std_logic
					);
	
	pll_rst	<=	not hard_arst_deb;
	
	main_pll_inst: main_pll
		port map	(
						areset	=>	pll_rst,	--: in std_logic	:=	'0';
						inclk0	=>	refclk,		--: in std_logic	:=	'0';
						c0		=>	clk_200_s,	--: out std_logic;
						locked	=>	locked_s	--: out std_logic
					);

	rst_to_sync	<=	locked_s and soft_arst_deb;

	reset_200_sync: entity work.async_rst_sync
		generic map	(
						polin	=>	'0',	--:	std_logic;	--	Polarity of input reset
						polout	=>	'1',	--:	std_logic;	--	Polarity of output reset
						stages	=>	3		--:	positive;	--	Number of reset stages
					)
		port map	(
						arst_in		=>	rst_to_sync,	--:	in	std_logic;
						clk_in		=>	clk_200_s,		--:	in	std_logic;
		
						arst_out	=>	reset_200		--:	out	std_logic
					);


	clk_200	<=	clk_200_s;
	locked	<=	locked_s;
	
end rtl;