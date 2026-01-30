

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_moltiplicatore is
end entity tb_moltiplicatore;

architecture testing of tb_moltiplicatore is
    constant comp_i : POSITIVE := 8;
    constant coeff_f : POSITIVE := 4;
    constant sum : POSITIVE := comp_i+coeff_f;
    constant CLK_PERIOD : time := 10 ns;
    
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
    bm: component booth_multiplier
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
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;
    
    stim_proc : process
    begin
        reset <= '1';
        valid <= '0';
        wait for 20 ns;
        reset <= '0';
        wait for 10 ns;

        
        F_1_1 <= std_logic_vector(to_signed(1, coeff_f));
        F_1_2 <= std_logic_vector(to_signed(2, coeff_f));
        F_1_3 <= std_logic_vector(to_signed(1, coeff_f));
        
        F_2_1 <= std_logic_vector(to_signed(2, coeff_f));
        F_2_2 <= std_logic_vector(to_signed(4, coeff_f));
        F_2_3 <= std_logic_vector(to_signed(2, coeff_f));
        
        F_3_1 <= std_logic_vector(to_signed(1, coeff_f));
        F_3_2 <= std_logic_vector(to_signed(2, coeff_f));
        F_3_3 <= std_logic_vector(to_signed(1, coeff_f));
        
        
        
        P_1_1 <= std_logic_vector(to_signed(10, comp_i));
        P_1_2 <= std_logic_vector(to_signed(20, comp_i));
        P_1_3 <= std_logic_vector(to_signed(30, comp_i));
        
        P_2_1 <= std_logic_vector(to_signed(40, comp_i));
        P_2_2 <= std_logic_vector(to_signed(50, comp_i));
        P_2_3 <= std_logic_vector(to_signed(60, comp_i));
        
        P_3_1 <= std_logic_vector(to_signed(70, comp_i));
        P_3_2 <= std_logic_vector(to_signed(80, comp_i));
        P_3_3 <= std_logic_vector(to_signed(90, comp_i));
        
        wait for CLK_PERIOD;
        valid <= '1';

        wait for CLK_PERIOD*10;
        
        valid <= '0';
        wait;
        end process;

        
        
end testing;
