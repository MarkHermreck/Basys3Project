library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity axi_master is
  port ( 
------------------------------------------------------------------------------- General and discrete IO
    clk_i               : in std_logic;
    do_read_i           : in std_logic;
    do_write_i          : in std_logic;
    local_copy_i        : in unsigned(31 downto 0);
    local_copy_o        : out unsigned(31 downto 0);
    read_state          : out std_logic_vector(3 downto 0);
    write_state         : out std_logic_vector(3 downto 0);
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
    wstrb_o             : out std_logic_vector(3 downto 0); -- 4b1111 includes all four bytes in data transfer
    wlast_o             : out std_logic := '0';
    wvalid_o            : out std_logic := '0';
------------------------------------------------------------------------------- AXI Master Write Response Channel
    bresp_i             : in std_logic_vector(1 downto 0);
    bvalid_i            : in std_logic;
    bready_o            : out std_logic -- Produced by master
-------------------------------------------------------------------------------     
);
end axi_master;

architecture rtl of axi_master is

begin


axi_read_logic : entity work.axi_read(rtl) 
port map(
  ------------------------------------------------------------------------------- General and discrete IO
    clk_i => clk_i,
    do_read_i => do_read_i,
    local_copy_o => local_copy_o,
    read_state => read_state,
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
    rready_o => rready_o);
    
axi_write_logic : entity work.axi_write(rtl) 
port map(
  ------------------------------------------------------------------------------- General and discrete IO
    clk_i => clk_i,
    do_write_i => do_write_i,
    local_copy_i => local_copy_i,
    write_state => write_state,
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

end rtl;
