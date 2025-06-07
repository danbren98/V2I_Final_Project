library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

entity main_controller is
	generic	(
				time_bw		:	positive
			);
	port	(
				app_clk						:	in	std_logic;
				app_rst						:	in	std_logic;

				valid_in					:	in	std_logic_vector(4-1 downto 0);
				time_in						:	in	std_logic_vector(4*time_bw-1 downto 0);
				
				traffic_light_out_red		:	out	std_logic_vector(4-1 downto 0);
				traffic_light_out_yellow	:	out	std_logic_vector(4-1 downto 0);
				traffic_light_out_green		:	out	std_logic_vector(4-1 downto 0)
			);
end entity main_controller;

architecture rtl of main_controller is

begin

end rtl;