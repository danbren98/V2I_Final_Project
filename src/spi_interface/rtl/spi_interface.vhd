library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

entity spi_interface is
	generic	(
				carid_bw	:	positive;
				speed_bw	:	positive;
				power_bw	:	positive
			);
	port	(
				app_clk			:	in	std_logic;
				app_rst			:	in	std_logic;
				
				valid_out		:	out	std_logic;
				car_id_out		:	out	std_logic_vector(carid_bw-1 downto 0);
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
	
	signal	spi_opr			:	std_logic;
	signal	spi_register	:	std_logic_vector(6 downto 0);
	signal	spi_data		:	std_logic_vector(7 downto 0);
	
	signal	car_id_loaded	:	std_logic								:=	'0';
	signal	car_id_reg		:	std_logic_vector(carid_bw-1 downto 0)	:=	(others =>	'0');
	signal	speed_loaded	:	std_logic								:=	'0';
	signal	speed_reg		:	std_logic_vector(speed_bw-1 downto 0)	:=	(others =>	'0');
	signal	sigpow_loaded	:	std_logic								:=	'0';
	signal	sigpow_reg		:	std_logic_vector(power_bw-1 downto 0)	:=	(others =>	'0');
	signal	info_ready		:	std_logic;

begin

	spi_slave_inst: entity work.spi_slave
		generic map	(
						data_width	=>	16		--: integer;
					)
		port map	(
						user_clk		=>	app_clk,			--:	in	std_logic;
						user_rst		=>	app_rst,			--:	in	std_logic;
						
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
	
	
	spi_opr			<=	spi_rxdata(15);
	spi_register	<=	spi_rxdata(14 downto 8);
	spi_data		<=	spi_rxdata(7 downto 0);

	info_ready		<=	car_id_loaded and speed_loaded and sigpow_loaded;
	
	process(app_rst, app_clk) is
	begin
		if (rising_edge(app_clk)) then
			if (spi_rxvalid = '1' and spi_opr = '1') then
				if (unsigned(spi_register) = 2) then
					car_id_reg	<=	spi_data;
				end if;
				
				if (unsigned(spi_register) = 3) then
					speed_reg	<=	spi_data;
				end if;

				if (unsigned(spi_register) = 4) then
					sigpow_reg	<=	spi_data;
				end if;
			end if;

			if (spi_rxvalid = '1' and spi_opr = '1') then
				valid_out	<=	'0';
				
				if (unsigned(spi_register) = 2) then
					car_id_loaded	<=	'1';
				end if;
				
				if (unsigned(spi_register) = 3) then
					speed_loaded	<=	'1';
				end if;

				if (unsigned(spi_register) = 4) then
					sigpow_loaded	<=	'1';
				end if;
			else
				valid_out	<=	info_ready;

				if (info_ready = '1') then
					car_id_loaded	<=	'0';
					speed_loaded	<=	'0';
					sigpow_loaded	<=	'0';
				end if;
				
			end if;
		end if;

		if (app_rst = '1') then
			valid_out		<=	'0';
			car_id_loaded	<=	'0';
			speed_loaded	<=	'0';
			sigpow_loaded	<=	'0';
		end if;
	end process;
	
	car_id_out	<=	car_id_reg;
	speed_out	<=	speed_reg;
	power_out	<=	sigpow_reg;

end rtl;