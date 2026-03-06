TITLE Store-Operated Calcium Entry (SOCE) for Microglia
: Orai1/CRAC channel activated by ER depletion via STIM1

NEURON {
    SUFFIX SOCE
    USEION ca READ cai WRITE ica
    RANGE gmax, g, ica
    RANGE caer_threshold
}

UNITS {
    (mA) = (milliamp)
    (mV) = (millivolt)
    (S)  = (siemens)
    (mM) = (milli/liter)
}

PARAMETER {
    gmax = 0.00005 (S/cm2)
    eca = 120 (mV)
    caer_threshold = 0.2 (mM)
    caer_slope = 0.05 (mM)
    tau_activate = 5000 (ms)
    tau_deactivate = 10000 (ms)
    Kicrac = 0.0005 (mM)
}

ASSIGNED {
    v (mV)
    cai (mM)
    ica (mA/cm2)
    g (S/cm2)
    caer (mM)
    cdi
    stim1
}

STATE {
    o
}

INITIAL {
    caer = 0.4
    o = 0
}

BREAKPOINT {
    SOLVE states METHOD cnexp
    cdi = Kicrac^2 / (cai^2 + Kicrac^2)
    g = gmax * o * cdi
    ica = g * (v - eca)
}

DERIVATIVE states {
    stim1 = 1 / (1 + exp((caer - caer_threshold) / caer_slope))
    if (stim1 > o) {
        o' = (stim1 - o) / tau_activate
    } else {
        o' = (stim1 - o) / tau_deactivate
    }
}
