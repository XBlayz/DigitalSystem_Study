library ieee;
    use ieee.std_logic_1164.all;

entity booth_multiplier_matrix is
    generic(
        img_nbit : POSITIVE := 8
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
end booth_multiplier_matrix;

architecture Instantiation of booth_multiplier_matrix is
    component booth_multiplier is
        generic (
            a_nbit : POSITIVE := 8
        );

        port(
            a : in std_logic_vector(a_nbit - 1 downto 0);
            b : in std_logic_vector(4 - 1 downto 0);
            r : out std_logic_vector(a_nbit + 4 - 1 downto 0)
        );
    end component booth_multiplier;

begin
    bm_11: booth_multiplier generic map(a_nbit => img_nbit) port map(a => P_1_1, b => F_1_1, r => M_1_1);
    bm_12: booth_multiplier generic map(a_nbit => img_nbit) port map(a => P_1_2, b => F_1_2, r => M_1_2);
    bm_13: booth_multiplier generic map(a_nbit => img_nbit) port map(a => P_1_3, b => F_1_3, r => M_1_3);
    bm_21: booth_multiplier generic map(a_nbit => img_nbit) port map(a => P_2_1, b => F_2_1, r => M_2_1);
    bm_22: booth_multiplier generic map(a_nbit => img_nbit) port map(a => P_2_2, b => F_2_2, r => M_2_2);
    bm_23: booth_multiplier generic map(a_nbit => img_nbit) port map(a => P_2_3, b => F_2_3, r => M_2_3);
    bm_31: booth_multiplier generic map(a_nbit => img_nbit) port map(a => P_3_1, b => F_3_1, r => M_3_1);
    bm_32: booth_multiplier generic map(a_nbit => img_nbit) port map(a => P_3_2, b => F_3_2, r => M_3_2);
    bm_33: booth_multiplier generic map(a_nbit => img_nbit) port map(a => P_3_3, b => F_3_3, r => M_3_3);

end Instantiation;
