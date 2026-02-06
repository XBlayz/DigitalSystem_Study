library ieee;
    use ieee.std_logic_1164.all;

entity booth_multiplier is
	generic (
        a_nbit : POSITIVE := 8
    );

	port(
        a : in std_logic_vector(a_nbit - 1 downto 0);
	    b : in std_logic_vector(4 - 1 downto 0);
	    r : out std_logic_vector(a_nbit + 4 - 1 downto 0)
    );
end booth_multiplier;

architecture Structural of booth_multiplier is
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

    constant b_nbit : POSITIVE := 4;
    constant r_size : POSITIVE := a_nbit + b_nbit;

    signal ext_b : std_logic_vector(b_nbit downto 0);
    signal zero, ext_a, neg_a, a2, neg_a2 : std_logic_vector(a_nbit + 1 downto 0);

    type partial_prod_array is array (0 to (b_nbit/2)-1) of std_logic_vector(r_size-1 downto 0);
    signal p : partial_prod_array;
begin
    -- Controllo che il numero di bit di B sia pari (metodo di generazione parametrica non supporta valori dispari)
    assert (b_nbit mod 2 = 0)
    report "ERRORE: Il numero di bit di B deve essere pari! Valore attuale: " & integer'image(b_nbit)
    severity failure;

    -- Estensione di b con Q_{-1} = 0
    ext_b <= b & '0';

    -- Calcolo preventivo dei possibili valori di A
    zero <= (others => '0');
    ext_a <= a(a_nbit - 1) & a(a_nbit - 1) & a;
    rca1 : ripple_carry_adder
        generic map (
            N => a_nbit + 2
        )

        port map (
            a => not(ext_a),
            b => zero,
            cin => '1',
            s => neg_a,
            cout => open
        );
    a2 <= a(a_nbit - 1) & a & '0';
    rca2 : ripple_carry_adder
        generic map (
            N => a_nbit + 2
        )

        port map (
            a => not(a2),
            b => zero,
            cin => '1',
            s => neg_a2,
            cout => open
        );

	gen_booth: for i in 0 to (b_nbit/2)-1 generate
        signal sel_val : std_logic_vector(a_nbit + 1 downto 0);
    begin
        process(ext_b((i+1)*2 downto i*2), zero, ext_a, a2, neg_a, neg_a2)
        begin
            case ext_b((i+1)*2 downto i*2) is
                -- Tabella codifica di Booth
                when "000" | "111" => sel_val <= zero;    -- 0
                when "001" | "010" => sel_val <= ext_a;   -- +A
                when "011"         => sel_val <= a2;      -- +2A
                when "100"         => sel_val <= neg_a2;  -- -2A
                when "101" | "110" => sel_val <= neg_a;   -- -A
                when others        => sel_val <= zero;
            end case;
        end process;

        -- Vettore p(i) <= [Estensione Segno] & [Valore] & [Zeri Shift]
        p_assign: process(sel_val)
        begin
            if i*2 = 0 then
                -- Caso base (i=0), nessun shift
                p(i)(sel_val'range) <= sel_val;
                p(i)(p(i)'high downto sel_val'length) <= (others => sel_val(a_nbit + 1));
            else
                -- Caso generale, shift di i*2 verso sinistra
                p(i)(i*2 - 1 downto 0) <= (others => '0');                                      -- SHIFT
                p(i)(i*2 + a_nbit + 1 downto i*2) <= sel_val;                                   -- VALUE
                p(i)(r_size - 1 downto i*2 + a_nbit + 2) <= (others => sel_val(a_nbit + 1));    -- SIGN_EXT
            end if;
        end process;
    end generate;

    -- Specializzazione del componente generico nel caso di `b'length=4`
    -- Uso di semplice "Ripple Carry Adder" invece di "Adder Tree"
    rca3: ripple_carry_adder
        generic map (
            N => r_size
        )

        port map (
            a => p(0),
            b => p(1),
            cin => '0',
            s => r,
            cout => open
        );

end Structural;
