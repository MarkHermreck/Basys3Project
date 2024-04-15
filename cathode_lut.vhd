
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cathode_lut is      
    port ( 
           clk_i            : in STD_LOGIC;
           number_i         : in unsigned(3 downto 0);
           cathodes_n_o     : out STD_LOGIC_VECTOR (7 downto 0) := (others => '1')); -- active low, drive low to illuminate segment)
end cathode_lut;

architecture rtl of cathode_lut is


alias c_a_n                 : std_logic is cathodes_n_o(0);
alias c_b_n                 : std_logic is cathodes_n_o(1);
alias c_c_n                 : std_logic is cathodes_n_o(2);
alias c_d_n                 : std_logic is cathodes_n_o(3);
alias c_e_n                 : std_logic is cathodes_n_o(4);
alias c_f_n                 : std_logic is cathodes_n_o(5);
alias c_g_n                 : std_logic is cathodes_n_o(6);
alias c_dp_n                : std_logic is cathodes_n_o(7);     

signal counter              : integer := 0;
signal threshold            : integer := 10000000;
signal choose               : unsigned(3 downto 0) := (others => '0');


begin


process(clk_i) is begin
    if rising_edge(clk_i) then
        if counter >= threshold then
            choose <= choose + 1;
            counter <= 0;
        else
            counter <= counter + 1;
        end if;
    end if;
end process;
    


c_dp_n <= '1'; -- Permanently drive high to disable.

cathode_lut : process(clk_i) is begin
    if rising_edge(clk_i) then
        case number_i is
--            case choose is
            when "0000" => -- display 0 ( abcdef = 0)
                c_a_n <= '0';
                c_b_n <= '0';
                c_c_n <= '0';
                c_d_n <= '0';
                c_e_n <= '0';
                c_f_n <= '0';
                c_g_n <= '1';
            when "0001" => -- display 1 (drive bc low)
                c_a_n <= '1';
                c_b_n <= '0';
                c_c_n <= '0';
                c_d_n <= '1';
                c_e_n <= '1';
                c_f_n <= '1';
                c_g_n <= '1';
            when "0010" => -- display 2 (drive abged)
                c_a_n <= '0';
                c_b_n <= '0';
                c_c_n <= '1';
                c_d_n <= '0';
                c_e_n <= '0';
                c_f_n <= '1';
                c_g_n <= '0';
            when "0011" => -- display 3 (abgcd)
                c_a_n <= '0';
                c_b_n <= '0';
                c_c_n <= '0';
                c_d_n <= '0';
                c_e_n <= '1';
                c_f_n <= '1';
                c_g_n <= '0';
            when "0100" => -- display 4 (fgbc)
                c_a_n <= '1';
                c_b_n <= '0';
                c_c_n <= '0';
                c_d_n <= '1';
                c_e_n <= '1';
                c_f_n <= '0';
                c_g_n <= '0';
            when "0101" => -- display 5 (afgcd)
                c_a_n <= '0';
                c_b_n <= '1';
                c_c_n <= '0';
                c_d_n <= '0';
                c_e_n <= '1';
                c_f_n <= '0';
                c_g_n <= '0';
            when "0110" => -- display 6 (afgedc)
                c_a_n <= '0';
                c_b_n <= '1';
                c_c_n <= '0';
                c_d_n <= '0';
                c_e_n <= '0';
                c_f_n <= '0';
                c_g_n <= '0';
            when "0111" => -- display 7 (abc)
                c_a_n <= '0';
                c_b_n <= '0';
                c_c_n <= '0';
                c_d_n <= '1';
                c_e_n <= '1';
                c_f_n <= '1';
                c_g_n <= '1';
            when "1000" => -- display 8 (abcdefg)
                cathodes_n_o(6 downto 0) <= (others => '0');
            when "1001" => -- display 9 (abcdfg)
                c_a_n <= '0';
                c_b_n <= '0';
                c_c_n <= '0';
                c_d_n <= '0';
                c_e_n <= '1';
                c_f_n <= '0';
                c_g_n <= '0';
            when "1010" => -- display a (efabcg)
                c_a_n <= '0';
                c_b_n <= '0';
                c_c_n <= '0';
                c_d_n <= '1';
                c_e_n <= '0';
                c_f_n <= '0';
                c_g_n <= '0';
            when "1011" => -- display b (fegcd)
                c_a_n <= '1';
                c_b_n <= '1';
                c_c_n <= '0';
                c_d_n <= '0';
                c_e_n <= '0';
                c_f_n <= '0';
                c_g_n <= '0';
            when "1100" => -- display c (afed)
                c_a_n <= '0';
                c_b_n <= '1';
                c_c_n <= '1';
                c_d_n <= '0';
                c_e_n <= '0';
                c_f_n <= '0';
                c_g_n <= '1';
            when "1101" => -- display d (edcbg)
                c_a_n <= '1';
                c_b_n <= '0';
                c_c_n <= '0';
                c_d_n <= '0';
                c_e_n <= '0';
                c_f_n <= '1';
                c_g_n <= '0';
            when "1110" => -- display e (afged)
                c_a_n <= '0';
                c_b_n <= '1';
                c_c_n <= '1';
                c_d_n <= '0';
                c_e_n <= '0';
                c_f_n <= '0';
                c_g_n <= '0';
            when "1111" => -- display f (afge)
                c_a_n <= '0';
                c_b_n <= '1';
                c_c_n <= '1';
                c_d_n <= '1';
                c_e_n <= '0';
                c_f_n <= '0';
                c_g_n <= '0';
            when others =>
        end case;
    end if;
end process;

end rtl;
