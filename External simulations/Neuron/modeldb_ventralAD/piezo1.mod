COMMENT

The model of Piezo1 mechanosensitive ion channel.
Based on the following papers:

1. Membrane depth analysis and Markov modeling of Piezo1 channels
   https://github.com/jiehanchong/membrane-depth-analysis
   https://github.com/GrandlLab/piezo_markov_simulation/tree/master

2. Conductive selectivity filter mechanics underlie gating in a K+ channel
   PNAS 2023, https://www.pnas.org/doi/10.1073/pnas.2215747120

3. Force-from-lipids gating of Piezo channels
   PMC article, https://pmc.ncbi.nlm.nih.gov/articles/PMC8105715/

The kinetic scheme implements a multi-state Markov model for Piezo1
mechanosensitive channels with mechanical force dependence.

ENDCOMMENT

NEURON {
    SUFFIX  Piezo1
    USEION ca READ cao, cai WRITE ica
    USEION na READ nao, nai WRITE ina  
    USEION k READ ko, ki WRITE ik
    RANGE P1, P2, P3, P4, P5, P6, P7, P8
    GLOBAL k12, k21, k23, k32, k34, k43, k45, k54, k56, k65, k67, k76, k78, k87, k81, k18
    RANGE ipiezo, density, mforce, force_sensitivity, pca, pna, pk
    NONSPECIFIC_CURRENT ipiezo
}

UNITS {
    (l) = (liter)
    (nA) = (nanoamp)
    (mV) = (millivolt)
    (mA) = (milliamp)
    (pS) = (picosiemens)
    (umho) = (micromho)
    (mM) = (milli/liter)
    (uM) = (micro/liter)
    (pN) = (piconewton)
    F = (faraday) (coulombs)
    PI = (pi) (1)
    R = (k-mole) (joule/degC)
}

PARAMETER {	
    : Mechanical force parameters
    mforce = 0             (pN)        : Applied mechanical force
    force_sensitivity = 1  (1/pN)      : Force sensitivity parameter
    
    : Transition rates (base rates without force)
    k12 = 0.1              (/ms)       : Closed to intermediate
    k21 = 0.05             (/ms)       : Intermediate to closed
    k23 = 0.08             (/ms)       : Intermediate 1 to 2
    k32 = 0.04             (/ms)       : Intermediate 2 to 1
    k34 = 0.06             (/ms)       : Intermediate 2 to 3
    k43 = 0.03             (/ms)       : Intermediate 3 to 2
    k45 = 0.04             (/ms)       : Intermediate 3 to 4
    k54 = 0.02             (/ms)       : Intermediate 4 to 3
    k56 = 0.05             (/ms)       : Intermediate 4 to 5
    k65 = 0.025            (/ms)       : Intermediate 5 to 4
    k67 = 0.03             (/ms)       : Intermediate 5 to pre-open
    k76 = 0.015            (/ms)       : Pre-open to intermediate 5
    k78 = 0.8              (/ms)       : Pre-open to open
    k87 = 0.4              (/ms)       : Open to pre-open
    k81 = 0.001            (/ms)       : Open to closed (slow inactivation)
    k18 = 0.0005           (/ms)       : Closed to open (rare direct)

    : Permeability parameters
    pca = 1.0              (cm/s)      : Ca2+ permeability
    pna = 0.1              (cm/s)      : Na+ permeability  
    pk = 0.08              (cm/s)      : K+ permeability

    density = 1e10         (/cm2)      : Channel density
}

ASSIGNED {
    v       (mV)           : membrane voltage
    celsius (degC)         : temperature
    cao     (mM)           : external Ca2+
    cai     (mM)           : internal Ca2+
    nao     (mM)           : external Na+
    nai     (mM)           : internal Na+
    ko      (mM)           : external K+
    ki      (mM)           : internal K+
    
    ica     (mA/cm2)       : Ca2+ current
    ina     (mA/cm2)       : Na+ current
    ik      (mA/cm2)       : K+ current
    ipiezo  (mA/cm2)       : Total Piezo1 current
    
    : Force-modified rates
    k12_eff (/ms)
    k23_eff (/ms)
    k34_eff (/ms)
    k45_eff (/ms)
    k56_eff (/ms)
    k67_eff (/ms)
    k78_eff (/ms)
    
    temp_factor
}

STATE {
    : Piezo1 channel states (all fractions)
    P1      (/cm2)         : Closed state
    P2      (/cm2)         : Intermediate state 1
    P3      (/cm2)         : Intermediate state 2  
    P4      (/cm2)         : Intermediate state 3
    P5      (/cm2)         : Intermediate state 4
    P6      (/cm2)         : Intermediate state 5
    P7      (/cm2)         : Pre-open state
    P8      (/cm2)         : Open state
}

INITIAL {
    P1 = 0.95
    P2 = 0.03
    P3 = 0.015
    P4 = 0.003
    P5 = 0.001
    P6 = 0.0008
    P7 = 0.0002
    P8 = 0.0000
}

BREAKPOINT {
    SOLVE kstates METHOD sparse
    
    : Calculate temperature factor
    temp_factor = exp((celsius - 22) * 0.1)
    
    : Calculate force-modified forward rates
    k12_eff = k12 * temp_factor * exp(mforce * force_sensitivity * 0.1)
    k23_eff = k23 * temp_factor * exp(mforce * force_sensitivity * 0.15)
    k34_eff = k34 * temp_factor * exp(mforce * force_sensitivity * 0.2)
    k45_eff = k45 * temp_factor * exp(mforce * force_sensitivity * 0.25)
    k56_eff = k56 * temp_factor * exp(mforce * force_sensitivity * 0.3)
    k67_eff = k67 * temp_factor * exp(mforce * force_sensitivity * 0.35)
    k78_eff = k78 * temp_factor * exp(mforce * force_sensitivity * 0.4)
    
    : Calculate ionic currents through open channels
    ica = -density * P8 * pca * ghk(v, cai, cao, 2)
    ina = -density * P8 * pna * ghk(v, nai, nao, 1)
    ik = -density * P8 * pk * ghk(v, ki, ko, 1)
    
    : Total Piezo1 current
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

FUNCTION ghk(v(mV), ci(mM), co(mM), z) {
    LOCAL arg
    arg = z * v * 0.037
    if (fabs(arg) < 1e-4) {
        ghk = z * 0.037 * (ci - co)
    } else {
        ghk = z * 0.037 * arg * (ci - co * exp(arg)) / (1 - exp(arg))
    }
}