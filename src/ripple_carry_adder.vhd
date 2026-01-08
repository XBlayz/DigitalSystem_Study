library ieee;
    use ieee.std_logic_1164.all;

entity ripple_carry_adder is
    generic (
        N : POSITIVE
    );

    port (
        a, b : in    STD_LOGIC_VECTOR(N - 1 downto 0);
        cin  : in    STD_LOGIC;
        s    : out   STD_LOGIC_VECTOR(N - 1 downto 0);
        cout : out   STD_LOGIC
    );
end entity ripple_carry_adder;

architecture behavioral of ripple_carry_adder is
    signal c : STD_LOGIC_VECTOR(N downto 0);

    component full_adder is
        port (
            a, b, cin : in    STD_LOGIC;
            s, cout   : out   STD_LOGIC
        );
    end component full_adder;

begin
    c(0) <= cin;

    loop_n: for i in 0 to N - 1 generate
        fa_i: component full_adder
            port map (
                a => a(i), b => b(i), cin => c(i),
                s => s(i), cout => c(i + 1)
            );
    end generate loop_n;

    cout <= c(N);
end architecture behavioral;
