library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;

library work;
	use work.global_package.all;

package communication_package is
	
	constant CAR_ID_ADDR	:	std_logic_vector(CAR_ID_BUS_WIDTH-1 downto 0)		:=	std_logic_vector(to_unsigned(2, CAR_ID_BUS_WIDTH));
	constant SPEED_ADDR		:	std_logic_vector(CAR_SPEED_BUS_WIDTH-1 downto 0)	:=	std_logic_vector(to_unsigned(3, CAR_SPEED_BUS_WIDTH));
	constant POWER_ADDR		:	std_logic_vector(RX_POWER_BUS_WIDTH-1 downto 0)		:=	std_logic_vector(to_unsigned(4, RX_POWER_BUS_WIDTH));

end communication_package;

package body communication_package is

end communication_package;