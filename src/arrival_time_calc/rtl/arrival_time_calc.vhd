library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

library work;
	use work.global_package.all;

entity arrival_time_calc is
	generic	(
				carid_bw	:	positive;
				speed_bw	:	positive;
				power_bw	:	positive;
				time_bw		:	positive
			);
	port	(
				app_clk			:	in	std_logic;
				app_rst			:	in	std_logic;

				valid_in		:	in	std_logic;
				carid_in		:	in	std_logic_vector(carid_bw-1 downto 0);
				speed_in		:	in	std_logic_vector(speed_bw-1 downto 0);
				power_in		:	in	std_logic_vector(power_bw-1 downto 0);
				
				valid_out		:	out	std_logic;
				carid_out		:	out	std_logic_vector(carid_bw-1 downto 0);
				arrival_time	:	out	std_logic_vector(time_bw-1 downto 0)
			);
end entity arrival_time_calc;

architecture rtl of arrival_time_calc is

	component divider
		port (
				clock		:	in	std_logic;
				denom		:	in	std_logic_vector(7 downto 0);
				numer		:	in	std_logic_vector(7 downto 0);
				quotient	:	out	std_logic_vector(7 downto 0);
				remain		:	out	std_logic_vector(7 downto 0)
				);
				end component;
				
	signal	valid_delay	:	std_logic_vector(1 downto 0)		:=	(others => '0');
	signal	carid_delay	:	stdarray(1 downto 0)(carid_in'range):=	(others => (others => '0'));
	signal	speed		:	std_logic_vector(speed_in'range)	:=	(others => '0');
	signal	power		:	unsigned(power_in'range)			:=	(others => '0');
	signal	distance	:	std_logic_vector(7 downto 0)		:=	(others => '0');
	signal	time_int	:	std_logic_vector(7 downto 0);
	signal	time_frac	:	std_logic_vector(7 downto 0);
	
begin


	Delay_p:
	--	Valids delay are synchronozized to:
	--	valid(0) - input valid to divider (speed and distance signals are synched to it);
	--	valid(1) - divider piplined valid. output valid of divider.
		process (app_rst, app_clk) is
		begin
			if (rising_edge(app_clk)) then
				valid_delay	<=	valid_delay(valid_delay'high-1 downto 0) & valid_in;
				carid_delay	<=	carid_delay(carid_delay'high-1 downto 0) & carid_in;
				speed		<=	speed_in;

			end if;

			if (app_rst = '1') then
				valid_delay	<=	(others => '0');
			end if;
		end process;
	
	
	power	<=	unsigned(power_in);

	Power2Distance_p:
		process (app_clk) is
		begin
			if (rising_edge(app_clk)) then
				
				if (power <= 20) then
					distance	<=	std_logic_vector(to_unsigned(0, distance'length));
				elsif (power > 20 and power <= 30) then
					distance	<=	std_logic_vector(to_unsigned(10, distance'length));
				elsif (power > 30 and power <= 40) then
					distance	<=	std_logic_vector(to_unsigned(20, distance'length));
				elsif (power > 40 and power <= 45) then
					distance	<=	std_logic_vector(to_unsigned(30, distance'length));
				else
					distance	<=	std_logic_vector(to_unsigned(40, distance'length));
				end if;
			end if;
		end process;


	divider_inst : divider
	port map	(
					clock		=>	app_clk,
					denom		=>	speed,
					numer		=>	distance,
					quotient	=>	time_int,
					remain		=>	time_frac
				);

	valid_out		<=	valid_delay(valid_delay'high);
	carid_out		<=	carid_delay(carid_delay'high);
	arrival_time	<=	time_int & time_frac;

end rtl;