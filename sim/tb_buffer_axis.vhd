library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use std.textio.all;

entity tb_buffer_axis is
end entity tb_buffer_axis;

architecture Behavioral of tb_buffer_axis is
    -- Testing parameters
    constant CLK_PERIOD : time := 10 ns; -- 100 MHz
    constant NCOL       : integer := 32;
    constant NUM_ROWS   : integer := 6;

    -- Testing signals
    signal s_axis_clk    : std_logic := '0';
    signal s_axis_rstn   : std_logic := '0';
    signal s_axis_tvalid : std_logic := '0';
    signal s_axis_tlast  : std_logic := '0';
    signal s_axis_tready : std_logic;
    signal s_axis_tdata  : std_logic_vector(7 downto 0) := (others => '0');

    signal m_axis_tvalid : std_logic;
    signal m_axis_tlast  : std_logic;
    signal m_axis_tready : std_logic := '1'; -- Backpressure control
    signal m_axis_tdata  : std_logic_vector(71 downto 0);

    -- Auxiliary signals
    signal sim_done      : boolean := false;
    signal pixel_count   : integer := 0;
    signal output_count  : integer := 0;

    signal curr_out_row  : integer := 0;
    signal curr_out_col  : integer := 0;

    -- Component to test
    component BufferLine is
        generic(
            ncol : integer
        );
        port(
            s_axis_clk      : in  std_logic;
            s_axis_rstn     : in  std_logic;
            s_axis_tvalid   : in  std_logic;
            s_axis_tlast    : in  std_logic;
            s_axis_tready   : out std_logic;
            s_axis_tdata    : in  std_logic_vector(7 downto 0);

            m_axis_tvalid   : out std_logic;
            m_axis_tlast    : out std_logic;
            m_axis_tready   : in  std_logic;

            m_axis_tdata    : out std_logic_vector(71 downto 0)
        );
    end component BufferLine;

    -- Pixel array
    type pixel_array is array (0 to NUM_ROWS-1, 0 to NCOL-1) of std_logic_vector(7 downto 0);
    signal sent_pixels   : pixel_array;

begin
    -- Main component instantiation
    dut: component BufferLine
        generic map (
            ncol => NCOL
        )
        port map (
            s_axis_clk    => s_axis_clk,
            s_axis_rstn   => s_axis_rstn,
            s_axis_tvalid => s_axis_tvalid,
            s_axis_tlast  => s_axis_tlast,
            s_axis_tready => s_axis_tready,
            s_axis_tdata  => s_axis_tdata,
            m_axis_tvalid => m_axis_tvalid,
            m_axis_tlast  => m_axis_tlast,
            m_axis_tready => m_axis_tready,
            m_axis_tdata  => m_axis_tdata
        );

    -- =====================================================================
    -- Clock Generation
    -- =====================================================================
    clk_gen : process
    begin
        while not sim_done loop
            s_axis_clk <= '0';
            wait for CLK_PERIOD/2;
            s_axis_clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    -- =====================================================================
    -- Generation INPUT data
    -- =====================================================================
    stimulus : process
        variable row, col : integer;
        variable pixel_val : std_logic_vector(7 downto 0);

        variable prec : std_logic_vector(7 downto 0) := std_logic_vector(to_signed(-1, 8));
    begin
        -- 1. Initial reset
        s_axis_rstn <= '0';
        wait for CLK_PERIOD * 10;
        s_axis_rstn <= '1';
        wait for CLK_PERIOD * 2;

        report "Inizio invio pixel...";

        -- 2. Sending data
        for row in 0 to NUM_ROWS-1 loop
            for col in 0 to NCOL-1 loop
                -- Pattern pixel: (riga * 32) + colonna (valore univoco)
                pixel_val := std_logic_vector(to_unsigned(row * NCOL + col, 8));

                s_axis_tdata  <= pixel_val;
                s_axis_tvalid <= '1';

                -- TLAST alto solo all'ultimo pixel della riga
                if col = NCOL-1 then
                    s_axis_tlast <= '1';
                else
                    s_axis_tlast <= '0';
                end if;

                -- Memorizza per verifica successiva
                sent_pixels(row, col) <= prec;
                prec := pixel_val;

                -- Attendi handshake (tvalid & tready)
                wait until rising_edge(s_axis_clk);
                while s_axis_tready = '0' loop
                    wait until rising_edge(s_axis_clk);
                end loop;

                pixel_count <= pixel_count + 1;
            end loop;

            -- TODO: Non tollerato
            -- Piccola pausa tra righe (per verificare robustezza del protocollo AXI)
            --s_axis_tvalid <= '0';
            --s_axis_tlast  <= '0';
            --wait for CLK_PERIOD * 2;
        end loop;

        -- 3. Ending transmission
        s_axis_tvalid <= '0';
        report "Trasmissione completata. Attesa svuotamento pipeline...";

        sim_done <= true;
        wait;
    end process;

    -- =====================================================================
    -- OUTPUT checker
    -- =====================================================================
    checker : process(s_axis_clk)
        variable expected_d00, expected_d01, expected_d02 : std_logic_vector(7 downto 0);
        variable expected_d10, expected_d11, expected_d12 : std_logic_vector(7 downto 0);
        variable expected_d20, expected_d21, expected_d22 : std_logic_vector(7 downto 0);
        variable actual_d00, actual_d01, actual_d02       : std_logic_vector(7 downto 0);
        variable actual_d10, actual_d11, actual_d12       : std_logic_vector(7 downto 0);
        variable actual_d20, actual_d21, actual_d22       : std_logic_vector(7 downto 0);
        variable error_found : boolean := false;

        impure function extract_byte(data : std_logic_vector(71 downto 0); pos : integer) return std_logic_vector is
        begin
            return data((pos+1)*8-1 downto pos*8);
        end function;

    begin
        if rising_edge(s_axis_clk) then
            actual_d22 := extract_byte(m_axis_tdata, 8);
            actual_d21 := extract_byte(m_axis_tdata, 7);
            actual_d20 := extract_byte(m_axis_tdata, 6);
            actual_d12 := extract_byte(m_axis_tdata, 5);
            actual_d11 := extract_byte(m_axis_tdata, 4);
            actual_d10 := extract_byte(m_axis_tdata, 3);
            actual_d02 := extract_byte(m_axis_tdata, 2);
            actual_d01 := extract_byte(m_axis_tdata, 1);
            actual_d00 := extract_byte(m_axis_tdata, 0);

            if s_axis_rstn = '1' and m_axis_tready = '1' and s_axis_tvalid = '1' then
                -- Verifica se la finestra è valida
                if curr_out_row >= 2 and curr_out_col >= 2 and not (curr_out_row = 2 and curr_out_col = 2) then
                    -- Valore corretto
                    expected_d00 := sent_pixels(curr_out_row, curr_out_col);
                    expected_d01 := sent_pixels(curr_out_row, curr_out_col-1);
                    expected_d02 := sent_pixels(curr_out_row, curr_out_col-2);
                    expected_d10 := sent_pixels(curr_out_row-1, curr_out_col);
                    expected_d11 := sent_pixels(curr_out_row-1, curr_out_col-1);
                    expected_d12 := sent_pixels(curr_out_row-1, curr_out_col-2);
                    expected_d20 := sent_pixels(curr_out_row-2, curr_out_col);
                    expected_d21 := sent_pixels(curr_out_row-2, curr_out_col-1);
                    expected_d22 := sent_pixels(curr_out_row-2, curr_out_col-2);

                    -- Verifica
                    error_found := false;
                    if actual_d00 /= expected_d00 then error_found := true; end if;
                    if actual_d01 /= expected_d01 then error_found := true; end if;
                    if actual_d02 /= expected_d02 then error_found := true; end if;
                    if actual_d10 /= expected_d10 then error_found := true; end if;
                    if actual_d11 /= expected_d11 then error_found := true; end if;
                    if actual_d12 /= expected_d12 then error_found := true; end if;
                    if actual_d20 /= expected_d20 then error_found := true; end if;
                    if actual_d21 /= expected_d21 then error_found := true; end if;
                    if actual_d22 /= expected_d22 then error_found := true; end if;

                    if error_found then
                        report "!!! ERRORE @ Row" & integer'image(curr_out_row) &
                               " Col" & integer'image(curr_out_col) severity error;
                        report "Atteso   d00=" & integer'image(to_integer(unsigned(expected_d00))) &
                               " d01=" & integer'image(to_integer(unsigned(expected_d01))) &
                               " d02=" & integer'image(to_integer(unsigned(expected_d02))) &
                               " | d10=" & integer'image(to_integer(unsigned(expected_d10))) &
                               " d11=" & integer'image(to_integer(unsigned(expected_d11))) &
                               " d12=" & integer'image(to_integer(unsigned(expected_d12))) &
                               " | d20=" & integer'image(to_integer(unsigned(expected_d20))) &
                               " d21=" & integer'image(to_integer(unsigned(expected_d21))) &
                               " d22=" & integer'image(to_integer(unsigned(expected_d22)));
                        report "Ricevuto d00=" & integer'image(to_integer(unsigned(actual_d00))) &
                               " d01=" & integer'image(to_integer(unsigned(actual_d01))) &
                               " d02=" & integer'image(to_integer(unsigned(actual_d02))) &
                               " | d10=" & integer'image(to_integer(unsigned(actual_d10))) &
                               " d11=" & integer'image(to_integer(unsigned(actual_d11))) &
                               " d12=" & integer'image(to_integer(unsigned(actual_d12))) &
                               " | d20=" & integer'image(to_integer(unsigned(actual_d20))) &
                               " d21=" & integer'image(to_integer(unsigned(actual_d21))) &
                               " d22=" & integer'image(to_integer(unsigned(actual_d22)));
                    else
                        report "OK @ Row" & integer'image(curr_out_row) &
                               " Col" & integer'image(curr_out_col) &
                               " (output_count=" & integer'image(output_count) & ")";
                    end if;

                    output_count <= output_count + 1;
                end if;

                -- Aggiorna coordinate output
                if curr_out_col = NCOL-1 then
                    curr_out_col <= 0;
                    curr_out_row <= curr_out_row + 1;
                else
                    curr_out_col <= curr_out_col + 1;
                end if;
            end if;
        end if;
    end process;

    -- =====================================================================
    -- Processo di Controllo Backpressure (Opzionale)
    -- =====================================================================
    -- Per testare il flusso con tready variabile, decommentare:
    backpressure : process
    begin
        m_axis_tready <= '1';
        wait for CLK_PERIOD * 50;
        m_axis_tready <= '0';  -- Blocca per 5 cicli
        wait for CLK_PERIOD * 5;
        m_axis_tready <= '1';
    end process;

end Behavioral;
