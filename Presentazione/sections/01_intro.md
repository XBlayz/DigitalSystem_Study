---
lang: IT, EN

layout: section
title: Introduzione e Architettura
---

# 1. Introduzione e Architettura

---
layout: two-cols-header
level: 2
---

# Descrizione del Progetto

::left::
## Specifiche
Progettazione di un filtro per immagini.
- **Immagine**: almeno 32x32 pixel a 8 bit (unsigned)
- **Filtro**: 3x3 con coefficienti 4 bit (signed)
- **Anchor point**: centrale
- **Kernel**: _a scelta_

::right::
## Obiettivo
- **Implementazione** descrizione _VHDL_ del circuito
- Creazione di **testbench** per verificare il _corretto funzionamento_
- Analisi dei **report** _post implementation_

---
layout: image-right
image: ../img/Architettura%20generale.svg
backgroundSize: 90%
level: 2
---

# Architettura generale
Architettura parallela in pipeline

I dati relativi ai pixel dell'immagine sono caricati in pipeline, una volta che il primo pixel dell'immagine raggiunge la posizione centrale (`d11`), il circuito inizia a elaborare i pixel filtrati ad ogni ciclo di clock.

### Timing
- **Latenza**: $34$

    $\lfloor\frac{N_{row,kernel}}{2}\rfloor \cdot N_{col,img} + \lceil\frac{N_{col,kernel}}{2}\rceil = \lfloor\frac{3}{2}\rfloor \cdot 32 + \lceil\frac{3}{2}\rceil = 34$

- **Throughput**: $1$

---
level: 2
---

# Scelte implementative
Moltiplicatori di **Booth** e **Carry Save Adder** tree

### Componenti di calcolo aritmetico
Oltre alla _pipeline_, i due componenti principali sono i circuiti moltiplicatori e sommatori implementati rispettivamente:

- **Booth Multiplier**: moltiplicatore con _pre-computazione_ e selezione tramite codifica di **Booth**
- **Carry Save Adder tree**: albero di somma **Carry Save** con **Carry Select** finale

### Circuito di controllo
Per gestire la _pipeline_ e le due interfacce **AXI-Stream** di ingresso e uscita abbiamo implementato una **Finite State Machine** che:

1. Gestisce l'**avanzamento** della _pipeline_
2. Gestisce i **segnali** relativi alle interfacce **AXI-Stream** di ingresso e uscita

---
level: 2
---

# Suddivisione del Lavoro

| Membro del Team  | Responsabilità Principali                                                  |
| ---------------- | -------------------------------------------------------------------------- |
| **M. De Fusco**  | **Componenti base**, `Buffer Line` e relative _testbench_                  |
| **C. Ferrari**   | `Booth Multiplier`, relative _testbench_ e script di verifica **MATLAB**   |
| **L. Lo Bianco** | `Carry Save Adder tree`, relative _testbench_ e report                     |
| **S. Scarcelli** | `Finite State Machine`, relative _testbench_ e _testbench_ **complessiva** |

<br>
<br>

> Anche se i lavori sono stati svolti **singolarmente**, ognuno ha contribuito a _miglioramenti_ o _modifiche_ di ogni parte del progetto.
