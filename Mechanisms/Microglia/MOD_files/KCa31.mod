TITLE KCa3.1 (IK) Calcium-Activated Potassium Channel for Microglia
: Intermediate conductance Ca-activated K+ channel
: Upregulated in activated microglia
: Critical for proliferation and migration
: Based on Khanna et al. 2001, Kaushal et al. 2007

NEURON {
    SUFFIX KCa31
    USEION k READ ek WRITE ik
    USEION ca READ cai
    RANGE gkbar, gk, ik
    RANGE oinf, otau
    RANGE EC50_ca
}

UNITS {
    (mA) = (milliamp)
    (mV) = (millivolt)
    (S)  = (siemens)
    (mM) = (milli/liter)
}

PARAMETER {
    gkbar = 0.0005 (S/cm2)    : Maximum conductance
    EC50_ca = 0.0003 (mM)     : Ca EC50 (~300 nM)
    nHill = 3.5               : Hill coefficient
    tau_min = 5 (ms)          : Minimum time constant
    tau_max = 50 (ms)         : Maximum time constant
}

ASSIGNED {
    v (mV)
    ek (mV)
    cai (mM)
    ik (mA/cm2)
    gk (S/cm2)
    oinf
    otau (ms)
}

STATE {
    o   : Open probability
}

BREAKPOINT {
    SOLVE states METHOD cnexp
    gk = gkbar * o
    ik = gk * (v - ek)
}

INITIAL {
    rates(cai)
    o = oinf
}

DERIVATIVE states {
    rates(cai)
    o' = (oinf - o) / otau
}

PROCEDURE rates(cai (mM)) {
    : Hill equation for Ca-dependent activation
    if (cai < 1e-9) {
        oinf = 0
    } else {
        oinf = cai^nHill / (cai^nHill + EC50_ca^nHill)
    }
    
    : Time constant - faster when more Ca
    otau = tau_min + (tau_max - tau_min) * (1 - oinf)
}
