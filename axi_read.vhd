library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity axi_read is
--    generic ( 
    
    
--    );
    port ( 
  ------------------------------------------------------------------------------- General and discrete IO
    clk_i               : in std_logic;
    do_read_i           : in std_logic;
    local_copy_o        : out unsigned(31 downto 0) := x"B8D5F3F1";
    read_state          : out std_logic_vector(3 downto 0);
------------------------------------------------------------------------------- AXI Master Read Address Channel
    arready_i           : in std_logic;
    arburst_o           : out std_logic_vector(1 downto 0) := "10"; -- Defaults to INC
    araddr_o            : out unsigned(12 downto 0) := (others => '0'); -- 2048x32 BRAM requires 11 bits of addressing
    arlen_o             : out unsigned(7 downto 0) := (others => '0'); -- Burst_Length = arlen_o + 1 (bytes to read(transfers in burst), incrementing from first address)
    arsize_o            : out unsigned(2 downto 0) := "010"; -- Burst Size (bytes per transfer) = 2^arsize_o
    arvalid_o           : out std_logic := '0';
------------------------------------------------------------------------------- AXI Master Read Data Channel
    rdata_i             : in unsigned(31 downto 0);
    rresp_i             : in std_logic_vector(1 downto 0);
    rlast_i             : in std_logic;
    rvalid_i            : in std_logic;
    rready_o            : out std_logic := '0'
);
end axi_read;

architecture rtl of axi_read is

constant idle_s        : std_logic_vector(3 downto 0) := "0000";
constant initiate_s    : std_logic_vector(3 downto 0) := "0001";
constant receiving_s   : std_logic_vector(3 downto 0) := "0010";
constant done_s        : std_logic_vector(3 downto 0) := "0100";

signal state           : std_logic_vector(3 downto 0) := idle_s;

signal error           : boolean := FALSE;

begin

read_state <= state;

read_sm : process(clk_i) is begin
    if rising_edge(clk_i) then
        case state is
            when idle_s =>
                arvalid_o <= '0';
                rready_o <= '0';
                if do_read_i = '1' then
                    state <= initiate_s;
                end if;
            when initiate_s =>
                arburst_o <= "10";
                araddr_o <= (others => '0');
                arlen_o <= "00000011";
                arsize_o <= "010";
                
                arvalid_o <= '1';
            
                if arready_i <= '1' then
                    state <= receiving_s;
                end if;
            when receiving_s =>
                arvalid_o <= '0';
                rready_o <= '1';
                if rresp_i(1) = '1' then
                    error <= TRUE;
                elsif rvalid_i = '1' and rresp_i(1) = '0' then
                    rready_o <= '1';
                    local_copy_o <= rdata_i;
                    
                end if;
                
                -- Add logic for multiple outputs in one transaction burst.
                if rlast_i = '1' then
                    rready_o <= '0';
                    state <= done_s;
                end if;
            when done_s =>
                -- Currently vestigial state. Add logic to copy temporary data in buffer here to FPGA-wide usable copies of memory.
                state <= idle_s;
            when others =>
                state <= idle_s;
        end case;
    end if;
end process read_sm;
        

end rtl;
