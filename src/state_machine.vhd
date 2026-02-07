library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;
    use ieee.numeric_std.all;

entity state_machine is
    generic(
        ncol_img        : integer := 32;
        nrow_img        : integer := 32;
        kernel_row_size : integer := 3
    );
    port(
        s_axis_clk      : in  std_logic;
        s_axis_rstn     : in  std_logic;

        s_axis_tvalid   : in  std_logic;
        s_axis_tready   : out std_logic;
        s_axis_tlast    : in  std_logic; -- Input EOL
        s_axis_tuser    : in  std_logic; -- Input SOF

        m_axis_tvalid   : out std_logic;
        m_axis_tready   : in  std_logic;
        m_axis_tlast    : out std_logic; -- Output EOL
        m_axis_tuser    : out std_logic; -- Output SOF

        pipeline_en     : out std_logic;
        window_valid    : out std_logic;
        flush_pipeline  : out std_logic
    );
end state_machine;

architecture Behavioral of state_machine is
    -- Definizione Stati
    type state_type is (LOADING, RUNNING, FLUSH);
    signal current_state : state_type;

    -- Segnali interni
    signal pipeline_en_s    : std_logic;
    signal window_valid_s   : std_logic;
    signal flush_pipeline_s : std_logic;
    signal m_axis_tlast_s   : std_logic;
    signal m_axis_tuser_s   : std_logic;

    -- Contatori
    -- Latency counter: conta quanto serve per riempire il buffer iniziale
    signal latency_counter  : integer range 0 to ncol_img + kernel_row_size * 2;
    -- Input row counter: conta le righe ricevute
    signal in_row_counter   : integer range 0 to nrow_img;
    -- Output col counter: conta i pixel validi usciti per generare il TLAST
    signal out_col_counter  : integer range 0 to ncol_img;

    -- Costante di latenza (Esempio: 1 riga + raggio kernel per avere centro valido 3x3)
    -- Modifica questo valore in base alla latenza effettiva dei tuoi shift register
    constant LATENCY_TARGET : integer := ncol_img + 1;

begin

    -- 1. Controllo Pipeline (Handshake & Enable)
    -- La pipeline avanza se:
    -- (Ho dati in ingresso o sto facendo flush) e (L'uscita è pronta ad accettare o se la finestra non sarà valida)
    pipeline_en_s <= '1' when ((s_axis_tvalid = '1' or current_state = FLUSH) and (m_axis_tready = '1' or window_valid_s = '0')) else '0';

    -- Accetto dati in ingresso solo se non sto facendo FLUSH e l'uscita è pronta
    s_axis_tready <= '1' when (current_state /= FLUSH and m_axis_tready = '1') else '0';

    -- 2. Macchina a Stati Principale con SOF
    process(s_axis_clk)
    begin
        if rising_edge(s_axis_clk) then
            -- Reset asincrono hardware (sempre utile)
            if s_axis_rstn = '0' then
                current_state   <= LOADING; -- Partiamo diretti in LOADING
                latency_counter <= 0;
                in_row_counter  <= 0;
                out_col_counter <= 0;
                flush_pipeline_s<= '0';
                m_axis_tlast_s  <= '0';
                m_axis_tuser_s  <= '0';

            elsif pipeline_en_s = '1' then

                -- LOGICA DI SINCRONIZZAZIONE SOF (Nuova parte)
                -- Se arriva un TUSER valido, è SEMPRE l'inizio di un nuovo frame.
                -- Resettiamo tutto indipendentemente dallo stato attuale.
                if s_axis_tvalid = '1' and s_axis_tuser = '1' then
                    current_state   <= LOADING;
                    latency_counter <= 1; -- Abbiamo già il primo pixel
                    in_row_counter  <= 0;
                    out_col_counter <= 0;
                    flush_pipeline_s<= '0'; -- Interrompe un eventuale flush in corso
                    m_axis_tuser_s  <= '0'; -- Reset SOF output

                else
                    -- Gestione TLAST output (Invariata)
                    if window_valid_s = '1' then
                        if out_col_counter = ncol_img - 1 then
                            out_col_counter <= 0;
                            m_axis_tlast_s  <= '1';
                        else
                            out_col_counter <= out_col_counter + 1;
                            m_axis_tlast_s  <= '0';
                        end if;
                    else
                        m_axis_tlast_s <= '0';
                    end if;

                    case current_state is
                        when LOADING =>
                            if latency_counter < LATENCY_TARGET then
                                latency_counter <= latency_counter + 1;
                            else
                                current_state <= RUNNING;
                                -- Setup contatori output...
                                if ncol_img > 1 then out_col_counter <= 1; else out_col_counter <= 0; end if;
                                -- Attiva SOF sul primo pixel valido di output
                                m_axis_tuser_s <= '1';
                            end if;

                            if s_axis_tlast = '1' then
                                in_row_counter <= in_row_counter + 1;
                            end if;

                        when RUNNING =>
                            -- Disattiva SOF dopo il primo pixel valido
                            if m_axis_tuser_s = '1' then
                                m_axis_tuser_s <= '0';
                            end if;

                            if s_axis_tlast = '1' then
                                if in_row_counter = nrow_img - 1 then
                                    current_state    <= FLUSH;
                                    flush_pipeline_s <= '1';
                                    latency_counter  <= LATENCY_TARGET;
                                else
                                    in_row_counter <= in_row_counter + 1;
                                end if;
                            end if;

                        when FLUSH =>
                            latency_counter <= latency_counter - 1;
                            if latency_counter = 0 then
                                -- Rimani in stato di attesa fino a prossimo SOF
                                current_state    <= LOADING;
                                latency_counter  <= 0;
                                flush_pipeline_s <= '0';
                            end if;

                    end case;
                end if;
            end if;
        end if;
    end process;

    -- 3. Logica Combinatoria Output
    -- La finestra è valida quando siamo a regime o stiamo svuotando
    window_valid_s <= '1' when (current_state = RUNNING or current_state = FLUSH) else '0';

    -- Assegnazione uscite
    m_axis_tvalid   <= window_valid_s; -- L'uscita è valida solo se window_valid è alto
    m_axis_tlast    <= m_axis_tlast_s;
    m_axis_tuser    <= m_axis_tuser_s; -- Output SOF

    pipeline_en     <= pipeline_en_s;
    window_valid    <= window_valid_s;
    flush_pipeline  <= flush_pipeline_s;

end Behavioral;
