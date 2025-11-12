COMMENT

The model of Piezo2 mechanosensitive ion channel.
Based on the following papers:

1. Membrane depth analysis and Markov modeling of Piezo channels
   https://github.com/jiehanchong/membrane-depth-analysis
   https://github.com/GrandlLab/piezo_markov_simulation/tree/master

2. Conductive selectivity filter mechanics underlie gating in a K+ channel
   PNAS 2023, https://www.pnas.org/doi/10.1073/pnas.2215747120

3. Force-from-lipids gating of Piezo channels
   PMC article, https://pmc.ncbi.nlm.nih.gov/articles/PMC8105715/

4. Voltage gating of mechanosensitive PIEZO channels
   Nature Communications 2018, https://www.nature.com/articles/s41467-018-07040-4

The kinetic scheme implements a multi-state Markov model for Piezo2
mechanosensitive channels with mechanical force dependence and physiological parameters.
Piezo2 exhibits faster kinetics and higher force sensitivity compared to Piezo1.

ENDCOMMENT


NEURON {
    SUFFIX  Piezo2
    USEION ca READ cao, cai WRITE ica
    USEION na READ nao, nai WRITE ina  
    USEION k READ ko, ki WRITE ik
    RANGE P1, P2, P3, P4, P5, P6, P7, P8
    GLOBAL k12, k21, k23, k32, k34, k43, k45, k54, k56, k65, k67, k76, k78, k87, k81, k18
    RANGE ipiezo, density, mforce, force_sensitivity, force_threshold, g_single, pca, pna, pk
    NONSPECIFIC_CURRENT ipiezo
}

UNITS {
    (mV) = (millivolt)
    (mA) = (milliamp)
    (mM) = (milli/liter)
    (pN) = (piconewton)
    (pS) = (picosiemens)
    F = (faraday) (coulombs)
    R = (k-mole) (joule/degC)
}

PARAMETER {	
    mforce = 0                  : Applied mechanical force (pN)
    force_sensitivity = 0.08    : Force sensitivity parameter (higher than Piezo1)
    force_threshold = 0.3       : Minimum force threshold (pN, lower than Piezo1)
    g_single = 30e-12           : Single channel conductance (30 pS, slightly higher)
    
    : Kinetic rate constants (per ms) - faster than Piezo1
    k12 = 0.8
    k21 = 0.08
    k23 = 0.6
    k32 = 0.06
    k34 = 0.5
    k43 = 0.05
    k45 = 0.4
    k54 = 0.04
    k56 = 0.5
    k65 = 0.05
    k67 = 0.3
    k76 = 0.03
    k78 = 6.0                  : Faster activation than Piezo1
    k87 = 0.6                  : Faster inactivation
    k81 = 0.002
    k18 = 0.001

    : Permeability ratios (slightly different from Piezo1)
    pca = 1.0
    pna = 0.12
    pk = 0.09
    
    : Channel density (channels per cm2)
    density = 1e8
}

ASSIGNED {
    v (mV)
    celsius (degC)
    cao (mM)
    cai (mM)
    nao (mM)
    nai (mM)
    ko (mM)
    ki (mM)
    
    ica (mA/cm2)
    ina (mA/cm2)
    ik (mA/cm2)
    ipiezo (mA/cm2)
    
    k12_eff
    k23_eff
    k34_eff
    k45_eff
    k56_eff
    k67_eff
    k78_eff
    temp_factor
    force_factor
    effective_force
}

STATE {
    P1
    P2
    P3
    P4
    P5
    P6
    P7
    P8
}

INITIAL {
    P1 = 0.90
    P2 = 0.05
    P3 = 0.025
    P4 = 0.01
    P5 = 0.005
    P6 = 0.005
    P7 = 0.003
    P8 = 0.002
}

BREAKPOINT {
    SOLVE kstates METHOD sparse
    
    temp_factor = exp((celsius - 22) * 0.1)
    
    : Apply force threshold - only forces above threshold are effective
    if (mforce > force_threshold) {
        effective_force = mforce - force_threshold
    } else {
        effective_force = 0
    }
    
    : Force-dependent rate constants with higher sensitivity for Piezo2
    k12_eff = k12 * temp_factor * exp(effective_force * force_sensitivity * 0.5)
    k23_eff = k23 * temp_factor * exp(effective_force * force_sensitivity * 0.6)
    k34_eff = k34 * temp_factor * exp(effective_force * force_sensitivity * 0.7)
    k45_eff = k45 * temp_factor * exp(effective_force * force_sensitivity * 0.8)
    k56_eff = k56 * temp_factor * exp(effective_force * force_sensitivity * 0.9)
    k67_eff = k67 * temp_factor * exp(effective_force * force_sensitivity * 1.0)
    k78_eff = k78 * temp_factor * exp(effective_force * force_sensitivity * 1.2)
    
    : Current calculations using single channel conductance
    ica = -density * P8 * pca * g_single * ghk(v, cai, cao, 2) * 1e3
    ina = -density * P8 * pna * g_single * ghk(v, nai, nao, 1) * 1e3
    ik = -density * P8 * pk * g_single * ghk(v, ki, ko, 1) * 1e3
    
    ipiezo = ica + ina + ik
}

KINETIC kstates {
    ~ P1 <-> P2     (k12_eff, k21 * temp_factor)
    ~ P2 <-> P3     (k23_eff, k32 * temp_factor)
    ~ P3 <-> P4     (k34_eff, k43 * temp_factor)
    ~ P4 <-> P5     (k45_eff, k54 * temp_factor)
    ~ P5 <-> P6     (k56_eff, k65 * temp_factor)
    ~ P6 <-> P7     (k67_eff, k76 * temp_factor)
    ~ P7 <-> P8     (k78_eff, k87 * temp_factor)
    ~ P8 <-> P1     (k81 * temp_factor, k18 * temp_factor)
    
    CONSERVE P1 + P2 + P3 + P4 + P5 + P6 + P7 + P8 = 1
}

FUNCTION ghk(v, ci, co, z) {
    LOCAL arg, fac
    fac = z * v / (R * (celsius + 273.15)) * F
    arg = fac * 1e-3
    if (fabs(arg) < 1e-4) {
        ghk = fac * (ci - co) * 1e-3
    } else {
        ghk = fac * arg * (ci - co * exp(arg)) / (1 - exp(arg)) * 1e-3
    }
}
