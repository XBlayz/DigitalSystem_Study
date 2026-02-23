---
lang: IT, EN

layout: section
title: Componenti Base
---

# 2. Componenti Base
Componenti base e di ausilio

---
level: 2
---

# Full Adder
L'elemento atomico per le operazioni aritmetiche.

Implementa la somma di tre bit ($A, B, C_{in}$).

<div class="grid grid-cols-2 gap-8">
<div>

### Logica Implementativa
Abbiamo scelto una descrizione `behavioral` ottimizzata per l'inferenza hardware.

- **Somma ($S$):** XOR a 3 ingressi.
- **Riporto ($C_{out}$):** Calcolato sfruttando il segnale di propagazione $P$.
    - Se $P = 1$ ($A \neq B$), il riporto dipende da $C_{in}$.
    - Se $P = 0$ ($A = B$), il riporto è uguale ad $A$.

$$S = A \oplus B \oplus C_{in}$$
$$C_{out} = A \cdot B + C_{in} \cdot (A \oplus B)$$

</div>
<div>

```vhdl {all|13-14|16}
entity full_adder is
    port (
        a, b, cin : in  STD_LOGIC;
        s, cout   : out STD_LOGIC
    );
end entity full_adder;

architecture behavioral of full_adder is
    signal p : STD_LOGIC;
begin
    -- Calcolo Propagate
    p    <- a xor b;
    s    <- p xor cin;

    -- Mux-based Carry logic (Efficiente su FPGA)
    cout <- cin when p = '1' else a;
end architecture behavioral;

```

</div>
</div>

---
level: 2
---

# N-Bit Ripple Carry Adder (RCA)
Per sommare vettori di bit, colleghiamo Full Adder in cascata

<div class="grid grid-cols-2 gap-8">
<div>

### Architettura Parametrica
Il componente è reso generico tramite il parametro `N`.
Utilizziamo il costrutto `generate` per istanziare dinamicamente la catena di addizionatori.

- **Vantaggi:** Semplicità e Area ridotta
- **Svantaggi:** Ritardo di propagazione lineare (il riporto deve attraversare tutta la catena)

<!-- #TODO: Uso del RCA con risorse dedicate su FPGA -->

</div>
<div>

```vhdl {1-4|6-21}
entity ripple_carry_adder is
    generic ( N : POSITIVE ); -- Parametro Generico
    port ( ... );
end entity ripple_carry_adder;

-- Architecture
begin
    c(0) <- cin; -- Carry in iniziale

    loop_n: for i in 0 to N - 1 generate
        fa_i: component full_adder
            port map (
                a    => a(i),
                b    => b(i),
                cin  => c(i),
                s    => s(i),
                cout => c(i + 1) -- Chain connection
            );
    end generate loop_n;

    cout <- c(N); -- Ultimo riporto
```

</div>
</div>

---
level: 2
---

# Unit Testing: Full Adder
Verifica esaustiva (Exhaustive testing)

Poiché il Full Adder ha solo 3 ingressi ($A, B, C_{in}$), lo spazio degli stati è piccolo ($2^3 = 8$ casi).
Abbiamo implementato una testbench che itera su una **Tabella della Verità** completa.

<div class="grid grid-cols-2 gap-4">
<div>

```vhdl {all|1-9|11-16}
type truth_table_type is array (0 to 7)
     of STD_LOGIC_VECTOR(4 downto 0);

constant TRUTH_TABLE : truth_table_type := (
    "000" & "00", -- 0+0+0 = 0 (C=0)
    "011" & "10", -- 0+1+1 = 0 (C=1)
    "111" & "11", -- 1+1+1 = 1 (C=1)
    ...
);

-- Loop di simulazione
for i in 0 to 7 loop
    gen_input <- unsigned(TRUTH_TABLE(i)(4 downto 2));

    -- Testing automatizzato...
end loop;
```

</div>
<div>

### Punti Chiave

1. **Copertura 100%**: Ogni possibile combinazione di ingresso viene testata
2. **Self-Checking**: L'istruzione `assert` verifica automaticamente l'uscita rispetto all'atteso
3. **Report**: In caso di errore, la simulazione stampa i valori esatti che hanno fallito

</div>
</div>

---

# Unit Testing: Ripple Carry Adder
Verifica mirata (Directed testing)

Per l'addizionatore a N bit, testare tutte le combinazioni richiederebbe troppo tempo (casi).
Abbiamo optato per una **Lookup Table** contenente casi specifici (*Corner Cases*).

<div class="grid grid-cols-2 gap-4">
<div>

```vhdl {all|2-6|7-14|16-18}
constant TRUTH_TABLE : truth_table_type := (
    -- Caso Base: 5 + 5 = 10
    2 => std_logic_vector(x"05") &
         std_logic_vector(x"05") &
         '0' &
         ...

    -- Caso Overflow (Carry Out generation):
    -- 255 (FF) + 1 (01) = 0 (00) con Carry=1
    3 => std_logic_vector(x"FF") &
         std_logic_vector(x"01") &
         '0' & -- Cin
         '1' & -- Expected Cout
         std_logic_vector(x"00"), -- Expected Sum

    -- Caso Saturazione (Max Propagation):
    -- 255 (FF) + 255 (FF) + 1 = 255 (FF) con Carry=1
    4 => ...
);
```

</div>
<div>

### Scenari Testati
Il vettore di test copre le criticità del ripple carry:

1. **Zero + Zero**: Verifica reset/base
2. **Somma standard**: Verifica funzionalità aritmetica
3. **Overflow (8-bit)**: Verifica che il riporto esca correttamente dal MSB ($C_{out}=1$)
4. **Propagazione Completa**: Verifica il ritardo e la correttezza quando il riporto deve attraversare tutta la catena ($C_{in} \rightarrow C_{out}$)

</div>
</div>
