library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity tb_carry_save_tree_adder is
end entity tb_carry_save_tree_adder;

architecture unit_test of tb_carry_save_tree_adder is
    -- Testing parameters
    constant N_BITS    : POSITIVE := 8;    -- Number of bits
    constant N_INPUTS  : POSITIVE := 6;    -- Number of addends
    constant TWOS_COMP : BOOLEAN  := TRUE; -- Interpret inputs as 2's complement

    -- Testing signals
    signal sum : STD_LOGIC_VECTOR(N_BITS + N_INPUTS - 2 downto 0); -- Outputs

    -- Auxiliary signals
    signal addends_concat : STD_LOGIC_VECTOR(N_BITS * N_INPUTS - 1 downto 0); -- Used as input

    -- Component to test
    component carry_save_tree_adder is
        generic (
            N_BITS          : POSITIVE;
            N_INPUTS        : POSITIVE;
            TWOS_COMPLEMENT : BOOLEAN
        );

        port (
            addends : in    STD_LOGIC_VECTOR(N_BITS * N_INPUTS - 1 downto 0);
            sum     : out   STD_LOGIC_VECTOR(N_BITS + N_INPUTS - 2 downto 0)
        );
    end component carry_save_tree_adder;

    -- Truth table
    type truth_table_type is array (0 to 2) of STD_LOGIC_VECTOR(N_BITS * (N_INPUTS + 1) + N_INPUTS - 2 downto 0);
    -- bit order: a, b, c, d, e, f | sum
    constant TRUTH_TABLE : truth_table_type := (
        -- 0 + 0 + 0 + 0 + 0 + 0 = 0
        0 =>
        std_logic_vector(to_signed(0, N_BITS)) &
        std_logic_vector(to_signed(0, N_BITS)) &
        std_logic_vector(to_signed(0, N_BITS)) &
        std_logic_vector(to_signed(0, N_BITS)) &
        std_logic_vector(to_signed(0, N_BITS)) &
        std_logic_vector(to_signed(0, N_BITS)) &
        std_logic_vector(to_signed(0, N_BITS + N_INPUTS - 1)),

        -- 1 + 1 + 1 + 1 + 1 + 1 = 6
        1 =>
        std_logic_vector(to_signed(1, N_BITS)) &
        std_logic_vector(to_signed(1, N_BITS)) &
        std_logic_vector(to_signed(1, N_BITS)) &
        std_logic_vector(to_signed(1, N_BITS)) &
        std_logic_vector(to_signed(1, N_BITS)) &
        std_logic_vector(to_signed(1, N_BITS)) &
        std_logic_vector(to_signed(6, N_BITS + N_INPUTS - 1)),

        -- -1 + -1 + -1 + -1 + -1 + -1 = -6
        2 =>
        std_logic_vector(to_signed(-1, N_BITS)) &
        std_logic_vector(to_signed(-1, N_BITS)) &
        std_logic_vector(to_signed(-1, N_BITS)) &
        std_logic_vector(to_signed(-1, N_BITS)) &
        std_logic_vector(to_signed(-1, N_BITS)) &
        std_logic_vector(to_signed(-1, N_BITS)) &
        std_logic_vector(to_signed(-6, N_BITS + N_INPUTS - 1))
    );

begin
    -- Main component instantiation
    rca: component carry_save_tree_adder
        generic map (
            N_BITS          => N_BITS,
            N_INPUTS        => N_INPUTS,
            TWOS_COMPLEMENT => TWOS_COMP
        )

        port map (
            addends => addends_concat,
            sum     => sum
        );

    -- Simulation
    sim: process is
    begin
        report "--- Starting `carry_save_tree_adder` (Directed Testing) simulation ---";

        for i in TRUTH_TABLE'range loop
            -- Set inputs
            addends_concat <= TRUTH_TABLE(i)(N_BITS * N_INPUTS + N_BITS + N_INPUTS - 2 downto N_BITS + N_INPUTS - 1);

            -- Wait
            wait for 10 ns;

            -- Assert
            assert sum = TRUTH_TABLE(i)(N_BITS + N_INPUTS - 2 downto 0)
                report "Error at input " & integer'image(i) &
                       " (a: " & integer'image(to_integer(signed(
                       addends_concat(N_BITS * N_INPUTS - 1 downto N_BITS * (N_INPUTS - 1))
                       ))) &
                       " b: " & integer'image(to_integer(signed(
                       addends_concat(N_BITS * (N_INPUTS - 1) - 1 downto N_BITS * (N_INPUTS - 2))
                       ))) &
                       " c: " & integer'image(to_integer(signed(
                       addends_concat(N_BITS * (N_INPUTS - 2) - 1 downto N_BITS * (N_INPUTS - 3))
                       ))) &
                       " d: " & integer'image(to_integer(signed(
                       addends_concat(N_BITS * (N_INPUTS - 3) - 1 downto N_BITS * (N_INPUTS - 4))
                       ))) &
                       " e: " & integer'image(to_integer(signed(
                       addends_concat(N_BITS * (N_INPUTS - 4) - 1 downto N_BITS * (N_INPUTS - 5))
                       ))) &
                       " f: " & integer'image(to_integer(signed(
                       addends_concat(N_BITS * (N_INPUTS - 5) - 1 downto N_BITS * (N_INPUTS - 6))
                       ))) & ")" &
                       " | expected: (sum: " & integer'image(to_integer(signed(
                       TRUTH_TABLE(i)(N_BITS + N_INPUTS - 2 downto 0)
                       ))) & ")" &
                       " | obtained: (sum: " & integer'image(to_integer(signed(sum))) & ")"
                severity error;
        end loop;

        report "--- Simulation completed ---";
        wait;
    end process sim;
end architecture unit_test;
