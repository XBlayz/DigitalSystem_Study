library ieee;
    use ieee.std_logic_1164.all;

entity carry_save_adder is
    generic (
        n : POSITIVE
    );

    port (
        a, b, c : in    STD_LOGIC_VECTOR(n - 1 downto 0);
        ps, cv  : out   STD_LOGIC_VECTOR(n - 1 downto 0)
    );
end entity carry_save_adder;

architecture behavioral of carry_save_adder is
    component full_adder is
        port (
            a, b, cin : in    STD_LOGIC;
            s, cout   : out   STD_LOGIC
        );
    end component full_adder;

begin
    loop_n: for i in 0 to n - 1 generate
        fa_i: component full_adder
            port map (
                a => a(i), b => b(i), cin => c(i),
                s => ps(i), cout => cv(i)
            );
    end generate loop_n;
end architecture behavioral;
