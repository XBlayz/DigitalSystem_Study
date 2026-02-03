library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity tb_booth_multiplier is
end entity tb_booth_multiplier;

architecture testing of tb_booth_multiplier is
    constant comp_i : POSITIVE := 8;
    constant coeff_f : POSITIVE := 4;
    constant sum : POSITIVE := comp_i+coeff_f;
    constant CLK_PERIOD : time := 10 ns;

    signal stop_simulation : boolean := false;
    signal clk, reset, valid  :  std_logic := '0';

    -- 3x3 componenti immagine
    signal P_1_1, P_1_2, P_1_3,
           P_2_1, P_2_2, P_2_3,
           P_3_1, P_3_2, P_3_3 : std_logic_vector(comp_i-1 downto 0);

        -- Filtro 3x3
    signal F_1_1, F_1_2, F_1_3,
           F_2_1, F_2_2, F_2_3,
           F_3_1, F_3_2, F_3_3 : std_logic_vector(coeff_f-1 downto 0);

        -- uscita
    signal M_1_1, M_1_2, M_1_3,
           M_2_1, M_2_2, M_2_3,
           M_3_1, M_3_2, M_3_3 : std_logic_vector(sum-1 downto 0);

    signal p : std_logic_vector(comp_i-1 downto 0);
    signal f : std_logic_vector(coeff_f-1 downto 0);


    component booth_multiplier is
    generic(
        componente_immagine : POSITIVE;
        coefficiente_filtro : POSITIVE;
        somma : POSITIVE
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
            somma => sum
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

        -- Generatore di Clock
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

        p <= (others => '0');
        f <= (others => '0');

        wait for 20 ns;
        reset <= '0';
        wait for 20 ns;

        --test sui massimi valori possibili
        -- immagine=255, filtro = +7
        --risultati attesi = 1785
        p <= std_logic_vector(to_unsigned(255, comp_i));
        f <= std_logic_vector(to_signed(7, coeff_f));
        wait for CLK_PERIOD;
        valid <= '1';
        wait for CLK_PERIOD;
        valid <= '0';
        wait for 50 ns;

        --test sul minimo possibile
        --immagine = 255, filtro = -8
        --risultato atteso = -2040
        f <= std_logic_vector(to_signed(-8, coeff_f));
        wait for CLK_PERIOD;
        valid <= '1';
        wait for CLK_PERIOD;
        valid <= '0';
        wait for 50 ns;

        --test sullo 0: immagine = 0, filtro =-8
        p <= (others => '0');
        wait for CLK_PERIOD;
        valid <= '1';
        wait for CLK_PERIOD;
        valid <= '0';
        wait for 50 ns;

        --iterazione per tutti ivalori del filtro e immagine a 255
        p <= std_logic_vector(to_unsigned(255, 8));
        for i in -8 to 7 loop
            f <= std_logic_vector(to_signed(i, coeff_f));
            wait for CLK_PERIOD;
            valid <= '1';
            wait for CLK_PERIOD;
            valid <= '0';
            wait for 50 ns;
        end loop;

        wait for CLK_PERIOD;
        valid <= '1';
        wait for CLK_PERIOD;
        valid <= '0';
        wait for 50 ns;

        stop_simulation <= true;
        wait;

        end process;



end testing;
