library ieee;
    use ieee.std_logic_1164.all;

entity main is
    port (
        a, b, c, d, e, f : in    STD_LOGIC_VECTOR(7 downto 0);
        sum              : out   STD_LOGIC_VECTOR(7 downto 0)
    );
end entity main;

architecture instantiation of main is
    component carry_save_tree_adder is
        generic (
            N_BITS          : POSITIVE;
            N_INPUTS        : POSITIVE;
            TWOS_COMPLEMENT : BOOLEAN
        );

        port (
            addends : in    STD_LOGIC_VECTOR(N_BITS * N_INPUTS - 1 downto 0);
            sum     : out   STD_LOGIC_VECTOR(N_BITS + N_INPUTS - 1 downto 0)
        );
    end component carry_save_tree_adder;

    -- Intermediate signal for concatenated addends (8 bits * 6 inputs = 48 bits)
    signal addends_concat : STD_LOGIC_VECTOR(47 downto 0);

begin
    -- Concatenate all addends into a single vector
    addends_concat <= a & b & c & d & e & f;

    comp: component carry_save_tree_adder
        generic map (
            N_BITS          => 8,
            N_INPUTS        => 6,
            TWOS_COMPLEMENT => true
        )

        port map (
            addends => addends_concat,
            sum     => sum
        );
end architecture instantiation;

