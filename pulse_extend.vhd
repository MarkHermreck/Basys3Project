-- Module is not robust. 
-- Use case will only be to extend brief period of signal high with long periods of downtime between.
-- Other use cases will not work with this module correctly.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pulse_extend is
  generic(
    extend_count        : integer := 25000000 --100 MHZ clock, 25M counts, .25s extension
  );
  port ( 
    clk_i               : in STD_LOGIC;
    sig_i               : in STD_LOGIC;
    sig_o               : out STD_LOGIC
  );
end pulse_extend;

architecture rtl of pulse_extend is

signal previous         : std_logic;
signal edge             : std_logic;
signal extending        : boolean;

signal counter          : integer := 0;

begin

--signal_extend : process(clk_i) is begin
--    if rising_edge(clk_i) then
--        if sig_i = '1' then
--            extending <= true;
--            counter <= extend_count;
--        end if;
--    end if;
--end process signal_extend;

extend : process(clk_i) is begin
    if rising_edge(clk_i) then
        if sig_i = '1' and not extending then
            extending <= true;
            counter <= extend_count;
        elsif counter = 0 then
            extending <= false;
            sig_o <= '0';
        elsif extending then
            counter <= counter - 1;
            sig_o <= '1';
        end if;
    end if;
end process extend;


--edge_detect : process(clk_i) is begin
--    if rising_edge(clk_i) then
--        previous <= sig_i;
--        edge <= sig_i and not previous;
--    end if;
--end process edge_detect;

end rtl;
