----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/02/2023 10:40:44 PM
-- Design Name: 
-- Module Name: debounce - rtl
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity debounce is
    generic ( 
    debounce_timer : integer := 100000000 -- defaults to 1s debounce, can be overridden
    );
    port ( clk_i : in STD_LOGIC;
           sig_i : in STD_LOGIC;
           sig_o : out STD_LOGIC);
end debounce;

architecture rtl of debounce is

signal timer : integer := 0;
signal previous : std_logic;
    
begin

debounce_timing : process(clk_i) is begin
    if rising_edge(clk_i) then
        if previous /= sig_i then
            timer <= 0;
        elsif timer < (debounce_timer) then   
            timer <= timer + 1;
        elsif timer >= debounce_timer-1 then
            sig_o <= sig_i;
        end if;
    end if;      
end process debounce_timing;

process(clk_i) is begin
    if rising_edge(clk_i) then
        previous <= sig_i;
    end if;
end process;


end rtl;
