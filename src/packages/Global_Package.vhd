library IEEE;
	use IEEE.std_logic_1164.all;


package global_package is

	constant CAR_ID_BUS_WIDTH		:	natural	:=	8;
	constant CAR_SPEED_BUS_WIDTH	:	natural	:=	8;
	constant RX_POWER_BUS_WIDTH		:	natural	:=	8;
	constant ARRIVAL_TIME_WIDTH		:	natural	:=	16;

	type stdarray is array (natural range <>) of std_logic_vector;


	function	ceil_log2	(input	:	positive) return natural;
	
end global_package;

package body global_package is

	function ceil_log2 (input : positive) return natural is
		variable i : natural := 0;
	begin
		while (2**i) <= input loop
			i := i + 1;
		end loop;

		return i;

	end ceil_log2;

end global_package;