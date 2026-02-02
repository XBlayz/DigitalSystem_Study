library ieee;
    use ieee.std_logic_1164.all;

entity main is
    port (
        s_axis_clk      : in  std_logic;
        s_axis_rstn     : in  std_logic;
        s_axis_tvalid   : in  std_logic;
        s_axis_tlast    : in  std_logic;
        s_axis_tready   : out std_logic;
        s_axis_tdata    : in  std_logic_vector(7 downto 0);

        m_axis_tvalid   : out std_logic;
        m_axis_tlast    : out std_logic;
        m_axis_tready   : in  std_logic;
        m_axis_tdata    : out std_logic_vector(8+4+4 downto 0) -- comp_i + coeff_f + 4
    );
end entity main;

architecture Structural of main is
    constant comp_i : POSITIVE := 8;
    constant coeff_f : POSITIVE := 4;
    constant n_adder : POSITIVE := comp_i+coeff_f;

    constant ncol_img : POSITIVE := 32;
    constant nrow_img : POSITIVE := 32;

    component buffer_line is
        generic(
            ncol : integer
        );
        port(
            clk   : in  std_logic;
            reset : in  std_logic;
            valid : in  std_logic;
            data  : in  std_logic_vector(7 downto 0);

            d00, d01, d02, d10, d11, d12, d20, d21, d22 : out std_logic_vector(7 downto 0)
        );
    end component buffer_line;

    component booth_multiplier is
        generic(
            componente_immagine : POSITIVE := 8;
            coefficiente_filtro : POSITIVE := 4;
            somma : POSITIVE := 12
        );
        port (
            clk    : in  std_logic;
            reset  : in  std_logic;
            valid  : in  std_logic;

            -- 3x3 componenti immagine
            P_1_1, P_1_2, P_1_3 : in std_logic_vector(componente_immagine-1 downto 0);
            P_2_1, P_2_2, P_2_3 : in std_logic_vector(componente_immagine-1 downto 0);
            P_3_1, P_3_2, P_3_3 : in std_logic_vector(componente_immagine-1 downto 0);

            -- Filtro 3x3
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

    -- #TODO: State_Machine

    signal d00, d01, d02, d10, d11, d12, d20, d21, d22 : std_logic_vector(7 downto 0);
    signal M_1_1, M_1_2, M_1_3 : std_logic_vector(n_adder-1 downto 0);
    signal M_2_1, M_2_2, M_2_3 : std_logic_vector(n_adder-1 downto 0);
    signal M_3_1, M_3_2, M_3_3 : std_logic_vector(n_adder-1 downto 0);
    signal output_sum          : std_logic_vector(comp_i+coeff_f+4 downto 0);

    constant kernel00 : std_logic_vector(7 downto 0) := "00000000"; -- #TODO
    constant kernel01 : std_logic_vector(7 downto 0) := "11111111"; -- #TODO
    constant kernel02 : std_logic_vector(7 downto 0) := "11111111"; -- #TODO
    constant kernel10 : std_logic_vector(7 downto 0) := "11111111"; -- #TODO
    constant kernel11 : std_logic_vector(7 downto 0) := "00000000"; -- #TODO
    constant kernel12 : std_logic_vector(7 downto 0) := "11111111"; -- #TODO
    constant kernel20 : std_logic_vector(7 downto 0) := "11111111"; -- #TODO
    constant kernel21 : std_logic_vector(7 downto 0) := "11111111"; -- #TODO
    constant kernel22 : std_logic_vector(7 downto 0) := "00000000"; -- #TODO

begin
    bl: buffer_line
        generic map(
            ncol => ncol_img
        )

        port map (
            clk => s_axis_clk, reset => s_axis_rstn, valid => s_axis_tvalid, -- #TODO: Valid_input dalla state machine
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
            clk => s_axis_clk, reset => s_axis_rstn, valid => s_axis_tvalid, -- #TODO: Rimuovere reset, valid e clk
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

    -- #TODO: Valid_output dalla state machine
    -- output_sum -> m_axis_tdata

end architecture Structural;
