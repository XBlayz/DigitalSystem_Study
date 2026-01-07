library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity tb_ripple_carry_adder is
end entity tb_ripple_carry_adder;

architecture unit_test of tb_ripple_carry_adder is
    constant n : POSITIVE := 8;

    signal a, b : STD_LOGIC_VECTOR(n - 1 downto 0);
    signal cin  : STD_LOGIC;
    signal s    : STD_LOGIC_VECTOR(n - 1 downto 0);
    signal cout : STD_LOGIC;

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

    type truth_table_type is array (0 to 4) of STD_LOGIC_VECTOR((n * 3) + 1 downto 0);
    -- bit order: a, b, cin, | exp_cout, exp_s
    constant truth_table : truth_table_type := (
        0 =>
        std_logic_vector(to_unsigned(16#00#, n)) &
        std_logic_vector(to_unsigned(16#00#, n)) &
        '0' &
        '0' &
        std_logic_vector(to_unsigned(16#00#, n)),

        1 =>
        std_logic_vector(to_unsigned(16#01#, n)) &
        std_logic_vector(to_unsigned(16#01#, n)) &
        '0' &
        '0' &
        std_logic_vector(to_unsigned(16#02#, n)),

        2 =>
        std_logic_vector(to_unsigned(16#05#, n)) &
        std_logic_vector(to_unsigned(16#05#, n)) &
        '0' &
        '0' &
        std_logic_vector(to_unsigned(16#0A#, n)),

        3 =>
        std_logic_vector(to_unsigned(16#FF#, n)) &
        std_logic_vector(to_unsigned(16#01#, n)) &
        '0' &
        '1' &
        std_logic_vector(to_unsigned(16#00#, n)),

        4 =>
        std_logic_vector(to_unsigned(16#FF#, n)) &
        std_logic_vector(to_unsigned(16#FF#, n)) &
        '1' &
        '1' &
        std_logic_vector(to_unsigned(16#FF#, n))
    );

begin
    rca: component ripple_carry_adder
        generic map (
            n => n
        )

        port map (
            a => a, b => b, cin => cin,
            s => s, cout => cout
        );

    sim: process is
    begin
        report "--- Starting `ripple_carry_adder` (Directed Testing) simulation ---";

        for i in truth_table'range loop
            a   <= truth_table(i)((n * 3) + 1 downto (n * 2) + 2);
            b   <= truth_table(i)((n * 2) + 1 downto n + 2);
            cin <= truth_table(i)(n + 1);

            wait for 10 ns;

            assert cout = truth_table(i)(n) and s = truth_table(i)(n - 1 downto 0)
                report "Error at input " & integer'image(i) &
                       " (a: " & integer'image(to_integer(unsigned(a))) &
                       " b: " & integer'image(to_integer(unsigned(b))) &
                       " cin: " & std_logic'image(truth_table(i)(n + 1)) & ")" &
                       " | expected: (s: " & integer'image(to_integer(unsigned(truth_table(i)(n - 1 downto 0)))) &
                       " cout: " & std_logic'image(truth_table(i)(n)) & ")" &
                       " | obtained: (s: " & integer'image(to_integer(unsigned(s))) &
                       " cout: " & std_logic'image(cout) & ")"
                severity error;
        end loop;

        report "--- Simulation completed ---";
        wait;
    end process sim;
end architecture unit_test;
