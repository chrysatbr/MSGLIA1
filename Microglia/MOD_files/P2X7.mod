TITLE P2X7 Purinergic Receptor for Microglia (Improved)
: ATP-gated cation channel P2X7
: Includes pore dilation phenomenon
: Critical for NLRP3 inflammasome activation and IL-1beta release
: Based on Bhattacharjee et al. 2023, Bhattacharjee & Bhattacharjee 2024

NEURON {
    SUFFIX P2X7
    USEION ca WRITE ica
    USEION na WRITE ina  
    USEION k WRITE ik
    RANGE gmax, g, i
    RANGE ATPo, EC50, nHill
    RANGE pore_dilated, dilation_factor
    RANGE tau_open, tau_close, tau_dilate
    POINTER atp
}

UNITS {
    (mA) = (milliamp)
    (mV) = (millivolt)
    (S)  = (siemens)
    (mM) = (milli/liter)
}

PARAMETER {
    gmax = 0.0001 (S/cm2)     : Maximum conductance (small pore)
    EC50 = 0.3 (mM)           : ATP EC50 (~300 uM)
    nHill = 2.5               : Hill coefficient
    
    : Permeability ratios (small pore state)
    pCa = 4                   : Relative Ca permeability
    pNa = 1                   : Relative Na permeability  
    pK = 1                    : Relative K permeability
    
    : Reversal potentials
    eca = 120 (mV)
    ena = 50 (mV)
    ek = -85 (mV)
    
    : Kinetics
    tau_open = 50 (ms)        : Opening time constant
    tau_close = 200 (ms)      : Closing time constant
    tau_dilate = 30000 (ms)   : Pore dilation time constant (~30 sec)
    
    : Pore dilation parameters
    dilation_threshold = 0.5  : Sustained activation needed for dilation
    dilation_max = 3          : Max conductance increase from dilation
}

ASSIGNED {
    v (mV)
    atp (mM)
    i (mA/cm2)
    ica (mA/cm2)
    ina (mA/cm2)
    ik (mA/cm2)
    g (S/cm2)
    ATPo (mM)
    popen
    pore_dilated
    dilation_factor
}

STATE {
    o           : Channel open state
    d           : Pore dilation state
}

BREAKPOINT {
    SOLVE states METHOD cnexp
    
    : Get ATP concentration
    if (atp > 0) {
        ATPo = atp
    } else {
        ATPo = 0
    }
    
    : Pore dilation increases conductance
    dilation_factor = 1 + (dilation_max - 1) * d
    pore_dilated = d
    
    g = gmax * o * dilation_factor
    
    : Distribute current among ions
    : In dilated state, permeability to large molecules increases
    : Here we simplify by just increasing total conductance
    ica = g * pCa / (pCa + pNa + pK) * (v - eca)
    ina = g * pNa / (pCa + pNa + pK) * (v - ena)
    ik = g * pK / (pCa + pNa + pK) * (v - ek)
    i = ica + ina + ik
}

INITIAL {
    o = 0
    d = 0
}

DERIVATIVE states {
    LOCAL target_o, target_d, tau_o
    
    : Hill equation for ATP activation
    if (ATPo > 1e-6) {
        target_o = ATPo^nHill / (ATPo^nHill + EC50^nHill)
    } else {
        target_o = 0
    }
    
    : Asymmetric kinetics for opening/closing
    if (target_o > o) {
        tau_o = tau_open
    } else {
        tau_o = tau_close
    }
    
    o' = (target_o - o) / tau_o
    
    : Pore dilation occurs with sustained high activation
    if (o > dilation_threshold) {
        target_d = 1
    } else {
        target_d = 0
    }
    
    : Dilation is slow and somewhat irreversible
    d' = (target_d - d) / tau_dilate
}
