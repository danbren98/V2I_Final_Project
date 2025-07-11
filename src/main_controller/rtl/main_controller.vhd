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

	constant	TRAFFIC_LIGHT_RED			:	std_logic_vector(3-1 downto 0)	:=	"001";	-- Red
	constant	TRAFFIC_LIGHT_YELLOW		:	std_logic_vector(3-1 downto 0)	:=	"010";	-- Yellow
	constant	TRAFFIC_LIGHT_PREP_GREEN	:	std_logic_vector(3-1 downto 0)	:=	"011";	-- Red + Yellow - prepare to green
	constant	TRAFFIC_LIGHT_GREEN			:	std_logic_vector(3-1 downto 0)	:=	"100";	-- Green

	constant	EMERGENCY_VALUE				:	natural							:=	60*2;	-- Emergency timer value
	constant	ONE_USEC_VAL				:	natural							:=	200;	-- 1 usec timer value

	signal	north_priority	:	std_logic_vector(4-1 downto 0)	:=	"0000";
	signal	south_priority	:	std_logic_vector(4-1 downto 0)	:=	"0000";
	signal	east_priority	:	std_logic_vector(4-1 downto 0)	:=	"0000";
	signal	west_priority	:	std_logic_vector(4-1 downto 0)	:=	"0000";

	signal	north_red_timer	:	unsigned(8-1 downto 0)			:=	(others => '0');
	signal	south_red_timer	:	unsigned(8-1 downto 0)			:=	(others => '0');
	signal	east_red_timer	:	unsigned(8-1 downto 0)			:=	(others => '0');
	signal	west_red_timer	:	unsigned(8-1 downto 0)			:=	(others => '0');

	signal	north_emergency	:	std_logic						:=	'0';
	signal	south_emergency	:	std_logic						:=	'0';
	signal	east_emergency	:	std_logic						:=	'0';
	signal	west_emergency	:	std_logic						:=	'0';

	signal	north_cars_num	:	unsigned(carid_bw-1 downto 0)	:=	(others => '0');
	signal	south_cars_num	:	unsigned(carid_bw-1 downto 0)	:=	(others => '0');
	signal	east_cars_num	:	unsigned(carid_bw-1 downto 0)	:=	(others => '0');
	signal	west_cars_num	:	unsigned(carid_bw-1 downto 0)	:=	(others => '0');

	signal	set_north_green	:	std_logic						:=	'0';
	signal	set_north_red	:	std_logic						:=	'1';
	signal	set_south_green	:	std_logic						:=	'0';
	signal	set_south_red	:	std_logic						:=	'1';
	signal	set_east_green	:	std_logic						:=	'0';
	signal	set_east_red	:	std_logic						:=	'1';
	signal	set_west_green	:	std_logic						:=	'0';
	signal	set_west_red	:	std_logic						:=	'1';

	signal	one_sec_cntr	:	unsigned(10 downto 0)			:=	(others => '0');
	signal	one_ms_cntr		:	unsigned(10 downto 0)			:=	(others => '0');
	signal	one_us_cntr		:	unsigned(10 downto 0)			:=	(others => '0');
	signal	one_sec_pulse	:	std_logic						:=	'0';
	signal	one_ms_pulse	:	std_logic						:=	'0';
	signal	one_us_pulse	:	std_logic						:=	'0';
	

begin

	-- Traffic_Lights_Timer_p:
	-- 	process(app_rst, app_clk)
	-- 	begin
	-- 		if (app_rst = '1') then
	-- 			north_red_timer	<=	(others => '0');
	-- 			north_emergency	<=	'0';
	-- 		elsif (rising_edge(app_clk)) then
				
	-- 			if (north_traffic_light = TRAFFIC_LIGHT_RED) then
	-- 				if (north_cars_num /= 0) then
	-- 					-- if (one_sec_pulse = '1') then
	-- 						if (north_red_timer /= (north_red_timer'range => '1')) then
	-- 							north_red_timer	<=	north_red_timer + 1;
	-- 						end if;
							
	-- 						if (north_red_timer = EMERGENCY_VALUE) then
	-- 							north_emergency	<=	'1';
	-- 						end if;
	-- 					end if;
	-- 				else
	-- 					north_red_timer	<=	(others => '0');
	-- 					north_emergency	<=	'0';
	-- 				end if;
	-- 			else
	-- 				north_red_timer	<=	(others => '0');
	-- 				north_emergency	<=	'0';
	-- 			end if;
				
	-- 			if (south_traffic_light = TRAFFIC_LIGHT_RED) then
	-- 				if (south_cars_num /= 0) then
	-- 					-- if (one_sec_pulse = '1') then
	-- 					if (one_ms_pulse = '1') then
	-- 						if (south_red_timer /= (south_red_timer'range => '1')) then
	-- 							south_red_timer	<=	south_red_timer + 1;
	-- 						end if;
							
	-- 						if (south_red_timer = EMERGENCY_VALUE) then
	-- 							south_emergency	<=	'1';
	-- 						end if;
	-- 					end if;
	-- 				else
	-- 					south_red_timer	<=	(others => '0');
	-- 					south_emergency	<=	'0';
	-- 				end if;
	-- 			else
	-- 				south_red_timer	<=	(others => '0');
	-- 				south_emergency	<=	'0';
	-- 			end if;
				
	-- 			if (east_traffic_light = TRAFFIC_LIGHT_RED) then
	-- 				if (east_cars_num /= 0) then
	-- 					-- if (one_sec_pulse = '1') then
	-- 					if (one_ms_pulse = '1') then
	-- 						if (east_red_timer /= (east_red_timer'range => '1')) then
	-- 							east_red_timer	<=	east_red_timer + 1;
	-- 						end if;
							
	-- 						if (east_red_timer = EMERGENCY_VALUE) then
	-- 							east_emergency	<=	'1';
	-- 						end if;
	-- 					end if;
	-- 				else
	-- 					east_red_timer	<=	(others => '0');
	-- 					east_emergency	<=	'0';
	-- 				end if;
	-- 			else
	-- 				east_red_timer	<=	(others => '0');
	-- 				east_emergency	<=	'0';
	-- 			end if;
				
	-- 			if (west_traffic_light = TRAFFIC_LIGHT_RED) then
	-- 				if (west_cars_num /= 0) then
	-- 					-- if (one_sec_pulse = '1') then
	-- 					if (one_ms_pulse = '1') then
	-- 						if (west_red_timer /= (west_red_timer'range => '1')) then
	-- 							west_red_timer	<=	west_red_timer + 1;
	-- 						end if;
							
	-- 						if (west_red_timer = EMERGENCY_VALUE) then
	-- 							west_emergency	<=	'1';
	-- 						end if;
	-- 					end if;
	-- 				else
	-- 					west_red_timer	<=	(others => '0');
	-- 					west_emergency	<=	'0';
	-- 				end if;
	-- 			else
	-- 				west_red_timer	<=	(others => '0');
	-- 				west_emergency	<=	'0';
	-- 			end if;

	-- 		end if;	
	-- 	end process;
	
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
				if (north_cars_num = 0) then
					north_priority	<=	"0000";
				else
					north_priority	<= "1000";
				end if;
				if (south_cars_num >= east_cars_num and south_cars_num >= west_cars_num) then
					if (south_cars_num = 0) then
						south_priority	<=	"0000";
					else
						south_priority	<= "0100";
					end if;
					if (east_cars_num >= west_cars_num) then
						if (east_cars_num = 0) then
							east_priority	<= "0000";
							west_priority	<= "0000";
						else
							east_priority	<= "0010";
							west_priority	<= "0001";
						end if;
					else
						east_priority	<= "0001";
						west_priority	<= "0010";
					end if;
				elsif (east_cars_num >= south_cars_num and east_cars_num >= west_cars_num) then
					if (east_cars_num = 0) then
						east_priority	<=	"0000";
					else
						east_priority	<= "0100";
					end if;
					if (south_cars_num >= west_cars_num) then
						if (south_cars_num = 0) then
							south_priority	<= "0000";
							west_priority	<= "0000";
						else
							south_priority	<= "0010";
							west_priority	<= "0001";
						end if;
					else
						south_priority	<= "0001";
						west_priority	<= "0010";
					end if;
				elsif (west_cars_num >= south_cars_num and west_cars_num >= east_cars_num) then
					if (west_cars_num = 0) then
						west_priority	<=	"0000";
					else
						west_priority	<= "0100";
					end if;
					if (south_cars_num >= east_cars_num) then
						if (south_cars_num = 0) then
							south_priority	<= "0000";
							east_priority	<= "0000";
						else
							south_priority	<= "0010";
							east_priority	<= "0001";
						end if;
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
				if (south_cars_num = 0) then
					south_priority		<= "0000";
				else	
					south_priority		<= "1000";
				end if;
				if (north_cars_num >= east_cars_num and north_cars_num >= west_cars_num) then
					if (north_cars_num = 0) then
						north_priority	<= "0000";
					else
						north_priority	<= "0100";
					end if;
					if (east_cars_num >= west_cars_num) then
						if (east_cars_num = 0) then
							east_priority	<= "0000";
							west_priority	<= "0000";
						else
							east_priority	<= "0010";
							west_priority	<= "0001";
						end if;
					else
						east_priority	<= "0001";
						west_priority	<= "0010";
					end if;
				elsif (east_cars_num >= north_cars_num and east_cars_num >= west_cars_num) then
					if (east_cars_num = 0) then
						east_priority	<= "0000";
					else
						east_priority	<= "0100";
					end if;
					if (north_cars_num >= west_cars_num) then
						if (north_cars_num = 0) then
							north_priority	<= "0000";
							west_priority	<= "0000";
						else
							north_priority	<= "0010";
							west_priority	<= "0001";
						end if;
					else
						north_priority	<= "0001";
						west_priority	<= "0010";
					end if;
				elsif (west_cars_num >= north_cars_num and west_cars_num >= east_cars_num) then
					if (west_cars_num = 0) then
						west_priority	<=	"0000";
					else
						west_priority	<= "0100";
					end if;
					if (north_cars_num >= east_cars_num) then
						if (north_cars_num = 0) then
							north_priority	<= "0000";
							east_priority	<= "0000";
						else
							north_priority	<= "0010";
							east_priority	<= "0001";
						end if;
					else
						north_priority	<= "0001";
						east_priority	<= "0010";
					end if;
				else
					north_priority	<= "0100";
					east_priority	<= "0010";
					west_priority	<= "0001";
				end if;
			
			elsif (east_cars_num >= north_cars_num and east_cars_num >= south_cars_num and east_cars_num >= west_cars_num) then
				east_priority		<= "1000";
				if (north_cars_num >= south_cars_num and north_cars_num >= west_cars_num) then
					north_priority	<= "0100";
					if (south_cars_num >= west_cars_num) then
						south_priority	<= "0010";
						west_priority	<= "0001";
					else
						south_priority	<= "0001";
						west_priority	<= "0010";
					end if;
				elsif (south_cars_num >= north_cars_num and south_cars_num >= west_cars_num) then
					south_priority	<= "0100";
					if (north_cars_num >= west_cars_num) then
						north_priority	<= "0010";
						west_priority	<= "0001";
					else
						north_priority	<= "0001";
						west_priority	<= "0010";
					end if;
				elsif (west_cars_num >= north_cars_num and west_cars_num >= south_cars_num) then
					west_priority	<= "0100";
					if (north_cars_num >= south_cars_num) then
						north_priority	<= "0010";
						south_priority	<= "0001";
					else
						north_priority	<= "0001";
						south_priority	<= "0010";
					end if;
				else
					north_priority	<= "0100";
					south_priority	<= "0010";
					west_priority	<= "0001";
				end if;
			
			else
				west_priority		<= "1000";
				if (north_cars_num >= south_cars_num and north_cars_num >= east_cars_num) then
					north_priority	<= "0100";
					if (south_cars_num >= east_cars_num) then
						south_priority	<= "0010";
						east_priority	<= "0001";
					else
						south_priority	<= "0001";
						east_priority	<= "0010";
					end if;
				elsif (south_cars_num >= north_cars_num and south_cars_num >= east_cars_num) then
					south_priority	<= "0100";
					if (north_cars_num >= east_cars_num) then
						north_priority	<= "0010";
						east_priority	<= "0001";
					else
						north_priority	<= "0001";
						east_priority	<= "0010";
					end if;
				elsif (east_cars_num >= north_cars_num and east_cars_num >= south_cars_num) then
					east_priority	<= "0100";
					if (north_cars_num >= south_cars_num) then
						north_priority	<= "0010";
						south_priority	<= "0001";
					else
						north_priority	<= "0001";
						south_priority	<= "0010";
					end if;
				else
					north_priority	<= "0100";
					south_priority	<= "0010";
					east_priority	<= "0001";
				end if;
			end if;
		end process;
	
	main_sm_p:
		process(app_rst, app_clk)
		begin
			if (rising_edge(app_clk)) then
				if (north_priority = "1000") then
					if (north_cars_num > 0) then
						set_north_green	<=	'1';
						set_north_red	<=	'0';
						set_south_green	<=	'0';
						set_south_red	<=	'1';
					else
						set_north_green	<=	'0';
						set_north_red	<=	'1';
						
						if (north_traffic_light = TRAFFIC_LIGHT_RED) then
							if (south_priority = "0100") then
								if (south_cars_num > 0) then
									set_south_green	<=	'1';
									set_south_red	<=	'0';
								else
									set_south_green	<=	'0';
									set_south_red	<=	'1';
								end if;
							else
								set_south_green	<=	'0';
								set_south_red	<=	'1';
							end if;
						else
							set_south_green	<=	'0';
							set_south_red	<=	'1';
						end if;
					end if;
					
					set_east_green	<=	'0';
					set_east_red	<=	'1';
					set_west_green	<=	'0';
					set_west_red	<=	'1';

				elsif (south_priority = "1000") then
					if (south_cars_num > 0) then
						set_north_green	<=	'0';
						set_north_red	<=	'1';
						set_south_green	<=	'1';
						set_south_red	<=	'0';
					else
						set_south_green	<=	'0';
						set_south_red	<=	'1';
					
						if (south_traffic_light = TRAFFIC_LIGHT_RED) then	
							if (north_priority = "0100") then
								if (north_cars_num > 0) then
									set_north_green	<=	'1';
									set_north_red	<=	'0';
								else
									set_north_green	<=	'0';
									set_north_red	<=	'1';
								end if;
							else
								set_north_green	<=	'0';
								set_north_red	<=	'1';
							end if;
						else
							set_north_green	<=	'0';
							set_north_red	<=	'1';
						end if;
					end if;
					
					set_east_green	<=	'0';
					set_east_red	<=	'1';
					set_west_green	<=	'0';
					set_west_red	<=	'1';
					
				elsif (east_priority = "1000") then
					if (east_cars_num > 0) then
						set_east_green	<=	'1';
						set_east_red	<=	'0';
						set_west_green	<=	'0';
						set_west_red	<=	'1';
					else
						set_east_green	<=	'0';
						set_east_red	<=	'1';
					
						if (east_traffic_light = TRAFFIC_LIGHT_RED) then	
							if (west_priority = "0100") then
								if (west_cars_num > 0) then
									set_west_green	<=	'1';
									set_west_red	<=	'0';
								else
									set_west_green	<=	'0';
									set_west_red	<=	'1';
								end if;
							else
								set_west_green	<=	'0';
								set_west_red	<=	'1';
							end if;
						else
							set_west_green	<=	'0';
							set_west_red	<=	'1';
						end if;
					end if;
					
					set_north_green	<=	'0';
					set_north_red	<=	'1';
					set_south_green	<=	'0';
					set_south_red	<=	'1';

				elsif (west_priority = "1000") then
					if (west_cars_num > 0) then
						set_east_green	<=	'0';
						set_east_red	<=	'1';
						set_west_green	<=	'1';
						set_west_red	<=	'0';
					else
						set_west_green	<=	'0';
						set_west_red	<=	'1';
					
						if (west_traffic_light = TRAFFIC_LIGHT_RED) then	
							if (east_priority = "0100") then
								if (east_cars_num > 0) then
									set_east_green	<=	'1';
									set_east_red	<=	'0';
								else
									set_east_green	<=	'0';
									set_east_red	<=	'1';
								end if;
							else
								set_east_green	<=	'0';
								set_east_red	<=	'1';
							end if;
						else
							set_east_green	<=	'0';
							set_east_red	<=	'1';
						end if;
					end if;
					
					set_north_green	<=	'0';
					set_north_red	<=	'1';
					set_south_green	<=	'0';
					set_south_red	<=	'1';

				else
					set_north_green	<=	'0';
					set_north_red	<=	'1';
					set_south_green	<=	'0';
					set_south_red	<=	'1';
					set_east_green	<=	'0';
					set_east_red	<=	'1';
					set_west_green	<=	'0';
					set_west_red	<=	'1';
				end if;
			end if;
			
			if (app_rst = '1') then
				set_north_green	<=	'0';
				set_north_red	<=	'1';
				set_south_green	<=	'0';
				set_south_red	<=	'1';
				set_east_green	<=	'0';
				set_east_red	<=	'1';
				set_west_green	<=	'0';
				set_west_red	<=	'1';
			end if;
		end process;
	
	north_traffic_light_ctrl: entity work.traffic_light_ctrl
		port map	(
						clk			=>	app_clk,				--:	in	std_logic;
						rst			=>	app_rst,				--:	in	std_logic;
						
						set_green	=>	set_north_green,		--:	in	std_logic;
						set_red		=>	set_north_red,			--:	in	std_logic;
						
						red			=>	north_traffic_light(0),	--:	out	std_logic;
						yellow		=>	north_traffic_light(1),	--:	out	std_logic;
						green		=>	north_traffic_light(2)	--:	out	std_logic
					);
	
	south_traffic_light_ctrl: entity work.traffic_light_ctrl
		port map	(
						clk			=>	app_clk,				--:	in	std_logic;
						rst			=>	app_rst,				--:	in	std_logic;
						
						set_green	=>	set_south_green,		--:	in	std_logic;
						set_red		=>	set_south_red,			--:	in	std_logic;
						
						red			=>	south_traffic_light(0),	--:	out	std_logic;
						yellow		=>	south_traffic_light(1),	--:	out	std_logic;
						green		=>	south_traffic_light(2)	--:	out	std_logic
					);
	
	east_traffic_light_ctrl: entity work.traffic_light_ctrl
		port map	(
						clk			=>	app_clk,				--:	in	std_logic;
						rst			=>	app_rst,				--:	in	std_logic;
						
						set_green	=>	set_east_green,			--:	in	std_logic;
						set_red		=>	set_east_red,			--:	in	std_logic;
						
						red			=>	east_traffic_light(0),	--:	out	std_logic;
						yellow		=>	east_traffic_light(1),	--:	out	std_logic;
						green		=>	east_traffic_light(2)	--:	out	std_logic
					);
	
	west_traffic_light_ctrl: entity work.traffic_light_ctrl
		port map	(
						clk			=>	app_clk,				--:	in	std_logic;
						rst			=>	app_rst,				--:	in	std_logic;
						
						set_green	=>	set_west_green,			--:	in	std_logic;
						set_red		=>	set_west_red,			--:	in	std_logic;
						
						red			=>	west_traffic_light(0),	--:	out	std_logic;
						yellow		=>	west_traffic_light(1),	--:	out	std_logic;
						green		=>	west_traffic_light(2)	--:	out	std_logic
					);
	
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