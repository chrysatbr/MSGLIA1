TITLE Microglia Activation State Mechanism
: Tracks microglial activation state and modulates channel expression
: Integrates inflammatory signals (ATP, cytokines) to determine phenotype

NEURON {
    SUFFIX MG_activation
    RANGE activation_state  : 0=ramified, 1=activated, 2=amoeboid
    RANGE M1_marker, M2_marker  : Polarization markers
    RANGE inflammatory_input
    RANGE Kv13_expression, P2X7_expression, THIK1_expression
    GLOBAL tau_activation
}

UNITS {
    (mM) = (milli/liter)
}

PARAMETER {
    tau_activation = 60000 (ms)  : Activation time constant (minutes)
    tau_resolution = 300000 (ms) : Resolution time constant (hours)
    : Baseline expression levels (ramified state)
    Kv13_base = 0.1
    P2X7_base = 0.1
    THIK1_base = 1.0
}

ASSIGNED {
    inflammatory_input     : Sum of inflammatory signals
    Kv13_expression       : Kv1.3 expression level (0-1)
    P2X7_expression       : P2X7 expression level (0-1)
    THIK1_expression      : THIK-1 expression level (0-1)
}

STATE {
    activation_state      : Continuous activation (0-2)
    M1_marker            : Pro-inflammatory marker
    M2_marker            : Anti-inflammatory marker
}

BREAKPOINT {
    SOLVE states METHOD cnexp
    
    : Channel expression depends on activation state
    : Kv1.3 and P2X7 upregulated in activated state
    Kv13_expression = Kv13_base + (1 - Kv13_base) * activation_state / 2
    P2X7_expression = P2X7_base + (1 - P2X7_base) * activation_state / 2
    
    : THIK-1 downregulated in activated state
    THIK1_expression = THIK1_base * (1 - 0.8 * activation_state / 2)
}

INITIAL {
    activation_state = 0
    M1_marker = 0
    M2_marker = 0
}

DERIVATIVE states {
    LOCAL target, tau
    
    : Target activation based on inflammatory input
    if (inflammatory_input > 0.5) {
        target = 2  : Amoeboid
    } else if (inflammatory_input > 0.1) {
        target = 1  : Activated
    } else {
        target = 0  : Ramified
    }
    
    : Asymmetric kinetics (fast activation, slow resolution)
    if (target > activation_state) {
        tau = tau_activation
    } else {
        tau = tau_resolution
    }
    
    activation_state' = (target - activation_state) / tau
    
    : M1/M2 polarization (simplified)
    M1_marker' = (activation_state - M1_marker) / tau_activation
    M2_marker' = (0.5 * activation_state - M2_marker) / tau_resolution
}
