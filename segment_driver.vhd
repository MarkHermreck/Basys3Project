----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/14/2023 11:41:40 PM
-- Design Name: 
-- Module Name: segment_driver - rtl
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
--use IEEE.std_logic_arith.all;
use IEEE.NUMERIC_STD.ALL;


entity segment_driver is
    generic ( 
           deadtime_g       : integer := 20;
           state_time_g     : integer := 20000);     -- 10mhz clock
    port ( 
           clk_i            : in STD_LOGIC;
           disable_i        : in STD_LOGIC;
           full_number_i    : in unsigned (15 downto 0);
           anodes_o         : out STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
           cathodes_n_o     : out STD_LOGIC_VECTOR (7 downto 0) := (others => '1')); -- active low
end segment_driver;

architecture rtl of segment_driver is

alias fourth_number         : unsigned(3 downto 0) is full_number_i(15 downto 12);
alias third_number          : unsigned(3 downto 0) is full_number_i(11 downto 8);
alias second_number         : unsigned(3 downto 0) is full_number_i(7 downto 4);
alias first_number          : unsigned(3 downto 0) is full_number_i(3 downto 0);

alias anodes                : std_logic_vector(3 downto 0) is anodes_o;
alias anode_3               : std_logic is anodes_o(3);
alias anode_2               : std_logic is anodes_o(2);
alias anode_1               : std_logic is anodes_o(1);
alias anode_0               : std_logic is anodes_o(0);

constant reset_s            : std_logic_vector(3 downto 0) := "1111";
constant drive0_s           : std_logic_vector(3 downto 0) := "1110";
constant drive1_s           : std_logic_vector(3 downto 0) := "1101";                                                                      
constant drive2_s           : std_logic_vector(3 downto 0) := "1011";
constant drive3_s           : std_logic_vector(3 downto 0) := "0111";

signal driver_state         : std_logic_vector(3 downto 0) := reset_s;
signal driver_pipeline      : std_logic_vector(3 downto 0);

signal timer                : integer := 0;
signal timer_reset          : std_logic := '0';
signal timer_expire         : boolean;
signal timer_expiry         : boolean;

signal dt_expire            : boolean;
signal dt_expiry            : boolean;

signal displayed_number     : unsigned(3 downto 0) := "0000";

begin


timer_driver : process(clk_i) is begin
    if rising_edge(clk_i) then
        if (timer_reset = '1') or (disable_i = '1') then
            timer <= 0;
        else
            timer <= timer + 1;
        end if;
    end if;
end process;

expiry : process(clk_i) is begin
    if rising_edge(clk_i) then
        dt_expiry <= (timer >= deadtime_g) and (timer_reset = '0');
        timer_expiry <= (timer >= state_time_g) and (timer_reset = '0');
    end if;
end process;

dt_expire <= dt_expiry and (timer_reset = '0');
timer_expire <= timer_expiry and (timer_reset = '0');

-- state machine
-- initial state latches full number, does other preparation work
-- second through fifth state picks an anode to drive, and drives the 

driver_sm : process(clk_i) is begin
    if rising_edge(clk_i) then
        timer_reset <= '0';
        if (disable_i = '1') then
            driver_state <= reset_s;
            timer_reset <= '1';
            displayed_number <= "0000";
        else
            case driver_state is
                when reset_s =>
                    if dt_expire then
                        driver_state <= drive3_s;
                        timer_reset <= '1';
                    end if;
                when drive3_s =>
                    if dt_expire then
                        displayed_number <= fourth_number;
                    end if;
                    if timer_expire and dt_expire then
                        driver_state <= drive2_s;
                        timer_reset <= '1';
                    end if;
                when drive2_s =>
                    if dt_expire then
                        displayed_number <= third_number;
                    end if;
                    if timer_expire and dt_expire then
                        driver_state <= drive1_s;
                        timer_reset <= '1';
                    end if;
                when drive1_s =>
                    if dt_expire then
                        displayed_number <= second_number;
                    end if;
                    if timer_expire and dt_expire then
                        driver_state <= drive0_s;
                        timer_reset <= '1';
                    end if;
                when drive0_s =>
                    if dt_expire then
                        displayed_number <= first_number;
                    end if;
                    if timer_expire and dt_expire then
                        driver_state <= reset_s;
                        timer_reset <= '1';
                    end if;
                when others =>
                    driver_state <= reset_s;
            end case;
        end if;
    end if;
end process driver_sm; 
         
--Figure out how to do this, this is very cool
--anode_3 <= dt_expire and driver_state(3) = '1';
--anode_2 <= dt_expire and driver_state(2);
--anode_1 <= dt_expire and driver_state(1);
--anode_0 <= dt_expire and driver_state(0);


--anodes_o <= driver_state;

anode_setting : process(clk_i) is begin
    if rising_edge(clk_i) then
        if dt_expire then
            driver_pipeline <= driver_state;
            anodes_o <= driver_pipeline;
        else
            anodes_o <= "1111";
        end if;
    end if;
end process anode_setting;

cathode_lut : entity work.cathode_lut(rtl)
    port map(
    clk_i => clk_i,
    number_i => displayed_number,
    cathodes_n_o => cathodes_n_o);

end rtl;
