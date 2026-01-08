library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity tb_full_adder is
end entity tb_full_adder;

architecture unit_test of tb_full_adder is
    signal a, b, cin : STD_LOGIC;
    signal s, cout   : STD_LOGIC;

    signal gen_input : UNSIGNED(2 downto 0);

    component full_adder is
        port (
            a, b, cin : in    STD_LOGIC;
            s, cout   : out   STD_LOGIC
        );
    end component full_adder;

    type truth_table_type is array (0 to 7) of STD_LOGIC_VECTOR(4 downto 0);
    -- bit order: a, b, cin, | exp_cout, exp_s
    constant TRUTH_TABLE : truth_table_type := (
        "000" & "00",
        "001" & "01",
        "010" & "01",
        "011" & "10",
        "100" & "01",
        "101" & "10",
        "110" & "10",
        "111" & "11"
    );

begin
    fa: component full_adder
        port map (
            a => a, b => b, cin => cin,
            s => s, cout => cout
        );

    sim: process is
    begin
        report "--- Starting `full_adder` (Exhaustive Testing) simulation ---";

        for i in 0 to 7 loop
            gen_input <= unsigned(TRUTH_TABLE(i)(4 downto 2));

            a   <= to_unsigned(i, 3)(2);
            b   <= to_unsigned(i, 3)(1);
            cin <= to_unsigned(i, 3)(0);

            wait for 10 ns;

            assert unsigned'(cout & s) = unsigned(TRUTH_TABLE(i)(1 downto 0))
                report "Error with input " & integer'image(i) &
                       " (binary: " & std_logic'image(gen_input(2)) &
                       " " & std_logic'image(gen_input(1)) &
                       " " & std_logic'image(gen_input(0)) & ")" &
                       " | expected: " & integer'image(to_integer(unsigned(TRUTH_TABLE(i)(1 downto 0)))) &
                       " | obtained: " & integer'image(to_integer(unsigned'(cout & s)))
                severity error;
        end loop;

        report "--- Simulation completed ---";
        wait;
    end process sim;
end architecture unit_test;
