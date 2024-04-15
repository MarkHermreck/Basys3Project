library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity axi_write is
  port ( 
  ------------------------------------------------------------------------------- General and discrete IO
    clk_i               : in std_logic;
    do_write_i          : in std_logic;
    local_copy_i        : in unsigned(31 downto 0);
    write_state         : out std_logic_vector(3 downto 0);
  ------------------------------------------------------------------------------- AXI Master Write Address Channel
    awready_i           : in std_logic;
    awburst_o           : out std_logic_vector(1 downto 0) := "10"; -- Defaults to INC
    awaddr_o            : out unsigned(12 downto 0) := (others => '0'); -- 2048x32 BRAM requires 11 bits of addressing
    awlen_o             : out unsigned(7 downto 0) := (others => '0'); -- Burst_Length = awlen_o + 1 (bytes to write(transfers in burst), incrementing from first address)
    awsize_o            : out unsigned(2 downto 0) := "010"; -- Burst Size (bytes per transfer) = 2^awsize_o
    awvalid_o           : out std_logic;
------------------------------------------------------------------------------- AXI Master Write Data Channel
    wready_i            : in std_logic;
    wdata_o             : out unsigned(31 downto 0);
    wstrb_o             : out std_logic_vector(3 downto 0) := (others => '1'); -- 4b1111 includes all four bytes in data transfer
    wlast_o             : out std_logic := '0';
    wvalid_o            : out std_logic := '0';
------------------------------------------------------------------------------- AXI Master Write Response Channel
    bresp_i             : in std_logic_vector(1 downto 0);
    bvalid_i            : in std_logic;
    bready_o            : out std_logic -- Produced by master
-------------------------------------------------------------------------------  
);
end axi_write;

architecture rtl of axi_write is

constant idle_s        : std_logic_vector(3 downto 0) := "0000";
constant initiate_s    : std_logic_vector(3 downto 0) := "0001";
constant transmitting_s: std_logic_vector(3 downto 0) := "0010";
constant done_s        : std_logic_vector(3 downto 0) := "0100";

signal state           : std_logic_vector(3 downto 0) := idle_s;

signal error           : boolean := FALSE;

begin

write_state <= state;

write_sm : process(clk_i) is begin
    if rising_edge(clk_i) then
        case state is
            when idle_s =>
                awvalid_o <= '0';
                bready_o <= '0';
                if do_write_i = '1' then
                    state <= initiate_s;
                end if;
            when initiate_s =>
                awburst_o <= "10";
                awaddr_o <= (others => '0');
                awlen_o <= "00000011";
                awsize_o <= "010";
                
                awvalid_o <= '1';
                
                if awready_i = '1' then
                    state <= transmitting_s;
                end if;
            when transmitting_s =>
            
                awvalid_o <= '0';
                bready_o <= '1';
            
                wvalid_o <= '1';
                wdata_o <= local_copy_i;
                wstrb_o <= "1111";
                wlast_o <= '1';
                
                -- Add logic for multiple outputs in one transaction burst.
                if wready_i = '1' then
                    state <= done_s;
                end if;
            when done_s =>
                wlast_o <= '0';
                wvalid_o <= '0';
                -- Currently vestigial state. Add logic to copy temporary data in buffer here to FPGA-wide usable copies of memory.
                if bvalid_i = '1' and bresp_i(1) = '1' then
                    error <= TRUE;
                    bready_o <= '0';
                    state <= idle_s;
                elsif bvalid_i = '1' and bresp_i(1) = '0' then
                    error <= FALSE;
                    bready_o <= '0';
                    state <= idle_s;
                end if;
            when others =>
                state <= idle_s;
        end case;
    end if;
end process write_sm;

end rtl;
