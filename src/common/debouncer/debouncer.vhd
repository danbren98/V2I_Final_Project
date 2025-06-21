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

	type dbnc_states is (st_idle, st_press, st_release);

	signal	dbnc_sm		:	dbnc_states;
	
	signal	sig_in_sync	:	std_logic_vector(1 downto 0)	:=	(others => not polarity);
	signal	timer		:	unsigned(time_out_w-1 downto 0)	:=	(others => '0');
	signal	sig_out_int	:	std_logic						:=	not polarity;

begin

	Debounce_p:
		process(clk_in)
		begin
			if (rising_edge(clk_in)) then
				sig_in_sync	<=	sig_in_sync(sig_in_sync'high-1 downto 0) & sig_in;
				
				case dbnc_sm is
					when st_idle =>
						sig_out_int	<=	not polarity;

						if (sig_in_sync(sig_in_sync'high) = polarity) then
							if (timer < timeout) then
								timer	<=	timer + 1;
							else
								timer	<=	(others => '0');
							end if;
						else
							timer	<=	(others => '0');
						end if;

						if (timer = timeout) then
							dbnc_sm	<=	st_press;
						end if;

					when st_press =>
						sig_out_int	<= polarity;

						if (sig_in_sync(sig_in_sync'high) = not polarity) then
							if (timer < timeout) then
								timer	<=	timer + 1;
							else
								timer	<=	(others => '0');
							end if;
						else
							timer	<=	(others => '0');
						end if;

						if (timer = timeout) then
							dbnc_sm	<=	st_release;
						end if;

					when st_release =>
						sig_out_int	<=	not polarity;
						
						if (timer < timeout) then
							timer	<=	timer + 1;
						else
							timer	<=	(others => '0');
						end if;
						
						if (timer = timeout) then
							dbnc_sm	<=	st_idle;
						end if;

					when others =>
						sig_out_int	<=	not polarity;
						timer		<=	(others => '0');
						dbnc_sm		<=	st_idle;
				end case;
			end if;
		end process;

	sig_out	<=	sig_out_int;

end rtl;