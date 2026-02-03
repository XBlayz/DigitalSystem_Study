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
        s_axis_tlast    : in  std_logic; -- Input TLAST

        m_axis_tvalid   : out std_logic;
        m_axis_tready   : in  std_logic;
        m_axis_tlast    : out std_logic; -- Output TLAST

        pipeline_en     : out std_logic;
        window_valid    : out std_logic;
        flush_pipeline  : out std_logic
    );
end state_machine;

architecture Behavioral of state_machine is
    -- Definizione Stati
    type state_type is (IDLE, LOADING, RUNNING, FLUSH);
    signal current_state : state_type;

    -- Segnali interni
    signal pipeline_en_s    : std_logic;
    signal window_valid_s   : std_logic;
    signal flush_pipeline_s : std_logic;
    signal m_axis_tlast_s   : std_logic;

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

    -- 2. Macchina a Stati Principale
    process(s_axis_clk)
    begin
        if rising_edge(s_axis_clk) then
            if s_axis_rstn = '0' then
                current_state   <= IDLE;
                latency_counter <= 0;
                in_row_counter  <= 0;
                out_col_counter <= 0;
                flush_pipeline_s<= '0';
                m_axis_tlast_s  <= '0';
            elsif pipeline_en_s = '1' then

                -- Gestione TLAST output (generica per RUNNING e FLUSH)
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

                -- FSM Transitions
                case current_state is

                    when IDLE =>
                        latency_counter <= 1; -- Iniziamo a contare il primo pixel
                        in_row_counter  <= 0;
                        out_col_counter <= 0;
                        current_state   <= LOADING;

                    when LOADING =>
                        -- Contiamo input fino a riempire la latenza necessaria
                        if latency_counter < LATENCY_TARGET then
                            latency_counter <= latency_counter + 1;
                        else
                            -- Latenza raggiunta, passiamo a regime
                            current_state <= RUNNING;
                            -- Primo pixel valido esce ora
                            if ncol_img > 1 then
                                out_col_counter <= 1;
                            else
                                out_col_counter <= 0; -- Caso degenere img 1px
                            end if;
                        end if;

                        -- Monitoraggio fine riga input
                        if s_axis_tlast = '1' then
                            in_row_counter <= in_row_counter + 1;
                        end if;

                    when RUNNING =>
                        -- Monitoraggio input
                        if s_axis_tlast = '1' then
                            if in_row_counter = nrow_img - 1 then
                                -- Abbiamo ricevuto l'ultimo pixel dell'immagine
                                -- Passiamo a FLUSH per svuotare la pipeline (padding bottom)
                                current_state    <= FLUSH;
                                flush_pipeline_s <= '1'; -- Abilita generazione zeri interni
                                -- Usiamo latency_counter per contare quanti pixel mancano da svuotare
                                latency_counter  <= LATENCY_TARGET;
                            else
                                in_row_counter <= in_row_counter + 1;
                            end if;
                        end if;

                    when FLUSH =>
                        -- Decrementiamo il contatore di svuotamento
                        latency_counter <= latency_counter - 1;

                        -- Se abbiamo svuotato tutto
                        if latency_counter = 0 then
                            current_state    <= IDLE;
                            flush_pipeline_s <= '0';
                        end if;

                end case;
            end if;
        end if;
    end process;

    -- 3. Logica Combinatoria Output
    -- La finestra è valida quando siamo a regime o stiamo svuotando
    window_valid_s <= '1' when (current_state = RUNNING or current_state = FLUSH) else '0';

    -- Assegnazione uscite
    m_axis_tvalid   <= window_valid_s; -- L'uscita è valida solo se window_valid è alto
    m_axis_tlast    <= m_axis_tlast_s;

    pipeline_en     <= pipeline_en_s;
    window_valid    <= window_valid_s;
    flush_pipeline  <= flush_pipeline_s;

end Behavioral;
