
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CSA_tree is
    generic N : POSITIVE := 12;
    
    port (
        i_1_1, i_1_2, i_1_3 : in  std_logic_vector(N-1 downto 0);
        i_2_1, i_2_2, i_2_3 : in  std_logic_vector(N-1 downto 0);
        i_3_1, i_3_2, i_3_3 : in  std_logic_vector(N-1 downto 0);
        sum                 : out std_logic_vector(N+4 downto 0);
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
    signal v_r_1_1, s_p_1_1 : STD_LOGIC_VECTOR(N downto 0);
    signal v_r_1_2, s_p_1_2 : STD_LOGIC_VECTOR(N downto 0);
    signal v_r_1_3, s_p_1_3 : STD_LOGIC_VECTOR(N downto 0);
    
    -- Secondo livello (dimensione = 14)
    signal v_r_2_1, s_p_2_1 : STD_LOGIC_VECTOR(N+1 downto 0);
    signal v_r_2_2, s_p_2_2 : STD_LOGIC_VECTOR(N+1 downto 0);
    
    -- Terzo livello (dimensione = 15)
    signal v_r_3_1, s_p_3_1 : STD_LOGIC_VECTOR(N+2 downto 0);
    
    -- Quarto livello (dimensione = 16)
    signal v_r_4_1, s_p_4_1 : STD_LOGIC_VECTOR(N+3 downto 0);
    signal rca_s_out : STD_LOGIC_VECTOR (N+3 downto 0);
    signal rca_c_out : STD_LOGIC;
    
    -- Ultimo livello
    signal result : STD_LOGIC_VECTOR(N+4 downto 0);
    
begin


end Structural;
