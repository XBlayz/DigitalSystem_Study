library ieee;
    use ieee.std_logic_1164.all;

entity main is
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
        s_axis_tlast    : in  std_logic; -- Input EOL
        s_axis_tready   : out std_logic;
        s_axis_tuser    : in  std_logic; -- Input SOF
        s_axis_tdata    : in  std_logic_vector(7 downto 0);

        m_axis_tvalid   : out std_logic;
        m_axis_tlast    : out std_logic; -- Output EOL
        m_axis_tready   : in  std_logic;
        m_axis_tuser    : out std_logic; -- Output SOF
        m_axis_tdata    : out std_logic_vector(8+4+4 downto 0) -- comp_i + coeff_f + 4
    );
end entity main;

architecture Structural of main is
    constant comp_i : POSITIVE := 8;
    constant coeff_f : POSITIVE := 4;
    constant n_adder : POSITIVE := comp_i+coeff_f;

    component buffer_line is
        generic(
            ncol : integer
        );
        port(
            clk   : in  std_logic;
            reset : in  std_logic;
            valid : in  std_logic;
            flush : in  std_logic;
            data  : in  std_logic_vector(7 downto 0);

            d00, d01, d02, d10, d11, d12, d20, d21, d22 : out std_logic_vector(7 downto 0)
        );
    end component buffer_line;

    component booth_multiplier is
        generic(
            componente_immagine : POSITIVE;
            coefficiente_filtro : POSITIVE;
            somma : POSITIVE
        );
        port (
            P_1_1, P_1_2, P_1_3 : in std_logic_vector(componente_immagine-1 downto 0);
            P_2_1, P_2_2, P_2_3 : in std_logic_vector(componente_immagine-1 downto 0);
            P_3_1, P_3_2, P_3_3 : in std_logic_vector(componente_immagine-1 downto 0);

            F_1_1, F_1_2, F_1_3 : in std_logic_vector(coefficiente_filtro-1 downto 0);
            F_2_1, F_2_2, F_2_3 : in std_logic_vector(coefficiente_filtro-1 downto 0);
            F_3_1, F_3_2, F_3_3 : in std_logic_vector(coefficiente_filtro-1 downto 0);

            M_1_1, M_1_2, M_1_3 : out std_logic_vector(somma-1 downto 0);
            M_2_1, M_2_2, M_2_3 : out std_logic_vector(somma-1 downto 0);
            M_3_1, M_3_2, M_3_3 : out std_logic_vector(somma-1 downto 0)
        );
    end component booth_multiplier;

    component carry_save_adder_tree is
        generic (N : POSITIVE := 12);

        port (
            i_1_1, i_1_2, i_1_3 : in  std_logic_vector(N-1 downto 0);
            i_2_1, i_2_2, i_2_3 : in  std_logic_vector(N-1 downto 0);
            i_3_1, i_3_2, i_3_3 : in  std_logic_vector(N-1 downto 0);
            sum                 : out std_logic_vector(N+4 downto 0)
        );
    end component carry_save_adder_tree;

    component state_machine is
        generic(
            ncol_img        : integer;
            nrow_img        : integer;
            kernel_row_size : integer
        );
        port(
            s_axis_clk      : in  std_logic;
            s_axis_rstn     : in  std_logic;

            s_axis_tvalid   : in  std_logic;
            s_axis_tready   : out std_logic;
            s_axis_tlast    : in  std_logic; -- Input EOL
            s_axis_tuser    : in  std_logic; -- Input SOF

            m_axis_tvalid   : out std_logic;
            m_axis_tready   : in  std_logic;
            m_axis_tlast    : out std_logic; -- Output EOL
            m_axis_tuser    : out std_logic; -- Output SOF

            pipeline_en     : out std_logic;
            window_valid    : out std_logic;
            flush_pipeline  : out std_logic
        );
    end component state_machine;

    signal s_pipeline_en    : std_logic;
    signal s_window_valid   : std_logic;
    signal s_flush_pipeline : std_logic;

    signal d00, d01, d02, d10, d11, d12, d20, d21, d22 : std_logic_vector(7 downto 0);
    signal M_1_1, M_1_2, M_1_3 : std_logic_vector(n_adder-1 downto 0);
    signal M_2_1, M_2_2, M_2_3 : std_logic_vector(n_adder-1 downto 0);
    signal M_3_1, M_3_2, M_3_3 : std_logic_vector(n_adder-1 downto 0);
    signal output_sum          : std_logic_vector(comp_i+coeff_f+4 downto 0);

    -- Latch output AXI signals
    signal m_axis_tvalid_s, m_axis_tlast_s, m_axis_tuser_s : std_logic;

begin
    bl: buffer_line
        generic map(
            ncol => ncol_img
        )

        port map (
            clk => s_axis_clk, reset => s_axis_rstn, valid => s_pipeline_en,
            flush => s_flush_pipeline,
            data => s_axis_tdata,

            d00 => d00, d01 => d01, d02 => d02,
            d10 => d10, d11 => d11, d12 => d12,
            d20 => d20, d21 => d21, d22 => d22
        );

    bm: booth_multiplier
        generic map (
            componente_immagine => comp_i,
            coefficiente_filtro => coeff_f,
            somma => n_adder
        )

        port map (
            P_1_1 => d00, P_1_2 => d01, P_1_3 => d02,
            P_2_1 => d10, P_2_2 => d11, P_2_3 => d12,
            P_3_1 => d20, P_3_2 => d21, P_3_3 => d22,

            F_1_1 => kernel00, F_1_2 => kernel01, F_1_3 => kernel02,
            F_2_1 => kernel10, F_2_2 => kernel11, F_2_3 => kernel12,
            F_3_1 => kernel20, F_3_2 => kernel21, F_3_3 => kernel22,

            M_1_1 => M_1_1, M_1_2 => M_1_2, M_1_3 => M_1_3,
            M_2_1 => M_2_1, M_2_2 => M_2_2, M_2_3 => M_2_3,
            M_3_1 => M_3_1, M_3_2 => M_3_2, M_3_3 => M_3_3
        );

    csat: carry_save_adder_tree
        generic map (
            N=>n_adder
        )

        port map(
            i_1_1=>M_1_1, i_1_2=>M_1_2, i_1_3=>M_1_3,
            i_2_1=>M_2_1, i_2_2=>M_2_2, i_2_3=>M_2_3,
            i_3_1=>M_3_1, i_3_2=>M_3_2, i_3_3=>M_3_3,
            sum=>output_sum
        );

    sm: state_machine
        generic map(
            ncol_img        => ncol_img,
            nrow_img        => nrow_img,
            kernel_row_size => 3
        )

        port map (
            s_axis_clk      => s_axis_clk,
            s_axis_rstn     => s_axis_rstn,
            s_axis_tvalid   => s_axis_tvalid,
            s_axis_tready   => s_axis_tready,
            s_axis_tlast    => s_axis_tlast,
            s_axis_tuser    => s_axis_tuser,
            m_axis_tvalid   => m_axis_tvalid_s,
            m_axis_tready   => m_axis_tready,
            m_axis_tlast    => m_axis_tlast_s,
            m_axis_tuser    => m_axis_tuser_s,
            pipeline_en     => s_pipeline_en,
            window_valid    => s_window_valid,
            flush_pipeline  => s_flush_pipeline
        );

    -- Output register
    process (s_axis_clk)
    begin
        if rising_edge(s_axis_clk) then
            if s_axis_rstn = '0' then
                m_axis_tdata <= (others => '0');
            elsif s_window_valid = '1' and m_axis_tready = '1' then
                m_axis_tdata <= output_sum;
            end if;

            m_axis_tvalid <= m_axis_tvalid_s;
            m_axis_tlast  <= m_axis_tlast_s;
            m_axis_tuser  <= m_axis_tuser_s;
        end if;
    end process;

end architecture Structural;
