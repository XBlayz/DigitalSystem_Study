library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;

entity state_machine is
    generic(
        kernel_row_size : integer := 3;
        kernel_col_size : integer := 3
    );
    port(
        s_axis_clk      : in  std_logic;
        s_axis_rstn     : in  std_logic;

        s_axis_tvalid   : in  std_logic;
        s_axis_tready   : out std_logic;
        s_axis_tlast    : in  std_logic; -- #TODO: ??? Segnale di fine del pixel o fine riga ??? !!!USATO COME FINE RIGA!!!

        m_axis_tvalid   : out std_logic;
        m_axis_tready   : in  std_logic;
        m_axis_tlast    : out std_logic; -- #TODO: ??? Segnale di fine del pixel o fine riga ???

        pipeline_en     : out std_logic;
        window_valid    : out std_logic
    );
end state_machine;

architecture Behavioral of state_machine is
    -- Stati
    type state is (IDLE, LOADING, RUNNING, WRAP_LINE);
    signal current_state : state;

    -- Contatori
    signal row_counter : integer range 0 to kernel_row_size := 0;
    signal gap_counter : integer range 0 to kernel_col_size := 0;

begin
    -- Controllo handshake AXI
    s_axis_tready <= m_axis_tready;

    -- Controllo della pipeline
    -- La pipeline è abilitata se:
    --     1. Il dato in ingresso è valido e posso mandare un dato in uscita
    --     2. Il dato in ingresso è valido e non devo mandare in uscita alcun dato (finestra non valida)
    --        #TODO: Non obbligatoria ma permette alla pipeline di proseguire anche se la porta di uscita non è valida ma non ho ancora un dato da mandare
    pipeline_en <= s_axis_tvalid and (m_axis_tready or not window_valid);

    -- Macchina a stati
    process(s_axis_clk)
    begin
        if rising_edge(s_axis_clk) then
            if s_axis_rstn = '0' then
                current_state <= IDLE;
                row_counter   <= 0;
                gap_counter   <= 0;
            elsif pipeline_en = '1' then
                case current_state is
                    -- Arrivo del primo dato
                    when IDLE =>
                        -- Reset riga
                        row_counter <= 0;

                        -- Transizione da IDLE a LOADING
                        current_state <= LOADING;

                    -- Caricamento della prima finestra
                    when LOADING =>
                        -- Se abbiamo finito una riga
                        if s_axis_tlast = '1' then
                            if row_counter < 1 then
                                -- Incrementiamo il contatore delle righe caricate
                                row_counter <= row_counter + 1;
                            else
                                -- Abbiamo finito la riga 1 (seconda riga)
                                -- La prossima è la riga 2, che inizierà a produrre output
                                -- Prima però dobbiamo rispettare il gap orizzontale
                                gap_counter   <= kernel_col_size;

                                -- Transizione da LOADING a WRAP_LINE
                                current_state <= WRAP_LINE;
                            end if;
                        end if;

                    -- Finestra valida, generazione output
                    when RUNNING =>
                        -- Se arriva tlast, significa che questo è l'ultimo pixel valido della riga
                        -- Dal prossimo ciclo dobbiamo attendere il wrap orizzontale
                        if s_axis_tlast = '1' then
                            gap_counter   <= kernel_col_size;

                            -- Transizione da RUNNING a WRAP_LINE
                            current_state <= WRAP_LINE;
                        end if;

                    -- Attesa che la finestra sia valida
                    when WRAP_LINE =>
                        -- Decrementa il contatore di attesa
                        if gap_counter > 1 then
                            gap_counter <= gap_counter - 1;
                        else

                            -- Transizione da WRAP_LINE a RUNNING
                            current_state <= RUNNING;
                        end if;
                end case;

            end if;
        end if;
    end process;

    -- Gestione segnali sulla base dello stato
    window_valid <= '1' when (current_state = RUNNING) else '0';
    m_axis_tvalid <= window_valid;
end Behavioral;
