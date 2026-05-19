# Wireless Power Transfer (WPT) at 6.78 MHz

A comprehensive MATLAB simulation suite for **inductive wireless power transfer** operating at the **ISM band (6.78 MHz)**, featuring frequency-domain analysis, spatial electromagnetic modeling, rectenna integration, and impedance matching visualization.

## Project Overview

This project models an **end-to-end WPT system** using series-series (SS) resonant compensation, with emphasis on:
- **Coupled inductor networks** with frequency-dependent behavior
- **Spatial misalignment effects** (lateral and angular) via Neumann's formula
- **AC-to-DC rectification** and smoothing through a Schottky diode bridge
- **Impedance trajectory visualization** on Smith charts
- **System optimization** across different coupling regimes

## Features

### 1. **WPT.m** — Core Frequency-Domain Analysis
- Series-series resonant compensation tuning
- Frequency sweep (5–8 MHz) with efficiency, gain, and phase calculations
- Mesh equation solver for coupled inductor networks
- Steady-state AC power transfer analysis

### 2. **rectenna.m** — AC-to-DC Conversion
- **High-frequency Schottky diode bridge** (6.78 MHz rectification)
- Full-wave rectification with diode forward-drop modeling (Vf = 0.45 V)
- Output LC smoothing filter (2.2 µF capacitor, 10 Ω load)
- Time-domain transient simulation (15 RF cycles)
- Efficiency calculations relative to equivalent AC resistance

### 3. **WPT_power_plot.m** — System Characteristics & Smith Chart
- Multi-coupling-regime analysis (critical, bifurcation, system match, over-coupled)
- Voltage gain, output power, and efficiency vs. frequency
- **Reflection coefficient (Γ) trajectory** on 50 Ω Smith chart
- Impedance matching visualization across four coupling points

### 4. **WPT_error_plot.m** — Spatial Misalignment Modeling
- **Lateral misalignment**: Horizontal offset (0–15 cm) sensitivity
- **Angular misalignment**: Coil tilt (0–90°) impact on coupling
- Neumann's formula integration for mutual inductance calculation
- Null-point detection for flux cancellation

### 5. **WPT_relations.m** — Distance & Turns Analysis
- **Distance vs. coupling**: 1/z³ decay in the near field
- **Turns scaling**: Effect of multi-turn coils on inductance and coupling coefficient
- Geometric optimization insights for coil design

## System Parameters

| Parameter | Value | Notes |
|-----------|-------|-------|
| **Operating Frequency** | 6.78 MHz | ISM band for AirFuel Resonant |
| **Primary Inductance (Lp)** | 10 µH | Series-S topology |
| **Secondary Inductance (Ls)** | 10 µH | Matched to primary |
| **Primary ESR (Rp)** | 0.5 Ω | Coil resistance |
| **Secondary ESR (Rs)** | 0.5 Ω | Coil resistance |
| **Coupling Coefficient (k)** | 0.075 (nominal) | Far-field operation |
| **Load Resistance (RL)** | 50 Ω | System impedance match |
| **Compensation Caps** | ~35 pF each | Resonance tuning at f₀ |
| **Diode Vf** | 0.45 V | Schottky (high-frequency) |

## Key Results & Physics

### Resonance Tuning
At 6.78 MHz, capacitors are tuned to **cancel** reactive components:
```
Cp = 1 / (ω₀² Lp)  ≈ 35 pF
Cs = 1 / (ω₀² Ls)  ≈ 35 pF
```
This achieves **matched resonance** and peak efficiency at the operating frequency.

### Coupling Regimes

| Coupling (k) | Regime | Characteristics |
|--------------|--------|-----------------|
| **0.011** | Critical | Bifurcation threshold for coil pair only |
| **0.075** | Bifurcation | Flat-top efficiency response; system matching begins |
| **0.117** | System Match | Perfect 50 Ω impedance alignment |
| **0.20** | Over-coupled | Split-peak response; magnetic field over-saturation |

### Rectifier Performance
The Schottky diode rectenna achieves **~70–80%** rectifier efficiency at nominal AC drive (22 V pk), with:
- Full-bridge topology for symmetric AC handling
- Output ripple: ~2 V pk-pk into 2.2 µF load
- Steady-state DC: ~18 V @ 10 Ω load → ~32 W output

## Running the Simulations

### Prerequisites
- MATLAB R2018a or later
- Signal Processing Toolbox (for `smithplot`)
- No external dependencies

### Execution
```matlab
% Run core frequency sweep
WPT.m

% Time-domain rectenna integration
rectenna.m

% Impedance matching & Smith chart
WPT_power_plot.m

% Spatial misalignment sensitivity
WPT_error_plot.m

% Distance & turns optimization
WPT_relations.m
```

Each script is self-contained; run independently or modify parameters inline.

## Project Context

This suite was developed as part of a **Biomimetics course project** at Shiv Nadar University (ECE), exploring **L-Systems and fractal antenna applications**. The WPT platform serves as a testbed for validating:
- Near-field coil optimization via spatial EM
- Multi-frequency (6.78 MHz ISM band) power delivery
- Rectifier integration for charging systems (battery emulation)
- Dynamic WPT feasibility for mobile applications (e.g., electric vehicles)

  
**References:**
- A. Karalis et al., "Wireless Power Transfer to Deep Implants," PNAS (2008)
- AirFuel Alliance ISM Band Specifications (6.78 MHz resonant)
- Series-Series Compensation Design in WPT Systems
