COMMENT

The model of Piezo2 mechanosensitive ion channel.
Based on the following papers:

1. Membrane depth analysis and Markov modeling of Piezo1 channels
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

ENDCOMMENT


NEURON {
    SUFFIX  Piezo2
    USEION ca READ cao, cai WRITE ica
    USEION na READ nao, nai WRITE ina  
    USEION k READ ko, ki WRITE ik
    RANGE P1, P2, P3, P4, P5, P6, P7, P8
    GLOBAL k12, k21, k23, k32, k34, k43, k45, k54, k56, k65, k67, k76, k78, k87, k81, k18
    RANGE ipiezo2_Piezo2, density_Piezo2, mforce_Piezo2, force_sensitivity_Piezo2, force_threshold_Piezo2, g_single_Piezo2, pca_Piezo2, pna_Piezo2, pk_Piezo2
    NONSPECIFIC_CURRENT ipiezo2_Piezo2
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
    mforce_Piezo2 = 0                  
    force_sensitivity_Piezo2 = 0.015   
    force_threshold_Piezo2 = 0.5       
    g_single_Piezo2 = 15e-12           
    
    
    k12 = 0.5
    k21 = 0.05
    k23 = 0.4
    k32 = 0.04
    k34 = 0.3
    k43 = 0.03
    k45 = 0.2
    k54 = 0.02
    k56 = 0.25
    k65 = 0.025
    k67 = 0.15
    k76 = 0.015
    k78 = 6.0                
    k87 = 0.6		       
    k81 = 0.002		       
    k18 = 0.0005

    
    pca_Piezo2 = 1.0
    pna_Piezo2 = 0.1
    pk_Piezo2 = 0.08
    
    
    density_Piezo2 = 5e3
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
    ipiezo2_Piezo2 (mA/cm2)
    
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
    
    temp_factor = exp((celsius - 22) * 0.03)
    
    : Apply force threshold - only forces above threshold are effective
    if (mforce_Piezo2 > force_threshold_Piezo2) {
        effective_force = mforce_Piezo2 - force_threshold_Piezo2
    } else {
        effective_force = 0
    }
    
    : Force-dependent rate constants with reduced sensitivity
    k12_eff = k12 * temp_factor * exp(effective_force * force_sensitivity_Piezo2 * 0.5)
    k23_eff = k23 * temp_factor * exp(effective_force * force_sensitivity_Piezo2 * 0.6)
    k34_eff = k34 * temp_factor * exp(effective_force * force_sensitivity_Piezo2 * 0.7)
    k45_eff = k45 * temp_factor * exp(effective_force * force_sensitivity_Piezo2 * 0.8)
    k56_eff = k56 * temp_factor * exp(effective_force * force_sensitivity_Piezo2 * 0.9)
    k67_eff = k67 * temp_factor * exp(effective_force * force_sensitivity_Piezo2 * 1.0)
    k78_eff = k78 * temp_factor * exp(effective_force * force_sensitivity_Piezo2 * 1.2)
    
    : Current calculations using single channel conductance
    ica = density_Piezo2 * P8 * pca_Piezo2 * g_single_Piezo2 * ghk(v, cai, cao, 2) * 1e3
    ina = density_Piezo2 * P8 * pna_Piezo2 * g_single_Piezo2 * ghk(v, nai, nao, 1) * 1e3
    ik = density_Piezo2 * P8 * pk_Piezo2 * g_single_Piezo2 * ghk(v, ki, ko, 1) * 1e3
    
    ipiezo2_Piezo2 = ica + ina + ik
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
    fac = z * F * v / (R * (celsius + 273.15))    
    arg = fac * 1e-3
    if (fabs(arg) < 1e-4) {
        ghk = fac * (ci - co) * 1e-3
    } else {
        ghk = fac * arg * (ci - co * exp(arg)) / (1 - exp(arg)) * 1e-3
    }
}