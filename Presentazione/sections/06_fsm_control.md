---
lang: IT, EN

layout: section
title: FSM e AXI-Stream
---

# 6. Finite State Machine e Interfacce AXI-Stream
Orchestrazione della _pipeline_ e **interfacce AXI-Stream**

---
level: 2
---

# Diagramma degli Stati della FSM
La FSM è strutturata nel seguente modo

<div class="grid grid-cols-2 gap-8 mt-4">
<div>

La macchina a stati principale controlla il _riempimento_ e lo _svuotamento_ della finestra `3x3`.

Ogni stato gestisce 3 segnali relativi alla pipeline:
- `pipeline_en`: gestisce l'avanzamento dei dati nella pipeline
- `window_valid`: gestisce il registro di uscita (sampling del pixel filtrato)
- `flush_pipeline`: gestisce se leggere un nuovo pixel o _zero_ in ingresso alla pipeline

</div>
<div class="flex justify-center mt-8">

```mermaid
stateDiagram-v2
    [*] --> IDLE : Reset
    IDLE --> LOADING : SOF

    LOADING --> RUNNING : Prima finestra caricata
    RUNNING --> FLUSH : Ricevuto l'ultimo pixel
    FLUSH --> IDLE : Elaborazioni ultimo pixel

    note right of IDLE
        Questo stato viene gestito dal segnale `s_axis_tuser` (SOF)
    end note

    classDef tratteggiato stroke-dasharray: 5 5
    class IDLE tratteggiato
```

</div>
</div>

<br>

> **Nota**: Lo stato di `IDLE` è assente in quanto si fa uso del segnale `s_axis_tuser` (**Start Of Frame**) per avviare la _pipeline_.

---
level: 2
---

# Gestione dell'Interfaccia AXI Stream
Il design agisce come un nodo di elaborazione stream (slave in ingresso, master in uscita), gestendo _handshake_, i segnali `TLAST` e `TUSER` e gestendo eventuale _back-pressure_ a valle del circuito.

<div class="grid grid-cols-2 gap-8 mt-4">
<div>

### AXI Slave (Ingresso)

- **Handshake**: `s_axis_tready` viene asserito quando la pipeline può avanzare (non siamo in `FLUSH` e l'uscita non è **bloccata**)
- **SOF (`tuser`)**: Campionato per avviare la pipeline
- **EOL (`tlast`)**: Campionato per contare le righe in ingresso e innescare la fase di `FLUSH` al caricamento dell'ultimo pixel

</div>
<div>

### AXI Master (Uscita)

- **Handshake**: `m_axis_tvalid` è alto *solo* quando `window_valid = '1'` (finestra 3x3 piena e dato in uscita valido)
- **SOF (`tuser`)**: Rigenerato artificialmente e tenuto alto per un solo ciclo in corrispondenza del primo pixel valido in uscita
- **EOL (`tlast`)**: Generato internamente da un contatore di _colonna_ per segnalare la fine della riga elaborata

</div>
</div>

---
level: 2
---

# Start of Frame (SOF) & Rimozione dell'IDLE
Sfruttamento del segnale `tuser` per eliminare lo stato di `IDLE`

Invece di avere uno stato inattivo la FSM si ferma fino a quando non arriva un **SOF**.

```vhdl {10-15|all}
-- Processo Sincrono della FSM
if rising_edge(s_axis_clk) then
    if s_axis_rstn = '0' then
        current_state <- LOADING;
        -- Reset registri...

    elsif pipeline_en_s = '1' then

        -- LOGICA DI SINCRONIZZAZIONE SOF
        -- Se arriva un TUSER valido, è SEMPRE l'inizio di un nuovo frame.
        if s_axis_tvalid = '1' and s_axis_tuser = '1' then
            current_state    <- LOADING;
            latency_counter  <- 1; -- Abbiamo già il primo pixel
            flush_pipeline_s <- '0'; -- Interrompe flush precedenti
            m_axis_tuser_s   <- '0';
            -- Reset contatori...
        else
            -- Evoluzione normale degli stati (LOADING, RUNNING, FLUSH)

```

---
level: 2
---

# Controllo Pipeline e Backpressure
La logica combinatoria che governa l'abilitazione dei registri (`pipeline_en`) è il cuore del dataflow

```vhdl {1-4|6-7|all}
-- 1. Controllo Pipeline (Avanzamento Globale)
pipeline_en_s <- '1' when ((s_axis_tvalid = '1' or current_state = FLUSH)
                           and (m_axis_tready = '1' or window_valid_s = '0'))
                     else '0';

-- 2. Handshake Ingresso (TREADY)
s_axis_tready <- '1' when (current_state /= FLUSH and m_axis_tready = '1') else '0';
```

### Analisi della Backpressure
Il segnale `m_axis_tready` in ingresso indica se il ricevitore a valle può accettare dati.
Se va basso (`'0'`) mentre la finestra è valida, `pipeline_en_s` va a `'0'`.
L'intero datapath si _"congela"_, preservando i risultati parziali senza perdere alcun pixel, per poi ripartire istantaneamente appena il ricevitore torna pronto.

---
level: 2
---

# Strategia di verifica di funzionamento
Abbiamo creato una testbench per verificare il corretto funzionamento della FSM insieme alla `buffer_line`

<div class="grid grid-cols-2 gap-8">
<div>

### Setup di Simulazione
Per facilitare il debug visivo delle waveform, abbiamo ridotto i parametri rispetto al design reale:
- **Immagine:** 5x5 pixel (invece di 32x32)
- **Pattern Dati:** Incrementale
    - *Pixel*: $Row \times Width + Col$ (0, 1, 2, ...)
    - _Nessuna elaborazione_
- **Obiettivo:** Verificare i casi limite (Start of Frame, End of Line, Flush finale)

</div>
<div>

```mermaid
graph TD
    subgraph "Testbench Scope"
        GEN[Stimulus Gen]

        subgraph "DUT"
            FSM[State Machine]
            BUF[Buffer Line]
        end

        GEN -- "AXI In (Valid/Last/Data)" --> FSM
        FSM -- "Control (En/Flush)" --> BUF
        GEN -- "Data Copy" --> BUF
        BUF -- "Window 3x3" --> WAVE[Waveform]
    end
```

![Testbench](../img/TB_waveforme_BL+FSM.png)

</div>
</div>

---
level: 2
---

# Generazione Stimoli e Handshake
Il processo di stimolo emula il flusso dati **AXI-Stream** in ingresso e legge il flusso dati **AXI-Stream** in uscita

Inoltre viene simulata la _backpressure_ e l'esecuzione del _flush_ anche in non validità dell'ingresso per testare la **robustezza** della FSM.

<div class="grid grid-cols-2 gap-4">
<div>

```vhdl {all|6-10}
-- Generazione Immagine 5x5
for row in 0 to NROW-1 loop
  for col in 0 to NCOL-1 loop
    -- Data = Indice univoco
    s_axis_tdata  <- std_logic_vector(...);
    s_axis_tvalid <- '1';

    -- Wait for Handshake (Backpressure)
    wait until rising_edge(clk);
    while s_axis_tready = '0' loop
       wait until rising_edge(clk);
    end loop;
  end loop;
end loop;

```

</div>
<div>

### Punti Chiave della Verifica

1. **Handshake Compliance:** Il loop `while` garantisce che il testbench si fermi se la FSM abbassa `tready` (es. durante il reset)
2. **Fase di Flush:** Al termine dei loop, `tvalid` va a 0. Verifichiamo che la FSM attivi il `flush_pipeline` e che il buffer continui a avanzare inserendo zeri (padding) fino allo svuotamento completo

</div>
</div>
