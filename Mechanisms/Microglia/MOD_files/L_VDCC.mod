TITLE L-Type Voltage-Dependent Calcium Channel for Microglia
: Cav1.2/Cav1.3

NEURON {
    SUFFIX L_VDCC
    USEION ca READ cai WRITE ica
    RANGE gmax, g, ica
    RANGE minf, hinf
}

UNITS {
    (mA) = (milliamp)
    (mV) = (millivolt)
    (S)  = (siemens)
    (mM) = (milli/liter)
}

PARAMETER {
    gmax = 0.00002 (S/cm2)
    eca = 120 (mV)
    vhalf_m = -20 (mV)
    k_m = 7 (mV)
    vhalf_h = -45 (mV)
    k_h = -8 (mV)
    tau_m = 2 (ms)
    tau_h = 50 (ms)
    Kcdi = 0.001 (mM)
}

ASSIGNED {
    v (mV)
    cai (mM)
    ica (mA/cm2)
    g (S/cm2)
    minf
    hinf
    cdi
}

STATE {
    m
    h
}

INITIAL {
    minf = 1 / (1 + exp(-(v - vhalf_m) / k_m))
    hinf = 1 / (1 + exp(-(v - vhalf_h) / k_h))
    m = minf
    h = hinf
}

BREAKPOINT {
    SOLVE states METHOD cnexp
    cdi = Kcdi^2 / (cai^2 + Kcdi^2)
    g = gmax * m * m * h * cdi
    ica = g * (v - eca)
}

DERIVATIVE states {
    minf = 1 / (1 + exp(-(v - vhalf_m) / k_m))
    hinf = 1 / (1 + exp(-(v - vhalf_h) / k_h))
    m' = (minf - m) / tau_m
    h' = (hinf - h) / tau_h
}
