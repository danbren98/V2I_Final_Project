library ieee;
    use ieee.std_logic_1164.all;

entity bus_sync is
    generic	(
                data_width	:	positive
            );
    port    (
                clk_in      :   in  std_logic;
                rst_in      :   in  std_logic;
                valid_in    :   in  std_logic;
                data_in     :   in  std_logic_vector(data_width-1 downto 0);
                busy        :   out std_logic;

                clk_out     :   in  std_logic;
                rst_out     :   in  std_logic;
                valid_out   :   out std_logic;
                data_out    :   out std_logic_vector(data_width-1 downto 0)
            );
end entity bus_sync;

architecture rtl of bus_sync is

    signal  valid   :   std_logic;

begin
    
    valid_sync: entity work.pulse_sync
        port map    (
                        clk_in      =>  clk_in,     --:   in  std_logic;
                        rst_in      =>  rst_in,     --:   in  std_logic;
                        pulse_in    =>  valid_in,   --:   in  std_logic;
                        busy        =>  busy,       --:   out std_logic;

                        clk_out     =>  clk_out,    --:   in  std_logic;
                        rst_out     =>  rst_out,    --:   in  std_logic;
                        pulse_out   =>  valid       --:   out std_logic;
                    );
    
    
    process(rst_out, clk_out)
    begin
        if (rising_edge(clk_out)) then
            valid_out   <=  valid;
            
            if (valid = '1') then
                data_out    <=  data_in;
            end if;

        end if;

        if (rst_out = '1') then
            valid_out   <=  '0';
        end if;
    end process;

end rtl;