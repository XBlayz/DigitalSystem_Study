# FPGA Design of a 2D Image Filter (3x3)

This repository contains the source code, simulations, and documentation for a university project focused on the design and FPGA implementation of a digital circuit for 2D image filtering (with a 3x3 kernel). The system is described entirely in **VHDL** and analyzed using **Xilinx Vivado**, supported by **MATLAB** scripts for image pre-processing and post-processing.

## 🎯 Project Objective

The main goal is to create a hardware architecture capable of applying a spatial filter to an image. Specifically, the system implements a low-pass filter (blur) based on the following 3x3 kernel:

```math
\begin{bmatrix}
1 & 2 & 1 \\
2 & 4 & 2 \\
1 & 2 & 1
\end{bmatrix}
```

*Note: The normalization of pixel values after filtering (to avoid saturation) is handled externally via MATLAB scripts.*

## 🧩 Hardware Architecture & Components

The circuit is structured modularly. The main hardware blocks implemented and tested (each with its dedicated Testbench) include:

* **Full Adder & Ripple Carry Adder (RCA)**: Basic units for addition. (The RCA was chosen and analyzed based on the specifics of FPGA implementation).
* **Carry Save Adder (CSA) Tree**: Used to optimize and parallelize multiple additions.
* **Booth Multiplier**: Hardware multiplier implemented to calculate the products between image pixels and kernel coefficients.
* **Parallel MAC (Multiply-Accumulate)**: Unit for the parallel computation of the dot product between the 3x3 image window and the filter mask.
* **Line Buffer**: Temporary memory needed to store image rows and efficiently slide the 3x3 window (data pipeline).
* **State Machine (FSM)**: Finite State Machine designed to orchestrate the data flow and control signals of the entire system.

## 📁 Repository Structure

The repository is organized as follows:

* 📂 **`src/`**: VHDL source files containing the hardware component descriptions.
* 📂 **`sim/`**: Testbench (TB) files written in VHDL for the simulation and validation of individual modules and the complete system.
* 📂 **`vivado_proj/`**: Project files and configurations for Xilinx Vivado.
* 📂 **`script matlab/`**: Scripts for image processing (converting images to input data for the VHDL simulation and reconstructing the final normalized image).
* 📂 **`Relazione/`**: LaTeX sources and PDF of the project's technical report (including power analysis, reports, and post-implementation characterization).
* 📂 **`Presentazione/`**: Presentation slides of the work.
* 📄 **`FILTRO.xlsx` / `FILTRAGGIO_Luigi.xlsx**`: Spreadsheets for manual/schematic analysis and verification of data and the architecture.

## 🛠️ Tools Used

* **Hardware Description Language:** VHDL
* **Synthesis, Implementation, and Simulation:** Xilinx Vivado
* **Data Processing and Validation:** MATLAB
* **Documentation:** LaTeX

## 📊 Results and Documentation

The complete characterization of the architecture (area consumption, estimated power dissipation, timing, and maximum post-implementation clock frequency) is documented in the [Technical Report](./Relazione/main.pdf).
