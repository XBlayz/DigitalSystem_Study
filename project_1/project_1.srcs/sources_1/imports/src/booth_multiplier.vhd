library ieee;
    use ieee.std_logic_1164.all;

entity booth_multiplier is
    generic(
        componente_immagine : POSITIVE := 8;
        coefficiente_filtro : POSITIVE := 4;
        somma : POSITIVE := 12
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

    signal P_P_A_1_1, P_P_B_1_1, P_P_A_1_2, P_P_B_1_2, P_P_A_1_3, P_P_B_1_3 : std_logic_vector(somma-1 downto 0);
    signal P_P_A_2_1, P_P_B_2_1, P_P_A_2_2, P_P_B_2_2, P_P_A_2_3, P_P_B_2_3 : std_logic_vector(somma-1 downto 0);
    signal P_P_A_3_1, P_P_B_3_1, P_P_A_3_2, P_P_B_3_2, P_P_A_3_3, P_P_B_3_3 : std_logic_vector(somma-1 downto 0);

    signal inv_1_1, inv_1_2, inv_1_3 : std_logic_vector(componente_immagine downto 0);
    signal inv_2_1, inv_2_2, inv_2_3 : std_logic_vector(componente_immagine downto 0);
    signal inv_3_1, inv_3_2, inv_3_3 : std_logic_vector(componente_immagine downto 0);

    signal N_P_1_1, N_P_1_2, N_P_1_3 : std_logic_vector(componente_immagine downto 0);
    signal N_P_2_1, N_P_2_2, N_P_2_3 : std_logic_vector(componente_immagine downto 0);
    signal N_P_3_1, N_P_3_2, N_P_3_3 : std_logic_vector(componente_immagine downto 0);

    signal zero: std_logic_vector(componente_immagine downto 0) := (others=>'0');

begin

    inv_1_1 <= std_logic_vector(not ('0' & P_1_1));
    inv_1_2 <= std_logic_vector(not ('0' & P_1_2));
    inv_1_3 <= std_logic_vector(not ('0' & P_1_3));
    inv_2_1 <= std_logic_vector(not ('0' & P_2_1));
    inv_2_2 <= std_logic_vector(not ('0' & P_2_2));
    inv_2_3 <= std_logic_vector(not ('0' & P_2_3));
    inv_3_1 <= std_logic_vector(not ('0' & P_3_1));
    inv_3_2 <= std_logic_vector(not ('0' & P_3_2));
    inv_3_3 <= std_logic_vector(not ('0' & P_3_3));

    RCA1: ripple_carry_adder generic map(N=>componente_immagine+1) port map(a=>inv_1_1, b=>zero, cin=>'1', s=>N_P_1_1, cout=>open);
    RCA2: ripple_carry_adder generic map(N=>componente_immagine+1) port map(a=>inv_1_2, b=>zero, cin=>'1', s=>N_P_1_2, cout=>open);
    RCA3: ripple_carry_adder generic map(N=>componente_immagine+1) port map(a=>inv_1_3, b=>zero, cin=>'1', s=>N_P_1_3, cout=>open);
    RCA4: ripple_carry_adder generic map(N=>componente_immagine+1) port map(a=>inv_2_1, b=>zero, cin=>'1', s=>N_P_2_1, cout=>open);
    RCA5: ripple_carry_adder generic map(N=>componente_immagine+1) port map(a=>inv_2_2, b=>zero, cin=>'1', s=>N_P_2_2, cout=>open);
    RCA6: ripple_carry_adder generic map(N=>componente_immagine+1) port map(a=>inv_2_3, b=>zero, cin=>'1', s=>N_P_2_3, cout=>open);
    RCA7: ripple_carry_adder generic map(N=>componente_immagine+1) port map(a=>inv_3_1, b=>zero, cin=>'1', s=>N_P_3_1, cout=>open);
    RCA8: ripple_carry_adder generic map(N=>componente_immagine+1) port map(a=>inv_3_2, b=>zero, cin=>'1', s=>N_P_3_2, cout=>open);
    RCA9: ripple_carry_adder generic map(N=>componente_immagine+1) port map(a=>inv_3_3, b=>zero, cin=>'1', s=>N_P_3_3, cout=>open);

    process(P_1_1, P_1_2, P_1_3,
            P_2_1, P_2_2, P_2_3, 
            P_3_1, P_3_2, P_3_3,
	    N_P_1_1, N_P_1_2, N_P_1_3,
            N_P_2_1, N_P_2_2, N_P_2_3,    
	    N_P_3_1, N_P_3_2, N_P_3_3,
	    F_1_1, F_1_2, F_1_3,
            F_2_1, F_2_2, F_2_3,
            F_3_1, F_3_2, F_3_3)
    begin
            P_P_A_1_1 <= (others => '0'); P_P_B_1_1 <= (others => '0');
            P_P_A_1_2 <= (others => '0'); P_P_B_1_2 <= (others => '0');
            P_P_A_1_3 <= (others => '0'); P_P_B_1_3 <= (others => '0');
            P_P_A_2_1 <= (others => '0'); P_P_B_2_1 <= (others => '0');
            P_P_A_2_2 <= (others => '0'); P_P_B_2_2 <= (others => '0');
            P_P_A_2_3 <= (others => '0'); P_P_B_2_3 <= (others => '0');
            P_P_A_3_1 <= (others => '0'); P_P_B_3_1 <= (others => '0');
            P_P_A_3_2 <= (others => '0'); P_P_B_3_2 <= (others => '0');
            P_P_A_3_3 <= (others => '0'); P_P_B_3_3 <= (others => '0');

            case F_1_1 is
                    when "0000" => P_P_A_1_1 <= (others => '0'); P_P_B_1_1 <= (others => '0');
                    when "0001" => P_P_A_1_1 <= "0000" & P_1_1; P_P_B_1_1 <= (others => '0');
                    when "0010" => P_P_A_1_1 <= N_P_1_1(componente_immagine) & N_P_1_1(componente_immagine)& N_P_1_1 & "0"; P_P_B_1_1 <= "00" & P_1_1 & "00";
                    when "0011" => P_P_A_1_1 <= N_P_1_1(componente_immagine) & N_P_1_1(componente_immagine) & N_P_1_1(componente_immagine) & N_P_1_1; P_P_B_1_1 <= "00" & P_1_1 & "00";
                    when "0100" => P_P_A_1_1 <= (others => '0'); P_P_B_1_1 <= "00" & P_1_1 & "00";
                    when "0101" => P_P_A_1_1 <= "0000" & P_1_1; P_P_B_1_1 <= "00" & P_1_1 & "00";
                    when "0110" => P_P_A_1_1 <= N_P_1_1(componente_immagine) & N_P_1_1(componente_immagine) & N_P_1_1 & "0"; P_P_B_1_1 <= "0" & P_1_1 & "000";
                    when "0111" => P_P_A_1_1 <= N_P_1_1(componente_immagine) & N_P_1_1(componente_immagine) & N_P_1_1(componente_immagine) & N_P_1_1; P_P_B_1_1 <= "0" & P_1_1 & "000";
                    when "1000" => P_P_A_1_1 <= (others => '0'); P_P_B_1_1 <= N_P_1_1 & "000";
                    when "1001" => P_P_A_1_1 <=  "0000" & P_1_1; P_P_B_1_1 <= N_P_1_1 & "000";
                    when "1010" => P_P_A_1_1 <= N_P_1_1(componente_immagine) & N_P_1_1(componente_immagine) & N_P_1_1 & "0"; P_P_B_1_1 <= N_P_1_1(componente_immagine) & N_P_1_1 & "00";
                    when "1011" => P_P_A_1_1 <= N_P_1_1(componente_immagine) & N_P_1_1(componente_immagine) & N_P_1_1(componente_immagine) & N_P_1_1; P_P_B_1_1 <= N_P_1_1(componente_immagine) & N_P_1_1 & "00";
                    when "1100" => P_P_A_1_1 <= (others => '0'); P_P_B_1_1 <= N_P_1_1(componente_immagine) & N_P_1_1 & "00";
                    when "1101" => P_P_A_1_1 <= "0000" & P_1_1; P_P_B_1_1 <= N_P_1_1(componente_immagine) & N_P_1_1 & "00";
                    when "1110" => P_P_A_1_1 <= N_P_1_1(componente_immagine) & N_P_1_1(componente_immagine) & N_P_1_1 & "0"; P_P_B_1_1 <= (others => '0');
                    when "1111" => P_P_A_1_1 <= N_P_1_1(componente_immagine) & N_P_1_1(componente_immagine) & N_P_1_1(componente_immagine) & N_P_1_1; P_P_B_1_1 <= (others => '0');
                    when others => P_P_A_1_1 <= (others => '0'); P_P_B_1_1 <= (others => '0');
                end case;

                case F_1_2 is
                    when "0000" => P_P_A_1_2 <= (others => '0'); P_P_B_1_2 <= (others => '0');
                    when "0001" => P_P_A_1_2 <= "0000" & P_1_2; P_P_B_1_2 <= (others => '0');
                    when "0010" => P_P_A_1_2 <= N_P_1_2(componente_immagine) & N_P_1_2(componente_immagine)& N_P_1_2 & "0"; P_P_B_1_2 <= "00" & P_1_2 & "00";
                    when "0011" => P_P_A_1_2 <= N_P_1_2(componente_immagine) & N_P_1_2(componente_immagine) & N_P_1_2(componente_immagine) & N_P_1_2; P_P_B_1_2 <= "00" & P_1_2 & "00";
                    when "0100" => P_P_A_1_2 <= (others => '0'); P_P_B_1_2 <= "00" & P_1_2 & "00";
                    when "0101" => P_P_A_1_2 <= "0000" & P_1_2; P_P_B_1_2 <= "00" & P_1_2 & "00";
                    when "0110" => P_P_A_1_2 <= N_P_1_2(componente_immagine) & N_P_1_2(componente_immagine) & N_P_1_2 & "0"; P_P_B_1_2 <= "0" & P_1_2 & "000";
                    when "0111" => P_P_A_1_2 <= N_P_1_2(componente_immagine) & N_P_1_2(componente_immagine) & N_P_1_2(componente_immagine) & N_P_1_2; P_P_B_1_2 <= "0" & P_1_2 & "000";
                    when "1000" => P_P_A_1_2 <= (others => '0'); P_P_B_1_2 <= N_P_1_2 & "000";
                    when "1001" => P_P_A_1_2 <=  "0000" & P_1_2; P_P_B_1_2 <= N_P_1_2 & "000";
                    when "1010" => P_P_A_1_2 <= N_P_1_2(componente_immagine) & N_P_1_2(componente_immagine) & N_P_1_2 & "0"; P_P_B_1_2 <= N_P_1_2(componente_immagine) & N_P_1_2 & "00";
                    when "1011" => P_P_A_1_2 <= N_P_1_2(componente_immagine) & N_P_1_2(componente_immagine) & N_P_1_2(componente_immagine) & N_P_1_2; P_P_B_1_2 <= N_P_1_2(componente_immagine) & N_P_1_2 & "00";
                    when "1100" => P_P_A_1_2 <= (others => '0'); P_P_B_1_2 <= N_P_1_2(componente_immagine) & N_P_1_2 & "00";
                    when "1101" => P_P_A_1_2 <= "0000" & P_1_2; P_P_B_1_2 <= N_P_1_2(componente_immagine) & N_P_1_2 & "00";
                    when "1110" => P_P_A_1_2 <= N_P_1_2(componente_immagine) & N_P_1_2(componente_immagine) & N_P_1_2 & "0"; P_P_B_1_2 <= (others => '0');
                    when "1111" => P_P_A_1_2 <= N_P_1_2(componente_immagine) & N_P_1_2(componente_immagine) & N_P_1_2(componente_immagine) & N_P_1_2; P_P_B_1_2 <= (others => '0');
                    when others => P_P_A_1_2 <= (others => '0'); P_P_B_1_2 <= (others => '0');
                end case;

                case F_1_3 is
                    when "0000" => P_P_A_1_3 <= (others => '0'); P_P_B_1_3 <= (others => '0');
                    when "0001" => P_P_A_1_3 <= "0000" & P_1_3; P_P_B_1_3 <= (others => '0');
                    when "0010" => P_P_A_1_3 <= N_P_1_3(componente_immagine) & N_P_1_3(componente_immagine)& N_P_1_3 & "0"; P_P_B_1_3 <= "00" & P_1_3 & "00";
                    when "0011" => P_P_A_1_3 <= N_P_1_3(componente_immagine) & N_P_1_3(componente_immagine) & N_P_1_3(componente_immagine) & N_P_1_3; P_P_B_1_3 <= "00" & P_1_3 & "00";
                    when "0100" => P_P_A_1_3 <= (others => '0'); P_P_B_1_3 <= "00" & P_1_3 & "00";
                    when "0101" => P_P_A_1_3 <= "0000" & P_1_3; P_P_B_1_3 <= "00" & P_1_3 & "00";
                    when "0110" => P_P_A_1_3 <= N_P_1_3(componente_immagine) & N_P_1_3(componente_immagine) & N_P_1_3 & "0"; P_P_B_1_3 <= "0" & P_1_3 & "000";
                    when "0111" => P_P_A_1_3 <= N_P_1_3(componente_immagine) & N_P_1_3(componente_immagine) & N_P_1_3(componente_immagine) & N_P_1_3; P_P_B_1_3 <= "0" & P_1_3 & "000";
                    when "1000" => P_P_A_1_3 <= (others => '0'); P_P_B_1_3 <= N_P_1_3 & "000";
                    when "1001" => P_P_A_1_3 <=  "0000" & P_1_3; P_P_B_1_3 <= N_P_1_3 & "000";
                    when "1010" => P_P_A_1_3 <= N_P_1_3(componente_immagine) & N_P_1_3(componente_immagine) & N_P_1_3 & "0"; P_P_B_1_3 <= N_P_1_3(componente_immagine) & N_P_1_3 & "00";
                    when "1011" => P_P_A_1_3 <= N_P_1_3(componente_immagine) & N_P_1_3(componente_immagine) & N_P_1_3(componente_immagine) & N_P_1_3; P_P_B_1_3 <= N_P_1_3(componente_immagine) & N_P_1_3 & "00";
                    when "1100" => P_P_A_1_3 <= (others => '0'); P_P_B_1_3 <= N_P_1_3(componente_immagine) & N_P_1_3 & "00";
                    when "1101" => P_P_A_1_3 <= "0000" & P_1_3; P_P_B_1_3 <= N_P_1_3(componente_immagine) & N_P_1_3 & "00";
                    when "1110" => P_P_A_1_3 <= N_P_1_3(componente_immagine) & N_P_1_3(componente_immagine) & N_P_1_3 & "0"; P_P_B_1_3 <= (others => '0');
                    when "1111" => P_P_A_1_3 <= N_P_1_3(componente_immagine) & N_P_1_3(componente_immagine) & N_P_1_3(componente_immagine) & N_P_1_3; P_P_B_1_3 <= (others => '0');
                    when others => P_P_A_1_3 <= (others => '0'); P_P_B_1_3 <= (others => '0');
                end case;

                case F_2_1 is
                    when "0000" => P_P_A_2_1 <= (others => '0'); P_P_B_2_1 <= (others => '0');
                    when "0001" => P_P_A_2_1 <= "0000" & P_2_1; P_P_B_2_1 <= (others => '0');
                    when "0010" => P_P_A_2_1 <= N_P_2_1(componente_immagine) & N_P_2_1(componente_immagine)& N_P_2_1 & "0"; P_P_B_2_1 <= "00" & P_2_1 & "00";
                    when "0011" => P_P_A_2_1 <= N_P_2_1(componente_immagine) & N_P_2_1(componente_immagine) & N_P_2_1(componente_immagine) & N_P_2_1; P_P_B_2_1 <= "00" & P_2_1 & "00";
                    when "0100" => P_P_A_2_1 <= (others => '0'); P_P_B_2_1 <= "00" & P_2_1 & "00";
                    when "0101" => P_P_A_2_1 <= "0000" & P_2_1; P_P_B_2_1 <= "00" & P_2_1 & "00";
                    when "0110" => P_P_A_2_1 <= N_P_2_1(componente_immagine) & N_P_2_1(componente_immagine) & N_P_2_1 & "0"; P_P_B_2_1 <= "0" & P_2_1 & "000";
                    when "0111" => P_P_A_2_1 <= N_P_2_1(componente_immagine) & N_P_2_1(componente_immagine) & N_P_2_1(componente_immagine) & N_P_2_1; P_P_B_2_1 <= "0" & P_2_1 & "000";
                    when "1000" => P_P_A_2_1 <= (others => '0'); P_P_B_2_1 <= N_P_2_1 & "000";
                    when "1001" => P_P_A_2_1 <=  "0000" & P_2_1; P_P_B_2_1 <= N_P_2_1 & "000";
                    when "1010" => P_P_A_2_1 <= N_P_2_1(componente_immagine) & N_P_2_1(componente_immagine) & N_P_2_1 & "0"; P_P_B_2_1 <= N_P_2_1(componente_immagine) & N_P_2_1 & "00";
                    when "1011" => P_P_A_2_1 <= N_P_2_1(componente_immagine) & N_P_2_1(componente_immagine) & N_P_2_1(componente_immagine) & N_P_2_1; P_P_B_2_1 <= N_P_2_1(componente_immagine) & N_P_2_1 & "00";
                    when "1100" => P_P_A_2_1 <= (others => '0'); P_P_B_2_1 <= N_P_2_1(componente_immagine) & N_P_2_1 & "00";
                    when "1101" => P_P_A_2_1 <= "0000" & P_2_1; P_P_B_2_1 <= N_P_2_1(componente_immagine) & N_P_2_1 & "00";
                    when "1110" => P_P_A_2_1 <= N_P_2_1(componente_immagine) & N_P_2_1(componente_immagine) & N_P_2_1 & "0"; P_P_B_2_1 <= (others => '0');
                    when "1111" => P_P_A_2_1 <= N_P_2_1(componente_immagine) & N_P_2_1(componente_immagine) & N_P_2_1(componente_immagine) & N_P_2_1; P_P_B_2_1 <= (others => '0');
                    when others => P_P_A_2_1 <= (others => '0'); P_P_B_2_1 <= (others => '0');
                end case;

                case F_2_2 is
                    when "0000" => P_P_A_2_2 <= (others => '0'); P_P_B_2_2 <= (others => '0');
                    when "0001" => P_P_A_2_2 <= "0000" & P_2_2; P_P_B_2_2 <= (others => '0');
                    when "0010" => P_P_A_2_2 <= N_P_2_2(componente_immagine) & N_P_2_2(componente_immagine)& N_P_2_2 & "0"; P_P_B_2_2 <= "00" & P_2_2 & "00";
                    when "0011" => P_P_A_2_2 <= N_P_2_2(componente_immagine) & N_P_2_2(componente_immagine) & N_P_2_2(componente_immagine) & N_P_2_2; P_P_B_2_2 <= "00" & P_2_2 & "00";
                    when "0100" => P_P_A_2_2 <= (others => '0'); P_P_B_2_2 <= "00" & P_2_2 & "00";
                    when "0101" => P_P_A_2_2 <= "0000" & P_2_2; P_P_B_2_2 <= "00" & P_2_2 & "00";
                    when "0110" => P_P_A_2_2 <= N_P_2_2(componente_immagine) & N_P_2_2(componente_immagine) & N_P_2_2 & "0"; P_P_B_2_2 <= "0" & P_2_2 & "000";
                    when "0111" => P_P_A_2_2 <= N_P_2_2(componente_immagine) & N_P_2_2(componente_immagine) & N_P_2_2(componente_immagine) & N_P_2_2; P_P_B_2_2 <= "0" & P_2_2 & "000";
                    when "1000" => P_P_A_2_2 <= (others => '0'); P_P_B_2_2 <= N_P_2_2 & "000";
                    when "1001" => P_P_A_2_2 <=  "0000" & P_2_2; P_P_B_2_2 <= N_P_2_2 & "000";
                    when "1010" => P_P_A_2_2 <= N_P_2_2(componente_immagine) & N_P_2_2(componente_immagine) & N_P_2_2 & "0"; P_P_B_2_2 <= N_P_2_2(componente_immagine) & N_P_2_2 & "00";
                    when "1011" => P_P_A_2_2 <= N_P_2_2(componente_immagine) & N_P_2_2(componente_immagine) & N_P_2_2(componente_immagine) & N_P_2_2; P_P_B_2_2 <= N_P_2_2(componente_immagine) & N_P_2_2 & "00";
                    when "1100" => P_P_A_2_2 <= (others => '0'); P_P_B_2_2 <= N_P_2_2(componente_immagine) & N_P_2_2 & "00";
                    when "1101" => P_P_A_2_2 <= "0000" & P_2_2; P_P_B_2_2 <= N_P_2_2(componente_immagine) & N_P_2_2 & "00";
                    when "1110" => P_P_A_2_2 <= N_P_2_2(componente_immagine) & N_P_2_2(componente_immagine) & N_P_2_2 & "0"; P_P_B_2_2 <= (others => '0');
                    when "1111" => P_P_A_2_2 <= N_P_2_2(componente_immagine) & N_P_2_2(componente_immagine) & N_P_2_2(componente_immagine) & N_P_2_2; P_P_B_2_2 <= (others => '0');
                    when others => P_P_A_2_2 <= (others => '0'); P_P_B_2_2 <= (others => '0');
                end case;

                case F_2_3 is
                    when "0000" => P_P_A_2_3 <= (others => '0'); P_P_B_2_3 <= (others => '0');
                    when "0001" => P_P_A_2_3 <= "0000" & P_2_3; P_P_B_2_3 <= (others => '0');
                    when "0010" => P_P_A_2_3 <= N_P_2_3(componente_immagine) & N_P_2_3(componente_immagine)& N_P_2_3 & "0"; P_P_B_2_3 <= "00" & P_2_3 & "00";
                    when "0011" => P_P_A_2_3 <= N_P_2_3(componente_immagine) & N_P_2_3(componente_immagine) & N_P_2_3(componente_immagine) & N_P_2_3; P_P_B_2_3 <= "00" & P_2_3 & "00";
                    when "0100" => P_P_A_2_3 <= (others => '0'); P_P_B_2_3 <= "00" & P_2_3 & "00";
                    when "0101" => P_P_A_2_3 <= "0000" & P_2_3; P_P_B_2_3 <= "00" & P_2_3 & "00";
                    when "0110" => P_P_A_2_3 <= N_P_2_3(componente_immagine) & N_P_2_3(componente_immagine) & N_P_2_3 & "0"; P_P_B_2_3 <= "0" & P_2_3 & "000";
                    when "0111" => P_P_A_2_3 <= N_P_2_3(componente_immagine) & N_P_2_3(componente_immagine) & N_P_2_3(componente_immagine) & N_P_2_3; P_P_B_2_3 <= "0" & P_2_3 & "000";
                    when "1000" => P_P_A_2_3 <= (others => '0'); P_P_B_2_3 <= N_P_2_3 & "000";
                    when "1001" => P_P_A_2_3 <=  "0000" & P_2_3; P_P_B_2_3 <= N_P_2_3 & "000";
                    when "1010" => P_P_A_2_3 <= N_P_2_3(componente_immagine) & N_P_2_3(componente_immagine) & N_P_2_3 & "0"; P_P_B_2_3 <= N_P_2_3(componente_immagine) & N_P_2_3 & "00";
                    when "1011" => P_P_A_2_3 <= N_P_2_3(componente_immagine) & N_P_2_3(componente_immagine) & N_P_2_3(componente_immagine) & N_P_2_3; P_P_B_2_3 <= N_P_2_3(componente_immagine) & N_P_2_3 & "00";
                    when "1100" => P_P_A_2_3 <= (others => '0'); P_P_B_2_3 <= N_P_2_3(componente_immagine) & N_P_2_3 & "00";
                    when "1101" => P_P_A_2_3 <= "0000" & P_2_3; P_P_B_2_3 <= N_P_2_3(componente_immagine) & N_P_2_3 & "00";
                    when "1110" => P_P_A_2_3 <= N_P_2_3(componente_immagine) & N_P_2_3(componente_immagine) & N_P_2_3 & "0"; P_P_B_2_3 <= (others => '0');
                    when "1111" => P_P_A_2_3 <= N_P_2_3(componente_immagine) & N_P_2_3(componente_immagine) & N_P_2_3(componente_immagine) & N_P_2_3; P_P_B_2_3 <= (others => '0');
                    when others => P_P_A_2_3 <= (others => '0'); P_P_B_2_3 <= (others => '0');
                end case;

                case F_3_1 is
                    when "0000" => P_P_A_3_1 <= (others => '0'); P_P_B_3_1 <= (others => '0');
                    when "0001" => P_P_A_3_1 <= "0000" & P_3_1; P_P_B_3_1 <= (others => '0');
                    when "0010" => P_P_A_3_1 <= N_P_3_1(componente_immagine) & N_P_3_1(componente_immagine)& N_P_3_1 & "0"; P_P_B_3_1 <= "00" & P_3_1 & "00";
                    when "0011" => P_P_A_3_1 <= N_P_3_1(componente_immagine) & N_P_3_1(componente_immagine) & N_P_3_1(componente_immagine) & N_P_3_1; P_P_B_3_1 <= "00" & P_3_1 & "00";
                    when "0100" => P_P_A_3_1 <= (others => '0'); P_P_B_3_1 <= "00" & P_3_1 & "00";
                    when "0101" => P_P_A_3_1 <= "0000" & P_3_1; P_P_B_3_1 <= "00" & P_3_1 & "00";
                    when "0110" => P_P_A_3_1 <= N_P_3_1(componente_immagine) & N_P_3_1(componente_immagine) & N_P_3_1 & "0"; P_P_B_3_1 <= "0" & P_3_1 & "000";
                    when "0111" => P_P_A_3_1 <= N_P_3_1(componente_immagine) & N_P_3_1(componente_immagine) & N_P_3_1(componente_immagine) & N_P_3_1; P_P_B_3_1 <= "0" & P_3_1 & "000";
                    when "1000" => P_P_A_3_1 <= (others => '0'); P_P_B_3_1 <= N_P_3_1 & "000";
                    when "1001" => P_P_A_3_1 <=  "0000" & P_3_1; P_P_B_3_1 <= N_P_3_1 & "000";
                    when "1010" => P_P_A_3_1 <= N_P_3_1(componente_immagine) & N_P_3_1(componente_immagine) & N_P_3_1 & "0"; P_P_B_3_1 <= N_P_3_1(componente_immagine) & N_P_3_1 & "00";
                    when "1011" => P_P_A_3_1 <= N_P_3_1(componente_immagine) & N_P_3_1(componente_immagine) & N_P_3_1(componente_immagine) & N_P_3_1; P_P_B_3_1 <= N_P_3_1(componente_immagine) & N_P_3_1 & "00";
                    when "1100" => P_P_A_3_1 <= (others => '0'); P_P_B_3_1 <= N_P_3_1(componente_immagine) & N_P_3_1 & "00";
                    when "1101" => P_P_A_3_1 <= "0000" & P_3_1; P_P_B_3_1 <= N_P_3_1(componente_immagine) & N_P_3_1 & "00";
                    when "1110" => P_P_A_3_1 <= N_P_3_1(componente_immagine) & N_P_3_1(componente_immagine) & N_P_3_1 & "0"; P_P_B_3_1 <= (others => '0');
                    when "1111" => P_P_A_3_1 <= N_P_3_1(componente_immagine) & N_P_3_1(componente_immagine) & N_P_3_1(componente_immagine) & N_P_3_1; P_P_B_3_1 <= (others => '0');
                    when others => P_P_A_3_1 <= (others => '0'); P_P_B_3_1 <= (others => '0');
                end case;

                case F_3_2 is
                    when "0000" => P_P_A_3_2 <= (others => '0'); P_P_B_3_2 <= (others => '0');
                    when "0001" => P_P_A_3_2 <= "0000" & P_3_2; P_P_B_3_2 <= (others => '0');
                    when "0010" => P_P_A_3_2 <= N_P_3_2(componente_immagine) & N_P_3_2(componente_immagine)& N_P_3_2 & "0"; P_P_B_3_2 <= "00" & P_3_2 & "00";
                    when "0011" => P_P_A_3_2 <= N_P_3_2(componente_immagine) & N_P_3_2(componente_immagine) & N_P_3_2(componente_immagine) & N_P_3_2; P_P_B_3_2 <= "00" & P_3_2 & "00";
                    when "0100" => P_P_A_3_2 <= (others => '0'); P_P_B_3_2 <= "00" & P_3_2 & "00";
                    when "0101" => P_P_A_3_2 <= "0000" & P_3_2; P_P_B_3_2 <= "00" & P_3_2 & "00";
                    when "0110" => P_P_A_3_2 <= N_P_3_2(componente_immagine) & N_P_3_2(componente_immagine) & N_P_3_2 & "0"; P_P_B_3_2 <= "0" & P_3_2 & "000";
                    when "0111" => P_P_A_3_2 <= N_P_3_2(componente_immagine) & N_P_3_2(componente_immagine) & N_P_3_2(componente_immagine) & N_P_3_2; P_P_B_3_2 <= "0" & P_3_2 & "000";
                    when "1000" => P_P_A_3_2 <= (others => '0'); P_P_B_3_2 <= N_P_3_2 & "000";
                    when "1001" => P_P_A_3_2 <=  "0000" & P_3_2; P_P_B_3_2 <= N_P_3_2 & "000";
                    when "1010" => P_P_A_3_2 <= N_P_3_2(componente_immagine) & N_P_3_2(componente_immagine) & N_P_3_2 & "0"; P_P_B_3_2 <= N_P_3_2(componente_immagine) & N_P_3_2 & "00";
                    when "1011" => P_P_A_3_2 <= N_P_3_2(componente_immagine) & N_P_3_2(componente_immagine) & N_P_3_2(componente_immagine) & N_P_3_2; P_P_B_3_2 <= N_P_3_2(componente_immagine) & N_P_3_2 & "00";
                    when "1100" => P_P_A_3_2 <= (others => '0'); P_P_B_3_2 <= N_P_3_2(componente_immagine) & N_P_3_2 & "00";
                    when "1101" => P_P_A_3_2 <= "0000" & P_3_2; P_P_B_3_2 <= N_P_3_2(componente_immagine) & N_P_3_2 & "00";
                    when "1110" => P_P_A_3_2 <= N_P_3_2(componente_immagine) & N_P_3_2(componente_immagine) & N_P_3_2 & "0"; P_P_B_3_2 <= (others => '0');
                    when "1111" => P_P_A_3_2 <= N_P_3_2(componente_immagine) & N_P_3_2(componente_immagine) & N_P_3_2(componente_immagine) & N_P_3_2; P_P_B_3_2 <= (others => '0');
                    when others => P_P_A_3_2 <= (others => '0'); P_P_B_3_2 <= (others => '0');
                end case;

                case F_3_3 is
                    when "0000" => P_P_A_3_3 <= (others => '0'); P_P_B_3_3 <= (others => '0');
                    when "0001" => P_P_A_3_3 <= "0000" & P_3_3; P_P_B_3_3 <= (others => '0');
                    when "0010" => P_P_A_3_3 <= N_P_3_3(componente_immagine) & N_P_3_3(componente_immagine)& N_P_3_3 & "0"; P_P_B_3_3 <= "00" & P_3_3 & "00";
                    when "0011" => P_P_A_3_3 <= N_P_3_3(componente_immagine) & N_P_3_3(componente_immagine) & N_P_3_3(componente_immagine) & N_P_3_3; P_P_B_3_3 <= "00" & P_3_3 & "00";
                    when "0100" => P_P_A_3_3 <= (others => '0'); P_P_B_3_3 <= "00" & P_3_3 & "00";
                    when "0101" => P_P_A_3_3 <= "0000" & P_3_3; P_P_B_3_3 <= "00" & P_3_3 & "00";
                    when "0110" => P_P_A_3_3 <= N_P_3_3(componente_immagine) & N_P_3_3(componente_immagine) & N_P_3_3 & "0"; P_P_B_3_3 <= "0" & P_3_3 & "000";
                    when "0111" => P_P_A_3_3 <= N_P_3_3(componente_immagine) & N_P_3_3(componente_immagine) & N_P_3_3(componente_immagine) & N_P_3_3; P_P_B_3_3 <= "0" & P_3_3 & "000";
                    when "1000" => P_P_A_3_3 <= (others => '0'); P_P_B_3_3 <= N_P_3_3 & "000";
                    when "1001" => P_P_A_3_3 <=  "0000" & P_3_3; P_P_B_3_3 <= N_P_3_3 & "000";
                    when "1010" => P_P_A_3_3 <= N_P_3_3(componente_immagine) & N_P_3_3(componente_immagine) & N_P_3_3 & "0"; P_P_B_3_3 <= N_P_3_3(componente_immagine) & N_P_3_3 & "00";
                    when "1011" => P_P_A_3_3 <= N_P_3_3(componente_immagine) & N_P_3_3(componente_immagine) & N_P_3_3(componente_immagine) & N_P_3_3; P_P_B_3_3 <= N_P_3_3(componente_immagine) & N_P_3_3 & "00";
                    when "1100" => P_P_A_3_3 <= (others => '0'); P_P_B_3_3 <= N_P_3_3(componente_immagine) & N_P_3_3 & "00";
                    when "1101" => P_P_A_3_3 <= "0000" & P_3_3; P_P_B_3_3 <= N_P_3_3(componente_immagine) & N_P_3_3 & "00";
                    when "1110" => P_P_A_3_3 <= N_P_3_3(componente_immagine) & N_P_3_3(componente_immagine) & N_P_3_3 & "0"; P_P_B_3_3 <= (others => '0');
                    when "1111" => P_P_A_3_3 <= N_P_3_3(componente_immagine) & N_P_3_3(componente_immagine) & N_P_3_3(componente_immagine) & N_P_3_3; P_P_B_3_3 <= (others => '0');
                    when others => P_P_A_3_3 <= (others => '0'); P_P_B_3_3 <= (others => '0');
                end case;
    end process;

    RCA10: ripple_carry_adder generic map(N => somma) port map(a => P_P_A_1_1, b => P_P_B_1_1, cin => '0', s => M_1_1, cout => open);
    RCA11: ripple_carry_adder generic map(N => somma) port map(a => P_P_A_1_2, b => P_P_B_1_2, cin => '0', s => M_1_2, cout => open);
    RCA12: ripple_carry_adder generic map(N => somma) port map(a => P_P_A_1_3, b => P_P_B_1_3, cin => '0', s => M_1_3, cout => open);
    RCA13: ripple_carry_adder generic map(N => somma) port map(a => P_P_A_2_1, b => P_P_B_2_1, cin => '0', s => M_2_1, cout => open);
    RCA14: ripple_carry_adder generic map(N => somma) port map(a => P_P_A_2_2, b => P_P_B_2_2, cin => '0', s => M_2_2, cout => open);
    RCA15: ripple_carry_adder generic map(N => somma) port map(a => P_P_A_2_3, b => P_P_B_2_3, cin => '0', s => M_2_3, cout => open);
    RCA16: ripple_carry_adder generic map(N => somma) port map(a => P_P_A_3_1, b => P_P_B_3_1, cin => '0', s => M_3_1, cout => open);
    RCA17: ripple_carry_adder generic map(N => somma) port map(a => P_P_A_3_2, b => P_P_B_3_2, cin => '0', s => M_3_2, cout => open);
    RCA18: ripple_carry_adder generic map(N => somma) port map(a => P_P_A_3_3, b => P_P_B_3_3, cin => '0', s => M_3_3, cout => open);

end architecture Structural;
