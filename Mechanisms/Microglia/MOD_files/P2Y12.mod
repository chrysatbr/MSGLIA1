TITLE P2Y12 Purinergic Receptor for Microglia
: ADP-activated G-protein coupled receptor
: Essential for microglial chemotaxis and process extension toward injury
: Homeostatic microglia marker

NEURON {
    SUFFIX P2Y12
    RANGE ADPo, EC50, activation
    RANGE chemotaxis_signal
    POINTER adp  : External ADP concentration
}

UNITS {
    (mM) = (milli/liter)
}

PARAMETER {
    EC50 = 0.001 (mM)      : ADP EC50 (1 uM typical)
    nHill = 1.5            : Hill coefficient
    tau_act = 1000 (ms)    : Activation time constant
    tau_deact = 5000 (ms)  : Deactivation time constant
}

ASSIGNED {
    adp (mM)
    ADPo (mM)
    chemotaxis_signal      : Output signal for process extension
}

STATE {
    activation             : Receptor activation level (0-1)
}

BREAKPOINT {
    SOLVE states METHOD cnexp
    
    : ADP concentration
    if (adp > 0) {
        ADPo = adp
    } else {
        ADPo = 0
    }
    
    : Chemotaxis signal proportional to activation
    chemotaxis_signal = activation
}

INITIAL {
    activation = 0
}

DERIVATIVE states {
    LOCAL target, tau
    
    : Hill equation for ADP activation
    target = ADPo^nHill / (ADPo^nHill + EC50^nHill)
    
    : Asymmetric kinetics
    if (target > activation) {
        tau = tau_act
    } else {
        tau = tau_deact
    }
    
    activation' = (target - activation) / tau
}
