

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity booth_multiplier is
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
end entity booth_multiplier;

architecture Structural of booth_multiplier is

    
    component ripple_carry_adder is
        generic ( N : POSITIVE );
        port (
            a, b : in  std_logic_vector(N - 1 downto 0);
            cin  : in  std_logic;
            s    : out std_logic_vector(N - 1 downto 0);
            cout : out std_logic
        );
    end component;

    -- Le 2 componenti da sommare per ottenere di quanto va moltiplicato il moltiplicando
    signal P_P_A_1_1, P_P_B_1_1, P_P_A_1_2, P_P_B_1_2, P_P_A_1_3, P_P_B_1_3 : std_logic_vector(somma-1 downto 0);
    signal P_P_A_2_1, P_P_B_2_1, P_P_A_2_2, P_P_B_2_2, P_P_A_2_3, P_P_B_2_3 : std_logic_vector(somma-1 downto 0);
    signal P_P_A_3_1, P_P_B_3_1, P_P_A_3_2, P_P_B_3_2, P_P_A_3_3, P_P_B_3_3 : std_logic_vector(somma-1 downto 0);

    -- Signal per prendere il negativo di una componente dell'immagine
    signal N_P_1_1, N_P_1_2, N_P_1_3, N_P_2_1, N_P_2_2, N_P_2_3, N_P_3_1, N_P_3_2, N_P_3_3 : std_logic_vector(componente_immagine-1 downto 0);

begin

    -- in N_P_x_y metto tutte le componenti dell'immagine con segno negativo per usarle successivamente
    N_P_1_1 <= std_logic_vector(unsigned(not P_1_1) + 1);
    N_P_1_2 <= std_logic_vector(unsigned(not P_1_2) + 1);
    N_P_1_3 <= std_logic_vector(unsigned(not P_1_3) + 1);
    N_P_2_1 <= std_logic_vector(unsigned(not P_2_1) + 1);
    N_P_2_2 <= std_logic_vector(unsigned(not P_2_2) + 1);
    N_P_2_3 <= std_logic_vector(unsigned(not P_2_3) + 1);
    N_P_3_1 <= std_logic_vector(unsigned(not P_3_1) + 1);
    N_P_3_2 <= std_logic_vector(unsigned(not P_3_2) + 1);
    N_P_3_3 <= std_logic_vector(unsigned(not P_3_3) + 1);

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then --faccio la reset di tutti i valori quindi li pongo a 0
                P_P_A_1_1 <= (others => '0'); P_P_B_1_1 <= (others => '0');
                P_P_A_1_2 <= (others => '0'); P_P_B_1_2 <= (others => '0');
                P_P_A_1_3 <= (others => '0'); P_P_B_1_3 <= (others => '0');
                P_P_A_2_1 <= (others => '0'); P_P_B_2_1 <= (others => '0');
                P_P_A_2_2 <= (others => '0'); P_P_B_2_2 <= (others => '0');
                P_P_A_2_3 <= (others => '0'); P_P_B_2_3 <= (others => '0');
                P_P_A_3_1 <= (others => '0'); P_P_B_3_1 <= (others => '0');
                P_P_A_3_2 <= (others => '0'); P_P_B_3_2 <= (others => '0');
                P_P_A_3_3 <= (others => '0'); P_P_B_3_3 <= (others => '0');
           
            elsif valid = '1' then --vuol dire che gli input sono validi e posso iniziare a lavorare     
                case F_1_1 is
                    when "0000" => P_P_A_1_1 <= (others => '0'); P_P_B_1_1 <= (others => '0');
                    when "0001" => P_P_A_1_1 <= P_1_1(componente_immagine-1) & P_1_1(componente_immagine-1) & P_1_1(componente_immagine-1) & P_1_1(componente_immagine-1) & P_1_1; P_P_B_1_1 <= (others => '0');                     
                    when "0010" => P_P_A_1_1 <= N_P_1_1(componente_immagine-1) & N_P_1_1(componente_immagine-1) & N_P_1_1(componente_immagine-1)& N_P_1_1 & "0"; P_P_B_1_1 <= P_1_1(componente_immagine-1) & P_1_1(componente_immagine-1) & P_1_1 & "00";
                    when "0011" => P_P_A_1_1 <= N_P_1_1(componente_immagine-1) & N_P_1_1(componente_immagine-1) & N_P_1_1(componente_immagine-1) & N_P_1_1(componente_immagine-1) & N_P_1_1; P_P_B_1_1 <= P_1_1(componente_immagine-1) & P_1_1(componente_immagine-1) & P_1_1 & "00";
                    when "0100" => P_P_A_1_1 <= (others => '0'); P_P_B_1_1 <= P_1_1(componente_immagine-1) & P_1_1(componente_immagine-1) & P_1_1 & "00";
                    when "0101" => P_P_A_1_1 <= P_1_1(componente_immagine-1) & P_1_1(componente_immagine-1) & P_1_1(componente_immagine-1) & P_1_1(componente_immagine-1) & P_1_1; P_P_B_1_1 <= P_1_1(componente_immagine-1) & P_1_1(componente_immagine-1) & P_1_1 & "00";
                    when "0110" | "0111" => P_P_A_1_1 <= N_P_1_1(componente_immagine-1) & N_P_1_1(componente_immagine-1) & N_P_1_1(componente_immagine-1) & N_P_1_1(componente_immagine-1) & N_P_1_1; P_P_B_1_1 <= P_1_1(componente_immagine-1) & P_1_1 & "000";
                    when "1000" => P_P_A_1_1 <= (others => '0'); P_P_B_1_1 <= N_P_1_1(componente_immagine-1) & N_P_1_1 & "000";
                    when "1001" => P_P_A_1_1 <=  P_1_1(componente_immagine-1) & P_1_1(componente_immagine-1) & P_1_1(componente_immagine-1) & P_1_1(componente_immagine-1) & P_1_1; P_P_B_1_1 <= N_P_1_1(componente_immagine-1) & N_P_1_1 & "000";
                    when "1010" => P_P_A_1_1 <= N_P_1_1(componente_immagine-1) & N_P_1_1(componente_immagine-1) & N_P_1_1(componente_immagine-1) & N_P_1_1 & "0"; P_P_B_1_1 <= N_P_1_1(componente_immagine-1) & N_P_1_1(componente_immagine-1) & N_P_1_1 & "00";
                    when "1011" => P_P_A_1_1 <= N_P_1_1(componente_immagine-1) & N_P_1_1(componente_immagine-1) & N_P_1_1(componente_immagine-1)& N_P_1_1(componente_immagine-1) & N_P_1_1; P_P_B_1_1 <= N_P_1_1(componente_immagine-1) & N_P_1_1(componente_immagine-1) & N_P_1_1 & "00";
                    when "1100" => P_P_A_1_1 <= (others => '0'); P_P_B_1_1 <= N_P_1_1(componente_immagine-1) & N_P_1_1(componente_immagine-1) & N_P_1_1 & "00";
                    when "1101" => P_P_A_1_1 <= P_1_1(componente_immagine-1) & P_1_1(componente_immagine-1) & P_1_1(componente_immagine-1) & P_1_1(componente_immagine-1) & P_1_1; P_P_B_1_1 <= N_P_1_1(componente_immagine-1) & N_P_1_1(componente_immagine-1) & N_P_1_1 & "00";
                    when "1110" => P_P_A_1_1 <= N_P_1_1(componente_immagine-1) & N_P_1_1(componente_immagine-1) & N_P_1_1(componente_immagine-1) & N_P_1_1 & "0"; P_P_B_1_1 <= (others => '0');
                    when "1111" => P_P_A_1_1 <= N_P_1_1(componente_immagine-1) & N_P_1_1(componente_immagine-1) & N_P_1_1(componente_immagine-1) & N_P_1_1(componente_immagine-1) & N_P_1_1; P_P_B_1_1 <= (others => '0');
                    when others => P_P_A_1_1 <= (others => '0'); P_P_B_1_1 <= (others => '0');
                end case;

                
                case F_1_2 is
                    when "0000" => P_P_A_1_2 <= (others => '0'); P_P_B_1_2 <= (others => '0');
                    when "0001" => P_P_A_1_2 <= P_1_2(7) & P_1_2(7) & P_1_2(7) & P_1_2(7) & P_1_2; P_P_B_1_2 <= (others => '0');                     
                    when "0010" => P_P_A_1_2 <= N_P_1_2(7) & N_P_1_2(7) & N_P_1_2(7)& N_P_1_2 & "0"; P_P_B_1_2 <= P_1_2(7) & P_1_2(7) & P_1_2 & "00";
                    when "0011" => P_P_A_1_2 <= N_P_1_2(7) & N_P_1_2(7) & N_P_1_2(7) & N_P_1_2(7) & N_P_1_2; P_P_B_1_2 <= P_1_2(7) & P_1_2(7) & P_1_2 & "00";
                    when "0100" => P_P_A_1_2 <= (others => '0'); P_P_B_1_2 <= P_1_2(7) & P_1_2(7) & P_1_2 & "00";
                    when "0101" => P_P_A_1_2 <= P_1_2(7) & P_1_2(7) & P_1_2(7) & P_1_2(7) & P_1_2; P_P_B_1_2 <= P_1_2(7) & P_1_2(7) & P_1_2 & "00";
                    when "0110" | "0111" => P_P_A_1_2 <= N_P_1_2(7) & N_P_1_2(7) & N_P_1_2(7) & N_P_1_2(7) & N_P_1_2; P_P_B_1_2 <= P_1_2(7) & P_1_2 & "000";
                    when "1000" => P_P_A_1_2 <= (others => '0'); P_P_B_1_2 <= N_P_1_2(7) & N_P_1_2 & "000";
                    when "1001" => P_P_A_1_2 <=  P_1_2(7) & P_1_2(7) & P_1_2(7) & P_1_2(7) & P_1_2; P_P_B_1_2 <= N_P_1_2(7) & N_P_1_2 & "000";
                    when "1010" => P_P_A_1_2 <= N_P_1_2(7) & N_P_1_2(7) & N_P_1_2(7) & N_P_1_2 & "0"; P_P_B_1_2 <= N_P_1_2(7) & N_P_1_2(7) & N_P_1_2 & "00";
                    when "1011" => P_P_A_1_2 <= N_P_1_2(7) & N_P_1_2(7) & N_P_1_2(7)& N_P_1_2(7) & N_P_1_2; P_P_B_1_2 <= N_P_1_2(7) & N_P_1_2(7) & N_P_1_2 & "00";
                    when "1100" => P_P_A_1_2 <= (others => '0'); P_P_B_1_2 <= N_P_1_2(7) & N_P_1_2(7) & N_P_1_2 & "00";
                    when "1101" => P_P_A_1_2 <= P_1_2(7) & P_1_2(7) & P_1_2(7) & P_1_2(7) & P_1_2; P_P_B_1_2 <= N_P_1_2(7) & N_P_1_2(7) & N_P_1_2 & "00";
                    when "1110" => P_P_A_1_2 <= N_P_1_2(7) & N_P_1_2(7) & N_P_1_2(7) & N_P_1_2 & "0"; P_P_B_1_2 <= (others => '0');
                    when "1111" => P_P_A_1_2 <= N_P_1_2(7) & N_P_1_2(7) & N_P_1_2(7) & N_P_1_2(7) & N_P_1_2; P_P_B_1_2 <= (others => '0');
                    when others => P_P_A_1_2 <= (others => '0'); P_P_B_1_2 <= (others => '0');
                end case;

                
                case F_1_3 is
                    when "0000" => P_P_A_1_3 <= (others => '0'); P_P_B_1_3 <= (others => '0');
                    when "0001" => P_P_A_1_3 <= P_1_3(7) & P_1_3(7) & P_1_3(7) & P_1_3(7) & P_1_3; P_P_B_1_3 <= (others => '0');                     
                    when "0010" => P_P_A_1_3 <= N_P_1_3(7) & N_P_1_3(7) & N_P_1_3(7)& N_P_1_3 & "0"; P_P_B_1_3 <= P_1_3(7) & P_1_3(7) & P_1_3 & "00";
                    when "0011" => P_P_A_1_3 <= N_P_1_3(7) & N_P_1_3(7) & N_P_1_3(7) & N_P_1_3(7) & N_P_1_3; P_P_B_1_3 <= P_1_3(7) & P_1_3(7) & P_1_3 & "00";
                    when "0100" => P_P_A_1_3 <= (others => '0'); P_P_B_1_3 <= P_1_3(7) & P_1_3(7) & P_1_3 & "00";
                    when "0101" => P_P_A_1_3 <= P_1_3(7) & P_1_3(7) & P_1_3(7) & P_1_3(7) & P_1_3; P_P_B_1_3 <= P_1_3(7) & P_1_3(7) & P_1_3 & "00";
                    when "0110" | "0111" => P_P_A_1_3 <= N_P_1_3(7) & N_P_1_3(7) & N_P_1_3(7) & N_P_1_3(7) & N_P_1_3; P_P_B_1_3 <= P_1_3(7) & P_1_3 & "000";
                    when "1000" => P_P_A_1_3 <= (others => '0'); P_P_B_1_3 <= N_P_1_3(7) & N_P_1_3 & "000";
                    when "1001" => P_P_A_1_3 <=  P_1_3(7) & P_1_3(7) & P_1_3(7) & P_1_3(7) & P_1_3; P_P_B_1_3 <= N_P_1_3(7) & N_P_1_3 & "000";
                    when "1010" => P_P_A_1_3 <= N_P_1_3(7) & N_P_1_3(7) & N_P_1_3(7) & N_P_1_3 & "0"; P_P_B_1_3 <= N_P_1_3(7) & N_P_1_3(7) & N_P_1_3 & "00";
                    when "1011" => P_P_A_1_3 <= N_P_1_3(7) & N_P_1_3(7) & N_P_1_3(7)& N_P_1_3(7) & N_P_1_3; P_P_B_1_3 <= N_P_1_3(7) & N_P_1_3(7) & N_P_1_3 & "00";
                    when "1100" => P_P_A_1_3 <= (others => '0'); P_P_B_1_3 <= N_P_1_3(7) & N_P_1_3(7) & N_P_1_3 & "00";
                    when "1101" => P_P_A_1_3 <= P_1_3(7) & P_1_3(7) & P_1_3(7) & P_1_3(7) & P_1_3; P_P_B_1_3 <= N_P_1_3(7) & N_P_1_3(7) & N_P_1_3 & "00";
                    when "1110" => P_P_A_1_3 <= N_P_1_3(7) & N_P_1_3(7) & N_P_1_3(7) & N_P_1_3 & "0"; P_P_B_1_3 <= (others => '0');
                    when "1111" => P_P_A_1_3 <= N_P_1_3(7) & N_P_1_3(7) & N_P_1_3(7) & N_P_1_3(7) & N_P_1_3; P_P_B_1_3 <= (others => '0');
                    when others => P_P_A_1_3 <= (others => '0'); P_P_B_1_3 <= (others => '0');
                end case;

                
                case F_2_1 is
                    when "0000" => P_P_A_2_1 <= (others => '0'); P_P_B_2_1 <= (others => '0');
                    when "0001" => P_P_A_2_1 <= P_2_1(7) & P_2_1(7) & P_2_1(7) & P_2_1(7) & P_2_1; P_P_B_2_1 <= (others => '0');                     
                    when "0010" => P_P_A_2_1 <= N_P_2_1(7) & N_P_2_1(7) & N_P_2_1(7)& N_P_2_1 & "0"; P_P_B_2_1 <= P_2_1(7) & P_2_1(7) & P_2_1 & "00";
                    when "0011" => P_P_A_2_1 <= N_P_2_1(7) & N_P_2_1(7) & N_P_2_1(7) & N_P_2_1(7) & N_P_2_1; P_P_B_2_1 <= P_2_1(7) & P_2_1(7) & P_2_1 & "00";
                    when "0100" => P_P_A_2_1 <= (others => '0'); P_P_B_2_1 <= P_2_1(7) & P_2_1(7) & P_2_1 & "00";
                    when "0101" => P_P_A_2_1 <= P_2_1(7) & P_2_1(7) & P_2_1(7) & P_2_1(7) & P_2_1; P_P_B_2_1 <= P_2_1(7) & P_2_1(7) & P_2_1 & "00";
                    when "0110" | "0111" => P_P_A_2_1 <= N_P_2_1(7) & N_P_2_1(7) & N_P_2_1(7) & N_P_2_1(7) & N_P_2_1; P_P_B_2_1 <= P_2_1(7) & P_2_1 & "000";
                    when "1000" => P_P_A_2_1 <= (others => '0'); P_P_B_2_1 <= N_P_2_1(7) & N_P_2_1 & "000";
                    when "1001" => P_P_A_2_1 <=  P_2_1(7) & P_2_1(7) & P_2_1(7) & P_2_1(7) & P_2_1; P_P_B_2_1 <= N_P_2_1(7) & N_P_2_1 & "000";
                    when "1010" => P_P_A_2_1 <= N_P_2_1(7) & N_P_2_1(7) & N_P_2_1(7) & N_P_2_1 & "0"; P_P_B_2_1 <= N_P_2_1(7) & N_P_2_1(7) & N_P_2_1 & "00";
                    when "1011" => P_P_A_2_1 <= N_P_2_1(7) & N_P_2_1(7) & N_P_2_1(7)& N_P_2_1(7) & N_P_2_1; P_P_B_2_1 <= N_P_2_1(7) & N_P_2_1(7) & N_P_2_1 & "00";
                    when "1100" => P_P_A_2_1 <= (others => '0'); P_P_B_2_1 <= N_P_2_1(7) & N_P_2_1(7) & N_P_2_1 & "00";
                    when "1101" => P_P_A_2_1 <= P_2_1(7) & P_2_1(7) & P_2_1(7) & P_2_1(7) & P_2_1; P_P_B_2_1 <= N_P_2_1(7) & N_P_2_1(7) & N_P_2_1 & "00";
                    when "1110" => P_P_A_2_1 <= N_P_2_1(7) & N_P_2_1(7) & N_P_2_1(7) & N_P_2_1 & "0"; P_P_B_2_1 <= (others => '0');
                    when "1111" => P_P_A_2_1 <= N_P_2_1(7) & N_P_2_1(7) & N_P_2_1(7) & N_P_2_1(7) & N_P_2_1; P_P_B_2_1 <= (others => '0');
                    when others => P_P_A_2_1 <= (others => '0'); P_P_B_2_1 <= (others => '0');
                end case;

                
                case F_2_2 is
                    when "0000" => P_P_A_2_2 <= (others => '0'); P_P_B_2_2 <= (others => '0');
                    when "0001" => P_P_A_2_2 <= P_2_2(7) & P_2_2(7) & P_2_2(7) & P_2_2(7) & P_2_2; P_P_B_2_2 <= (others => '0');                     
                    when "0010" => P_P_A_2_2 <= N_P_2_2(7) & N_P_2_2(7) & N_P_2_2(7)& N_P_2_2 & "0"; P_P_B_2_2 <= P_2_2(7) & P_2_2(7) & P_2_2 & "00";
                    when "0011" => P_P_A_2_2 <= N_P_2_2(7) & N_P_2_2(7) & N_P_2_2(7) & N_P_2_2(7) & N_P_2_2; P_P_B_2_2 <= P_2_2(7) & P_2_2(7) & P_2_2 & "00";
                    when "0100" => P_P_A_2_2 <= (others => '0'); P_P_B_2_2 <= P_2_2(7) & P_2_2(7) & P_2_2 & "00";
                    when "0101" => P_P_A_2_2 <= P_2_2(7) & P_2_2(7) & P_2_2(7) & P_2_2(7) & P_2_2; P_P_B_2_2 <= P_2_2(7) & P_2_2(7) & P_2_2 & "00";
                    when "0110" | "0111" => P_P_A_2_2 <= N_P_2_2(7) & N_P_2_2(7) & N_P_2_2(7) & N_P_2_2(7) & N_P_2_2; P_P_B_2_2 <= P_2_2(7) & P_2_2 & "000";
                    when "1000" => P_P_A_2_2 <= (others => '0'); P_P_B_2_2 <= N_P_2_2(7) & N_P_2_2 & "000";
                    when "1001" => P_P_A_2_2 <=  P_2_2(7) & P_2_2(7) & P_2_2(7) & P_2_2(7) & P_2_2; P_P_B_2_2 <= N_P_2_2(7) & N_P_2_2 & "000";
                    when "1010" => P_P_A_2_2 <= N_P_2_2(7) & N_P_2_2(7) & N_P_2_2(7) & N_P_2_2 & "0"; P_P_B_2_2 <= N_P_2_2(7) & N_P_2_2(7) & N_P_2_2 & "00";
                    when "1011" => P_P_A_2_2 <= N_P_2_2(7) & N_P_2_2(7) & N_P_2_2(7)& N_P_2_2(7) & N_P_2_2; P_P_B_2_2 <= N_P_2_2(7) & N_P_2_2(7) & N_P_2_2 & "00";
                    when "1100" => P_P_A_2_2 <= (others => '0'); P_P_B_2_2 <= N_P_2_2(7) & N_P_2_2(7) & N_P_2_2 & "00";
                    when "1101" => P_P_A_2_2 <= P_2_2(7) & P_2_2(7) & P_2_2(7) & P_2_2(7) & P_2_2; P_P_B_2_2 <= N_P_2_2(7) & N_P_2_2(7) & N_P_2_2 & "00";
                    when "1110" => P_P_A_2_2 <= N_P_2_2(7) & N_P_2_2(7) & N_P_2_2(7) & N_P_2_2 & "0"; P_P_B_2_2 <= (others => '0');
                    when "1111" => P_P_A_2_2 <= N_P_2_2(7) & N_P_2_2(7) & N_P_2_2(7) & N_P_2_2(7) & N_P_2_2; P_P_B_2_2 <= (others => '0');
                    when others => P_P_A_2_2 <= (others => '0'); P_P_B_2_2 <= (others => '0');
                end case;

                
                case F_2_3 is
                    when "0000" => P_P_A_2_3 <= (others => '0'); P_P_B_2_3 <= (others => '0');
                    when "0001" => P_P_A_2_3 <= P_2_3(7) & P_2_3(7) & P_2_3(7) & P_2_3(7) & P_2_3; P_P_B_2_3 <= (others => '0');                     
                    when "0010" => P_P_A_2_3 <= N_P_2_3(7) & N_P_2_3(7) & N_P_2_3(7)& N_P_2_3 & "0"; P_P_B_2_3 <= P_2_3(7) & P_2_3(7) & P_2_3 & "00";
                    when "0011" => P_P_A_2_3 <= N_P_2_3(7) & N_P_2_3(7) & N_P_2_3(7) & N_P_2_3(7) & N_P_2_3; P_P_B_2_3 <= P_2_3(7) & P_2_3(7) & P_2_3 & "00";
                    when "0100" => P_P_A_2_3 <= (others => '0'); P_P_B_2_3 <= P_2_3(7) & P_2_3(7) & P_2_3 & "00";
                    when "0101" => P_P_A_2_3 <= P_2_3(7) & P_2_3(7) & P_2_3(7) & P_2_3(7) & P_2_3; P_P_B_2_3 <= P_2_3(7) & P_2_3(7) & P_2_3 & "00";
                    when "0110" | "0111" => P_P_A_2_3 <= N_P_2_3(7) & N_P_2_3(7) & N_P_2_3(7) & N_P_2_3(7) & N_P_2_3; P_P_B_2_3 <= P_2_3(7) & P_2_3 & "000";
                    when "1000" => P_P_A_2_3 <= (others => '0'); P_P_B_2_3 <= N_P_2_3(7) & N_P_2_3 & "000";
                    when "1001" => P_P_A_2_3 <=  P_2_3(7) & P_2_3(7) & P_2_3(7) & P_2_3(7) & P_2_3; P_P_B_2_3 <= N_P_2_3(7) & N_P_2_3 & "000";
                    when "1010" => P_P_A_2_3 <= N_P_2_3(7) & N_P_2_3(7) & N_P_2_3(7) & N_P_2_3 & "0"; P_P_B_2_3 <= N_P_2_3(7) & N_P_2_3(7) & N_P_2_3 & "00";
                    when "1011" => P_P_A_2_3 <= N_P_2_3(7) & N_P_2_3(7) & N_P_2_3(7)& N_P_2_3(7) & N_P_2_3; P_P_B_2_3 <= N_P_2_3(7) & N_P_2_3(7) & N_P_2_3 & "00";
                    when "1100" => P_P_A_2_3 <= (others => '0'); P_P_B_2_3 <= N_P_2_3(7) & N_P_2_3(7) & N_P_2_3 & "00";
                    when "1101" => P_P_A_2_3 <= P_2_3(7) & P_2_3(7) & P_2_3(7) & P_2_3(7) & P_2_3; P_P_B_2_3 <= N_P_2_3(7) & N_P_2_3(7) & N_P_2_3 & "00";
                    when "1110" => P_P_A_2_3 <= N_P_2_3(7) & N_P_2_3(7) & N_P_2_3(7) & N_P_2_3 & "0"; P_P_B_2_3 <= (others => '0');
                    when "1111" => P_P_A_2_3 <= N_P_2_3(7) & N_P_2_3(7) & N_P_2_3(7) & N_P_2_3(7) & N_P_2_3; P_P_B_2_3 <= (others => '0');
                    when others => P_P_A_2_3 <= (others => '0'); P_P_B_2_3 <= (others => '0');
                end case;

                
                case F_3_1 is
                    when "0000" => P_P_A_3_1 <= (others => '0'); P_P_B_3_1 <= (others => '0');
                    when "0001" => P_P_A_3_1 <= P_3_1(7) & P_3_1(7) & P_3_1(7) & P_3_1(7) & P_3_1; P_P_B_3_1 <= (others => '0');                     
                    when "0010" => P_P_A_3_1 <= N_P_3_1(7) & N_P_3_1(7) & N_P_3_1(7)& N_P_3_1 & "0"; P_P_B_3_1 <= P_3_1(7) & P_3_1(7) & P_3_1 & "00";
                    when "0011" => P_P_A_3_1 <= N_P_3_1(7) & N_P_3_1(7) & N_P_3_1(7) & N_P_3_1(7) & N_P_3_1; P_P_B_3_1 <= P_3_1(7) & P_3_1(7) & P_3_1 & "00";
                    when "0100" => P_P_A_3_1 <= (others => '0'); P_P_B_3_1 <= P_3_1(7) & P_3_1(7) & P_3_1 & "00";
                    when "0101" => P_P_A_3_1 <= P_3_1(7) & P_3_1(7) & P_3_1(7) & P_3_1(7) & P_3_1; P_P_B_3_1 <= P_3_1(7) & P_3_1(7) & P_3_1 & "00";
                    when "0110" | "0111" => P_P_A_3_1 <= N_P_3_1(7) & N_P_3_1(7) & N_P_3_1(7) & N_P_3_1(7) & N_P_3_1; P_P_B_3_1 <= P_3_1(7) & P_3_1 & "000";
                    when "1000" => P_P_A_3_1 <= (others => '0'); P_P_B_3_1 <= N_P_3_1(7) & N_P_3_1 & "000";
                    when "1001" => P_P_A_3_1 <=  P_3_1(7) & P_3_1(7) & P_3_1(7) & P_3_1(7) & P_3_1; P_P_B_3_1 <= N_P_3_1(7) & N_P_3_1 & "000";
                    when "1010" => P_P_A_3_1 <= N_P_3_1(7) & N_P_3_1(7) & N_P_3_1(7) & N_P_3_1 & "0"; P_P_B_3_1 <= N_P_3_1(7) & N_P_3_1(7) & N_P_3_1 & "00";
                    when "1011" => P_P_A_3_1 <= N_P_3_1(7) & N_P_3_1(7) & N_P_3_1(7)& N_P_3_1(7) & N_P_3_1; P_P_B_3_1 <= N_P_3_1(7) & N_P_3_1(7) & N_P_3_1 & "00";
                    when "1100" => P_P_A_3_1 <= (others => '0'); P_P_B_3_1 <= N_P_3_1(7) & N_P_3_1(7) & N_P_3_1 & "00";
                    when "1101" => P_P_A_3_1 <= P_3_1(7) & P_3_1(7) & P_3_1(7) & P_3_1(7) & P_3_1; P_P_B_3_1 <= N_P_3_1(7) & N_P_3_1(7) & N_P_3_1 & "00";
                    when "1110" => P_P_A_3_1 <= N_P_3_1(7) & N_P_3_1(7) & N_P_3_1(7) & N_P_3_1 & "0"; P_P_B_3_1 <= (others => '0');
                    when "1111" => P_P_A_3_1 <= N_P_3_1(7) & N_P_3_1(7) & N_P_3_1(7) & N_P_3_1(7) & N_P_3_1; P_P_B_3_1 <= (others => '0');
                    when others => P_P_A_3_1 <= (others => '0'); P_P_B_3_1 <= (others => '0');
                end case;

                
                case F_3_2 is
                    when "0000" => P_P_A_3_2 <= (others => '0'); P_P_B_3_2 <= (others => '0');
                    when "0001" => P_P_A_3_2 <= P_3_2(7) & P_3_2(7) & P_3_2(7) & P_3_2(7) & P_3_2; P_P_B_3_2 <= (others => '0');                     
                    when "0010" => P_P_A_3_2 <= N_P_3_2(7) & N_P_3_2(7) & N_P_3_2(7)& N_P_3_2 & "0"; P_P_B_3_2 <= P_3_2(7) & P_3_2(7) & P_3_2 & "00";
                    when "0011" => P_P_A_3_2 <= N_P_3_2(7) & N_P_3_2(7) & N_P_3_2(7) & N_P_3_2(7) & N_P_3_2; P_P_B_3_2 <= P_3_2(7) & P_3_2(7) & P_3_2 & "00";
                    when "0100" => P_P_A_3_2 <= (others => '0'); P_P_B_3_2 <= P_3_2(7) & P_3_2(7) & P_3_2 & "00";
                    when "0101" => P_P_A_3_2 <= P_3_2(7) & P_3_2(7) & P_3_2(7) & P_3_2(7) & P_3_2; P_P_B_3_2 <= P_3_2(7) & P_3_2(7) & P_3_2 & "00";
                    when "0110" | "0111" => P_P_A_3_2 <= N_P_3_2(7) & N_P_3_2(7) & N_P_3_2(7) & N_P_3_2(7) & N_P_3_2; P_P_B_3_2 <= P_3_2(7) & P_3_2 & "000";
                    when "1000" => P_P_A_3_2 <= (others => '0'); P_P_B_3_2 <= N_P_3_2(7) & N_P_3_2 & "000";
                    when "1001" => P_P_A_3_2 <=  P_3_2(7) & P_3_2(7) & P_3_2(7) & P_3_2(7) & P_3_2; P_P_B_3_2 <= N_P_3_2(7) & N_P_3_2 & "000";
                    when "1010" => P_P_A_3_2 <= N_P_3_2(7) & N_P_3_2(7) & N_P_3_2(7) & N_P_3_2 & "0"; P_P_B_3_2 <= N_P_3_2(7) & N_P_3_2(7) & N_P_3_2 & "00";
                    when "1011" => P_P_A_3_2 <= N_P_3_2(7) & N_P_3_2(7) & N_P_3_2(7)& N_P_3_2(7) & N_P_3_2; P_P_B_3_2 <= N_P_3_2(7) & N_P_3_2(7) & N_P_3_2 & "00";
                    when "1100" => P_P_A_3_2 <= (others => '0'); P_P_B_3_2 <= N_P_3_2(7) & N_P_3_2(7) & N_P_3_2 & "00";
                    when "1101" => P_P_A_3_2 <= P_3_2(7) & P_3_2(7) & P_3_2(7) & P_3_2(7) & P_3_2; P_P_B_3_2 <= N_P_3_2(7) & N_P_3_2(7) & N_P_3_2 & "00";
                    when "1110" => P_P_A_3_2 <= N_P_3_2(7) & N_P_3_2(7) & N_P_3_2(7) & N_P_3_2 & "0"; P_P_B_3_2 <= (others => '0');
                    when "1111" => P_P_A_3_2 <= N_P_3_2(7) & N_P_3_2(7) & N_P_3_2(7) & N_P_3_2(7) & N_P_3_2; P_P_B_3_2 <= (others => '0');
                    when others => P_P_A_3_2 <= (others => '0'); P_P_B_3_2 <= (others => '0');
                end case;

                
                case F_3_3 is
                    when "0000" => P_P_A_3_3 <= (others => '0'); P_P_B_3_3 <= (others => '0');
                    when "0001" => P_P_A_3_3 <= P_3_3(7) & P_3_3(7) & P_3_3(7) & P_3_3(7) & P_3_3; P_P_B_3_3 <= (others => '0');                     
                    when "0010" => P_P_A_3_3 <= N_P_3_3(7) & N_P_3_3(7) & N_P_3_3(7)& N_P_3_3 & "0"; P_P_B_3_3 <= P_3_3(7) & P_3_3(7) & P_3_3 & "00";
                    when "0011" => P_P_A_3_3 <= N_P_3_3(7) & N_P_3_3(7) & N_P_3_3(7) & N_P_3_3(7) & N_P_3_3; P_P_B_3_3 <= P_3_3(7) & P_3_3(7) & P_3_3 & "00";
                    when "0100" => P_P_A_3_3 <= (others => '0'); P_P_B_3_3 <= P_3_3(7) & P_3_3(7) & P_3_3 & "00";
                    when "0101" => P_P_A_3_3 <= P_3_3(7) & P_3_3(7) & P_3_3(7) & P_3_3(7) & P_3_3; P_P_B_3_3 <= P_3_3(7) & P_3_3(7) & P_3_3 & "00";
                    when "0110" | "0111" => P_P_A_3_3 <= N_P_3_3(7) & N_P_3_3(7) & N_P_3_3(7) & N_P_3_3(7) & N_P_3_3; P_P_B_3_3 <= P_3_3(7) & P_3_3 & "000";
                    when "1000" => P_P_A_3_3 <= (others => '0'); P_P_B_3_3 <= N_P_3_3(7) & N_P_3_3 & "000";
                    when "1001" => P_P_A_3_3 <=  P_3_3(7) & P_3_3(7) & P_3_3(7) & P_3_3(7) & P_3_3; P_P_B_3_3 <= N_P_3_3(7) & N_P_3_3 & "000";
                    when "1010" => P_P_A_3_3 <= N_P_3_3(7) & N_P_3_3(7) & N_P_3_3(7) & N_P_3_3 & "0"; P_P_B_3_3 <= N_P_3_3(7) & N_P_3_3(7) & N_P_3_3 & "00";
                    when "1011" => P_P_A_3_3 <= N_P_3_3(7) & N_P_3_3(7) & N_P_3_3(7)& N_P_3_3(7) & N_P_3_3; P_P_B_3_3 <= N_P_3_3(7) & N_P_3_3(7) & N_P_3_3 & "00";
                    when "1100" => P_P_A_3_3 <= (others => '0'); P_P_B_3_3 <= N_P_3_3(7) & N_P_3_3(7) & N_P_3_3 & "00";
                    when "1101" => P_P_A_3_3 <= P_3_3(7) & P_3_3(7) & P_3_3(7) & P_3_3(7) & P_3_3; P_P_B_3_3 <= N_P_3_3(7) & N_P_3_3(7) & N_P_3_3 & "00";
                    when "1110" => P_P_A_3_3 <= N_P_3_3(7) & N_P_3_3(7) & N_P_3_3(7) & N_P_3_3 & "0"; P_P_B_3_3 <= (others => '0');
                    when "1111" => P_P_A_3_3 <= N_P_3_3(7) & N_P_3_3(7) & N_P_3_3(7) & N_P_3_3(7) & N_P_3_3; P_P_B_3_3 <= (others => '0');
                    when others => P_P_A_3_3 <= (others => '0'); P_P_B_3_3 <= (others => '0');
                end case;
            end if;
        end if;
    end process;

    RCA1: ripple_carry_adder generic map(N => 12) port map(a => P_P_A_1_1, b => P_P_B_1_1, cin => '0', s => M_1_1, cout => open);
    RCA2: ripple_carry_adder generic map(N => 12) port map(a => P_P_A_1_2, b => P_P_B_1_2, cin => '0', s => M_1_2, cout => open);
    RCA3: ripple_carry_adder generic map(N => 12) port map(a => P_P_A_1_3, b => P_P_B_1_3, cin => '0', s => M_1_3, cout => open);
    RCA4: ripple_carry_adder generic map(N => 12) port map(a => P_P_A_2_1, b => P_P_B_2_1, cin => '0', s => M_2_1, cout => open);
    RCA5: ripple_carry_adder generic map(N => 12) port map(a => P_P_A_2_2, b => P_P_B_2_2, cin => '0', s => M_2_2, cout => open);
    RCA6: ripple_carry_adder generic map(N => 12) port map(a => P_P_A_2_3, b => P_P_B_2_3, cin => '0', s => M_2_3, cout => open);
    RCA7: ripple_carry_adder generic map(N => 12) port map(a => P_P_A_3_1, b => P_P_B_3_1, cin => '0', s => M_3_1, cout => open);
    RCA8: ripple_carry_adder generic map(N => 12) port map(a => P_P_A_3_2, b => P_P_B_3_2, cin => '0', s => M_3_2, cout => open);
    RCA9: ripple_carry_adder generic map(N => 12) port map(a => P_P_A_3_3, b => P_P_B_3_3, cin => '0', s => M_3_3, cout => open);

end architecture;