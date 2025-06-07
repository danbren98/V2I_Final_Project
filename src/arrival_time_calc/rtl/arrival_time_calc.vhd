library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

entity arrival_time_calc is
	generic	(
				speed_bw	:	positive;
				power_bw	:	positive;
				time_bw		:	positive
			);
	port	(
				app_clk			:	in	std_logic;
				app_rst			:	in	std_logic;

				valid_in		:	in	std_logic;
				speed_in		:	in	std_logic_vector(speed_bw-1 downto 0);
				power_in		:	in	std_logic_vector(power_bw-1 downto 0);
				
				valid_out		:	out	std_logic;
				arrival_time	:	out	std_logic_vector(time_bw-1 downto 0)
			);
end entity arrival_time_calc;

architecture rtl of arrival_time_calc is

begin

end rtl;