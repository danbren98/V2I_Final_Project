library IEEE;
    use IEEE.std_logic_1164.all;

entity pulse_sync is
    port    (
                clk_in      :   in  std_logic;
                rst_in      :   in  std_logic;
                pulse_in    :   in  std_logic;
                busy        :   out std_logic;

                clk_out     :   in  std_logic;
                rst_out     :   in  std_logic;
                pulse_out   :   out std_logic
            );
end entity pulse_sync;

architecture rtl of pulse_sync is

    signal    src_pls2lvl       :   std_logic   :=  '0';
    signal    dst_pls2lvl       :   std_logic   :=  '0';
    signal    src_pls2lvl_back  :   std_logic   :=  '0';
    signal    dst_pls2lvl_s     :   std_logic   :=  '0';

begin
    
    input_interface_p:
        process (rst_in, clk_in) is
        begin
            if (rst_in = '1') then
                src_pls2lvl    <=  '0';
            elsif (rising_edge(clk_in)) then
                if (pulse_in = '1') then
                    src_pls2lvl    <=  '1';
                elsif (src_pls2lvl_back = '1') then
                    src_pls2lvl    <=  '0';
                end if;
                
                busy    <=  src_pls2lvl_back or src_pls2lvl;
            end if;
        end process;
    
    
    src2dst_sync: entity work.level_sync
        generic map (
                        stages  =>  2                   --:   positive
                    )
        port map    (
                        signal_in   =>  src_pls2lvl,    --:   in  std_logic;

                        clk_out     =>  clk_out,        --:   in  std_logic;
                        rst_out     =>  rst_out,        --:   in  std_logic;
                        signal_out  =>  dst_pls2lvl     --:   out std_logic
                    );
    
    dst2src_sync: entity work.level_sync
        generic map (
                        stages  =>  2                       --:   positive
                    )
        port map    (
                        signal_in   =>  dst_pls2lvl,        --:   in  std_logic;

                        clk_out     =>  clk_in,             --:   in  std_logic;
                        rst_out     =>  rst_in,             --:   in  std_logic;
                        signal_out  =>  src_pls2lvl_back    --:   out std_logic
                    );
    
    output_interface_p:
        process (rst_out, clk_out) is
        begin
            if (rst_out = '1') then
                pulse_out       <=  '0';
                dst_pls2lvl_s   <=  '0';
            elsif (rising_edge(clk_out)) then
                dst_pls2lvl_s   <=  dst_pls2lvl;
                
                if (dst_pls2lvl_s = '0' and dst_pls2lvl = '1') then
                    pulse_out    <=  '1';
                end if;
            end if;
        end process;

end rtl;