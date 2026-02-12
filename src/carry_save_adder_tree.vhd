library ieee;
    use ieee.std_logic_1164.all;

entity carry_save_adder_tree is
    generic (N : POSITIVE := 12);

    port (
        i_1_1, i_1_2, i_1_3 : in  std_logic_vector(N-1 downto 0);
        i_2_1, i_2_2, i_2_3 : in  std_logic_vector(N-1 downto 0);
        i_3_1, i_3_2, i_3_3 : in  std_logic_vector(N-1 downto 0);
        sum                 : out std_logic_vector(N+4 downto 0)
    );
end carry_save_adder_tree;

architecture Structural of carry_save_adder_tree is
    component full_adder is
        port(
            a, b, cin : in STD_LOGIC;
            s, cout : out STD_LOGIC
        );
    end component;

    component ripple_carry_adder is
        generic (N : POSITIVE);
        port(
            a, b : in  std_logic_vector(N - 1 downto 0);
            cin  : in  std_logic;
            s    : out std_logic_vector(N - 1 downto 0);
            cout : out std_logic
        );
    end component;

    -- Primo livello (dimensione = 13)
    signal vr_1_1, vs_1_1 : STD_LOGIC_VECTOR(N downto 0);
    signal vr_1_2, vs_1_2 : STD_LOGIC_VECTOR(N downto 0);
    signal vr_1_3, vs_1_3 : STD_LOGIC_VECTOR(N downto 0);

    -- Secondo livello (dimensione = 14)
    signal vr_2_1, vs_2_1 : STD_LOGIC_VECTOR(N+1 downto 0);
    signal vs_2_2 : STD_LOGIC_VECTOR(N+1 downto 0);
    signal vr_2_2 : STD_LOGIC_VECTOR(N+2 downto 0);

    -- Terzo livello (dimensione = 15)
    signal vr_3_1, vs_3_1 : STD_LOGIC_VECTOR(N+2 downto 0);

    -- Quarto livello (dimensione = 16)
    signal vr_4_1, vs_4_1 : STD_LOGIC_VECTOR(N+3 downto 0);

    signal sum_rca_0 : STD_LOGIC_VECTOR (7 downto 0);
    signal c_out_rca_0 : STD_LOGIC;

    signal sum_RCA_1    : std_logic_vector(7 downto 0);
    signal sum_RCA_2    : std_logic_vector(7 downto 0);

begin
    vr_1_1(0) <= '0';
    primo_sommatore_Lev1: for i in 0 to N-1 generate
        istanziazione_FA: full_adder
            port map(
                a=>i_1_1(i),
                b=>i_1_2(i),
                cin=>i_1_3(i),
                s=>vs_1_1(i),
                cout=>vr_1_1(i+1)
            );
    end generate primo_sommatore_Lev1;
    vs_1_1(N) <= i_1_1(N-1);

    vr_1_2(0)  <= '0';
    secondo_sommatore_Lev1: for i in 0 to N-1 generate
        istanziazione_FA: full_adder
            port map(
                a=>i_2_1(i),
                b=>i_2_2(i),
                cin=>i_2_3(i),
                s=>vs_1_2(i),
                cout=>vr_1_2(i+1)
            );
    end generate secondo_sommatore_Lev1;
    vs_1_2(N) <= i_2_1(N-1);

    vr_1_3(0)  <= '0';
    terzo_sommatore_Lev1: for i in 0 to N-1 generate
        istanziazione_FA: full_adder
        port map(
            a=>i_3_1(i),
            b=>i_3_2(i),
            cin=>i_3_3(i),
            s=>vs_1_3(i),
            cout=>vr_1_3(i+1)
        );
    end generate terzo_sommatore_Lev1;
    vs_1_3(N) <= i_3_1(N-1);

    vr_2_1(0)  <= '0';
    primo_sommatore_Lev2: for i in 0 to N generate
        istanziazione_FA: full_adder
            port map(
                a=>vs_1_1(i),
                b=>vr_1_1(i),
                cin=>vs_1_2(i),
                s=>vs_2_1(i),
                cout=>vr_2_1(i+1)
            );
    end generate primo_sommatore_Lev2;
    vs_2_1(N+1) <= vs_2_1(N);

    vr_2_2(0)  <= '0';
    secondo_sommatore_Lev2: for i in 0 to N generate
        istanziazione_FA: full_adder
            port map(
                a=>vr_1_2(i),
                b=>vs_1_3(i),
                cin=>vr_1_3(i),
                s=>vs_2_2(i),
                cout=>vr_2_2(i+1)
            );
    end generate secondo_sommatore_Lev2;
    vs_2_2(N+1) <= vs_2_2(N);

    -- estendo con segno per portarli alla stessa dimensione per dopo
    vr_2_2(N+2) <= vr_2_2(N+1);

    vr_3_1(0) <= '0';
    sommatore_Lev3: for i in 0 to N+1 generate
        istanziazione_FA: full_adder
            port map(
                a=>vs_2_1(i),
                b=>vr_2_1(i),
                cin=>vs_2_2(i),
                s=>vs_3_1(i),
                cout=>vr_3_1(i+1)
            );
    end generate sommatore_Lev3;
    vs_3_1(N+2) <= vs_3_1(N+1);

    vr_4_1(0) <= '0';
    sommatore_Lev4: for i in 0 to N+2 generate
        istanziazione_FA: full_adder
            port map(
                a=>vs_3_1(i),
                b=>vr_3_1(i),
                cin=>vr_2_2(i),
                s=>vs_4_1(i),
                cout=>vr_4_1(i+1)
            );
    end generate sommatore_Lev4;
    vs_4_1(N+3)<= vs_4_1(N+2);

--questo rca fa la somma per la met� meno significativa degli ingressi
    RCA_0: ripple_carry_adder
        generic map(N => 8)
        port map(
            a    => vs_4_1(7 downto 0),
            b    => vr_4_1(7 downto 0),
            cin  => '0',
            s    => sum_RCA_0,
            cout => c_out_RCA_0   --questo segnale serve per la selezione del sommatore dopo
        );

-- questo somma la met� pi� significativa degli ingressi con cin=0
    RCA_1: ripple_carry_adder
        generic map(N => 8)
        port map(
            a    => vs_4_1(15 downto 8),
            b    => vr_4_1(15 downto 8),
            cin  => '0',
            s    => sum_RCA_1,
            cout => open
        );

-- questo somma la met� pi� significativa degli ingressi con cin=1
    RCA_2: ripple_carry_adder
        generic map(N => 8)
        port map(
            a    => vs_4_1(15 downto 8),
            b    => vr_4_1(15 downto 8),
            cin  => '1',
            s    => sum_RCA_2,
            cout => open
        );

--selettore per capire quale sommatore utilizzare per la met� pi� significativa
    with c_out_RCA_0 select
        sum <= sum_RCA_1(7) & sum_RCA_1 & sum_RCA_0 when '0',
               sum_RCA_2(7) & sum_RCA_2 & sum_RCA_0 when '1',
               (others => '0') when others;


end Structural;
