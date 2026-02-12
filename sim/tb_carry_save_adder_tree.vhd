
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity tb_carry_save_adder_tree is
end tb_carry_save_adder_tree;

architecture testing of tb_carry_save_adder_tree is
    constant n : POSITIVE := 12;

    signal i_1_1, i_1_2, i_1_3,
           i_2_1, i_2_2, i_2_3,
           i_3_1, i_3_2, i_3_3 : STD_LOGIC_VECTOR(n-1 downto 0) := (others => '0');
    signal sum_out : STD_LOGIC_VECTOR(n+4 downto 0);

    component carry_save_adder_tree is
        generic (N : POSITIVE);

        port (i_1_1, i_1_2, i_1_3,
              i_2_1, i_2_2, i_2_3,
              i_3_1, i_3_2, i_3_3 : in  STD_LOGIC_VECTOR(N-1 downto 0);
              sum                 : out STD_LOGIC_VECTOR(N+4 downto 0)
        );
   end component carry_save_adder_tree;

begin
    CSAt: carry_save_adder_tree
        generic map(N=>n)

        port map( i_1_1=>i_1_1, i_1_2=>i_1_2, i_1_3=>i_1_3,
                  i_2_1=>i_2_1, i_2_2=>i_2_2, i_2_3=>i_2_3,
                  i_3_1=>i_3_1, i_3_2=>i_3_2, i_3_3=>i_3_3,
                  sum=>sum_out
        );
    stim_proc: process
    begin
        i_1_1 <= (others=>'0');
        i_1_2 <= (others=>'0');
        i_1_3 <= (others=>'0');
        i_2_1 <= (others=>'0');
        i_2_2 <= (others=>'0');
        i_2_3 <= (others=>'0');
        i_3_1 <= (others=>'0');
        i_3_2 <= (others=>'0');
        i_3_3 <= (others=>'0');
        wait for 20 ns;
        i_1_1 <= std_logic_vector(to_signed(1, n));
        i_1_2 <= std_logic_vector(to_signed(2, n));
        i_1_3 <= std_logic_vector(to_signed(3, n));
        i_2_1 <= std_logic_vector(to_signed(4, n));
        i_2_2 <= std_logic_vector(to_signed(5, n));
        i_2_3 <= std_logic_vector(to_signed(6, n));
        i_3_1 <= std_logic_vector(to_signed(7, n));
        i_3_2 <= std_logic_vector(to_signed(8, n));
        i_3_3 <= std_logic_vector(to_signed(9, n));
        wait for 20 ns;
        i_1_1 <= std_logic_vector(to_signed(10, n));
        i_1_2 <= std_logic_vector(to_signed(40, n));
        i_1_3 <= std_logic_vector(to_signed(30, n));
        i_2_1 <= std_logic_vector(to_signed(80, n));
        i_2_2 <= std_logic_vector(to_signed(200, n));
        i_2_3 <= std_logic_vector(to_signed(120, n));
        i_3_1 <= std_logic_vector(to_signed(70, n));
        i_3_2 <= std_logic_vector(to_signed(160, n));
        i_3_3 <= std_logic_vector(to_signed(90, n));
        wait for 20 ns;
        i_1_1 <= std_logic_vector(to_signed(-10, n));
        i_1_2 <= std_logic_vector(to_signed(10, n));
        i_1_3 <= (others => '0');
        i_2_1 <= (others => '0');
        i_2_2 <= (others => '0');
        i_2_3 <= (others => '0');
        i_3_1 <= (others => '0');
        i_3_2 <= (others => '0');
        i_3_3 <= (others => '0');
        wait for 20 ns;
        wait;
    end process;

end testing;
