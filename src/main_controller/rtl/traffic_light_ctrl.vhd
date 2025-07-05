library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

entity traffic_light_ctrl is
	port	(
				clk				:	in	std_logic;
				rst				:	in	std_logic;
				
				set_green		:	in	std_logic;
				set_red			:	in	std_logic;
				
				red				:	out	std_logic;
				yellow			:	out	std_logic;
				green			:	out	std_logic
			);
end entity traffic_light_ctrl;

architecture rtl of traffic_light_ctrl is

	constant	TRAFFIC_LIGHT_RED			:	std_logic_vector(3-1 downto 0)	:=	"001";	-- Red
	constant	TRAFFIC_LIGHT_YELLOW		:	std_logic_vector(3-1 downto 0)	:=	"010";	-- Yellow
	constant	TRAFFIC_LIGHT_PREP_GREEN	:	std_logic_vector(3-1 downto 0)	:=	"011";	-- Red + Yellow - prepare to green
	constant	TRAFFIC_LIGHT_GREEN			:	std_logic_vector(3-1 downto 0)	:=	"100";	-- Green

	constant	ONE_USEC_VAL				:	natural							:=	200;	-- 1 usec timer value

	type traffic_light_state is (st_red_light, st_prep_green_light, st_green_light, st_yellow_light);

	signal	traffic_light				:	std_logic_vector(3-1 downto 0)	:=	TRAFFIC_LIGHT_RED;
	signal	traffic_light_sm			:	traffic_light_state				:=	st_red_light;
	signal	light_cntr					:	unsigned(2 downto 0)			:=	(others => '0');

	signal	one_sec_cntr				:	unsigned(10 downto 0)			:=	(others => '0');
	signal	one_ms_cntr					:	unsigned(10 downto 0)			:=	(others => '0');
	signal	one_us_cntr					:	unsigned(10 downto 0)			:=	(others => '0');
	signal	one_sec_pulse				:	std_logic						:=	'0';
	signal	one_ms_pulse				:	std_logic						:=	'0';
	signal	one_us_pulse				:	std_logic						:=	'0';
	

begin

	red		<=	traffic_light(0);
	yellow	<=	traffic_light(1);
	green	<=	traffic_light(2);


	main_sm_p:
		process(rst, clk)
		begin
			if (rst = '1') then
				traffic_light		<=	TRAFFIC_LIGHT_RED;
				traffic_light_sm	<=	st_red_light;
			elsif (rising_edge(clk)) then
				case traffic_light_sm is
					when st_red_light =>
						traffic_light	<=	TRAFFIC_LIGHT_RED;
						
						if (set_green = '1') then
							if (one_sec_pulse = '1') then
								traffic_light_sm	<=	st_prep_green_light;
							end if;
						end if;
						
					when st_prep_green_light =>
						traffic_light	<=	TRAFFIC_LIGHT_PREP_GREEN;
						if (one_sec_pulse = '1') then
							if (light_cntr = 1) then
								light_cntr	<= (others => '0');
							else
								light_cntr	<=	light_cntr + 1;
							end if;
							
							if (light_cntr = 1) then
								traffic_light_sm	<=	st_green_light;
							end if;
						end if;
						
					when st_green_light =>
						traffic_light	<=	TRAFFIC_LIGHT_GREEN;
						if (set_red = '1') then
							if (one_sec_pulse = '1') then
								traffic_light_sm	<=	st_yellow_light;
							end if;
						end if;
						
					when st_yellow_light =>
						traffic_light	<=	TRAFFIC_LIGHT_YELLOW;
						if (one_sec_pulse = '1') then
							if (light_cntr = 1) then
								light_cntr	<= (others => '0');
							else
								light_cntr	<=	light_cntr + 1;
							end if;
							
							if (light_cntr = 1) then
								traffic_light_sm	<=	st_red_light;
							end if;
						end if;
						
					when others =>
						traffic_light		<=	TRAFFIC_LIGHT_RED;
						traffic_light_sm	<=	st_red_light;
				end case;
				
			end if;
		end process;
	
	
	One_Second_Timer_p:
		process(rst, clk)
		begin
			if (rst = '1') then
				one_sec_cntr	<=	(others => '0');
				one_ms_cntr		<=	(others => '0');
				one_us_cntr		<=	(others => '0');
				one_sec_pulse	<=	'0';
				one_ms_pulse	<=	'0';
				one_us_pulse	<=	'0';
			elsif (rising_edge(clk)) then
				if (one_ms_pulse = '1') then
					if (one_sec_cntr = 1000-1) then
						one_sec_pulse	<=	'1';
						one_sec_cntr	<=	(others => '0');
					else
						one_sec_pulse	<=	'0';
						one_sec_cntr	<=	one_sec_cntr + 1;
					end if;
				else
					one_sec_pulse	<=	'0';
				end if;
				
				if (one_us_pulse = '1') then
					if (one_ms_cntr = 1000-1) then
						one_ms_pulse	<=	'1';
						one_ms_cntr		<=	(others => '0');
					else
						one_ms_pulse	<=	'0';
						one_ms_cntr		<=	one_ms_cntr + 1;
					end if;
				else
					one_ms_pulse	<=	'0';
				end if;
				
				if (one_us_cntr = ONE_USEC_VAL-1) then
					one_us_pulse	<=	'1';
					one_us_cntr		<=	(others => '0');
				else
					one_us_pulse	<=	'0';
					one_us_cntr		<=	one_us_cntr + 1;
				end if;
				
			end if;
		end process;


end rtl;