library ieee;
    use ieee.std_logic_1164.all;

entity buffer_line is
    generic(
        ncol : integer := 32  -- Impostato a 32 per immagine
    );
    port(
        clk   : in  std_logic;
        reset : in  std_logic;
        valid : in  std_logic;
        data  : in  std_logic_vector(7 downto 0);

        d00, d01, d02, d10, d11, d12, d20, d21, d22 : out std_logic_vector(7 downto 0)
    );
end buffer_line;

architecture Behavioral of buffer_line is
    signal buffer1_out, buffer2_out : std_logic_vector(7 downto 0);

    -- Buffer di linea (FIFO)
    type reg_array is array (ncol-4 downto 0) of std_logic_vector(7 downto 0);
    signal buffer1, buffer2 : reg_array;

begin
    -- RIGA 0 (Ingresso diretto + shift registers locali)
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '0' then
                d00 <= (others => '0');
                d01 <= (others => '0');
                d02 <= (others => '0');
            else
                if valid = '1' then
                    d00 <= data;
                    d01 <= d00;
                    d02 <= d01;
                end if;
            end if;
        end if;
    end process;

    -- LINE BUFFER 1 (Memorizza una riga intera)
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '0' then
                for j in 0 to ncol-4 loop
                    buffer1(j) <= (others => '0');
                end loop;
            else
                if valid = '1' then
                    buffer1(0) <= d02; -- Prende l'uscita dello stadio precedente
                    for j in 1 to ncol-4 loop
                        buffer1(j) <= buffer1(j-1);
                    end loop;
                end if;
            end if;
        end if;
    end process;

    buffer1_out <= buffer1(ncol-4);

    -- RIGA 1 (Uscita dal buffer 1 + shift registers locali)
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '0' then
                d10 <= (others => '0');
                d11 <= (others => '0');
                d12 <= (others => '0');
            else
                if valid = '1' then
                    d10 <= buffer1_out;
                    d11 <= d10;
                    d12 <= d11;
                end if;
            end if;
        end if;
    end process;

    -- LINE BUFFER 2 (Memorizza la seconda riga intera)
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '0' then
                for j in 0 to ncol-4 loop
                    buffer2(j) <= (others => '0');
                end loop;
            else
                if valid = '1' then
                    buffer2(0) <= d12;
                    for j in 1 to ncol-4 loop
                        buffer2(j) <= buffer2(j-1);
                    end loop;
                end if;
            end if;
        end if;
    end process;

    buffer2_out <= buffer2(ncol-4);

    -- RIGA 2 (Uscita dal buffer 2 + shift registers locali)
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '0' then
                d20 <= (others => '0');
                d21 <= (others => '0');
                d22 <= (others => '0');
            else
                if valid = '1' then
                    d20 <= buffer2_out;
                    d21 <= d20;
                    d22 <= d21;
                end if;
            end if;
        end if;
    end process;

end Behavioral;
