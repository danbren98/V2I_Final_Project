library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

entity results_generator is
	port	(
				SYS_CLK		:	in	std_logic;
				SYS_RSTN	:	in	std_logic;

				USER_LEDS	:	out	std_logic_vector(7 downto 0)
			);
				
end entity results_generator;

architecture rtl of results_generator is

	constant MAX_COUNT	:   natural	:=	50000000 / 2; -- 50 MHz / 2 = 25 million for 1 second period

	component divider is
	port	(
				denom		:	in	std_logic_vector(7 downto 0);
				numer		:	in	std_logic_vector(5 downto 0);
				quotient	:	out	std_logic_vector(5 downto 0);
				remain		:	out	std_logic_vector(7 downto 0)
			);
	end component divider;
	
	signal	global_reset	:	std_logic;

	signal	gp_driver_cntr		:	unsigned(15 downto 0);
	signal	spi_north_rxvalid	:	std_logic;
	signal	spi_north_rxdata	:	std_logic_vector(15 downto 0);

	signal	spi_opcode			:	std_logic_vector(7 downto 0);
	signal	spi_register		:	std_logic_vector(7 downto 0);
	signal	spi_data			:	std_logic_vector(7 downto 0);
	
	signal	regaddr				:	std_logic_vector(7 downto 0);
	signal	speed_reg			:	std_logic_vector(7 downto 0);
	signal	sigpow_reg			:	std_logic_vector(7 downto 0);
	signal	distance			:	std_logic_vector(5 downto 0);
	
	signal	div_quotient		:	std_logic_vector(5 downto 0);
	signal	div_remain			:	std_logic_vector(7 downto 0);
	signal	div_quotient_s		:	std_logic_vector(5 downto 0);
	signal	div_remain_s		:	std_logic_vector(7 downto 0);


	attribute noprune : boolean;
	attribute noprune of div_quotient_s		:	signal is true;
	attribute noprune of div_remain_s		:	signal is true;
	-- attribute noprune of gp_driver_cntr		:	signal is true;
	-- attribute noprune of spi_north_rxvalid	:	signal is true;
	-- attribute noprune of spi_north_rxdata	:	signal is true;

begin
	
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
	
	
	Driver_p:
		process (global_reset, SYS_CLK) is
		begin
			if (global_reset = '1') then
				spi_north_rxvalid	<=	'0';
				spi_north_rxdata	<=	(others => '0');
				gp_driver_cntr		<=	(others => '0');
			elsif (rising_edge(SYS_CLK)) then
				if (gp_driver_cntr < x"FFFF") then
					gp_driver_cntr	<=	gp_driver_cntr + 1;
				end if;
				
				if (gp_driver_cntr < 10) then
					spi_north_rxvalid	<=	'0';
					spi_north_rxdata	<=	(others => '0');
				
				elsif (gp_driver_cntr = 10) then
					spi_north_rxvalid				<=	'1';
					spi_north_rxdata(15 downto 8)	<=	x"02";
					spi_north_rxdata(7 downto 0)	<=	x"10";

				elsif (gp_driver_cntr = 1) then
					spi_north_rxvalid				<=	'0';
					spi_north_rxdata(15 downto 8)	<=	x"02";
					spi_north_rxdata(7 downto 0)	<=	x"10";

				elsif (gp_driver_cntr > 11 and gp_driver_cntr < 263) then
					spi_north_rxvalid				<=	'0';
					spi_north_rxdata(15 downto 8)	<=	x"02";
					spi_north_rxdata(7 downto 0)	<=	x"10";

				elsif (gp_driver_cntr = 263) then
					spi_north_rxvalid				<=	'1';
					spi_north_rxdata(15 downto 8)	<=	x"02";
					spi_north_rxdata(7 downto 0)	<=	x"11";

				elsif (gp_driver_cntr = 264) then
					spi_north_rxvalid				<=	'0';
					spi_north_rxdata(15 downto 8)	<=	x"02";
					spi_north_rxdata(7 downto 0)	<=	x"11";
				end if;
			end if;
		end process;

	
	
	
	
	spi_opcode		<=	spi_north_rxdata(15 downto 8);
	spi_register	<=	spi_north_rxdata(7 downto 0);
	spi_data		<=	spi_north_rxdata(7 downto 0);

	process(SYS_CLK) is
	begin
		if (rising_edge(SYS_CLK)) then
			if (spi_north_rxvalid = '1') then
				if (spi_opcode = x"02") then
					regaddr	<=	spi_register;
				end if;
			end if;
		end if;
	end process;

	process(SYS_CLK) is
	begin
		if (rising_edge(SYS_CLK)) then
			if (spi_north_rxvalid = '1') then
				if (regaddr = x"10") then
					speed_reg	<=	spi_data;
				end if;

				if (regaddr = x"11") then
					sigpow_reg	<=	spi_data;
				end if;
			end if;
		end if;
	end process;
	

	process (SYS_CLK) is
	begin
		if (rising_edge(SYS_CLK)) then
			if (unsigned(sigpow_reg) < 20) then
				distance	<=	"000000";
			elsif (unsigned(sigpow_reg) >= 20 and unsigned(sigpow_reg) <= 35) then
				distance	<=	"000101";
			elsif (unsigned(sigpow_reg) >= 36 and unsigned(sigpow_reg) <= 40) then
				distance	<=	"010000";
			else
				distance	<=	"111111";
			end if;
		end if;
	end process;
	
	divider_inst: divider
	port map	(
					denom		=>	speed_reg,		--:	in	std_logic_vector(7 downto 0);
					numer		=>	distance,		--:	in	std_logic_vector(5 downto 0);
					quotient	=>	div_quotient,	--:	out	std_logic_vector(5 downto 0);
					remain		=>	div_remain		--:	out	std_logic_vector(7 downto 0);
				);
	
	
	process (SYS_CLK) is
	begin
		if (rising_edge(SYS_CLK)) then
			div_quotient_s	<=	div_quotient;
			div_remain_s	<=	div_remain;
		end if;
	end process;
	
	
	
	process(global_reset, SYS_CLK)
	begin
		if (global_reset = '1') then
			USER_LEDS	<=	(others => '0');
		elsif (rising_edge(SYS_CLK)) then
			USER_LEDS	<=	(others => '1');
		end if;
	end process;

end rtl;