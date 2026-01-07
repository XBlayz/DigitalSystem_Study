library ieee;
    use ieee.std_logic_1164.all;

entity rca_8 is
    port (
        a, b : in    STD_LOGIC_VECTOR(7 downto 0);
        cin  : in    STD_LOGIC;
        s    : out   STD_LOGIC_VECTOR(7 downto 0);
        cout : out   STD_LOGIC
    );
end entity rca_8;

architecture instantiation of rca_8 is
    component ripple_carry_adder is
        generic (
            n : POSITIVE
        );

        port (
            a, b : in    STD_LOGIC_VECTOR(n - 1 downto 0);
            cin  : in    STD_LOGIC;
            s    : out   STD_LOGIC_VECTOR(n - 1 downto 0);
            cout : out   STD_LOGIC
        );
    end component ripple_carry_adder;

begin
    rca: component ripple_carry_adder
        generic map (
            n => 8
        )

        port map (
            a => a, b => b, cin => cin,
            s => s, cout => cout
        );
end architecture instantiation;
