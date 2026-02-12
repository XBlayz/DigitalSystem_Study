library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use std.textio.all;

entity tb_project is
end entity tb_project;

architecture testing of tb_project is
    -- Testing parameters
    constant CLK_PERIOD       : time := 10 ns;
    constant NCOL_IMG         : integer := 32;
    constant NROW_IMG         : integer := 32;

    -- FILE I/O SETTINGS
    -- Assicurati che questi file esistano nella cartella della simulazione
    file input_file  : text open read_mode  is "lena32_vettore.txt";
    file output_file : text open write_mode is "filtered_lena32_vettore.txt";

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
    signal m_axis_tdata  : std_logic_vector((8+4+4)-1 downto 0); -- 16 bits

    -- Auxiliary signals
    signal pixel_count   : integer := 0;
    signal output_count  : integer := 0;
    signal last_line_count : integer := 0;

    -- Component to test
    component main_static is
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
            m_axis_tdata    : out std_logic_vector((8+4+4)-1 downto 0)
        );
    end component main_static;

begin
    -- Component instantiation
    main_inst: main_static
         port map (
            s_axis_clk      => not(s_axis_clk), -- #TODO: Da verificare
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

    -- ================================================================
    -- PROCESS 1: LETTURA FILE E INVIO DATI
    -- ================================================================
    stimulus : process
        variable row, col : integer;

        variable file_line : line;
        variable pixel_int : integer;
        variable pixel_slv : std_logic_vector(7 downto 0);
    begin
        -- 1. Initial reset
        s_axis_rstn <= '0';
        wait for CLK_PERIOD * 10;
        s_axis_rstn <= '1';
        -- Cambio segnali nel falling edge
        wait until falling_edge(s_axis_clk);

        report "Inizio lettura file e invio pixel...";

         -- 2. Sending data
        for row in 0 to NROW_IMG-1 loop
            for col in 0 to NCOL_IMG-1 loop
                -- LETTURA DAL FILE
                if not endfile(input_file) then
                    readline(input_file, file_line); -- Legge una riga
                    read(file_line, pixel_int);      -- Legge l'intero dalla riga
                    pixel_slv := std_logic_vector(to_unsigned(pixel_int, 8));
                else
                    report "Attenzione: Fine del file raggiunta prima del previsto!" severity warning;
                    pixel_slv := (others => '0'); -- Padding con neri
                end if;

                -- PILOTAGGIO SEGNALI
                s_axis_tdata  <= pixel_slv;
                s_axis_tvalid <= '1';

                -- Gestione TLAST (Fine riga)
                if col = NCOL_IMG-1 then
                    s_axis_tlast <= '1';
                else
                    s_axis_tlast <= '0';
                end if;

                -- Gestione TUSER (Start of Frame)
                if row = 0 and col = 0 then
                    s_axis_tuser <= '1';
                else
                    s_axis_tuser <= '0';
                end if;

                -- Attesa Handshake (Rising Edge)
                wait until rising_edge(s_axis_clk);
                while s_axis_tready = '0' loop
                    wait until rising_edge(s_axis_clk);
                end loop;

                -- Ritorno al falling edge per il prossimo dato
                wait until falling_edge(s_axis_clk);

            end loop;
        end loop;

        -- 3. Fine invio
        s_axis_tvalid <= '0';
        s_axis_tlast  <= '0';
        report "Invio file completato.";
        wait;
    end process;

    -- ================================================================
    -- PROCESS 2: RICEZIONE DATI E SCRITTURA SU FILE
    -- ================================================================
    output_writer : process(s_axis_clk)
        variable out_line : line;
        variable out_int  : integer;
    begin
        if rising_edge(s_axis_clk) then
            if s_axis_rstn = '1' and m_axis_tvalid = '1' and m_axis_tready = '1' then
                -- Converti il dato ricevuto in intero
                out_int := to_integer(signed(m_axis_tdata));

                -- Scrivi sul file
                write(out_line, out_int);       -- Scrive il numero nella linea buffer
                writeline(output_file, out_line); -- Scrive la linea buffer nel file
            end if;
        end if;
    end process;

end testing;
