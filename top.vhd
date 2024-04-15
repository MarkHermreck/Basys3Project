library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library axi_master;
use axi_master.all;

entity top is port (  
------------------------------------------------------------------------------- General and discrete IO
    clk_i               : in std_logic;
    disable_i           : in std_logic;
    led_o               : out std_logic_vector(9 downto 0) := (others => '0'); --2 = arready_i, 3 = awready_i, 4 = write op, 5 = read op, 6-9 read_state (9 leftmost)
    anodes_o            : out std_logic_vector(3 downto 0) := (others => '0'); 
    cathodes_o          : out std_logic_vector(7 downto 0) := (others => '1');
------------------------------------------------------------------------------- AXI Master Read Address Channel
    arready_i           : in std_logic := '0';
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
    rready_o            : out std_logic;
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

end top;

architecture rtl of top is

--type axi_regs is array (natural range <>) of unsigned(31 downto 0);

signal counter1                 : unsigned(24 downto 0) := (others => '0');
signal counter2                 : unsigned(26 downto 0) := (others => '0');

signal debounced_disable        : std_logic := '0';

signal seven_segment_output     : unsigned(15 downto 0) := x"F0F0";--f5c0

signal clk_10mhz                : std_logic := '0';

signal local_copy               : unsigned(31 downto 0) := x"BBBBBBBB";
signal register_copy            : unsigned(31 downto 0);

signal do_read                  : std_logic := '0';
signal do_write                 : std_logic := '0';

signal read_state               : std_logic_vector(3 downto 0);
signal write_state              : std_logic_vector(3 downto 0);

--signal mem_regs                 : axi_regs(31 downto 0) := (others => (others => '0'));

---------------------------------------------------------------

begin


segment_driver : entity work.segment_driver(rtl)
    port map (
    clk_i => clk_10mhz,
    disable_i => debounced_disable,
    full_number_i => seven_segment_output,
    anodes_o => anodes_o,
    cathodes_n_o => cathodes_o
    );

debounce : entity work.debounce(rtl)
    generic map (debounce_timer => 100000000)
    port map (
    clk_i => clk_i,
    sig_i => disable_i,
    sig_o => debounced_disable);
    
clock_gen_10MHz : entity work.clock_divider(rtl)
    generic map (divider => 10)
    port map(
    clk_i => clk_i,
    clk_o => clk_10mhz);
    
axi_master_interface : entity work.axi_master(rtl)
port map(
------------------------------------------------------------------------------- General and discrete IO
    clk_i => clk_i,
    do_read_i => do_read,
    do_write_i => do_write,
    local_copy_i => local_copy,
    local_copy_o => register_copy,
    read_state => read_state,
    write_state => write_state,    
------------------------------------------------------------------------------- AXI Master Read Address Channel
    arready_i => arready_i,
    arburst_o => arburst_o,
    araddr_o => araddr_o,
    arlen_o => arlen_o,
    arsize_o => arsize_o,
    arvalid_o => arvalid_o,
------------------------------------------------------------------------------- AXI Master Read Data Channel
    rdata_i => rdata_i,
    rresp_i => rresp_i,
    rlast_i => rlast_i,
    rvalid_i => rvalid_i,
    rready_o => rready_o,
------------------------------------------------------------------------------- AXI Master Write Address Channel
    awready_i => awready_i,
    awburst_o => awburst_o,
    awaddr_o => awaddr_o,
    awlen_o => awlen_o,
    awsize_o => awsize_o,
    awvalid_o => awvalid_o,
------------------------------------------------------------------------------- AXI Master Write Data Channel
    wready_i => wready_i,
    wdata_o => wdata_o,
    wstrb_o => wstrb_o,
    wlast_o => wlast_o,
    wvalid_o => wvalid_o,
------------------------------------------------------------------------------- AXI Master Write Response Channel
    bresp_i => bresp_i,
    bvalid_i => bvalid_i,
    bready_o => bready_o);
     
--extend_arready : entity work.pulse_extend(rtl)
--    port map(
--    clk_i => clk_i,
--    sig_i => arready_i,
--    sig_o => led_o(2));
    
--extend_rvalid : entity work.pulse_extend(rtl)
--    port map(
--    clk_i => clk_i,
--    sig_i => rvalid_i,
--    sig_o => led_o(3));
    
extend_awready : entity work.pulse_extend(rtl)
    port map(
    clk_i => clk_i,
    sig_i => rresp_i(0),
    sig_o => led_o(2));
    
extend_bvalid : entity work.pulse_extend(rtl)
    port map(
    clk_i => clk_i,
    sig_i => rresp_i(1),
    sig_o => led_o(3));

extend_doread : entity work.pulse_extend(rtl)
    port map(
    clk_i => clk_i,
    sig_i => do_read,
    sig_o => led_o(4));
    
extend_dowrite : entity work.pulse_extend(rtl)
    port map(
    clk_i => clk_i,
    sig_i => do_write,
    sig_o => led_o(5));
-----------------------------------------------------------------------------------------------------
-- Processes & Logic
-----------------------------------------------------------------------------------------------------

--seven_segment_output <= mem_regs(0)(15 downto 0);

--mem_regs(0) <= register_copy;

led_o(0) <= counter1(24);
led_o(1) <= counter2(25);

change_number : process(counter2(25)) is begin
        if rising_edge(counter2(25)) then
            local_copy <= local_copy + 1;
        end if;
end process change_number;

led_o(9 downto 6) <= not write_state;

ram_operations : process(clk_i) is begin
    if rising_edge(clk_i) then
    
        seven_segment_output <= register_copy(15 downto 0);
--        if arready_i = '1' then
--            led_o(2) <= '1';
----        else
----            led_o(2) <= '0';
--        end if;
--        if rlast_i = '1' then
--            led_o(2) <= '1';
----        else
----            led_o(2) <= '0';
--        end if;
        
--        if awready_i = '1' then
--            led_o(3) <= '1';
--        else
--            led_o(3) <= '0';
--        end if;
        
--        if read_state = "0001" then
--            led_o(4) <= '1';
--        end if;
        
--        if read_state = "0010" then
--            led_o(5) <= '1';
--        end if;
        
        if counter2 = 75000000 then
            do_read <= '1';
        else 
            do_read <= '0';
        end if;
        
        if counter2 = 25000000 then
            do_write <= '1';
        else
            do_write <= '0';
        end if;
    end if;
end process ram_operations;

increment_counters : process(clk_i) is begin
    if rising_edge(clk_i) then
        if(debounced_disable = '1') then
            counter1 <= (others => '0');
            counter2 <= (others => '0');
        else
            counter1 <= counter1 + 1;
            counter2 <= counter2 + 1;
        end if;
    end if; 
end process increment_counters;
end rtl;
