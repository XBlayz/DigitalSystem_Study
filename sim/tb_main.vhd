library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use std.textio.all;

entity tb_main is
end entity tb_main;

architecture testing of tb_main is
    -- Testing parameters (5x5 image)
    constant CLK_PERIOD       : time := 10 ns; -- 100 MHz
    constant NCOL_IMG         : integer := 5;  -- Columns
    constant NROW_IMG         : integer := 5;  -- Rows
    constant KERNEL_SIZE      : integer := 3;  -- 3x3 kernel

    -- Testing signals
    signal s_axis_clk    : std_logic := '0';
    signal s_axis_rstn   : std_logic := '0';
    signal s_axis_tvalid : std_logic := '0';
    signal s_axis_tlast  : std_logic := '0';
    signal s_axis_tuser  : std_logic := '0';
    signal s_axis_tready : std_logic;
    signal s_axis_tdata  : std_logic_vector(7 downto 0) := (others => '0');

    signal m_axis_tvalid : std_logic;
    signal m_axis_tlast  : std_logic;
    signal m_axis_tuser  : std_logic;
    signal m_axis_tready : std_logic := '1';
    signal m_axis_tdata  : std_logic_vector(8+4+4 downto 0); -- 16 bits

    -- Auxiliary signals
    signal pixel_count   : integer := 0;
    signal output_count  : integer := 0;
    signal last_line_count : integer := 0;

    -- Component to test
    component main is
        generic (
            ncol_img : integer;
            nrow_img : integer;

            kernel00 : STD_LOGIC_VECTOR(3 downto 0);
            kernel01 : STD_LOGIC_VECTOR(3 downto 0);
            kernel02 : STD_LOGIC_VECTOR(3 downto 0);
            kernel10 : STD_LOGIC_VECTOR(3 downto 0);
            kernel11 : STD_LOGIC_VECTOR(3 downto 0);
            kernel12 : STD_LOGIC_VECTOR(3 downto 0);
            kernel20 : STD_LOGIC_VECTOR(3 downto 0);
            kernel21 : STD_LOGIC_VECTOR(3 downto 0);
            kernel22 : STD_LOGIC_VECTOR(3 downto 0)
        );
        port (
            s_axis_clk      : in  std_logic;
            s_axis_rstn     : in  std_logic;
            s_axis_tvalid   : in  std_logic;
            s_axis_tlast    : in  std_logic; -- Input EOL
            s_axis_tready   : out std_logic;
            s_axis_tuser    : in  std_logic; -- Input SOF
            s_axis_tdata    : in  std_logic_vector(7 downto 0);

            m_axis_tvalid   : out std_logic;
            m_axis_tlast    : out std_logic; -- Output EOL
            m_axis_tready   : in  std_logic;
            m_axis_tuser    : out std_logic; -- Output SOF
            m_axis_tdata    : out std_logic_vector(8+4+4 downto 0)
        );
    end component main;

    -- Pixel array for verification
    type pixel_array is array (0 to NROW_IMG-1, 0 to NCOL_IMG-1) of std_logic_vector(7 downto 0);
    signal sent_pixels   : pixel_array;

    -- Pixel array to store received output
    type output_pixel_array is array (0 to NROW_IMG-1, 0 to NCOL_IMG-1) of std_logic_vector(16 downto 0);
    signal received_pixels : output_pixel_array;

begin
    -- Component instantiation
    main_inst: main
        generic map(
            ncol_img => NCOL_IMG,
            nrow_img => NROW_IMG,
            kernel00 => "0000",
            kernel01 => "0000",
            kernel02 => "0000",
            kernel10 => "0000",
            kernel11 => "0001",  -- Kernel con solo il centro attivo
            kernel12 => "0000",
            kernel20 => "0000",
            kernel21 => "0000",
            kernel22 => "0000"
        )
         port map (
            s_axis_clk      => s_axis_clk,
            s_axis_rstn     => s_axis_rstn,
            s_axis_tvalid   => s_axis_tvalid,
            s_axis_tlast    => s_axis_tlast,
            s_axis_tuser    => s_axis_tuser,
            s_axis_tready   => s_axis_tready,
            s_axis_tdata    => s_axis_tdata,
            m_axis_tvalid   => m_axis_tvalid,
            m_axis_tlast    => m_axis_tlast,
            m_axis_tuser    => m_axis_tuser,
            m_axis_tready   => m_axis_tready,
            m_axis_tdata    => m_axis_tdata
        );

    -- Clock Generation
    clk_gen : process
    begin
        s_axis_clk <= '0';
        wait for CLK_PERIOD/2;
        s_axis_clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Generation INPUT data
    stimulus : process
        variable row, col : integer;
        variable pixel_val : std_logic_vector(7 downto 0);

    begin
        -- 1. Initial reset
        s_axis_rstn <= '0';
        wait for CLK_PERIOD * 10;
        s_axis_rstn <= '1';
        --wait for CLK_PERIOD * 2;
        wait until falling_edge(s_axis_clk);

        report "Inizio invio pixel (5x5)...";

         -- 2. Sending data
        for row in 0 to NROW_IMG-1 loop
            for col in 0 to NCOL_IMG-1 loop
                -- Pattern pixel: (riga * NCOL_IMG) + colonna (valore univoco)
                pixel_val := std_logic_vector(to_unsigned(row * NCOL_IMG + col, 8));

                s_axis_tdata  <= pixel_val;
                s_axis_tvalid <= '1';

                -- TLAST alto solo all'ultimo pixel della riga
                if col = NCOL_IMG-1 then
                    s_axis_tlast <= '1';
                else
                    s_axis_tlast <= '0';
                end if;

                -- TUSER alto solo all'ultimo pixel dell'immagine (SOF)
                if row = 0 and col = 0 then
                    s_axis_tuser <= '1';
                else
                    s_axis_tuser <= '0';
                end if;

                -- Memorizza per verifica successiva
                sent_pixels(row, col) <= pixel_val;

                -- Attendi handshake (tvalid & tready)
                wait until rising_edge(s_axis_clk);
                while s_axis_tready = '0' loop
                    wait until rising_edge(s_axis_clk);
                end loop;

                wait until falling_edge(s_axis_clk);

                pixel_count <= pixel_count + 1;
            end loop;
        end loop;

        -- 3. Ending transmission
        s_axis_tvalid <= '0';
        report "Trasmissione completata. Attesa completamento elaborazione...";

        wait;
    end process;

    -- ================================================================
    -- Reading OUTPUT data and storing in received_pixels
    -- ================================================================
    output_reader : process(s_axis_clk)
        variable curr_out_row : integer := 0;
        variable curr_out_col : integer := 0;
    begin
        if rising_edge(s_axis_clk) then
            if s_axis_rstn = '1' and m_axis_tvalid = '1' and m_axis_tready = '1' then
                -- Store received pixel in output array
                if curr_out_row <= NROW_IMG-1 and curr_out_col <= NCOL_IMG-1 then
                    received_pixels(curr_out_row, curr_out_col) <= m_axis_tdata;
                    report "Salvato pixel @ (" & integer'image(curr_out_row) & ", " &
                           integer'image(curr_out_col) & "): " &
                           integer'image(to_integer(unsigned(m_axis_tdata)));
                end if;

                -- Aggiorna coordinate output
                if curr_out_col = NCOL_IMG-1 then
                    curr_out_col := 0;
                    curr_out_row := curr_out_row + 1;
                else
                    curr_out_col := curr_out_col + 1;
                end if;

                -- Monitora M_AXIS_TLAST
                if m_axis_tlast = '1' then
                    last_line_count <= last_line_count + 1;
                    report "M_AXIS_TLAST attivo (contatore: " & integer'image(last_line_count) & ")";
                end if;

                -- Monitora M_AXIS_TUSER (SOF)
                if m_axis_tuser = '1' then
                    report "M_AXIS_TUSER attivo (SOF - primo pixel della frame)";
                end if;

                output_count <= output_count + 1;
            end if;
        end if;
    end process;

    -- ================================================================
    -- Simulation termination and final verification
    -- ================================================================
    sim_termination : process
        variable all_pixels_match : boolean := true;
        variable row, col : integer;
        variable expected_val : std_logic_vector(16 downto 0);
        variable actual_val : std_logic_vector(16 downto 0);
    begin
        -- Attende che m_axis_tlast sia attivo per il numero di righe attese
        -- Per un'immagine 5x5, ci dovrebbero essere 5 righe di output
        wait until last_line_count = NROW_IMG;
        wait for CLK_PERIOD * 5; -- Attesa per completamento pipeline

        report "=== Verifica finale immagini ===";
        report "Immagine in ingresso (5x5):";
        for row in 0 to NROW_IMG-1 loop
            for col in 0 to NCOL_IMG-1 loop
                report "R" & integer'image(row) & "C" & integer'image(col) & ": " &
                       integer'image(to_integer(unsigned(sent_pixels(row, col))));
            end loop;
        end loop;

        report "Immagine in uscita (5x5):";
        for row in 0 to NROW_IMG-1 loop
            for col in 0 to NCOL_IMG-1 loop
                report "R" & integer'image(row) & "C" & integer'image(col) & ": " &
                       integer'image(to_integer(unsigned(received_pixels(row, col))));
            end loop;
        end loop;

        -- Verifica se le due immagini sono uguali
        report "=== Confronto immagini ===";
        all_pixels_match := true;
        for row in 0 to NROW_IMG-1 loop
            for col in 0 to NCOL_IMG-1 loop
                expected_val := std_logic_vector(resize(unsigned(sent_pixels(row, col)), 17));
                actual_val := received_pixels(row, col);

                if expected_val /= actual_val then
                    report "ERRORE: Pixel (" & integer'image(row) & "," & integer'image(col) & ")" &
                           " - Atteso: " & integer'image(to_integer(unsigned(expected_val))) &
                           ", Ricevuto: " & integer'image(to_integer(unsigned(actual_val)))
                           severity error;
                    all_pixels_match := false;
                else
                    report "OK: Pixel (" & integer'image(row) & "," & integer'image(col) & ")" &
                           " - Valore: " & integer'image(to_integer(unsigned(expected_val)));
                end if;
            end loop;
        end loop;

        if all_pixels_match then
            report "=== VERIFICA SUPERATA ===" severity note;
            report "Tutte le finestre valide contengono il pixel centrale atteso";
        else
            report "=== VERIFICA FALLITA ===" severity error;
            report "Alcuni pixel nella finestra non corrispondono al pixel centrale";
        end if;

        report "Simulazione completata. Total pixels sent: " & integer'image(pixel_count);
        report "Total outputs received: " & integer'image(output_count);
        wait;
    end process;

    -- ================================================================
    -- Processo di monitoraggio segnali di interesse
    -- ================================================================
    signal_monitor : process(s_axis_clk)
    begin
        if rising_edge(s_axis_clk) then
            -- Monitora handshake input
            if s_axis_tvalid = '1' and s_axis_tready = '1' then
                report "S_AXIS handshake @ " & time'image(now) &
                       ", Pixel: " & integer'image(to_integer(unsigned(s_axis_tdata)));
            end if;

            -- Monitora handshake output
            if m_axis_tvalid = '1' and m_axis_tready = '1' then
                report "M_AXIS handshake @ " & time'image(now) &
                       ", Output: " & integer'image(to_integer(unsigned(m_axis_tdata)));
            end if;
        end if;
    end process;

    -- ================================================================
    -- Processo di Controllo Backpressure (Opzionale)
    -- ================================================================
    -- Per testare il flusso con tready variabile, decommentare:
    backpressure : process
    begin
        m_axis_tready <= '1';
        wait for CLK_PERIOD * 10;
        m_axis_tready <= '0';  -- Blocca per 3 cicli
        wait for CLK_PERIOD * 3;
        m_axis_tready <= '1';
    end process;

end testing;