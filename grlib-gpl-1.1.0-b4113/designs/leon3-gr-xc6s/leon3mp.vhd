-----------------------------------------------------------------------------
--  LEON3 Demonstration design
--  Copyright (C) 2011 Jiri Gaisler, Gaisler Research
------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003 - 2008, Gaisler Research
--  Copyright (C) 2008 - 2011, Aeroflex Gaisler
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
library grlib, techmap;
use grlib.amba.all;
use grlib.amba.all;
use grlib.stdlib.all;
use techmap.gencomp.all;
use techmap.allclkgen.all;
library gaisler;
use gaisler.memctrl.all;
use gaisler.leon3.all;
use gaisler.uart.all;
use gaisler.misc.all;
use gaisler.spi.all;
use gaisler.can.all;
use gaisler.net.all;
use gaisler.jtag.all;
use gaisler.spacewire.all;
use gaisler.grusb.all;
--use gaisler.ata.all;
-- pragma translate_off
use gaisler.sim.all;
-- pragma translate_on


library esa;
use esa.memoryctrl.all;

use work.config.all;

entity leon3mp is
  generic (
    fabtech       : integer := CFG_FABTECH;
    memtech       : integer := CFG_MEMTECH;
    padtech       : integer := CFG_PADTECH;
    clktech       : integer := CFG_CLKTECH;
    disas         : integer := CFG_DISAS;   -- Enable disassembly to console
    dbguart       : integer := CFG_DUART;   -- Print UART on console
    pclow         : integer := CFG_PCLOW
  );
  port (
    resetn      : in  std_ulogic;
    clk         : in  std_ulogic;    -- 50 MHz main clock
    clk2        : in  std_ulogic;    -- User clock
    clk125      : in  std_ulogic;    -- 125 MHz clock from PHY
    wdogn       : out std_ulogic;
    address     : out std_logic_vector(24 downto 0);
    data        : inout std_logic_vector(31 downto 24);
    oen         : out std_ulogic;
    writen      : out std_ulogic;
    romsn       : out std_logic;

    ddr_clk        : out std_logic;
    ddr_clkb       : out std_logic;
    ddr_cke        : out std_logic;
    ddr_odt        : out std_logic;
    ddr_we         : out std_ulogic;                       -- ddr write enable
    ddr_ras        : out std_ulogic;                       -- ddr ras

    ddr_cas        : out std_ulogic;                       -- ddr cas
    ddr_dm         : out std_logic_vector (1 downto 0);    -- ddr dm
    ddr_dqs        : inout std_logic_vector (1 downto 0);  -- ddr dqs
    ddr_ad         : out std_logic_vector (12 downto 0);   -- ddr address
    ddr_ba         : out std_logic_vector (2 downto 0);    -- ddr bank address
    ddr_dq         : inout std_logic_vector (15 downto 0); -- ddr data
    ddr_rzq        : inout std_ulogic;                       
    ddr_zio        : inout std_ulogic;                       
   
 --   dsuen        : in std_ulogic;   -- dip swtich 7
--    dsubre       : in std_ulogic; -- switch 9
--    dsuact       : out std_ulogic; -- led (0)

    txd1        : out std_ulogic;          -- UART1 tx data
    rxd1        : in  std_ulogic;           -- UART1 rx data
    ctsn1       : in  std_ulogic;           -- UART1 ctsn
    rtsn1       : out std_ulogic;           -- UART1 trsn
    txd2        : out std_ulogic;          -- UART2 tx data
    rxd2        : in  std_ulogic;           -- UART2 rx data
    ctsn2       : in  std_ulogic;           -- UART2 ctsn
    rtsn2       : out std_ulogic;           -- UART2 rtsn

    pio          : inout std_logic_vector(17 downto 0);    -- I/O port
    genio        : inout std_logic_vector(59 downto 0);    -- I/O port
    switch       : in std_logic_vector(9 downto 0);    -- I/O port
    led          : out std_logic_vector(3 downto 0);    -- I/O port

    erx_clk      : in std_ulogic; 
    emdio        : inout std_logic;      -- ethernet PHY interface
    erxd         : in std_logic_vector(3 downto 0);   
    erx_dv       : in std_ulogic; 
    emdint       : in std_ulogic;
    etx_clk      : out std_ulogic; 
    etxd         : out std_logic_vector(3 downto 0);   
    etx_en       : out std_ulogic; 
    emdc         : out std_ulogic;

    ps2clk        : inout std_logic_vector(1 downto 0);
    ps2data       : inout std_logic_vector(1 downto 0);
	
    iic_scl       : inout std_ulogic;
    iic_sda       : inout std_ulogic;

    ddc_scl       : inout std_ulogic;
    ddc_sda       : inout std_ulogic;

    dvi_iic_scl   : inout std_logic;
    dvi_iic_sda   : inout std_logic;
	
	

    tft_lcd_data    : out std_logic_vector(11 downto 0);
    tft_lcd_clk_p   : out std_ulogic;
    tft_lcd_clk_n   : out std_ulogic;
    tft_lcd_hsync   : out std_ulogic;
    tft_lcd_vsync   : out std_ulogic;
    tft_lcd_de      : out std_ulogic;
    tft_lcd_reset_b : out std_ulogic;
   

    spw_clk         : in  std_ulogic;
    spw_rxdp        : in  std_logic_vector(0 to CFG_SPW_NUM-1);
    spw_rxdn        : in  std_logic_vector(0 to CFG_SPW_NUM-1);
    spw_rxsp        : in  std_logic_vector(0 to CFG_SPW_NUM-1);
    spw_rxsn        : in  std_logic_vector(0 to CFG_SPW_NUM-1);
    spw_txdp        : out std_logic_vector(0 to CFG_SPW_NUM-1);
    spw_txdn        : out std_logic_vector(0 to CFG_SPW_NUM-1);
    spw_txsp        : out std_logic_vector(0 to CFG_SPW_NUM-1);
    spw_txsn        : out std_logic_vector(0 to CFG_SPW_NUM-1);

    usb_clk     : in std_logic;
    usb_d       : inout std_logic_vector(7 downto 0);
    usb_nxt     : in  std_logic;
    usb_stp     : out std_logic;
    usb_dir     : in  std_logic;
    usb_resetn  : out std_ulogic;
	
	-- ATA / IDE Interface
	
-- This interface shares pins with GENIO port.
	
 --   ata_rstn  : out std_logic; 
 --   ata_data  : inout std_logic_vector(15 downto 0);
 --   ata_da    : out std_logic_vector(2 downto 0);  
 --   ata_cs0   : out std_logic;
 --   ata_cs1   : out std_logic;
 --  ata_dior  : out std_logic;
 --  ata_diow  : out std_logic;
 --   ata_iordy : in std_logic;
 --  ata_intrq : in std_logic;
 --  ata_dmarq : in std_logic; 
 --  ata_dmack : out std_logic;
 --   --ata_dasp  : in std_logic
 --   ata_csel  : out std_logic;

    -- SPI flash
    spi_sel_n : inout std_ulogic;
    spi_clk   : out   std_ulogic;
    spi_mosi  : out   std_ulogic
	
	-- SD Card interface (SD SPI interface)
--    sdata     : inout std_ulogic_vector(3 downto 0);
--    sd_clk    : out   std_ulogic;
--    spi_cmd   : out   std_ulogic;
 
--    sd_prot   : in std_logic;
--    sd_detect : in std_logic
	
   );
end;

architecture rtl of leon3mp is

attribute syn_netlist_hierarchy : boolean;
attribute syn_netlist_hierarchy of rtl : architecture is false;


constant blength : integer := 12;
constant fifodepth : integer := 8;
constant maxahbm : integer := CFG_NCPU+CFG_AHB_UART+CFG_GRETH+
   CFG_AHB_JTAG+CFG_SPW_NUM*CFG_SPW_EN+CFG_GRUSB_DCL+
   CFG_ATA+CFG_GRUSBDC;

   
signal vcc, gnd   : std_logic;
signal memi  : memory_in_type;
signal memo  : memory_out_type;
signal wpo   : wprot_out_type;
signal sdi   : sdctrl_in_type;
signal sdo   : sdram_out_type;
signal sdo2, sdo3 : sdctrl_out_type;

signal apbi, apbi2  : apb_slv_in_type;
signal apbo, apbo2  : apb_slv_out_vector := (others => apb_none);
signal ahbsi : ahb_slv_in_type;
signal ahbso : ahb_slv_out_vector := (others => ahbs_none);
signal ahbmi : ahb_mst_in_type;
signal vahbmi : ahb_mst_in_type;
signal ahbmo : ahb_mst_out_vector := (others => ahbm_none);
signal vahbmo : ahb_mst_out_type;

signal clkm, rstn, rstraw, sdclkl : std_ulogic;
signal clk_200 : std_ulogic;
signal clk25, clk40, clk65 : std_ulogic;

signal cgi, cgi2   : clkgen_in_type;
signal cgo, cgo2   : clkgen_out_type;
signal u1i, u2i, dui : uart_in_type;
signal u1o, u2o, duo : uart_out_type;

signal irqi : irq_in_vector(0 to CFG_NCPU-1);
signal irqo : irq_out_vector(0 to CFG_NCPU-1);

signal dbgi : l3_debug_in_vector(0 to CFG_NCPU-1);
signal dbgo : l3_debug_out_vector(0 to CFG_NCPU-1);

signal dsui : dsu_in_type;
signal dsuo : dsu_out_type; 

signal gmiii, rgmiii : eth_in_type;
signal gmiio, rgmiio : eth_out_type;
signal rgmii_lock : std_ulogic;

signal gpti : gptimer_in_type;
signal gpto : gptimer_out_type;

signal gpioi : gpio_in_type;
signal gpioo : gpio_out_type;

signal gpioi2 : gpio_in_type;
signal gpioo2 : gpio_out_type;

signal gpioi3 : gpio_in_type;
signal gpioo3 : gpio_out_type;


signal clklock, elock, ulock : std_ulogic;

signal can_lrx, can_ltx   : std_logic_vector(0 to 7);

signal lock, calib_done, clkml, lclk, rst, ndsuact, wdogl : std_ulogic;
signal tck, tckn, tms, tdi, tdo : std_ulogic;

signal uclk : std_ulogic;
signal usbi : grusb_in_vector(0 downto 0);
signal usbo : grusb_out_vector(0 downto 0);

signal ethclk, ddr2clk : std_ulogic;

signal kbdi  : ps2_in_type;
signal kbdo  : ps2_out_type;
signal moui  : ps2_in_type;
signal mouo  : ps2_out_type;
signal vgao  : apbvga_out_type;
signal lcd_datal : std_logic_vector(11 downto 0);
signal lcd_hsyncl, lcd_vsyncl, lcd_del, lcd_reset_bl : std_ulogic;

signal i2ci, dvi_i2ci : i2c_in_type;
signal i2co, dvi_i2co : i2c_out_type;

signal spmi : spimctrl_in_type;
signal spmo : spimctrl_out_type;

signal spmi2 : spimctrl_in_type;
signal spmo2 : spimctrl_out_type;

constant BOARD_FREQ : integer := 50000;   -- input frequency in KHz
constant CPU_FREQ : integer := BOARD_FREQ * CFG_CLKMUL / CFG_CLKDIV;  -- cpu frequency in KHz
constant IOAEN : integer := CFG_CAN + CFG_ATA + CFG_GRUSBDC;
constant DDR2_FREQ  : integer := 200000;                               -- DDR2 input frequency in KHz


signal spwi : grspw_in_type_vector(0 to CFG_SPW_NUM-1);
signal spwo : grspw_out_type_vector(0 to CFG_SPW_NUM-1);
signal dtmp    : std_logic_vector(CFG_SPW_NUM-1 downto 0);
signal stmp    : std_logic_vector(CFG_SPW_NUM-1 downto 0);
signal spw_clkl   : std_ulogic;
signal spw_clkln  : std_ulogic;
signal rxclko     : std_logic_vector(CFG_SPW_NUM-1 downto 0);
signal stati : ahbstat_in_type;
signal lusb_clk  : std_ulogic;

signal ddsi  : ddrmem_in_type;
signal ddso  : ddrmem_out_type;

signal fpi : grfpu_in_vector_type;
signal fpo : grfpu_out_vector_type;

  -- Used for connecting input/output signals to the DDR2 controller
  signal core_ddr_clk  : std_logic_vector(2 downto 0);
  signal core_ddr_clkb : std_logic_vector(2 downto 0);
  signal core_ddr_cke  : std_logic_vector(1 downto 0);
  signal core_ddr_csb  : std_logic_vector(1 downto 0);
  signal core_ddr_ad   : std_logic_vector(13 downto 0);
  signal core_ddr_odt  : std_logic_vector(1 downto 0);
  

constant SPW_LOOP_BACK : integer := 0;

signal video_clk, clk50, clk100, spw100 : std_logic;  -- signals to vga_clkgen.
signal clk_sel : std_logic_vector(1 downto 0);
signal clkvga, clkvga_p, clkvga_n : std_ulogic;

attribute keep : boolean;
attribute syn_keep : boolean;
attribute syn_preserve : boolean;
attribute syn_keep of clk50 : signal is true;
attribute syn_preserve of clk50 : signal is true;
attribute keep of clk50 : signal is true;
attribute syn_keep of video_clk : signal is true;
attribute syn_preserve of video_clk : signal is true;
attribute keep of video_clk : signal is true;
attribute syn_preserve of ddr2clk : signal is true;
attribute keep of ddr2clk : signal is true;
attribute syn_preserve of spw100 : signal is true;
attribute keep of spw100 : signal is true;
attribute syn_preserve of clkm : signal is true;
attribute keep of clkm : signal is true;

begin

----------------------------------------------------------------------
---  Reset and Clock generation  -------------------------------------
----------------------------------------------------------------------
  
  vcc <= '1'; gnd <= '0';
  cgi.pllctrl <= "00"; cgi.pllrst <= rstraw;

--  pllref_pad : clkpad generic map (tech => padtech) port map (pllref, cgi.pllref); 
--  ethclk_pad : inpad generic map (tech => padtech) port map(clk2, ethclk);
  ethclk <= lclk;
  clk_pad : clkpad generic map (tech => padtech) port map (clk, lclk); 
--  clkddr_pad : clkpad generic map (tech => padtech) port map (clk, ddr2clk); 
   ddr2clk <= lclk;
  clkgen0 : clkgen        -- clock generator
    generic map (clktech, CFG_CLKMUL, CFG_CLKDIV, CFG_MCTRL_SDEN,
   CFG_CLK_NOFB, 0, 0, 0, BOARD_FREQ)
    port map (lclk, lclk, clkm, open, open, sdclkl, open, cgi, cgo, open, clk50, clk100);


  resetn_pad : inpad generic map (tech => padtech) port map (resetn, rst); 
  rst0 : rstgen         -- reset generator
  port map (rst, clkm, lock, rstn, rstraw);
  lock <= cgo.clklock and calib_done when CFG_MIG_DDR2 = 1 else cgo.clklock;

----------------------------------------------------------------------
---  AHB CONTROLLER --------------------------------------------------
----------------------------------------------------------------------

  ahb0 : ahbctrl       -- AHB arbiter/multiplexer
  generic map (defmast => CFG_DEFMST, split => CFG_SPLIT, 
   rrobin => CFG_RROBIN, ioaddr => CFG_AHBIO,
   ioen => IOAEN, nahbm => maxahbm, nahbs => 16)
  port map (rstn, clkm, ahbmi, ahbmo, ahbsi, ahbso);

----------------------------------------------------------------------
---  LEON3 processor and DSU -----------------------------------------
----------------------------------------------------------------------

  nosh : if CFG_GRFPUSH = 0 generate
    cpu : for i in 0 to CFG_NCPU-1 generate
      l3ft : if CFG_LEON3FT_EN /= 0 generate
        leon3ft0 : leon3ft		-- LEON3 processor      
        generic map (i, fabtech, memtech, CFG_NWIN, CFG_DSU, CFG_FPU, CFG_V8, 
  	  0, CFG_MAC, pclow, CFG_NOTAG, CFG_NWP, CFG_ICEN, CFG_IREPL, CFG_ISETS, CFG_ILINE, 
	  CFG_ISETSZ, CFG_ILOCK, CFG_DCEN, CFG_DREPL, CFG_DSETS, CFG_DLINE, CFG_DSETSZ,
	  CFG_DLOCK, CFG_DSNOOP, CFG_ILRAMEN, CFG_ILRAMSZ, CFG_ILRAMADDR, CFG_DLRAMEN,
          CFG_DLRAMSZ, CFG_DLRAMADDR, CFG_MMUEN, CFG_ITLBNUM, CFG_DTLBNUM, CFG_TLB_TYPE, CFG_TLB_REP, 
          CFG_LDDEL, disas, CFG_ITBSZ, CFG_PWD, CFG_SVT, CFG_RSTADDR, CFG_NCPU-1,
	  CFG_IUFT_EN, CFG_FPUFT_EN, CFG_CACHE_FT_EN, CFG_RF_ERRINJ, 
	  CFG_CACHE_ERRINJ, CFG_DFIXED, CFG_LEON3_NETLIST, CFG_SCAN, CFG_MMU_PAGE)
        port map (clkm, rstn, ahbmi, ahbmo(i), ahbsi, ahbso, 
    		irqi(i), irqo(i), dbgi(i), dbgo(i), clkm);
      end generate;

      l3s : if CFG_LEON3FT_EN = 0 generate
        u0 : leon3s 		-- LEON3 processor
        generic map (i, fabtech, memtech, CFG_NWIN, CFG_DSU, CFG_FPU, CFG_V8,
	  0, CFG_MAC, pclow, CFG_NOTAG, CFG_NWP, CFG_ICEN, CFG_IREPL, CFG_ISETS, CFG_ILINE,
	  CFG_ISETSZ, CFG_ILOCK, CFG_DCEN, CFG_DREPL, CFG_DSETS, CFG_DLINE, CFG_DSETSZ,
	  CFG_DLOCK, CFG_DSNOOP, CFG_ILRAMEN, CFG_ILRAMSZ, CFG_ILRAMADDR, CFG_DLRAMEN,
          CFG_DLRAMSZ, CFG_DLRAMADDR, CFG_MMUEN, CFG_ITLBNUM, CFG_DTLBNUM, CFG_TLB_TYPE, CFG_TLB_REP,
          CFG_LDDEL, disas, CFG_ITBSZ, CFG_PWD, CFG_SVT, CFG_RSTADDR, CFG_NCPU-1,
	  CFG_DFIXED, CFG_SCAN, CFG_MMU_PAGE)
        port map (clkm, rstn, ahbmi, ahbmo(i), ahbsi, ahbso,
    		irqi(i), irqo(i), dbgi(i), dbgo(i));
      end generate;
    end generate;
  end generate;

  sh : if CFG_GRFPUSH = 1 generate
    cpu : for i in 0 to CFG_NCPU-1 generate
      l3ft : if CFG_LEON3FT_EN /= 0 generate
        leon3ft0 : leon3ftsh		-- LEON3 processor      
        generic map (i, fabtech, memtech, CFG_NWIN, CFG_DSU, CFG_FPU, CFG_V8, 
  	  0, CFG_MAC, pclow, CFG_NOTAG, CFG_NWP, CFG_ICEN, CFG_IREPL, CFG_ISETS, CFG_ILINE, 
	  CFG_ISETSZ, CFG_ILOCK, CFG_DCEN, CFG_DREPL, CFG_DSETS, CFG_DLINE, CFG_DSETSZ,
	  CFG_DLOCK, CFG_DSNOOP, CFG_ILRAMEN, CFG_ILRAMSZ, CFG_ILRAMADDR, CFG_DLRAMEN,
          CFG_DLRAMSZ, CFG_DLRAMADDR, CFG_MMUEN, CFG_ITLBNUM, CFG_DTLBNUM, CFG_TLB_TYPE, CFG_TLB_REP, 
          CFG_LDDEL, disas, CFG_ITBSZ, CFG_PWD, CFG_SVT, CFG_RSTADDR, CFG_NCPU-1,
	  CFG_IUFT_EN, CFG_FPUFT_EN, CFG_CACHE_FT_EN, CFG_RF_ERRINJ, 
	  CFG_CACHE_ERRINJ, CFG_DFIXED, CFG_LEON3_NETLIST, CFG_SCAN, CFG_MMU_PAGE)
        port map (clkm, rstn, ahbmi, ahbmo(i), ahbsi, ahbso, 
    		irqi(i), irqo(i), dbgi(i), dbgo(i), clkm,  fpi(i), fpo(i));

      end generate;
      l3s : if CFG_LEON3FT_EN = 0 generate
        u0 : leon3sh 		-- LEON3 processor
        generic map (i, fabtech, memtech, CFG_NWIN, CFG_DSU, CFG_FPU, CFG_V8,
	  0, CFG_MAC, pclow, CFG_NOTAG, CFG_NWP, CFG_ICEN, CFG_IREPL, CFG_ISETS, CFG_ILINE,
	  CFG_ISETSZ, CFG_ILOCK, CFG_DCEN, CFG_DREPL, CFG_DSETS, CFG_DLINE, CFG_DSETSZ,
	  CFG_DLOCK, CFG_DSNOOP, CFG_ILRAMEN, CFG_ILRAMSZ, CFG_ILRAMADDR, CFG_DLRAMEN,
          CFG_DLRAMSZ, CFG_DLRAMADDR, CFG_MMUEN, CFG_ITLBNUM, CFG_DTLBNUM, CFG_TLB_TYPE, CFG_TLB_REP,
          CFG_LDDEL, disas, CFG_ITBSZ, CFG_PWD, CFG_SVT, CFG_RSTADDR, CFG_NCPU-1,
	  CFG_DFIXED, CFG_SCAN, CFG_MMU_PAGE)
        port map (clkm, rstn, ahbmi, ahbmo(i), ahbsi, ahbso,
    		irqi(i), irqo(i), dbgi(i), dbgo(i), fpi(i), fpo(i));
      end generate;
    end generate;

    grfpush0 : grfpushwx generic map ((CFG_FPU-1), CFG_NCPU, fabtech)
    port map (clkm, rstn, fpi, fpo);

  end generate;

  led1_pad : odpad generic map (tech => padtech) port map (led(1), dbgo(0).error);
    
  dsugen : if CFG_DSU = 1 generate
      dsu0 : dsu3         -- LEON3 Debug Support Unit
      generic map (hindex => 2, haddr => 16#900#, hmask => 16#F00#, 
         ncpu => CFG_NCPU, tbits => 30, tech => memtech, irq => 0, kbytes => CFG_ATBSZ)
      port map (rstn, clkm, ahbmi, ahbsi, ahbso(2), dbgo, dbgi, dsui, dsuo);
      dsuen_pad : inpad generic map (tech => padtech) port map (switch(7), dsui.enable); 
      dsubre_pad : inpad generic map (tech => padtech) port map (switch(8), dsui.break); 
      dsuact_pad : outpad generic map (tech => padtech) port map (led(0), ndsuact);
      ndsuact <= not dsuo.active;
  end generate;

  nodsu : if CFG_DSU = 0 generate 
    dsuo.tstop <= '0'; dsuo.active <= '0'; ahbso(2) <= ahbs_none;
  end generate;

  dcomgen : if CFG_AHB_UART = 1 generate
    dcom0: ahbuart      -- Debug UART
    generic map (hindex => CFG_NCPU, pindex => 7, paddr => 7)
    port map (rstn, clkm, dui, duo, apbi, apbo(7), ahbmi, ahbmo(CFG_NCPU));
    dsurx_pad : inpad generic map (tech => padtech) port map (rxd2, dui.rxd); 
    dsutx_pad : outpad generic map (tech => padtech) port map (txd2, duo.txd);
  end generate;
  nouah : if CFG_AHB_UART = 0 generate apbo(7) <= apb_none; end generate;

  ahbjtaggen0 :if CFG_AHB_JTAG = 1 generate
    ahbjtag0 : ahbjtag generic map(tech => fabtech, hindex => CFG_NCPU+CFG_AHB_UART)
      port map(rstn, clkm, tck, tms, tdi, tdo, ahbmi, ahbmo(CFG_NCPU+CFG_AHB_UART),
               open, open, open, open, open, open, open, gnd);
  end generate;
  
----------------------------------------------------------------------
---  Memory controllers ----------------------------------------------
----------------------------------------------------------------------

  memi.writen <= '1'; memi.wrn <= "1111"; memi.bwidth <= "00";
  memi.brdyn <= '0'; memi.bexcn <= '1';

  mctrl0 : mctrl generic map (hindex => 0, pindex => 0,
   paddr => 0, srbanks => 2, ram8 => CFG_MCTRL_RAM8BIT, 
   ram16 => CFG_MCTRL_RAM16BIT, sden => CFG_MCTRL_SDEN, 
   invclk => CFG_CLK_NOFB, sepbus => CFG_MCTRL_SEPBUS,
   pageburst => CFG_MCTRL_PAGE, rammask => 0, iomask => 0)
  port map (rstn, clkm, memi, memo, ahbsi, ahbso(0), apbi, apbo(0), wpo, sdo);

  addr_pad : outpadv generic map (width => 25, tech => padtech) 
   port map (address, memo.address(24 downto 0)); 
  roms_pad : outpad generic map (tech => padtech) 
   port map (romsn, memo.romsn(0)); 
  oen_pad  : outpad generic map (tech => padtech) 
   port map (oen, memo.oen);
  wri_pad  : outpad generic map (tech => padtech) 
   port map (writen, memo.writen);
  bdr : for i in 0 to 0 generate
      data_pad : iopadv generic map (tech => padtech, width => 8)
      port map (data(31-i*8 downto 24-i*8), memo.data(31-i*8 downto 24-i*8),
   memo.bdrive(i), memi.data(31-i*8 downto 24-i*8));
  end generate;

-----------------------------------------------------------------------
---  Test report module  ----------------------------------------------
-----------------------------------------------------------------------

-- pragma translate_off

  test0 : ahbrep generic map (hindex => 6, haddr => 16#200#)
	port map (rstn, clkm, ahbsi, ahbso(6));

-- pragma translate_on

----------------------------------------------------------------------
---  DDR2 memory controller ------------------------------------------
----------------------------------------------------------------------
  
  mig_gen : if (CFG_MIG_DDR2 = 1) generate 
    ddrc : entity work.ahb2mig_grxc6s_2p generic map( 
	hindex => 4, haddr => 16#400#, hmask => 16#F80#, 
	pindex => 0, paddr => 0,
	vgamst => CFG_SVGA_ENABLE, vgaburst => 64)  
    port map(
   	mcb3_dram_dq  	=> ddr_dq,
   	mcb3_dram_a	=> ddr_ad,
   	mcb3_dram_ba  	=> ddr_ba,
   	mcb3_dram_ras_n	=> ddr_ras,
   	mcb3_dram_cas_n	=> ddr_cas,
   	mcb3_dram_we_n	=> ddr_we,
   	mcb3_dram_odt	=> ddr_odt,
   	mcb3_dram_cke	=> ddr_cke,
   	mcb3_dram_dm	=> ddr_dm(0),
   	mcb3_dram_udqs	=> ddr_dqs(1),
   	mcb3_rzq	=> ddr_rzq,
   	mcb3_zio	=> ddr_zio,
   	mcb3_dram_udm	=> ddr_dm(1),
	mcb3_dram_dqs	=> ddr_dqs(0),
   	mcb3_dram_ck	=> ddr_clk,
   	mcb3_dram_ck_n	=> ddr_clkb,
	ahbsi		=> ahbsi,
	ahbso		=> ahbso(4),
	ahbmi		=> vahbmi,
	ahbmo		=> vahbmo,
	apbi 		=> apbi2,
	apbo 		=> apbo2(0),
	calib_done	=> calib_done,
	rst_n_syn	=> rstn,
	rst_n_async	=> rstraw,  
	clk_amba	=> clkm,
	clk_mem_n	=> ddr2clk,
	clk_mem_p	=> ddr2clk,
	test_error	=> open
	);
  end generate;

  noddr : if (CFG_DDR2SP+CFG_MIG_DDR2) = 0 generate lock <= '1'; end generate;

----------------------------------------------------------------------
---  SPI Memory Controller--------------------------------------------
----------------------------------------------------------------------

  spimc: if CFG_SPICTRL_ENABLE = 0 and CFG_SPIMCTRL = 1 generate
    spimctrl0 : spimctrl        -- SPI Memory Controller
      generic map (hindex => 3, hirq => 11, faddr => 16#e00#, fmask => 16#ff8#,
                   ioaddr => 16#002#, iomask => 16#fff#,
                   spliten => CFG_SPLIT, oepol  => 0,
                   sdcard => CFG_SPIMCTRL_SDCARD,
                   readcmd => CFG_SPIMCTRL_READCMD,
                   dummybyte => CFG_SPIMCTRL_DUMMYBYTE,
                   dualoutput => CFG_SPIMCTRL_DUALOUTPUT,
                   scaler => CFG_SPIMCTRL_SCALER,
                   altscaler => CFG_SPIMCTRL_ASCALER,
                   pwrupcnt => CFG_SPIMCTRL_PWRUPCNT)
      port map (rstn, clkm, ahbsi, ahbso(3), spmi, spmo); 
	  

    -- MISO is shared with Flash data 0
    spmi.miso <= memi.data(24);
    mosi_pad : outpad generic map (tech => padtech)
      port map (spi_mosi, spmo.mosi);
    sck_pad  : outpad generic map (tech => padtech)
      port map (spi_clk, spmo.sck);
    slvsel0_pad : odpad generic map (tech => padtech)
      port map (spi_sel_n, spmo.csn);  
  end generate;

----------------------------------------------------------------------
---  APB Bridge and various periherals -------------------------------
----------------------------------------------------------------------

  apb0 : apbctrl            -- AHB/APB bridge
  generic map (hindex => 1, haddr => CFG_APBADDR, nslaves => 16)
  port map (rstn, clkm, ahbsi, ahbso(1), apbi, apbo );

  apb1 : apbctrl            -- AHB/APB bridge
  generic map (hindex => 13, haddr => CFG_APBADDR+1, nslaves => 16)
  port map (rstn, clkm, ahbsi, ahbso(13), apbi2, apbo2 );

  ua1 : if CFG_UART1_ENABLE /= 0 generate
    uart1 : apbuart         -- UART 1
    generic map (pindex => 1, paddr => 1,  pirq => 2, console => dbguart,
   fifosize => CFG_UART1_FIFO)
    port map (rstn, clkm, apbi, apbo(1), u1i, u1o);
    u1i.extclk <= '0';
    rxd1_pad : inpad generic map (tech => padtech) port map (rxd1, u1i.rxd); 
    txd1_pad : outpad generic map (tech => padtech) port map (txd1, u1o.txd);
    cts1_pad : inpad generic map (tech => padtech) port map (ctsn1, u1i.ctsn); 
    rts1_pad : outpad generic map (tech => padtech) port map (rtsn1, u1o.rtsn);
  end generate;
  noua0 : if CFG_UART1_ENABLE = 0 generate apbo(1) <= apb_none; end generate;

  irqctrl : if CFG_IRQ3_ENABLE /= 0 generate
    irqctrl0 : irqmp         -- interrupt controller
    generic map (pindex => 2, paddr => 2, ncpu => CFG_NCPU)
    port map (rstn, clkm, apbi, apbo(2), irqo, irqi);
  end generate;
  irq3 : if CFG_IRQ3_ENABLE = 0 generate
    x : for i in 0 to CFG_NCPU-1 generate
      irqi(i).irl <= "0000";
    end generate;
    apbo(2) <= apb_none;
  end generate;

  gpt : if CFG_GPT_ENABLE /= 0 generate
    timer0 : gptimer          -- timer unit
    generic map (pindex => 3, paddr => 3, pirq => CFG_GPT_IRQ, 
   sepirq => CFG_GPT_SEPIRQ, sbits => CFG_GPT_SW, ntimers => CFG_GPT_NTIM, 
   nbits => CFG_GPT_TW, wdog => CFG_GPT_WDOGEN*CFG_GPT_WDOG)
    port map (rstn, clkm, apbi, apbo(3), gpti, gpto);
    gpti.dhalt <= dsuo.tstop; gpti.extclk <= '0';
  end generate;
  wden : if CFG_GPT_WDOGEN /= 0 generate
    wdogl <= gpto.wdogn or not rstn;
    wdogn_pad : odpad generic map (tech => padtech) port map (wdogn, wdogl);
  end generate;
  wddis : if CFG_GPT_WDOGEN = 0 generate
    wdogn_pad : odpad generic map (tech => padtech) port map (wdogn, vcc);
  end generate;

  nogpt : if CFG_GPT_ENABLE = 0 generate apbo(3) <= apb_none; end generate;

  kbd : if CFG_KBD_ENABLE /= 0 generate
    ps21 : apbps2 generic map(pindex => 4, paddr => 4, pirq => 4)
      port map(rstn, clkm, apbi, apbo(4), moui, mouo);
    ps20 : apbps2 generic map(pindex => 5, paddr => 5, pirq => 5)
      port map(rstn, clkm, apbi, apbo(5), kbdi, kbdo);
  end generate;
  nokbd : if CFG_KBD_ENABLE = 0 generate 
   apbo(4) <= apb_none; mouo <= ps2o_none;
   apbo(5) <= apb_none; kbdo <= ps2o_none;
  end generate;
  kbdclk_pad : iopad generic map (tech => padtech)
      port map (ps2clk(1),kbdo.ps2_clk_o, kbdo.ps2_clk_oe, kbdi.ps2_clk_i);
  kbdata_pad : iopad generic map (tech => padtech)
        port map (ps2data(1), kbdo.ps2_data_o, kbdo.ps2_data_oe, kbdi.ps2_data_i);
  mouclk_pad : iopad generic map (tech => padtech)
      port map (ps2clk(0),mouo.ps2_clk_o, mouo.ps2_clk_oe, moui.ps2_clk_i);
  mouata_pad : iopad generic map (tech => padtech)
        port map (ps2data(0), mouo.ps2_data_o, mouo.ps2_data_oe, moui.ps2_data_i);

  vga : if CFG_VGA_ENABLE /= 0 generate
    vga0 : apbvga generic map(memtech => memtech, pindex => 6, paddr => 6)
       port map(rstn, clkm, ethclk, apbi, apbo(6), vgao);
    video_clk <= not ethclk;
   end generate;
  
  svga : if CFG_SVGA_ENABLE /= 0 generate
    svga0 : svgactrl generic map(memtech => memtech, pindex => 6, paddr => 6,
        hindex => CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG, 
   	clk0 => 20000, clk1 => 0, --1000000000/((BOARD_FREQ * CFG_CLKMUL)/CFG_CLKDIV),
	clk2 => 0, clk3 => 0, burstlen => 6)
       port map(rstn, clkm, video_clk, apbi, apbo(6), vgao, vahbmi, 
      vahbmo, clk_sel);
  end generate;
  
  vgadvi : if (CFG_VGA_ENABLE + CFG_SVGA_ENABLE) /= 0 generate 
    b0 : techbuf generic map (2, fabtech) port map (clk50, video_clk);
    dvi0 : entity work.svga2ch7301c generic map (tech => fabtech, dynamic => 1)
      port map (clkm, vgao, video_clk, clkvga_p, clkvga_n, 
                lcd_datal, lcd_hsyncl, lcd_vsyncl, lcd_del);
    i2cdvi : i2cmst
      generic map (pindex => 9, paddr => 9, pmask => 16#FFF#, pirq => 14)
      port map (rstn, clkm, apbi, apbo(9), dvi_i2ci, dvi_i2co);
  end generate;

  novga : if (CFG_VGA_ENABLE = 0 and CFG_SVGA_ENABLE = 0) generate
    apbo(6) <= apb_none; vgao <= vgao_none;
    video_clk <= clk50;
  end generate;
  
  tft_lcd_data_pad : outpadv generic map (width => 12, tech => padtech)
        port map (tft_lcd_data, lcd_datal);
  tft_lcd_clkp_pad : outpad generic map (tech => padtech)
    port map (tft_lcd_clk_p, clkvga_p);
  tft_lcd_clkn_pad : outpad generic map (tech => padtech)
    port map (tft_lcd_clk_n, clkvga_n);
  tft_lcd_hsync_pad : outpad generic map (tech => padtech)
    port map (tft_lcd_hsync, lcd_hsyncl);
  tft_lcd_vsync_pad : outpad generic map (tech => padtech)
    port map (tft_lcd_vsync, lcd_vsyncl);
  tft_lcd_de_pad : outpad generic map (tech => padtech)
    port map (tft_lcd_de, lcd_del);
  tft_lcd_reset_pad : outpad generic map (tech => padtech)
    port map (tft_lcd_reset_b, rstn);
  dvi_i2c_scl_pad : iopad generic map (tech => padtech)
    port map (dvi_iic_scl, dvi_i2co.scl, dvi_i2co.scloen, dvi_i2ci.scl);
  dvi_i2c_sda_pad : iopad generic map (tech => padtech)
    port map (dvi_iic_sda, dvi_i2co.sda, dvi_i2co.sdaoen, dvi_i2ci.sda);
  
  gpio0 : if CFG_GRGPIO_ENABLE /= 0 generate     -- GPIO unit
    grgpio0: grgpio
    generic map(pindex => 10, paddr => 10, imask => CFG_GRGPIO_IMASK, nbits => 16)
    port map(rst => rstn, clk => clkm, apbi => apbi, apbo => apbo(10),
    gpioi => gpioi, gpioo => gpioo);
    p0 : if (CFG_CAN = 0) or (CFG_CAN_NUM = 1) generate
      pio_pads : for i in 1 to 2 generate
        pio_pad : iopad generic map (tech => padtech)
            port map (pio(i), gpioo.dout(i), gpioo.oen(i), gpioi.din(i));
      end generate;
    end generate;
    p1 : if (CFG_CAN = 0) generate
      pio_pads : for i in 4 to 5 generate
        pio_pad : iopad generic map (tech => padtech)
            port map (pio(i), gpioo.dout(i), gpioo.oen(i), gpioi.din(i));
      end generate;
    end generate;
    pio_pad0 : iopad generic map (tech => padtech)
            port map (pio(0), gpioo.dout(0), gpioo.oen(0), gpioi.din(0));
    pio_pad1 : iopad generic map (tech => padtech)
            port map (pio(3), gpioo.dout(3), gpioo.oen(3), gpioi.din(3));
    pio_pads : for i in 6 to 15 generate
        pio_pad : iopad generic map (tech => padtech)
            port map (pio(i), gpioo.dout(i), gpioo.oen(i), gpioi.din(i));
    end generate;
  end generate;	
  
  
  -- make an additonal 32 bit GPIO port for genio(31..0)
  -- Pins only usable if ATA interface is not enabled. 
  
  gpio1 : if CFG_ATA /=1 and CFG_GRGPIO_ENABLE /= 0 generate     -- GPIO unit
    grgpio1: grgpio
    generic map(pindex => 11, paddr => 11, imask => CFG_GRGPIO_IMASK, nbits => 32)
    port map(rst => rstn, clk => clkm, apbi => apbi, apbo => apbo(11),
    gpioi => gpioi2, gpioo => gpioo2);
        pio_pads : for i in 0 to 31 generate
        pio_pad : iopad generic map (tech => padtech)
            port map (genio(i), gpioo2.dout(i), gpioo2.oen(i), gpioi2.din(i));
    end generate;

  end generate;
  
  
   -- make an additonal 28 bit GPIO port for genio(59..32) 
  -- Pins only usable if ATA interface is not enabled.  
 
   gpio2 : if CFG_ATA /=1 and CFG_GRGPIO_ENABLE /= 0 generate     -- GPIO unit
    grgpio2: grgpio
    generic map(pindex => 12, paddr => 12, imask => CFG_GRGPIO_IMASK, nbits => 28)
    port map(rst => rstn, clk => clkm, apbi => apbi, apbo => apbo(12),
    gpioi => gpioi3, gpioo => gpioo3);
        pio_pads : for i in 0 to 27 generate
        pio_pad : iopad generic map (tech => padtech)
            port map (genio(i+32), gpioo3.dout(i), gpioo3.oen(i), gpioi3.din(i));
    end generate;

  end generate;
  
  ahbs : if CFG_AHBSTAT = 1 generate   -- AHB status register
    ahbstat0 : ahbstat generic map (pindex => 15, paddr => 15, pirq => 7,
   nftslv => CFG_AHBSTATN)
      port map (rstn, clkm, ahbmi, ahbsi, stati, apbi, apbo(15));
  end generate;

-----------------------------------------------------------------------
---  ETHERNET ---------------------------------------------------------
-----------------------------------------------------------------------

    eth0 : if CFG_GRETH = 1 generate -- Gaisler ethernet MAC
      e1 : grethm generic map(
   hindex => CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG, 
   pindex => 14, paddr => 14, pirq => 12, memtech => memtech,
        mdcscaler => CPU_FREQ/1000, rmii => 0, enable_mdio => 1, fifosize => CFG_ETH_FIFO,
        nsync => 1, edcl => CFG_DSU_ETH, edclbufsz => CFG_ETH_BUF, phyrstadr => 1,
        macaddrh => CFG_ETH_ENM, macaddrl => CFG_ETH_ENL, enable_mdint => 1,
	ipaddrh => CFG_ETH_IPM, ipaddrl => CFG_ETH_IPL,
	giga => CFG_GRETH1G)
      port map( rst => rstn, clk => clkm, ahbmi => ahbmi,
        ahbmo => ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG), 
   apbi => apbi, apbo => apbo(14), ethi => gmiii, etho => gmiio); 
    end generate;

    rgmii0 : entity work.rgmii generic map (fabtech, 2, CFG_GRETH1G, 0)
      port map (rstn, lclk, rgmii_lock, gmiii, gmiio, rgmiii, rgmiio);

    ethpads : if (CFG_GRETH = 1) generate -- eth pads
      emdio_pad : iopad generic map (tech => padtech) 
        port map (emdio, rgmiio.mdio_o, rgmiio.mdio_oe, rgmiii.mdio_i);
      etxc_pad : outpad generic map (tech => padtech) 
   	port map (etx_clk, rgmiio.tx_er);
      erxc_pad : inpad generic map (tech => padtech) 
   	port map (erx_clk, rgmiii.rx_clk);
      erxd_pad : inpadv generic map (tech => padtech, width => 4) 
   	port map (erxd, rgmiii.rxd(3 downto 0));
      erxdv_pad : inpad generic map (tech => padtech) 
   	port map (erx_dv, rgmiii.rx_dv);
      emdint_pad : inpad generic map (tech => padtech) 
   	port map (emdint, rgmiii.mdint);

      etxd_pad : outpadv generic map (tech => padtech, width => 4) 
   	port map (etxd, rgmiio.txd(3 downto 0));
      etxen_pad : outpad generic map (tech => padtech) 
   	port map ( etx_en, rgmiio.tx_en);
      emdc_pad : outpad generic map (tech => padtech) 
   	port map (emdc, rgmiio.mdc);
    end generate;

-----------------------------------------------------------------------
---  AHB RAM ----------------------------------------------------------
-----------------------------------------------------------------------

  ocram : if CFG_AHBRAMEN = 1 generate 
    ahbram0 : ahbram generic map (hindex => 7, haddr => CFG_AHBRADDR, 
   tech => CFG_MEMTECH, kbytes => CFG_AHBRSZ)
    port map ( rstn, clkm, ahbsi, ahbso(7));
  end generate;

-----------------------------------------------------------------------
---  Multi-core CAN ---------------------------------------------------
-----------------------------------------------------------------------

   can0 : if CFG_CAN = 1 generate 
     can0 : can_mc generic map (slvndx => 4, ioaddr => CFG_CANIO,
       iomask => 16#FF0#, irq => CFG_CANIRQ, memtech => memtech,
   ncores => CFG_CAN_NUM, sepirq => CFG_CANSEPIRQ)
      port map (rstn, clkm, ahbsi, ahbso(4), can_lrx, can_ltx );
      can_tx_pad1 : iopad generic map (tech => padtech)
            port map (pio(5), can_ltx(0), gnd, gpioi.din(5));
      can_rx_pad1 : iopad generic map (tech => padtech)
            port map (pio(4), gnd, vcc, can_lrx(0));
      canpas : if CFG_CAN_NUM = 2 generate 
        can_tx_pad2 : iopad generic map (tech => padtech)
            port map (pio(2), can_ltx(1), gnd, gpioi.din(2));
        can_rx_pad2 : iopad generic map (tech => padtech)
            port map (pio(1), gnd, vcc, can_lrx(1));
      end generate;
   end generate;

   -- standby controlled by pio(3) and pio(0)

-----------------------------------------------------------------------
---  SPACEWIRE  -------------------------------------------------------
-----------------------------------------------------------------------

-- temporary, just to make sure the SPW pins are instantiated correctly

  no_spw : if CFG_SPW_EN = 0 generate
  pad_gen: for i in 0 to CFG_SPW_NUM-1 generate
   spw_rxd_pad : inpad_ds generic map (padtech, lvds, x33v)
         port map (spw_rxdp(i), spw_rxdn(i), dtmp(i));
       spw_rxs_pad : inpad_ds generic map (padtech, lvds, x33v)
         port map (spw_rxsp(i), spw_rxsn(i), stmp(i));
       spw_txd_pad : outpad_ds generic map (padtech, lvds, x33v)
         port map (spw_txdp(i), spw_txdn(i), dtmp(i), gnd);
       spw_txs_pad : outpad_ds generic map (padtech, lvds, x33v)
         port map (spw_txsp(i), spw_txsn(i), stmp(i), gnd);
    end generate;
  end generate;
	


  spw : if CFG_SPW_EN > 0 generate
  
    core0: if CFG_SPW_GRSPW = 1 generate
      spw_clkl <= clkm;
    end generate;
    
    core1 : if CFG_SPW_GRSPW = 2 generate
--      cgi2.pllctrl <= "00"; cgi2.pllrst <= rstraw;
--      clkgen_spw_rx : clkgen        -- clock generator
--      generic map (clktech, 4, 2, 0, 1, 0, 0, 0, 50000)
--      port map (lclk, lclk, spw_clkl, spw_clkln, open, open, open, cgi2, cgo2, open, open);
--      x0 : techbuf generic map( tech => padtech, buftype => 2)
--      port map (clk100, spw100);
      spw100 <= clk100;
      spw_clkl <= spw100; spw_clkln <= not spw100;
    end generate;
        
    swloop : for i in 0 to CFG_SPW_NUM-1 generate
      core1 : if CFG_SPW_GRSPW = 2 generate
        spw_phy0 : grspw2_phy 
          generic map(
            scantest   => 0,
            tech       => memtech,
            input_type => CFG_SPW_INPUT)
          port map(
            rstn       => rstn,
            rxclki     => spw_clkl,
            rxclkin    => spw_clkln,
            nrxclki    => spw_clkl,
            di         => dtmp(i),
            si         => stmp(i),
            do         => spwi(i).d(1 downto 0),
            dov        => spwi(i).dv(1 downto 0),
            dconnect   => spwi(i).dconnect(1 downto 0),
            rxclko     => rxclko(i));
      end generate;

      sw0 : grspwm generic map(tech => memtech,
        hindex => CFG_NCPU+CFG_AHB_UART+CFG_GRETH+CFG_AHB_JTAG+i,
        sysfreq => CPU_FREQ, usegen => 1,
        pindex => 10+i, paddr => 10+i, pirq => 10+i, 
        nsync => 1, rmap => CFG_SPW_RMAP, rxunaligned => CFG_SPW_RXUNAL,
        rmapcrc => CFG_SPW_RMAPCRC, fifosize1 => CFG_SPW_AHBFIFO, 
        fifosize2 => CFG_SPW_RXFIFO, rxclkbuftype => 2, dmachan => CFG_SPW_DMACHAN,
        rmapbufs => CFG_SPW_RMAPBUF, ft => CFG_SPW_FT, ports => CFG_SPW_PORTS,
        spwcore => CFG_SPW_GRSPW, netlist => CFG_SPW_NETLIST,
        rxtx_sameclk => CFG_SPW_RTSAME, input_type => CFG_SPW_INPUT,
        output_type => CFG_SPW_OUTPUT)
      port map(rstn, clkm, rxclko(i), rxclko(i), spw_clkl, spw_clkl, ahbmi,
        ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_GRETH+CFG_AHB_JTAG+i), 
        apbi2, apbo2(10+i), spwi(i), spwo(i));
      spwi(i).tickin <= '0'; spwi(i).rmapen <= '1';
      spwi(i).clkdiv10 <= conv_std_logic_vector(CPU_FREQ/10000-1, 8) when CFG_SPW_GRSPW = 1
   	else conv_std_logic_vector(10-1, 8);

      spwlb0 : if SPW_LOOP_BACK = 1 generate
        core0 : if CFG_SPW_GRSPW = 1 generate
          spwi(i).d(0) <= spwo(i).d(0); spwi(i).s(0) <= spwo(i).s(0);
        end generate;
        core1 : if CFG_SPW_GRSPW = 2 generate
          dtmp(i) <= spwo(i).d(0); stmp(i) <= spwo(i).s(0);
        end generate;
      end generate;
      
      nospwlb0 : if SPW_LOOP_BACK = 0 generate
        core0 : if CFG_SPW_GRSPW = 1 generate
          spwi(i).d(0) <= dtmp(i); spwi(i).s(0) <= stmp(i);
        end generate;  	  
	   
        spw_rxd_pad : inpad_ds generic map (padtech, lvds, x33v, 1)
          port map (spw_rxdp(i), spw_rxdn(i), dtmp(i));
        spw_rxs_pad : inpad_ds generic map (padtech, lvds, x33v, 1)
          port map (spw_rxsp(i), spw_rxsn(i), stmp(i));
        spw_txd_pad : outpad_ds generic map (padtech, lvds, x33v)
          port map (spw_txdp(i), spw_txdn(i), spwo(i).d(0), gnd);
        spw_txs_pad : outpad_ds generic map (padtech, lvds, x33v)
          port map (spw_txsp(i), spw_txsn(i), spwo(i).s(0), gnd);
      end generate;
    end generate;
  end generate;

-------------------------------------------------------------------------------
-- USB ------------------------------------------------------------------------
-------------------------------------------------------------------------------
  -- Note that more than one USB component can not be instantiated at the same
  -- time (board has only one USB transceiver), therefore they share AHB
  -- master/slave indexes
  -----------------------------------------------------------------------------
  -- Shared pads
  -----------------------------------------------------------------------------
  usbpads: if (CFG_GRUSBHC + CFG_GRUSBDC + CFG_GRUSB_DCL) /= 0 generate
    -- Incoming 60 MHz clock from transceiver, arch 3 = through BUFGDLL or
    -- similiar.
--    usb_clkout_pad : clkpad generic map (tech => padtech, arch => 3) port map (usb_clk, uclk, cgo.clklock, ulock);
--    usb_clkout_pad : clkpad generic map (tech => padtech, arch => 0) port map (usb_clk, lusb_clk);
    usb_clk_pad : clkpad generic map (tech => padtech, arch => 0) port map (usb_clk, uclk);

--    x0 : clkmul_virtex2 port map (rstn, lusb_clk, uclk, ulock);

    usb_d_pad: iopadv
      generic map(tech => padtech, width => 8)
      port map (usb_d, usbo(0).dataout(7 downto 0), usbo(0).oen,
                usbi(0).datain(7 downto 0));
    usb_nxt_pad : inpad generic map (tech => padtech)
      port map (usb_nxt, usbi(0).nxt);
    usb_dir_pad : inpad generic map (tech => padtech)
      port map (usb_dir, usbi(0).dir);
    usb_resetn_pad : outpad generic map (tech => padtech, slew => 1)
      port map (usb_resetn, usbo(0).reset);
    usb_stp_pad : outpad generic map (tech => padtech, slew => 1)
      port map (usb_stp, usbo(0).stp);
  end generate usbpads;
  nousb: if (CFG_GRUSBHC + CFG_GRUSBDC + CFG_GRUSB_DCL) = 0 generate
    ulock <= '1';
  end generate nousb;
  
  -----------------------------------------------------------------------------
  -- USB 2.0 Host Controller
  -----------------------------------------------------------------------------
  usbhc0: if CFG_GRUSBHC = 1 generate
    usbhc0 : grusbhc
      generic map (
 --       ehchindex => CFG_NCPU+CFG_AHB_UART+log2x(CFG_PCI)+CFG_AHB_JTAG+CFG_GRETH+CFG_SPW_EN*CFG_SPW_NUM,
        ehchindex => CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_GRETH+CFG_SPW_EN*CFG_SPW_NUM,
        ehcpindex => 13, ehcpaddr => 13, ehcpirq => 13, ehcpmask => 16#fff#,
 --       uhchindex => CFG_NCPU+CFG_AHB_UART+log2x(CFG_PCI)+CFG_AHB_JTAG+CFG_GRETH+CFG_SPW_EN*CFG_SPW_NUM+1,
        uhchindex => CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_GRETH+CFG_SPW_EN*CFG_SPW_NUM+1,
        uhchsindex => 8, uhchaddr => 16#A00#, uhchmask => 16#fff#, uhchirq => 9, tech => fabtech,
        memtech => memtech, ehcgen => CFG_GRUSBHC_EHC, uhcgen => CFG_GRUSBHC_UHC,
        endian_conv => CFG_GRUSBHC_ENDIAN, be_regs => CFG_GRUSBHC_BEREGS,
        be_desc => CFG_GRUSBHC_BEDESC, uhcblo => CFG_GRUSBHC_BLO,
        bwrd => CFG_GRUSBHC_BWRD, vbusconf => CFG_GRUSBHC_VBUSCONF)
      port map (
        clkm,uclk,rstn,apbi,apbo(13),ahbmi,ahbsi,
        ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_GRETH+CFG_SPW_EN*CFG_SPW_NUM),
        ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_GRETH+CFG_SPW_EN*CFG_SPW_NUM+1
 --       ahbmo(CFG_NCPU+CFG_AHB_UART+log2x(CFG_PCI)+CFG_AHB_JTAG+CFG_GRETH+CFG_SPW_EN*CFG_SPW_NUM),
--        ahbmo(CFG_NCPU+CFG_AHB_UART+log2x(CFG_PCI)+CFG_AHB_JTAG+CFG_GRETH+CFG_SPW_EN*CFG_SPW_NUM+1
              downto
 --             CFG_NCPU+CFG_AHB_UART+log2x(CFG_PCI)+CFG_AHB_JTAG+CFG_GRETH+CFG_SPW_EN*CFG_SPW_NUM+1),
              CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_GRETH+CFG_SPW_EN*CFG_SPW_NUM+1),
        ahbso(8 downto 8),
        usbo,usbi);    
  end generate usbhc0;

  -----------------------------------------------------------------------------
  -- USB 2.0 Device Controller
  -----------------------------------------------------------------------------
  usbdc0: if CFG_GRUSBDC = 1 generate
    usbdc0: grusbdc
      generic map(
        hsindex => 8, hirq => 9, haddr => 16#004#, hmask => 16#FFC#,        
 --       hmindex => CFG_NCPU+CFG_AHB_UART+log2x(CFG_PCI)+CFG_AHB_JTAG+CFG_GRETH+CFG_SPW_EN*CFG_SPW_NUM,
       hmindex => CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_GRETH+CFG_SPW_EN*CFG_SPW_NUM,
        aiface => CFG_GRUSBDC_AIFACE, uiface => 1,
        nepi => CFG_GRUSBDC_NEPI, nepo => CFG_GRUSBDC_NEPO,
        i0 => CFG_GRUSBDC_I0, i1 => CFG_GRUSBDC_I1,
        i2 => CFG_GRUSBDC_I2, i3 => CFG_GRUSBDC_I3,
        i4 => CFG_GRUSBDC_I4, i5 => CFG_GRUSBDC_I5,
        i6 => CFG_GRUSBDC_I6, i7 => CFG_GRUSBDC_I7,
        i8 => CFG_GRUSBDC_I8, i9 => CFG_GRUSBDC_I9,
        i10 => CFG_GRUSBDC_I10, i11 => CFG_GRUSBDC_I11,
        i12 => CFG_GRUSBDC_I12, i13 => CFG_GRUSBDC_I13,
        i14 => CFG_GRUSBDC_I14, i15 => CFG_GRUSBDC_I15,
        o0 => CFG_GRUSBDC_O0, o1 => CFG_GRUSBDC_O1,
        o2 => CFG_GRUSBDC_O2, o3 => CFG_GRUSBDC_O3,
        o4 => CFG_GRUSBDC_O4, o5 => CFG_GRUSBDC_O5,
        o6 => CFG_GRUSBDC_O6, o7 => CFG_GRUSBDC_O7,
        o8 => CFG_GRUSBDC_O8, o9 => CFG_GRUSBDC_O9,
        o10 => CFG_GRUSBDC_O10, o11 => CFG_GRUSBDC_O11,
        o12 => CFG_GRUSBDC_O12, o13 => CFG_GRUSBDC_O13,
        o14 => CFG_GRUSBDC_O14, o15 => CFG_GRUSBDC_O15,
        memtech => memtech, keepclk => 1)
      port map(
        uclk  => uclk,
        usbi  => usbi(0),
        usbo  => usbo(0),
        hclk  => clkm,
        hrst  => rstn,
        ahbmi => ahbmi,
--        ahbmo => ahbmo(CFG_NCPU+CFG_AHB_UART+log2x(CFG_PCI)+CFG_AHB_JTAG+CFG_GRETH+CFG_SPW_EN*CFG_SPW_NUM),
        ahbmo => ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_GRETH+CFG_SPW_EN*CFG_SPW_NUM),
        ahbsi => ahbsi,
        ahbso => ahbso(8)
        );
  end generate usbdc0;

  -----------------------------------------------------------------------------
  -- USB DCL
  -----------------------------------------------------------------------------
  usb_dcl0: if CFG_GRUSB_DCL = 1 generate
    usb_dcl0: grusb_dcl
      generic map (
--        hindex => CFG_NCPU+CFG_AHB_UART+log2x(CFG_PCI)+CFG_AHB_JTAG+CFG_GRETH+CFG_SPW_EN*CFG_SPW_NUM,
        hindex => CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_GRETH+CFG_SPW_EN*CFG_SPW_NUM,
        memtech => memtech, keepclk => 1, uiface => 1)
      port map (
        uclk, usbi(0), usbo(0), clkm, rstn, ahbmi,
 --       ahbmo(CFG_NCPU+CFG_AHB_UART+log2x(CFG_PCI)+CFG_AHB_JTAG+CFG_GRETH+CFG_SPW_EN*CFG_SPW_NUM));
       ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_GRETH+CFG_SPW_EN*CFG_SPW_NUM));
  end generate usb_dcl0;
  
-----------------------------------------------------------------------
---  AHB ATA ----------------------------------------------------------
-----------------------------------------------------------------------

--   ata0 : if CFG_ATA = 1 generate
--     atac0 : atactrl
--       generic map(
--         tech => 0, fdepth => CFG_ATAFIFO,
--         mhindex => CFG_NCPU+CFG_AHB_UART+CFG_GRETH+CFG_AHB_JTAG+CFG_SVGA_ENABLE+
-- 		CFG_SPW_NUM*CFG_SPW_EN+CFG_GRUSB_DCL+CFG_GRUSBDC,
--         shindex => 3, haddr => 16--A00--, hmask => 16--fff--, pirq  => CFG_ATAIRQ,
--         mwdma => CFG_ATADMA, TWIDTH   => 8,
--         -- PIO mode 0 settings (@100MHz clock)
--         PIO_mode0_T1   => 6,   -- 70ns
--         PIO_mode0_T2   => 28,  -- 290ns
--         PIO_mode0_T4   => 2,   -- 30ns
--         PIO_mode0_Teoc => 23   -- 240ns ==> T0 - T1 - T2 = 600 - 70 - 290 = 240
--         )
--       port map(
--         rst => rstn, arst => vcc, clk => clkm, ahbmi => ahbmi,
--         ahbmo => ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_GRETH+CFG_AHB_JTAG+
--                        CFG_SVGA_ENABLE+CFG_SPW_NUM*CFG_SPW_EN+
--                        CFG_GRUSB_DCL+CFG_GRUSBDC),
--         ahbsi => ahbsi, ahbso => ahbso(11), atai => idei, atao => ideo);
--     
--     ata_rstn_pad : outpad generic map (tech => padtech)
--       port map (ata_rstn, ideo.rstn);
--     ata_data_pad : iopadv generic map (tech => padtech, width => 16, oepol => 1)
--       port map (ata_data, ideo.ddo, ideo.oen, idei.ddi);
--     ata_da_pad : outpadv generic map (tech => padtech, width => 3)
--       port map (ata_da, ideo.da);
--     ata_cs0_pad : outpad generic map (tech => padtech)
--       port map (ata_cs0, ideo.cs0);
--     ata_cs1_pad : outpad generic map (tech => padtech)
--       port map (ata_cs1, ideo.cs1);
--     ata_dior_pad : outpad generic map (tech => padtech)
--       port map (ata_dior, ideo.dior);
--     ata_diow_pad : outpad generic map (tech => padtech)
--       port map (ata_diow, ideo.diow);
--     iordy_pad : inpad generic map (tech => padtech)
--       port map (ata_iordy, idei.iordy);
--     intrq_pad : inpad generic map (tech => padtech)
--       port map (ata_intrq, idei.intrq);
--     dmarq_pad : inpad generic map (tech => padtech)
--       port map (ata_dmarq, idei.dmarq);
--     dmack_pad : outpad generic map (tech => padtech)
--       port map (ata_dmack, ideo.dmack);
--     ata_csel <= '0';
--   end generate;
 
 -----------------------------------------------------------------------
 ---  Drive unused bus elements  ---------------------------------------
 -----------------------------------------------------------------------
 
 --  nam1 : for i in (CFG_NCPU+CFG_AHB_UART+CFG_GRETH+CFG_AHB_JTAG) to NAHBMST-1 generate
 --    ahbmo(i) <= ahbm_none;
 --  end generate;
 --  nap0 : for i in 11 to NAPBSLV-1 generate apbo(i) <= apb_none; end generate;
 --  nah0 : for i in 8 to NAHBSLV-1 generate ahbso(i) <= ahbs_none; end generate;
 
 -----------------------------------------------------------------------
 ---  Boot message  ----------------------------------------------------
 -----------------------------------------------------------------------

 -- pragma translate_off
   x : report_version 
   generic map (
    msg1 => "LEON3 GR-XC6S-LX75 Demonstration design",
       msg2 => "GRLIB Version " & tost(LIBVHDL_VERSION/1000) & "." & tost((LIBVHDL_VERSION mod 1000)/100)
         & "." & tost(LIBVHDL_VERSION mod 100) & ", build " & tost(LIBVHDL_BUILD),
    msg3 => "Target technology: " & tech_table(fabtech) & ",  memory library: " & tech_table(memtech),
   mdel => 1
   );
 -- pragma translate_on
 end;
 
