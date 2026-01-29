----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 11.12.2019 09:25:27
-- Design Name:
-- Module Name: BufferLine - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- use IEEE.NUMERIC_STD.ALL;

entity BufferLine is
    generic(
        ncol : integer := 32  -- Impostato a 32 per immagine
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
        -- Output a 72 bit: contiene i 9 pixel della finestra 3x3
        -- Formato: d22 & d21 & d20 & d12 & d11 & d10 & d02 & d01 & d00
        m_axis_tdata    : out std_logic_vector(71 downto 0) 
    );
end BufferLine;

architecture Behavioral of BufferLine is

    type state is (s0, s1, s2, s3);
    signal state_curr, state_next : state;
    
    -- Registri per la finestra 3x3
    -- d0x: riga corrente 
    -- d1x: riga precedente (ritardo 1 linea)
    -- d2x: due righe fa (ritardo 2 linee)
    signal d00, d01, d02 : std_logic_vector(7 downto 0);
    signal d10, d11, d12 : std_logic_vector(7 downto 0);
    signal d20, d21, d22 : std_logic_vector(7 downto 0);
    
    signal buffer1_out, buffer2_out : std_logic_vector(7 downto 0);
    
    -- Buffer di linea (FIFO)
    type reg_array is array (ncol-4 downto 0) of std_logic_vector(7 downto 0);
    signal buffer1, buffer2 : reg_array;
    
    signal count_latencyin, count_latencyout : std_logic_vector(9 downto 0); -- Usiamo std_logic_vector per coerenza con UNSIGNED
    signal data_valid, en_countout : std_logic;

begin

    s_axis_tready <= m_axis_tready;
    data_valid    <= s_axis_tvalid and m_axis_tready;

    -- =========================================================================
    -- RIGA 0 (Ingresso diretto + shift registers locali)
    -- =========================================================================
    process(s_axis_clk)
    begin
        if rising_edge(s_axis_clk) then
            if s_axis_rstn = '0' then
                d00 <= (others => '0');
                d01 <= (others => '0');
                d02 <= (others => '0');
            else
                if data_valid = '1' then
                    d00 <= s_axis_tdata; -- Pixel più nuovo
                end if;
                if m_axis_tready = '1' then
                    d01 <= d00;
                    d02 <= d01;
                end if;
            end if;
        end if;
    end process;

    -- =========================================================================
    -- LINE BUFFER 1 (Memorizza una riga intera)
    -- =========================================================================
    process(s_axis_clk)
    begin
        if rising_edge(s_axis_clk) then
            if s_axis_rstn = '0' then
                for j in 0 to ncol-4 loop
                    buffer1(j) <= (others => '0');
                end loop;
            else
                if m_axis_tready = '1' then
                    buffer1(0) <= d02; -- Prende l'uscita dello stadio precedente
                    for j in 1 to ncol-4 loop
                        buffer1(j) <= buffer1(j-1);
                    end loop;
                end if;
            end if;
        end if;
    end process;

    buffer1_out <= buffer1(ncol-4);

    -- =========================================================================
    -- RIGA 1 (Uscita dal buffer 1 + shift registers locali)
    -- =========================================================================
    process(s_axis_clk)
    begin
        if rising_edge(s_axis_clk) then
            if s_axis_rstn = '0' then
                d10 <= (others => '0');
                d11 <= (others => '0');
                d12 <= (others => '0');
            else
                if m_axis_tready = '1' then
                    d10 <= buffer1_out;
                    d11 <= d10;
                    d12 <= d11;
                end if;
            end if;
        end if;
    end process;

    -- =========================================================================
    -- LINE BUFFER 2 (Memorizza la seconda riga intera)
    -- =========================================================================
    process(s_axis_clk)
    begin
        if rising_edge(s_axis_clk) then
            if s_axis_rstn = '0' then
                for j in 0 to ncol-4 loop
                    buffer2(j) <= (others => '0');
                end loop;
            else
                if m_axis_tready = '1' then
                    buffer2(0) <= d12;
                    for j in 1 to ncol-4 loop
                        buffer2(j) <= buffer2(j-1);
                    end loop;
                end if;
            end if;
        end if;
    end process;

    buffer2_out <= buffer2(ncol-4);

    -- =========================================================================
    -- RIGA 2 (Uscita dal buffer 2 + shift registers locali)
    -- =========================================================================
    process(s_axis_clk)
    begin
        if rising_edge(s_axis_clk) then
            if s_axis_rstn = '0' then
                d20 <= (others => '0');
                d21 <= (others => '0');
                d22 <= (others => '0');
            else
                if m_axis_tready = '1' then
                    d20 <= buffer2_out;
                    d21 <= d20;
                    d22 <= d21;
                end if;
            end if;
        end if;
    end process;

    -- =========================================================================
    -- MACCHINA A STATI (Gestione Valid/Last e Riempimento Pipeline)
    -- =========================================================================
    process(s_axis_clk)
    begin
        if rising_edge(s_axis_clk) then
            if s_axis_rstn = '0' then
                state_curr <= s0;
            else
                case state_curr is
                    when s0 =>
                        if s_axis_rstn = '1' then
                            state_curr <= s1;
                        else
                            state_curr <= s0;
                        end if;
                    when s1 =>
                        -- Attende il riempimento iniziale dei buffer (2 righe + latenza)
                        if count_latencyin > 2*ncol + 5 then
                            state_curr <= s2;
                        else
                            state_curr <= s1;
                        end if;
                    when s2 =>
                        if s_axis_tlast = '1' then
                            state_curr <= s3;
                        else
                            state_curr <= s2;
                        end if;
                    when s3 =>
                        -- Gestisce lo svuotamento finale
                        if count_latencyout > 5 then
                            state_curr <= s0;
                        else
                            state_curr <= s3;
                        end if;
                end case;
            end if;
        end if;
    end process;

    -- Logica di uscita della FSM
    process(state_curr, count_latencyout)
    begin
        case state_curr is
            when s0 =>
                m_axis_tvalid <= '0';
                m_axis_tlast  <= '0';
            when s1 =>
                m_axis_tvalid <= '0';
                m_axis_tlast  <= '0';
            when s2 =>
                m_axis_tvalid <= '1';
                m_axis_tlast  <= '0';
            when s3 =>
                m_axis_tvalid <= '1';
                if count_latencyout = 5 then
                    m_axis_tlast <= '1';
                else
                    m_axis_tlast <= '0';
                end if;
        end case;
    end process;

    -- Contatori di latenza
    process(s_axis_clk)
    begin
        if rising_edge(s_axis_clk) then
            if s_axis_rstn = '0' then
                en_countout      <= '0';
                count_latencyin  <= (others => '0');
                count_latencyout <= (others => '0');
            else
                if s_axis_tvalid = '1' then
                    count_latencyin <= count_latencyin + 1;
                end if;
                
                if s_axis_tlast = '1' then
                    en_countout <= '1';
                end if;
                
                if en_countout = '1' then
                    count_latencyin  <= (others => '0');
                    count_latencyout <= count_latencyout + 1;
                else
                    count_latencyout <= (others => '0');
                end if;
            end if;
        end if;
    end process;

    -- =========================================================================
    -- ASSEGNAZIONE OUTPUT
    -- =========================================================================
    -- 9 pixel. 
    -- MSB -> d22 (Riga 2, Col 2 - Pixel più vecchio nella finestra)
    -- LSB -> d00 (Riga 0, Col 0 - Pixel più nuovo nella finestra)
    m_axis_tdata <= d22 & d21 & d20 & d12 & d11 & d10 & d02 & d01 & d00;

end Behavioral;