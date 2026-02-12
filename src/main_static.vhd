library ieee;
    use ieee.std_logic_1164.all;

entity main_static is
    -- Specializzazione componente immagine 32x32
    port (
        s_axis_clk      : in  std_logic;
        s_axis_rstn     : in  std_logic;

        s_axis_tvalid   : in  std_logic;
        s_axis_tlast    : in  std_logic;
        s_axis_tready   : out std_logic;
        s_axis_tuser    : in  std_logic;
        s_axis_tdata    : in  std_logic_vector(7 downto 0);

        m_axis_tvalid   : out std_logic;
        m_axis_tlast    : out std_logic;
        m_axis_tready   : in  std_logic;
        m_axis_tuser    : out std_logic;
        m_axis_tdata    : out std_logic_vector(8+4+4 downto 0)
    );
end entity main_static;

architecture Instantiation of main_static is
    -- Specificazione generic component per test post implementation
    constant ncol_img : integer := 32;
    constant nrow_img : integer := 32;

    constant kernel00 : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    constant kernel01 : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    constant kernel02 : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    constant kernel10 : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    constant kernel11 : STD_LOGIC_VECTOR(3 downto 0) := "0001";
    constant kernel12 : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    constant kernel20 : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    constant kernel21 : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    constant kernel22 : STD_LOGIC_VECTOR(3 downto 0) := "0000";

    -- Generic component
    component main is
        generic (
            ncol_img : integer := 32;
            nrow_img : integer := 32;

            kernel00 : STD_LOGIC_VECTOR(3 downto 0) := "0000";
            kernel01 : STD_LOGIC_VECTOR(3 downto 0) := "0000";
            kernel02 : STD_LOGIC_VECTOR(3 downto 0) := "0000";
            kernel10 : STD_LOGIC_VECTOR(3 downto 0) := "0000";
            kernel11 : STD_LOGIC_VECTOR(3 downto 0) := "0001";
            kernel12 : STD_LOGIC_VECTOR(3 downto 0) := "0000";
            kernel20 : STD_LOGIC_VECTOR(3 downto 0) := "0000";
            kernel21 : STD_LOGIC_VECTOR(3 downto 0) := "0000";
            kernel22 : STD_LOGIC_VECTOR(3 downto 0) := "0000"
        );
        port (
            s_axis_clk      : in  std_logic;
            s_axis_rstn     : in  std_logic;
            s_axis_tvalid   : in  std_logic;
            s_axis_tlast    : in  std_logic;
            s_axis_tready   : out std_logic;
            s_axis_tuser    : in  std_logic;
            s_axis_tdata    : in  std_logic_vector(7 downto 0);

            m_axis_tvalid   : out std_logic;
            m_axis_tlast    : out std_logic;
            m_axis_tready   : in  std_logic;
            m_axis_tuser    : out std_logic;
            m_axis_tdata    : out std_logic_vector(8+4+4 downto 0)
        );
    end component main;

begin
    -- Instantiation generic component
    generic_main: main
        generic map(
            ncol_img => ncol_img,
            nrow_img => nrow_img,

            kernel00 => kernel00,
            kernel01 => kernel01,
            kernel02 => kernel02,
            kernel10 => kernel10,
            kernel11 => kernel11,
            kernel12 => kernel12,
            kernel20 => kernel20,
            kernel21 => kernel21,
            kernel22 => kernel22
        )
        port map(
            s_axis_clk      => s_axis_clk,
            s_axis_rstn     => s_axis_rstn,

            s_axis_tvalid   => s_axis_tvalid,
            s_axis_tlast    => s_axis_tlast,
            s_axis_tready   => s_axis_tready,
            s_axis_tuser    => s_axis_tuser,
            s_axis_tdata    => s_axis_tdata,

            m_axis_tvalid   => m_axis_tvalid,
            m_axis_tlast    => m_axis_tlast,
            m_axis_tready   => m_axis_tready,
            m_axis_tuser    => m_axis_tuser,
            m_axis_tdata    => m_axis_tdata
        );

end architecture Instantiation;
