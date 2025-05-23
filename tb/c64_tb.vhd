--
-- c64 tb
--

use std.textio.ALL;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity c64_tb is
end;

architecture c64_tb of c64_tb is

  constant CLKPERIOD_27MHz : time := 37.037 ns;

  --
  signal tmds_clk_n       : std_logic;
  signal tmds_clk_p       : std_logic;
  signal tmds_d_n         : std_logic_vector(2 downto 0);
  signal tmds_d_p         : std_logic_vector(2 downto 0);
  --
  signal I_CLK_REF        : std_logic;
 --
  signal reset            : std_logic;
  signal user             : std_logic;
 
  component tang_nano_20k_c64_top
  generic
  (
   DUAL  : integer := 1; -- 0:no, 1:yes dual SID build option
   MIDI  : integer := 1 -- 0:no, 1:yes optional MIDI Interface
   );
  port
  (
    clk         : in std_logic;
    reset       : in std_logic; -- S2 button
    user        : in std_logic; -- S1 button
    leds_n      : out std_logic_vector(5 downto 0);
    io          : in std_logic_vector(5 downto 0);
    -- USB-C BL616 UART
    uart_rx     : in std_logic;
    uart_tx     : out std_logic;
   -- external hw pin UART
    uart_ext_rx : in std_logic;
    uart_ext_tx : out std_logic;
    -- SPI interface Sipeed M0S Dock external BL616 uC
    m0s         : inout std_logic_vector(4 downto 0);
    --
    tmds_clk_n  : out std_logic;
    tmds_clk_p  : out std_logic;
    tmds_d_n    : out std_logic_vector( 2 downto 0);
    tmds_d_p    : out std_logic_vector( 2 downto 0);
    -- sd interface
    sd_clk      : out std_logic;
    sd_cmd      : inout std_logic;
    sd_dat      : inout std_logic_vector(3 downto 0);
    ws2812      : out std_logic;
    -- "Magic" port names that the gowin compiler connects to the on-chip SDRAM
    O_sdram_clk  : out std_logic;
    O_sdram_cke  : out std_logic;
    O_sdram_cs_n : out std_logic;            -- chip select
    O_sdram_cas_n : out std_logic;           -- columns address select
    O_sdram_ras_n : out std_logic;           -- row address select
    O_sdram_wen_n : out std_logic;           -- write enable
    IO_sdram_dq  : inout std_logic_vector(31 downto 0); -- 32 bit bidirectional data bus
    O_sdram_addr : out std_logic_vector(10 downto 0);  -- 11 bit multiplexed address bus
    O_sdram_ba   : out std_logic_vector(1 downto 0);     -- two banks
    O_sdram_dqm  : out std_logic_vector(3 downto 0);     -- 32/4
    -- Gamepad
    joystick_clk  : out std_logic;
    joystick_mosi : out std_logic;
    joystick_miso : inout std_logic; -- midi_out
    joystick_cs   : inout std_logic; -- midi_in
    -- spi flash interface
    mspi_cs       : out std_logic;
    mspi_clk      : out std_logic;
    mspi_di       : inout std_logic;
    mspi_hold     : inout std_logic;
    mspi_wp       : inout std_logic;
    mspi_do       : inout std_logic
    );
  end component;

  COMPONENT GSR 
  PORT (
       GSRI : in std_logic
  );
end COMPONENT;

begin

GSR_inst: work.GSR
 port map (
    GSRI <= '1'
  ) ;

  u0 : tang_nano_20k_c64_top
    port map (
    clk         => I_CLK_REF,
    reset       => reset,
    user        => user,
    leds_n      => open,
    io          => (others => '0'),
    uart_rx       => '0',
    uart_tx       => open,
    uart_ext_rx   => '0',
    uart_ext_tx   => open,
    -- SPI interface Sipeed M0S Dock external BL616 uC
    m0s           => (others => '0'),

    tmds_clk_n    => tmds_clk_n,
    tmds_clk_p    => tmds_clk_p,
    tmds_d_n      => tmds_d_n,
    tmds_d_p      => tmds_d_p, 
    -- sd interface
    sd_clk        => open,
    sd_cmd        => '0',
    sd_dat        => (others => '0'),
    ws2812        => open,
    --
    O_sdram_clk   => open,
    O_sdram_cke   => open,
    O_sdram_cs_n  => open,
    O_sdram_cas_n => open,
    O_sdram_ras_n => open,
    O_sdram_wen_n => open,
    IO_sdram_dq   => (others => '0'),
    O_sdram_addr  => open,
    O_sdram_ba    => open,
    O_sdram_dqm   => open,
    -- Gamepad
    joystick_clk  => open,
    joystick_mosi => open,
    joystick_miso => '0',
    joystick_cs   => open,
    -- spi flash interface
    mspi_cs       => open,
    mspi_clk      => open,
    mspi_di       => '0',
    mspi_hold     => '0',
    mspi_wp       => '0',
    mspi_do       => '0'
      );

  p_clk_27mhz  : process
  begin
    I_CLK_REF <= '0';
    wait for CLKPERIOD_27MHz / 2;
    I_CLK_REF <= '1';
    wait for CLKPERIOD_27MHz - (CLKPERIOD_27MHz / 2);
  end process;

  p_rst : process
  begin
    reset <= '0';
    wait for 100 ns;
    reset <= '1';
    wait;
  end process;

  user <= '1';

end c64_tb;

