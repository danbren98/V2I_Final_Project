library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

entity main_controller is
	generic	(
				carid_bw	:	positive;
				time_bw		:	positive
			);
	port	(
				app_clk						:	in	std_logic;
				app_rst						:	in	std_logic;
				
				north_valid					:	in	std_logic;
				north_carid					:	in	std_logic_vector(carid_bw-1 downto 0);
				north_arrival_time			:	in	std_logic_vector(time_bw-1 downto 0);
				
				south_valid					:	in	std_logic;
				south_carid					:	in	std_logic_vector(carid_bw-1 downto 0);
				south_arrival_time			:	in	std_logic_vector(time_bw-1 downto 0);
				
				east_valid					:	in	std_logic;
				east_carid					:	in	std_logic_vector(carid_bw-1 downto 0);
				east_arrival_time			:	in	std_logic_vector(time_bw-1 downto 0);
				
				west_valid					:	in	std_logic;
				west_carid					:	in	std_logic_vector(carid_bw-1 downto 0);
				west_arrival_time			:	in	std_logic_vector(time_bw-1 downto 0);
				
				north_traffic_light			:	out	std_logic_vector(3-1 downto 0);
				south_traffic_light			:	out	std_logic_vector(3-1 downto 0);
				east_traffic_light			:	out	std_logic_vector(3-1 downto 0);
				west_traffic_light			:	out	std_logic_vector(3-1 downto 0)
			);
end entity main_controller;

architecture rtl of main_controller is

	constant	TRAFFIC_LIGHT_RED			:	std_logic_vector(3-1 downto 0)	:=	"100";	-- Red
	constant	TRAFFIC_LIGHT_YELLOW		:	std_logic_vector(3-1 downto 0)	:=	"010";	-- Yellow
	constant	TRAFFIC_LIGHT_PREP_GREEN	:	std_logic_vector(3-1 downto 0)	:=	"110";	-- Red + Yellow - prepare to green
	constant	TRAFFIC_LIGHT_GREEN			:	std_logic_vector(3-1 downto 0)	:=	"001";	-- Green

	constant	EMERGENCY_VALUE				:	natural							:=	60*2;	-- Emergency timer value

begin

	Traffic_Lights_Timer_p:
		process(app_rst, app_clk)
		begin
			if (app_rst = '1') then
				north_red_timer	<=	(others => '0');
				north_emergency	<=	'0';
			elsif (rising_edge(app_clk)) then
				
				if (north_traffic_light = TRAFFIC_LIGHT_RED) then
					if (north_cars_num /= 0) then
						if (one_sec_pulse = '1') then
							if (north_red_timer /= (north_red_timer'range => '1')) then
								north_red_timer	<=	north_red_timer + 1;
							end if;
							
							if (north_red_timer = EMERGENCY_VALUE) then
								north_emergency	<=	'1';
							end if;
						end if;
					else
						north_red_timer	<=	(others => '0');
						north_emergency	<=	'0';
					end if;
				else
					north_red_timer	<=	(others => '0');
					north_emergency	<=	'0';
				end if;
			end if;	
		end process;
	
	Information_Storage_p:
		process(app_rst, app_clk)
		begin
			if (app_rst = '1') then
				north_cars_num	<=	(others => '0');
				south_cars_num	<=	(others => '0');
				east_cars_num	<=	(others => '0');
				west_cars_num	<=	(others => '0');
			elsif (rising_edge(app_clk)) then
				if (north_valid = '1') then
					if (north_carid(north_carid'high) = '1') then
						north_cars_num	<=	north_cars_num + 1;
					else
						north_cars_num	<=	north_cars_num - 1;
					end if;
				end if;
				
				if (south_valid = '1') then
					if (south_carid(south_carid'high) = '1') then
						south_cars_num	<=	south_cars_num + 1;
					else
						south_cars_num	<=	south_cars_num - 1;
					end if;
				end if;
				
				if (east_valid = '1') then
					if (east_carid(east_carid'high) = '1') then
						east_cars_num	<=	east_cars_num + 1;
					else
						east_cars_num	<=	east_cars_num - 1;
					end if;
				end if;
				
				if (west_valid = '1') then
					if (west_carid(west_carid'high) = '1') then
						west_cars_num	<=	west_cars_num + 1;
					else
						west_cars_num	<=	west_cars_num - 1;
					end if;
				end if;
			end if;
		end process;
	
	
	Cars_Number_Based_Prioretizer_p:
		process(north_cars_num, south_cars_num, east_cars_num, west_cars_num) is
		begin
			if (north_cars_num >= south_cars_num and north_cars_num >= east_cars_num and north_cars_num >= west_cars_num) then
				north_priority		<= "1000";
				if (south_cars_num >= east_cars_num and south_cars_num >= west_cars_num) then
					south_priority	<= "0100";
					if (east_cars_num >= west_cars_num) then
						east_priority	<= "0010";
						west_priority	<= "0001";
					else
						east_priority	<= "0001";
						west_priority	<= "0010";
					end if;
				elsif (east_cars_num >= south_cars_num and east_cars_num >= west_cars_num) then
					east_priority	<= "0100";
					if (south_cars_num >= west_cars_num) then
						south_priority	<= "0010";
						west_priority	<= "0001";
					else
						south_priority	<= "0001";
						west_priority	<= "0010";
					end if;
				elsif (west_cars_num >= south_cars_num and west_cars_num >= east_cars_num) then
					west_priority	<= "0100";
					if (south_cars_num >= east_cars_num) then
						south_priority	<= "0010";
						east_priority	<= "0001";
					else
						south_priority	<= "0001";
						east_priority	<= "0010";
					end if;
				else
					south_priority	<= "0100";
					east_priority	<= "0010";
					west_priority	<= "0001";
				end if;
				
			elsif (south_cars_num >= north_cars_num and south_cars_num >= east_cars_num and south_cars_num >= west_cars_num) then
				north_traffic_light <= TRAFFIC_LIGHT_RED;
				south_traffic_light <= TRAFFIC_LIGHT_GREEN;
				east_traffic_light  <= TRAFFIC_LIGHT_RED;
				west_traffic_light  <= TRAFFIC_LIGHT_RED;
			elsif (east_cars_num >= north_cars_num and east_cars_num >= south_cars_num and east_cars_num >= west_cars_num) then
				north_traffic_light <= TRAFFIC_LIGHT_RED;
				south_traffic_light <= TRAFFIC_LIGHT_RED;
				east_traffic_light  <= TRAFFIC_LIGHT_GREEN;
				west_traffic_light  <= TRAFFIC_LIGHT_RED;
			else
				north_traffic_light <= TRAFFIC_LIGHT_RED;
				south_traffic_light <= TRAFFIC_LIGHT_RED;
				east_traffic_light  <= TRAFFIC_LIGHT_RED;
				west_traffic_light  <= TRAFFIC_LIGHT_GREEN;
			end if;
		end process;
	
	
	main_sm_p:
		process(app_rst, app_clk)
		begin
			if (rising_edge(app_clk)) then
				
			end if;
			if (app_rst = '1') then
				north_traffic_light	<=	TRAFFIC_LIGHT_RED;
				south_traffic_light	<=	TRAFFIC_LIGHT_RED;
				east_traffic_light	<=	TRAFFIC_LIGHT_RED;
				west_traffic_light	<=	TRAFFIC_LIGHT_RED;
			end if;
		end process;









	
	One_Second_Timer_p:
		process(app_rst, app_clk)
		begin
			if (app_rst = '1') then
				one_sec_cntr	<=	(others => '0');
				one_ms_cntr		<=	(others => '0');
				one_us_cntr		<=	(others => '0');
				one_sec_pulse	<=	'0';
				one_ms_pulse	<=	'0';
				one_us_pulse	<=	'0';
			elsif (rising_edge(app_clk)) then
				if (one_ms_pulse = '1') then
					if (one_sec_cntr = 1000) then
						one_sec_pulse	<=	'1';
						one_sec_cntr	<=	(others => '0');
					else
						one_sec_pulse	<=	'0';
						one_sec_cntr	<=	one_ms_cntr + 1;
					end if;
				end if;
				
				if (one_us_pulse = '1') then
					if (one_ms_cntr = 1000) then
						one_ms_pulse	<=	'1';
						one_ms_cntr		<=	(others => '0');
					else
						one_ms_pulse	<=	'0';
						one_ms_cntr		<=	one_ms_cntr + 1;
					end if;
				end if;
				
				if (one_us_cntr = ONE_USEC_VAL) then
					one_us_pulse	<=	'1';
					one_us_cntr		<=	(others => '0');
				else
					one_us_pulse	<=	'0';
					one_us_cntr		<=	one_us_cntr + 1;
				end if;
				
			end if;
		end process;


end rtl;