TITLE Kv1.3 Potassium Channel for Microglia (Improved)
: Voltage-gated potassium channel Kv1.3
: Key channel in activated microglia
: Kinetics based on Bhattacharjee et al. 2023, Bhattacharjee & Bhattacharjee (2022)
: and Bhattacharjee, Bhattacharjee & bhattacharjee 2023 patch clamp data

NEURON {
    SUFFIX Kv13
    USEION k READ ek WRITE ik
    RANGE gkbar, gk, ik
    RANGE ninf, ntau, hinf, htau
    RANGE use_inactivation
}

UNITS {
    (mA) = (milliamp)
    (mV) = (millivolt)
    (S)  = (siemens)
}

PARAMETER {
    gkbar = 0.001 (S/cm2)     : Maximum conductance
    
    : Activation parameters (from patch clamp data)
    vhalf_n = -37 (mV)        : Half-activation voltage
    k_n = 7 (mV)              : Slope factor
    
    : Inactivation parameters (C-type inactivation)
    vhalf_h = -50 (mV)        : Half-inactivation voltage  
    k_h = -10 (mV)            : Slope factor (negative for inactivation)
    
    : Time constants
    tau_n_min = 2 (ms)        : Min activation tau
    tau_n_max = 15 (ms)       : Max activation tau
    tau_h_min = 500 (ms)      : Min inactivation tau (slow C-type)
    tau_h_max = 2000 (ms)     : Max inactivation tau
    
    use_inactivation = 1      : 1 = include inactivation, 0 = no inactivation
}

ASSIGNED {
    v (mV)
    ek (mV)
    ik (mA/cm2)
    gk (S/cm2)
    ninf
    ntau (ms)
    hinf
    htau (ms)
}

STATE {
    n   : Activation gate
    h   : Inactivation gate (C-type, slow)
}

BREAKPOINT {
    SOLVE states METHOD cnexp
    if (use_inactivation == 1) {
        gk = gkbar * n^4 * h
    } else {
        gk = gkbar * n^4
    }
    ik = gk * (v - ek)
}

INITIAL {
    rates(v)
    n = ninf
    h = hinf
}

DERIVATIVE states {
    rates(v)
    n' = (ninf - n) / ntau
    h' = (hinf - h) / htau
}

PROCEDURE rates(v (mV)) {
    LOCAL alpha_n, beta_n
    
    : Activation (Hodgkin-Huxley style)
    ninf = 1 / (1 + exp(-(v - vhalf_n) / k_n))
    
    : Voltage-dependent tau for activation
    : Bell-shaped curve centered around -40 mV
    ntau = tau_n_min + (tau_n_max - tau_n_min) * exp(-((v + 40)^2) / 500)
    
    : C-type inactivation (slow)
    hinf = 1 / (1 + exp(-(v - vhalf_h) / k_h))
    
    : Tau for inactivation - slower at depolarized potentials
    htau = tau_h_min + (tau_h_max - tau_h_min) / (1 + exp((v + 30) / 20))
}
