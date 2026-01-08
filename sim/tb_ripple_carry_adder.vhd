library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity tb_ripple_carry_adder is
end entity tb_ripple_carry_adder;

architecture unit_test of tb_ripple_carry_adder is
    -- Testing parameters
    constant N : POSITIVE := 8; -- Number of bits

    -- Testing signals
    signal a, b : STD_LOGIC_VECTOR(N - 1 downto 0); -- Inputs
    signal cin  : STD_LOGIC;
    signal s    : STD_LOGIC_VECTOR(N - 1 downto 0); -- Outputs
    signal cout : STD_LOGIC;

    -- Component to test
    component ripple_carry_adder is
        generic (
            N : POSITIVE
        );

        port (
            a, b : in    STD_LOGIC_VECTOR(N - 1 downto 0);
            cin  : in    STD_LOGIC;
            s    : out   STD_LOGIC_VECTOR(N - 1 downto 0);
            cout : out   STD_LOGIC
        );
    end component ripple_carry_adder;

    -- Truth table
    type truth_table_type is array (0 to 4) of STD_LOGIC_VECTOR((N * 3) + 1 downto 0);
    -- bit order: a, b, cin, | exp_cout, exp_s
    constant TRUTH_TABLE : truth_table_type := (
        -- 0 + 0 + 0 = 0 | 0
        0 =>
        std_logic_vector(to_unsigned(16#00#, N)) &
        std_logic_vector(to_unsigned(16#00#, N)) &
        '0' &
        '0' &
        std_logic_vector(to_unsigned(16#00#, N)),

        -- 1 + 1 + 0 = 2 | 0
        1 =>
        std_logic_vector(to_unsigned(16#01#, N)) &
        std_logic_vector(to_unsigned(16#01#, N)) &
        '0' &
        '0' &
        std_logic_vector(to_unsigned(16#02#, N)),

        -- 5 + 5 + 0 = 10 | 0
        2 =>
        std_logic_vector(to_unsigned(16#05#, N)) &
        std_logic_vector(to_unsigned(16#05#, N)) &
        '0' &
        '0' &
        std_logic_vector(to_unsigned(16#0A#, N)),

        -- 255 + 1 + 0 = 0 | 1
        3 =>
        std_logic_vector(to_unsigned(16#FF#, N)) &
        std_logic_vector(to_unsigned(16#01#, N)) &
        '0' &
        '1' &
        std_logic_vector(to_unsigned(16#00#, N)),

        -- 255 + 255 + 1 = 255 | 1
        4 =>
        std_logic_vector(to_unsigned(16#FF#, N)) &
        std_logic_vector(to_unsigned(16#FF#, N)) &
        '1' &
        '1' &
        std_logic_vector(to_unsigned(16#FF#, N))
    );

begin
    -- Main component instantiation
    rca: component ripple_carry_adder
        generic map (
            N => N
        )

        port map (
            a => a, b => b, cin => cin,
            s => s, cout => cout
        );

    -- Simulation
    sim: process is
    begin
        report "--- Starting `ripple_carry_adder` (Directed Testing) simulation ---";

        for i in TRUTH_TABLE'range loop
            -- Set inputs
            a   <= TRUTH_TABLE(i)((N * 3) + 1 downto (N * 2) + 2);
            b   <= TRUTH_TABLE(i)((N * 2) + 1 downto N + 2);
            cin <= TRUTH_TABLE(i)(N + 1);

            -- Wait
            wait for 10 ns;

            -- Assert
            assert cout = TRUTH_TABLE(i)(N) and s = TRUTH_TABLE(i)(N - 1 downto 0)
                report "Error at input " & integer'image(i) &
                       " (a: " & integer'image(to_integer(unsigned(a))) &
                       " b: " & integer'image(to_integer(unsigned(b))) &
                       " cin: " & std_logic'image(TRUTH_TABLE(i)(N + 1)) & ")" &
                       " | expected: (s: " & integer'image(to_integer(unsigned(TRUTH_TABLE(i)(N - 1 downto 0)))) &
                       " cout: " & std_logic'image(TRUTH_TABLE(i)(N)) & ")" &
                       " | obtained: (s: " & integer'image(to_integer(unsigned(s))) &
                       " cout: " & std_logic'image(cout) & ")"
                severity error;
        end loop;

        report "--- Simulation completed ---";
        wait;
    end process sim;
end architecture unit_test;
