
library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity top is
  port(
    clk   : in std_logic;
    reset : in std_logic);
end entity;

architecture rtl of top is

  component riscV_wishbone is

    generic (
      REGISTER_SIZE : integer := 32;
      RESET_VECTOR  : natural := 16#00000200#);

    port(
      clk   : in std_logic;
      reset : in std_logic;

      --conduit end point
      coe_to_host         : out std_logic_vector(REGISTER_SIZE -1 downto 0);
      coe_from_host       : in  std_logic_vector(REGISTER_SIZE -1 downto 0);
      coe_program_counter : out std_logic_vector(REGISTER_SIZE -1 downto 0);

      data_ADR_O : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      data_DAT_I : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
      data_DAT_O : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      data_WE_O  : out std_logic;
      data_SEL_O : out std_logic_vector(REGISTER_SIZE/8 -1 downto 0);
      data_STB_O : out std_logic;
      data_ACK_I : in  std_logic;
      data_CYC_O : out std_logic;

      instr_ADR_O : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      instr_DAT_I : in  std_logic_vector(REGISTER_SIZE-1 downto 0);
      instr_DAT_O : out std_logic_vector(REGISTER_SIZE-1 downto 0);
      instr_WE_O  : out std_logic;
      instr_SEL_O : out std_logic_vector(REGISTER_SIZE/8 -1 downto 0);
      instr_STB_O : out std_logic;
      instr_ACK_I : in  std_logic;
      instr_CYC_O : out std_logic
      );

  end component riscV_wishbone;

  component ram_wb
    generic(
      dat_width : integer;
      adr_width : integer;
      mem_size  : integer);
    port(
      dat_i : in  std_logic_vector(31 downto 0);
      dat_o : out std_logic_vector(31 downto 0);
      adr_i : in  std_logic_vector(adr_width-1 downto 0);
      we_i  : in  std_logic;
      sel_i : in  std_logic_vector(3 downto 0);
      cyc_i : in  std_logic;
      stb_i : in  std_logic;
      ack_o : out std_logic;
      cti_i : in  std_logic_vector(2 downto 0);

      clk_i : in std_logic;
      rst_i : in std_logic);
  end component;

  component wb_ebr_ctrl
    generic(
      SIZE             : integer := 4096;
      EBR_WB_DAT_WIDTH : integer := 32;
      INIT_FILE_FORMAT : string  := "hex";
      INIT_FILE_NAME   : string  := "none");
    port(
      CLK_I : in std_logic;
      RST_I : in std_logic;

      EBR_ADR_I  : in std_logic_vector(31 downto 0);
      EBR_DAT_I  : in std_logic_vector(EBR_WB_DAT_WIDTH-1 downto 0);
      EBR_WE_I   : in std_logic;
      EBR_CYC_I  : in std_logic;
      EBR_STB_I  : in std_logic;
      EBR_SEL_I  : in std_logic_vector(EBR_WB_DAT_WIDTH/8-1 downto 0);
      EBR_CTI_I  : in std_logic_vector(2 downto 0);
      EBR_BTE_I  : in std_logic_vector(1 downto 0);
      EBR_LOCK_I : in std_logic;

      EBR_DAT_O : out std_logic_vector(EBR_WB_DAT_WIDTH-1 downto 0);
      EBR_ACK_O : out std_logic;
      EBR_ERR_O : out std_logic;
      EBR_RTY_O : out std_logic);
  end component;

  constant REGISTER_SIZE : natural := 32;

  signal EBR_ADR_I  : std_logic_vector(31 downto 0);
  signal EBR_DAT_I  : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal EBR_WE_I   : std_logic;
  signal EBR_CYC_I  : std_logic;
  signal EBR_STB_I  : std_logic;
  signal EBR_SEL_I  : std_logic_vector(REGISTER_SIZE/8-1 downto 0);
  signal EBR_CTI_I  : std_logic_vector(2 downto 0);
  signal EBR_BTE_I  : std_logic_vector(1 downto 0);
  signal EBR_LOCK_I : std_logic;

  signal EBR_DAT_O : std_logic_vector(REGISTER_SIZE-1 downto 0);
  signal EBR_ACK_O : std_logic;
  signal EBR_ERR_O : std_logic;
  signal EBR_RTY_O : std_logic;


begin

  --mem : component ram_wb;
  --generic map(
  --  MEM_SIZE => 8*1024)
  --  port map(
  --    clk_i => clk,
  --    rst_i => reset,

  --    adr_i => EBR_ADR_I,
  --    dat_i => EBR_DAT_I,
  --    we_i  => EBR_WE_I,
  --    cyc_i => EBR_CYC_I,
  --    stb_i => EBR_STB_I,
  --    sel_i => EBR_SEL_I,
  --    cti_i => EBR_CTI_I,
  --    dat_o => EBR_DAT_O,
  --    ack_o => EBR_ACK_O,
  --    );

  mem : component wb_ebr_ctrl
    generic map(
      SIZE => 8*1024,
      INIT_FILE_FORMAT => "hex",
      INIT_FILE_NAME => "test.mem")
    port map(
      CLK_I => clk,
      RST_I => reset,

      EBR_ADR_I  => EBR_ADR_I,
      EBR_DAT_I  => EBR_DAT_I,
      EBR_WE_I   => EBR_WE_I,
      EBR_CYC_I  => EBR_CYC_I,
      EBR_STB_I  => EBR_STB_I,
      EBR_SEL_I  => EBR_SEL_I,
      EBR_CTI_I  => EBR_CTI_I,
      EBR_BTE_I  => EBR_BTE_I,
      EBR_LOCK_I => EBR_LOCK_I,

      EBR_DAT_O  => EBR_DAT_O,
      EBR_ACK_O  => EBR_ACK_O,
      EBR_ERR_O  => EBR_ERR_O,
      EBR_RTY_O  => EBR_RTY_O);




  rv : component riscV_wishbone
    port map(

      clk   => clk,
      reset => reset,

      --conduit end point
      -- coe_to_host         =>
      coe_from_host => (others => '0'),
      --  coe_program_counter =>

      -- data_ADR_O =>
      data_DAT_I => (others => '0'),
      -- data_DAT_O =>
      -- data_WE_O  =>
      -- data_SEL_O =>
      -- data_STB_O =>
      data_ACK_I => '0',
      -- data_CYC_O =>

      instr_ADR_O => EBR_ADR_I,
      instr_DAT_I => EBR_DAT_O,
      instr_DAT_O => EBR_DAT_I,
      instr_WE_O  => EBR_WE_I,
      instr_SEL_O => EBR_SEL_I,
      instr_STB_O => EBR_STB_I,
      instr_ACK_I => EBR_ACK_O,
      instr_CYC_O => EBR_CYC_I);

  EBR_LOCK_I <= '0';
  EBR_BTE_I  <= (others => '0');
      EBR_CTI_I <= (others => '0');

end architecture;