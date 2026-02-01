
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CSA_tree is
    generic (N : POSITIVE := 12);
    
    port (
        i_1_1, i_1_2, i_1_3 : in  std_logic_vector(N-1 downto 0);
        i_2_1, i_2_2, i_2_3 : in  std_logic_vector(N-1 downto 0);
        i_3_1, i_3_2, i_3_3 : in  std_logic_vector(N-1 downto 0);
        sum                 : out std_logic_vector(N+4 downto 0)
    );
end CSA_tree;

architecture Structural of CSA_tree is
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
    signal vr_2_2, vs_2_2 : STD_LOGIC_VECTOR(N+1 downto 0);
    signal temp : STD_LOGIC_VECTOR(N+2 downto 0);
     
    -- Terzo livello (dimensione = 15)
    signal vr_3_1, vs_3_1 : STD_LOGIC_VECTOR(N+2 downto 0);
    
    -- Quarto livello (dimensione = 16)
    signal vr_4_1, vs_4_1 : STD_LOGIC_VECTOR(N+3 downto 0);
    signal rca_s_out : STD_LOGIC_VECTOR (N+3 downto 0); 
    signal rca_c_out : STD_LOGIC;
    
    
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
    temp <= vr_2_2(N+1) & vr_2_2;
    
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
                cin=>temp(i),  
                s=>vs_4_1(i),  
                cout=>vr_4_1(i+1)
            );
    end generate sommatore_Lev4;
    vs_4_1(N+3)<= vs_4_1(N+2);
    
    sommatore_Lev5: ripple_carry_adder
        generic map(N => N+4)
            port map(
                a    => vs_4_1,
                b    => vr_4_1,
                cin  => '0',
                s    => rca_s_out,
                cout => rca_c_out
            );
    sum <= rca_s_out(N+3) & rca_s_out;

end Structural;
