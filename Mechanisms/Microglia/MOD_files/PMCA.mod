TITLE Plasma Membrane Ca2+ ATPase (PMCA) for Microglia
: ATP-dependent calcium extrusion pump

NEURON {
    SUFFIX PMCA
    USEION ca READ cai WRITE ica
    RANGE ipump_max, ica
}

UNITS {
    (mA) = (milliamp)
    (mV) = (millivolt)
    (mM) = (milli/liter)
}

PARAMETER {
    ipump_max = 0.0001 (mA/cm2)
    Km = 0.0002 (mM)
}

ASSIGNED {
    v (mV)
    cai (mM)
    ica (mA/cm2)
    pump_rate
}

BREAKPOINT {
    pump_rate = cai^2 / (cai^2 + Km^2)
    ica = -ipump_max * pump_rate
}
