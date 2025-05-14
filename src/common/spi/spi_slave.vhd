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
                user_rstn       :   in  std_logic;                                  -- asynchronous active low reset
                
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
    
    signal  bit_counter     :   unsigned(dw_log2-1 downto 0)                :=  (others => '0');
    signal  rxbuffer_valid  :   std_logic;
    signal  rxbuffer        :   std_logic_vector(data_width-1 downto 0)     :=  (others => '0');    --receiver buffer
    signal  load_txbuffer   :   std_logic;
    signal  txbuffer_s      :   std_logic_vector(data_width-1 downto 0)     :=  (others => '0');
    signal  txbuffer        :   std_logic_vector(data_width-1 downto 0)     :=  (others => '0');    --transmit buffer
begin

    spi_rx_interface_p:
        process(ss_n, sclk)
        begin
            if (falling_edge(sclk)) then
                rxbuffer    <=  rxbuffer(rxbuffer'high-1 downto 0) & mosi;

                if (bit_counter = data_width-1) then
                    bit_counter     <=  (others => '0');
                    rxbuffer_valid  <=  '1';
                else
                    bit_counter     <=  bit_counter + 1;
                    rxbuffer_valid  <=  '0';
                end if;
            end if;

            if (ss_n = '0') then
                bit_counter     <=  (others => '0');
                rxbuffer_valid  <=  '0';
            end if;
        end process;

    rxbuffer_sync: entity work.bus_sync
        generic map (
                        data_width	=>  data_width  --:	positive
                    )
        port map    (
                        clk_in      =>  sclk,           --: in  std_logic;
                        rst_in      =>  not ss_n,       --: in  std_logic;
                        valid_in    =>  rxbuffer_valid, --: in  std_logic;
                        data_in     =>  rxbuffer,       --: in  std_logic_vector(data_width-1 downto 0);
                        busy        =>  open,           --: out std_logic;

                        clk_out     =>  user_clk,       --: in  std_logic;
                        rst_out     =>  user_rstn,      --: in  std_logic;
                        valid_out   =>  user_valid_rx,  --: out std_logic;
                        data_out    =>  user_data_rx    --: out std_logic_vector(data_width-1 downto 0);
                    );
    
    txbuffer_sync: entity work.bus_sync
        generic map (
                        data_width	=>  data_width  --:	positive
                    )
        port map    (
                        clk_in      =>  user_clk,       --: in  std_logic;
                        rst_in      =>  user_rstn,      --: in  std_logic;
                        valid_in    =>  user_valid_tx,  --: in  std_logic;
                        data_in     =>  user_data_tx,   --: in  std_logic_vector(data_width-1 downto 0);
                        busy        =>  open,           --: out std_logic;

                        clk_out     =>  sclk,           --: in  std_logic;
                        rst_out     =>  not ss_n,       --: in  std_logic;
                        valid_out   =>  load_txbuffer,  --: out std_logic;
                        data_out    =>  txbuffer_s      --: out std_logic_vector(data_width-1 downto 0);
                    );   
    
    spi_tx_interface_p:
        process(ss_n, sclk)
        begin
            if (rising_edge(sclk)) then
                if (load_txbuffer = '1') then
                    txbuffer    <=  txbuffer_s;
                else
                    txbuffer    <=  txbuffer(txbuffer'high-1 downto 0) & '0';
                end if;
            end if;

            if (ss_n = '0') then
                txbuffer    <=  (others => '0');
            end if;
        end process;
    
    miso    <=  txbuffer(txbuffer'high);

end behavioural;
