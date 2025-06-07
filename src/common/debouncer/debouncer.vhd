library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

entity debouncer is
	generic	(
				polarity	:	std_logic;
				time_out_w	:	positive;
				timeout		:	natural
			);
	port	(
				clk_in		:	in	std_logic;

				sig_in		:	in	std_logic;
				sig_out		:	out	std_logic
			);
end entity debouncer;

architecture rtl of debouncer is

	signal	sig_in_sync	:	std_logic_vector(1 downto 0)	:=	(others => polarity);
	signal	sig_in_s	:	std_logic						:=	polarity;
	signal	sig_in_stbl	:	std_logic;
	signal	timer		:	unsigned(time_out_w-1 downto 0)	:=	(others => '0');


begin

	sig_in_stbl	<=	sig_in_s xnor sig_in_sync(sig_in_sync'high);
	
	process(clk_in)
	begin
		if (rising_edge(clk_in)) then
			sig_in_sync	<=	sig_in_sync(0) & sig_in;
			sig_in_s	<=	sig_in_sync(sig_in_sync'high);

			if (sig_in_stbl = '1') then
				if (timer < timeout) then
					timer	<=	timer + 1;
				end if;
			else
				timer	<=	(others => '0');
			end if;
			
			if (sig_in_stbl = '1') then
				if (timer = timeout) then
					sig_out	<=	sig_in_sync(sig_in_sync'high);
				end if;
			end if;
		end if;
	end process;

end rtl;