
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;


entity tb_multiplier_adder is
end tb_multiplier_adder;

architecture testing of tb_multiplier_adder is
    constant comp_i : POSITIVE := 8;
    constant coeff_f : POSITIVE := 4;
    constant n_adder : POSITIVE := comp_i+coeff_f;
    constant CLK_PERIOD : time := 10 ns;

    signal stop_simulation : boolean := false;
    signal clk, reset, valid  :  std_logic := '0';
    --componenti immagine
    signal P_1_1, P_1_2, P_1_3,
           P_2_1, P_2_2, P_2_3,
           P_3_1, P_3_2, P_3_3 : std_logic_vector(comp_i-1 downto 0) := (others => '0');

    --componenti filtro
    signal F_1_1, F_1_2, F_1_3,
           F_2_1, F_2_2, F_2_3,
           F_3_1, F_3_2, F_3_3 : std_logic_vector(coeff_f-1 downto 0):= (others => '0');

    --uscite moltiplicatore
    signal M_1_1, M_1_2, M_1_3,
           M_2_1, M_2_2, M_2_3,
           M_3_1, M_3_2, M_3_3 : std_logic_vector(n_adder-1 downto 0);

    --uscita sommatore (Pixel filtrato)
    signal sum_out : std_logic_vector(n_adder+3 downto 0);
    signal p : std_logic_vector(comp_i-1 downto 0);
    signal f : std_logic_vector(coeff_f-1 downto 0);

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
            sum                 : out std_logic_vector(N+3 downto 0)
        );
    end component carry_save_adder_tree;

begin
    P_1_1 <= p;
        P_1_2 <= p;
        P_1_3 <= p;
        P_2_1 <= p;
        P_2_2 <= p;
        P_2_3 <= p;
        P_3_1 <= p;
        P_3_2 <= p;
        P_3_3 <= p;

        F_1_1 <= f;
        F_1_2 <= f;
        F_1_3 <= f;
        F_2_1 <= f;
        F_2_2 <= f;
        F_2_3 <= f;
        F_3_1 <= f;
        F_3_2 <= f;
        F_3_3 <= f;

    bm: booth_multiplier
        generic map(
            componente_immagine => comp_i,
            coefficiente_filtro => coeff_f,
            somma => n_adder
        )

        port map (
            clk => clk, reset => reset, valid => valid,
            P_1_1 => P_1_1, P_1_2 => P_1_2, P_1_3 => P_1_3,
            P_2_1 => P_2_1, P_2_2 => P_2_2, P_2_3 => P_2_3,
            P_3_1 => P_3_1, P_3_2 => P_3_2, P_3_3 => P_3_3,

            F_1_1 => F_1_1, F_1_2 => F_1_2, F_1_3 => F_1_3,
            F_2_1 => F_2_1, F_2_2 => F_2_2, F_2_3 => F_2_3,
            F_3_1 => F_3_1, F_3_2 => F_3_2, F_3_3 => F_3_3,

            M_1_1 => M_1_1, M_1_2 => M_1_2, M_1_3 => M_1_3,
            M_2_1 => M_2_1, M_2_2 => M_2_2, M_2_3 => M_2_3,
            M_3_1 => M_3_1, M_3_2 => M_3_2, M_3_3 => M_3_3
        );

    CSAt: carry_save_adder_tree
        generic map(N=>n_adder)

        port map( i_1_1=>M_1_1, i_1_2=>M_1_2, i_1_3=>M_1_3,
                  i_2_1=>M_2_1, i_2_2=>M_2_2, i_2_3=>M_2_3,
                  i_3_1=>M_3_1, i_3_2=>M_3_2, i_3_3=>M_3_3,
                  sum=>sum_out
        );

    clk_process : process
    begin
        while not stop_simulation loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    stim_proc : process
    begin
        reset <= '1';
        valid <= '0';
        --metto prima tutto a 0
        p <= (others=>'0');
        f <= (others=>'0');
        wait for 20 ns;
        reset <= '0';
        wait for 20 ns;

        --Test sul valore massimo positivo
        --(componenti immagine = 1255 (8 bit), coefficienti filtro = 7 (4 bit)
        -- valore atteso: 9*(255*7) = 16065)
        p <= std_logic_vector(to_unsigned(255, comp_i));
        f <= std_logic_vector(to_signed(7, coeff_f));
        wait for CLK_PERIOD;
        valid <= '1';
        wait for CLK_PERIOD;
        valid <= '0';
        wait for 100 ns;

        --test sul valore minimo negativo
        --(componenti immagine = 255 (8 bit), coefficienti filtro = -8 (4 bit)
        -- valore atteso: 9*(255*-8) = -18360)
        f <= std_logic_vector(to_signed(-8, coeff_f));
        wait for CLK_PERIOD;
        valid <= '1';
        wait for CLK_PERIOD;
        valid <= '0';
        wait for 100 ns;

        --test con filtro negativo e immagine positiva
        --componenti immagine = 50, coefficienti filtro = -2
        --valore atteso = -900
        p <= std_logic_vector(to_unsigned(50, comp_i));
        f <= std_logic_vector(to_signed(-2, coeff_f));
        wait for CLK_PERIOD;
        valid <= '1';
        wait for CLK_PERIOD;
        valid <= '0';
        wait for 100 ns;

        --test con filtro con coefficienti = 1
        --componenti dell'immagine da -10 a -5
        f <= std_logic_vector(to_signed(1, coeff_f));
        for i in 5 to 10 loop
            p <= std_logic_vector(to_unsigned(i, comp_i));
            wait for CLK_PERIOD;
            valid <= '1';
            wait for CLK_PERIOD;
            valid <= '0';
            wait for 50 ns;
        end loop;

        wait for 100 ns;
        stop_simulation <= true;
        wait;
    end process;

end testing;
