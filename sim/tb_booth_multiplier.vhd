library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity tb_booth_multiplier is
end entity tb_booth_multiplier;

architecture testing of tb_booth_multiplier is
    constant img_nbit : POSITIVE := 8;
    constant cof_nbit : POSITIVE := 4;
    constant CLK_PERIOD : time := 10 ns;

    -- Componenti immagine 3x3
    signal P_1_1, P_1_2, P_1_3 : std_logic_vector(img_nbit-1 downto 0);
    signal P_2_1, P_2_2, P_2_3 : std_logic_vector(img_nbit-1 downto 0);
    signal P_3_1, P_3_2, P_3_3 : std_logic_vector(img_nbit-1 downto 0);

    -- Filtro 3x3
    signal F_1_1, F_1_2, F_1_3 : std_logic_vector(cof_nbit-1 downto 0);
    signal F_2_1, F_2_2, F_2_3 : std_logic_vector(cof_nbit-1 downto 0);
    signal F_3_1, F_3_2, F_3_3 : std_logic_vector(cof_nbit-1 downto 0);

    -- Risultato
    signal M_1_1, M_1_2, M_1_3 : std_logic_vector(img_nbit+cof_nbit-1 downto 0);
    signal M_2_1, M_2_2, M_2_3 : std_logic_vector(img_nbit+cof_nbit-1 downto 0);
    signal M_3_1, M_3_2, M_3_3 : std_logic_vector(img_nbit+cof_nbit-1 downto 0);

    signal p : std_logic_vector(img_nbit-1 downto 0);
    signal f : std_logic_vector(cof_nbit-1 downto 0);

    component booth_multiplier_matrix is
        generic(
            img_nbit : POSITIVE
        );
        port (
            -- Componenti immagine 3x3
            P_1_1, P_1_2, P_1_3 : in std_logic_vector(img_nbit-1 downto 0);
            P_2_1, P_2_2, P_2_3 : in std_logic_vector(img_nbit-1 downto 0);
            P_3_1, P_3_2, P_3_3 : in std_logic_vector(img_nbit-1 downto 0);

            -- Filtro 3x3
            F_1_1, F_1_2, F_1_3 : in std_logic_vector(4-1 downto 0);
            F_2_1, F_2_2, F_2_3 : in std_logic_vector(4-1 downto 0);
            F_3_1, F_3_2, F_3_3 : in std_logic_vector(4-1 downto 0);

            -- Risultato
            M_1_1, M_1_2, M_1_3 : out std_logic_vector(img_nbit+4-1 downto 0);
            M_2_1, M_2_2, M_2_3 : out std_logic_vector(img_nbit+4-1 downto 0);
            M_3_1, M_3_2, M_3_3 : out std_logic_vector(img_nbit+4-1 downto 0)
        );
    end component booth_multiplier_matrix;

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

    bm: booth_multiplier_matrix
        generic map(
            img_nbit => img_nbit
        )

        port map (
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

    -- Generazione stimoli con casi rappresentativi
    stim_proc: process
    begin
        report "Inizio test con casi rappresentativi...";

        -- Caso 1: positivo * positivo
        -- Valori piccoli
        p <= std_logic_vector(to_unsigned(1, img_nbit));    -- 1
        f <= std_logic_vector(to_unsigned(1, cof_nbit));    -- 1
        wait for 10 ns;

        p <= std_logic_vector(to_unsigned(2, img_nbit));    -- 2
        f <= std_logic_vector(to_unsigned(3, cof_nbit));    -- 3
        wait for 10 ns;

        -- Valori medi
        p <= std_logic_vector(to_unsigned(10, img_nbit));   -- 10
        f <= std_logic_vector(to_unsigned(5, cof_nbit));    -- 5
        wait for 10 ns;

        -- Valori massimi positivi
        p <= std_logic_vector(to_unsigned(2**(img_nbit-1)-1, img_nbit)); -- 127
        f <= std_logic_vector(to_unsigned(2**(cof_nbit-1)-1, cof_nbit)); -- 7
        wait for 10 ns;

        -- Caso 2: positivo * negativo
        -- Valori piccoli
        p <= std_logic_vector(to_unsigned(1, img_nbit));    -- 1
        f <= std_logic_vector(to_signed(-1, cof_nbit));     -- -1
        wait for 10 ns;

        p <= std_logic_vector(to_unsigned(2, img_nbit));    -- 2
        f <= std_logic_vector(to_signed(-3, cof_nbit));     -- -3
        wait for 10 ns;

        -- Valori medi
        p <= std_logic_vector(to_unsigned(10, img_nbit));   -- 10
        f <= std_logic_vector(to_signed(-5, cof_nbit));     -- -5
        wait for 10 ns;

        -- Valore massimo positivo * valore minimo negativo
        p <= std_logic_vector(to_unsigned(2**(img_nbit-1)-1, img_nbit)); -- 127
        f <= std_logic_vector(to_signed(-2**(cof_nbit-1), cof_nbit));    -- -8
        wait for 10 ns;

        -- Caso 3: negativo * positivo
        -- Valori piccoli
        p <= std_logic_vector(to_signed(-1, img_nbit));     -- -1
        f <= std_logic_vector(to_unsigned(1, cof_nbit));    -- 1
        wait for 10 ns;

        p <= std_logic_vector(to_signed(-2, img_nbit));     -- -2
        f <= std_logic_vector(to_unsigned(3, cof_nbit));    -- 3
        wait for 10 ns;

        -- Valori medi
        p <= std_logic_vector(to_signed(-10, img_nbit));    -- -10
        f <= std_logic_vector(to_unsigned(5, cof_nbit));    -- 5
        wait for 10 ns;

        -- Valore minimo negativo * valore massimo positivo
        p <= std_logic_vector(to_signed(-2**(img_nbit-1), img_nbit));    -- -128
        f <= std_logic_vector(to_unsigned(2**(cof_nbit-1)-1, cof_nbit)); -- 7
        wait for 10 ns;

        -- Caso 4: negativo * negativo
        -- Valori piccoli
        p <= std_logic_vector(to_signed(-1, img_nbit));     -- -1
        f <= std_logic_vector(to_signed(-1, cof_nbit));     -- -1
        wait for 10 ns;

        p <= std_logic_vector(to_signed(-2, img_nbit));     -- -2
        f <= std_logic_vector(to_signed(-3, cof_nbit));     -- -3
        wait for 10 ns;

        -- Valori medi
        p <= std_logic_vector(to_signed(-10, img_nbit));    -- -10
        f <= std_logic_vector(to_signed(-5, cof_nbit));     -- -5
        wait for 10 ns;

        -- Valori massimi negativi
        p <= std_logic_vector(to_signed(-2**(img_nbit-1), img_nbit));    -- -128
        f <= std_logic_vector(to_signed(-2**(cof_nbit-1), cof_nbit));    -- -8
        wait for 10 ns;

        -- Caso 5: Valori speciali
        -- Zero * qualsiasi valore
        p <= (others => '0');
        f <= std_logic_vector(to_signed(-5, cof_nbit));     -- -5
        wait for 10 ns;

        p <= std_logic_vector(to_unsigned(255, img_nbit));  -- 255
        f <= (others => '0');
        wait for 10 ns;

        -- Uno * qualsiasi valore
        p <= std_logic_vector(to_unsigned(1, img_nbit));    -- 1
        f <= std_logic_vector(to_signed(-8, cof_nbit));     -- -8
        wait for 10 ns;

        p <= std_logic_vector(to_signed(-128, img_nbit));   -- -128
        f <= std_logic_vector(to_unsigned(1, cof_nbit));    -- 1
        wait for 10 ns;

        wait;
    end process stim_proc;

end testing;
