library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

entity spi_interface is
	generic	(
				speed_bw	:	positive;
				power_bw	:	positive
			);
	port	(
				app_clk			:	in	std_logic;
				app_rst			:	in	std_logic;
				
				valid_out		:	out	std_logic;
				speed_out		:	out	std_logic_vector(speed_bw-1 downto 0);
				power_out		:	out	std_logic_vector(power_bw-1 downto 0);
				
				sclk			:	in	std_logic;
				ss_n			:	in	std_logic;
				mosi			:	in	std_logic;
				miso			:	out	std_logic
			);
end entity spi_interface;

architecture rtl of spi_interface is

	signal	spi_rxvalid		:	std_logic;
	signal	spi_rxdata		:	std_logic_vector(15 downto 0);
	
	signal	spi_opcode		:	std_logic_vector(7 downto 0);
	signal	spi_register	:	std_logic_vector(7 downto 0);
	signal	spi_data		:	std_logic_vector(7 downto 0);
	
	signal	regaddr			:	std_logic_vector(7 downto 0);
	signal	speed_reg		:	std_logic_vector(speed_bw-1 downto 0);
	signal	sigpow_reg		:	std_logic_vector(power_bw-1 downto 0);

begin

	spi_slave_inst: entity work.spi_slave
		generic map	(
						data_width	=>	16		--: integer;
					)
		port map	(
						user_clk		=>	app_clk,			--:	in	std_logic;
						user_rstn		=>	app_rst,			--:	in	std_logic;
						
						user_valid_tx	=>	'0',				--:	in	std_logic;
						user_data_tx	=>	(others => '0'),	--:	in	std_logic_vector(data_width-1 downto 0);

						user_valid_rx	=>	spi_rxvalid,		--:	in	std_logic;
						user_data_rx	=>	spi_rxdata,			--:	out	std_logic_vector(data_width-1 downto 0);
							
						cpol			=>	'0',				--:	in	std_logic;
						cpha			=>	'0',				--:	in	std_logic;
						busy			=>	open,				--:	out	std_logic;

						sclk			=>	sclk,				--:	in	std_logic;
						ss_n			=>	ss_n,				--:	in	std_logic;
						mosi			=>	mosi,				--:	in	std_logic;
						miso			=>	miso				--:	out	std_logic;
					);
	
	
	spi_opcode		<=	spi_rxdata(15 downto 8);
	spi_register	<=	spi_rxdata(7 downto 0);
	spi_data		<=	spi_rxdata(7 downto 0);

	process(app_rst, app_clk) is
	begin
		if (rising_edge(app_clk)) then
			if (spi_rxvalid = '1') then
				if (spi_opcode = x"02") then
					regaddr	<=	spi_register;
				end if;
				
				if (regaddr = x"10") then
					speed_reg	<=	spi_data;
				end if;

				if (regaddr = x"11") then
					sigpow_reg	<=	spi_data;
				end if;
			end if;

			if (spi_rxvalid = '1') then
				if (regaddr = x"11") then
					valid_out	<=	'1';
				else
					valid_out	<=	'0';
				end if;
			else
				valid_out	<=	'0';
			end if;
		end if;

		if (app_rst = '1') then
			valid_out	<=	'0';
		end if;
	end process;

	speed_out	<=	speed_reg;
	power_out	<=	sigpow_reg;

end rtl;