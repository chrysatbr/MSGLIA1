TITLE THIK-1 (K2P13.1) Two-Pore Potassium Channel for Microglia
: Tandem pore domain halothane-inhibited K+ channel
: Major K+ conductance in ramified microglia
: Sets resting membrane potential, involved in surveillance

NEURON {
    SUFFIX THIK1
    USEION k READ ek WRITE ik
    RANGE gkbar, gk, ik
    RANGE pHi, pHo  : pH sensitivity
}

UNITS {
    (mA) = (milliamp)
    (mV) = (millivolt)
    (S)  = (siemens)
}

PARAMETER {
    gkbar = 0.0005 (S/cm2) : Maximum conductance
    pHi = 7.2              : Intracellular pH
    pHo = 7.4              : Extracellular pH
    pH_half = 6.8          : Half-inhibition pH
    : Voltage-dependent parameters (weak)
    vhalf = 0 (mV)
    k = 50 (mV)            : Shallow voltage dependence
}

ASSIGNED {
    v (mV)
    ek (mV)
    ik (mA/cm2)
    gk (S/cm2)
    pH_factor              : pH modulation factor
}

STATE {
    o   : Open probability
}

BREAKPOINT {
    SOLVE states METHOD cnexp
    
    : pH modulation (acidic pH inhibits)
    pH_factor = 1 / (1 + exp(-(pHo - pH_half) / 0.3))
    
    gk = gkbar * o * pH_factor
    ik = gk * (v - ek)
}

INITIAL {
    rates(v)
    o = 1 / (1 + exp(-(v - vhalf) / k))
}

DERIVATIVE states {
    rates(v)
    o' = (1 / (1 + exp(-(v - vhalf) / k)) - o) / 10
}

PROCEDURE rates(v (mV)) {
    : Minimal voltage dependence typical of K2P channels
}
