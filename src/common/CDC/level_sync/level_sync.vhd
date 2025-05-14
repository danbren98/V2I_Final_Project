library IEEE;
    use IEEE.std_logic_1164.all;

entity level_sync is
    generic (
                stages  :   positive    -- Number of synchronization stages.
            );
    port    (
                signal_in   :   in  std_logic;

                clk_out     :   in  std_logic;
                rst_out     :   in  std_logic;
                signal_out  :   out std_logic
            );
end entity level_sync;

architecture rtl of level_sync is

    signal    buffer_int    :   std_logic_vector(stages-1 downto 0) :=  (others => '0');

begin
    
	process (rst_out, clk_out) is
	begin
        if (rst_out = '1') then
            buffer_int  <=  (others => '0');
        elsif (rising_edge(clk_out)) then
            buffer_int  <=  buffer_int(buffer_int'high-1 downto 0) & signal_in;
        end if;
	end process;
    
    signal_out  <=  buffer_int(buffer_int'high);

end rtl;