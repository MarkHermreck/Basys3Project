library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clock_divider is
generic( 
    divider : integer := 10 -- Dividing off 100MHz base clock.
);
port (      clk_i : in STD_LOGIC;
            clk_o : out STD_LOGIC);
end clock_divider;


architecture rtl of clock_divider is

signal counter : integer := 0;
signal clock_output : std_logic := '0';

constant threshold : integer := divider -1;

begin

clk_o <= clock_output;

process(clk_i) is begin
    if rising_edge(clk_i) then
        if counter < threshold then
            counter <= counter + 1;
        elsif counter >= threshold then
            counter <= 0;
        end if;
    end if;
end process;

process(clk_i) is begin
    if rising_edge(clk_i) then
        if counter >= threshold then
            clock_output <= not clock_output;
        end if;
    end if;
end process;


end rtl;
