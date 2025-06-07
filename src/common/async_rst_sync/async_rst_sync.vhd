library ieee;
	use ieee.std_logic_1164.all;

entity async_rst_sync is
	generic	(
				polin		:	std_logic;	--	Polarity of input reset
				polout		:	std_logic;	--	Polarity of output reset
				stages		:	positive	--	Number of reset stage
			);
	port	(
				arst_in		:	in	std_logic;
				clk_in		:	in	std_logic;

				arst_out	:	out	std_logic
			);
end entity async_rst_sync;

architecture rtl of async_rst_sync is

	signal	arst_out_reg	:	std_logic_vector(stages-1 downto 0)	:=	(others => polout);

begin

	process(arst_in, clk_in)
	begin
		if (arst_in = polin) then
			arst_out_reg	<=	(others => polout);
		elsif (rising_edge(clk_in)) then
			arst_out_reg	<=	arst_out_reg(arst_out_reg'high-1 downto 0) & (not polout);
		end if;
	end process;

	arst_out	<=	arst_out_reg(arst_out_reg'high);

end rtl;