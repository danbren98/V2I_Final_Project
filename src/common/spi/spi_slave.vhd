library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

library work;
	use work.global_package.all;

entity spi_slave is
	generic (
				data_width      :   positive     -- data length in bits
			);
	port    (
				user_clk        :   in  std_logic;                                  -- user clock. user interface is synced to it.
				user_rst        :   in  std_logic;                                  -- asynchronous active low reset
				
				user_valid_tx   :   in  std_logic;                                  -- data to trasmit is valid
				user_data_tx    :   in  std_logic_vector(data_width-1 downto 0);    -- data to transmit
				
				user_valid_rx   :   out std_logic;                                  -- data received is valid
				user_data_rx    :   out std_logic_vector(data_width-1 downto 0);    -- data received
				
				cpol            :   in  std_logic;                                  -- clock polarity mode
				cpha            :   in  std_logic;                                  -- clock phase mode
				busy            :   out std_logic;                                  -- slave busy signal     
				
				sclk            :   in  std_logic;                                  -- spi clk
				ss_n            :   in  std_logic;                                  -- slave select
				mosi            :   in  std_logic;                                  -- master out slave in
				miso            :   out std_logic                                   -- master in slave out
			);
end spi_slave;

architecture behavioural of spi_slave is
	constant dw_log2    :   positive    :=  ceil_log2(data_width);
	
	signal  bit_counter		:	unsigned(dw_log2-1 downto 0)                :=  (others => '0');
	signal  rxbuffer		:	std_logic_vector(data_width-1 downto 0)     :=  (others => '0');    --receiver buffer
	signal  load_txbuffer	:	std_logic;
	signal  txbuffer_s		:	std_logic_vector(data_width-1 downto 0)     :=  (others => '0');
	signal  txbuffer		:	std_logic_vector(data_width-1 downto 0)     :=  (others => '0');    --transmit buffer

	signal  ssn_synced		:	std_logic									:=  '1';
	signal  ssn_sync_sr		:	std_logic_vector(7 downto 0)				:=  (others => '1');
	signal  ssn_synced_s	:	std_logic                                   :=  '1';
	signal  ssn_synced_re	:	std_logic;
	signal  ssn_synced_fe	:	std_logic;

begin
	
	spi_rx_interface_p:
		process(ss_n, sclk)
		begin
			if (ss_n = '1') then
				bit_counter     <=  (others => '0');
			elsif (rising_edge(sclk)) then
				rxbuffer    <=  rxbuffer(rxbuffer'high-1 downto 0) & mosi;
				
				if (bit_counter = data_width-1) then
					bit_counter     <=  (others => '0');
				else
					bit_counter     <=  bit_counter + 1;
				end if;
			end if;
		end process;
	
	process (user_rst, user_clk) is
	begin
		if (user_rst = '1') then
			ssn_synced	<=	'1';
			ssn_sync_sr	<=	(others => '1');
		elsif (rising_edge(user_clk)) then
			ssn_sync_sr	<=	(ssn_sync_sr(ssn_sync_sr'high-1 downto 0) & ss_n);
			if (ssn_sync_sr = (ssn_sync_sr'range => '0')) then
				ssn_synced	<=	'0';
			elsif (ssn_sync_sr = (ssn_sync_sr'range => '1')) then
				ssn_synced	<=	'1';
			end if;
		end if;
	end process;

	ssn_synced_re   <=  '1' when ssn_synced_s = '0' and ssn_synced = '1' else '0';
	ssn_synced_fe   <=  '1' when ssn_synced_s = '1' and ssn_synced = '0' else '0';
	
	User_Output_p:
		process (user_rst, user_clk) is
		begin
			if (rising_edge(user_clk)) then
				ssn_synced_s    <=  ssn_synced;

				user_valid_rx   <=  ssn_synced_re;
				user_data_rx    <=  rxbuffer;
			end if;
			
			if (user_rst = '1') then
				user_valid_rx   <=  '0';
				ssn_synced_s    <=  '1';
			end if;
		end process;
	
	txbuffer_sync: entity work.bus_sync
		generic map (
						data_width	=>  data_width  --:	positive
					)
		port map    (
						clk_in      =>  user_clk,       --: in  std_logic;
						rst_in      =>  user_rst,       --: in  std_logic;
						valid_in    =>  user_valid_tx,  --: in  std_logic;
						data_in     =>  user_data_tx,   --: in  std_logic_vector(data_width-1 downto 0);
						busy        =>  open,           --: out std_logic;

						clk_out     =>  sclk,           --: in  std_logic;
						rst_out     =>  ss_n,           --: in  std_logic;
						valid_out   =>  load_txbuffer,  --: out std_logic;
						data_out    =>  txbuffer_s      --: out std_logic_vector(data_width-1 downto 0);
					);   
	
	spi_tx_interface_p:
		process(ss_n, sclk)
		begin
			if (ss_n = '1') then
				txbuffer    <=  (others => '0');
			elsif (falling_edge(sclk)) then
				if (load_txbuffer = '1') then
					txbuffer    <=  txbuffer_s;
				else
					txbuffer    <=  txbuffer(txbuffer'high-1 downto 0) & '0';
				end if;
			end if;
		end process;
	
	miso    <=  txbuffer(txbuffer'high);

end behavioural;
