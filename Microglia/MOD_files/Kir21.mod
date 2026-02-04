TITLE Kir2.1 Inward Rectifier Potassium Channel for Microglia
: Strong inward rectifier K+ channel
: Present in microglia, contributes to resting potential
: Different from astrocyte Kir4.1

NEURON {
    SUFFIX Kir21
    USEION k READ ek, ko WRITE ik
    RANGE gkbar, gk, ik
    RANGE rectification
}

UNITS {
    (mA) = (milliamp)
    (mV) = (millivolt)
    (S)  = (siemens)
    (mM) = (milli/liter)
}

PARAMETER {
    gkbar = 0.0002 (S/cm2) : Maximum conductance
    vhalf = -80 (mV)       : Half-rectification voltage
    k = 10 (mV)            : Slope factor
}

ASSIGNED {
    v (mV)
    ek (mV)
    ko (mM)
    ik (mA/cm2)
    gk (S/cm2)
    rectification
}

BREAKPOINT {
    : Strong inward rectification
    : Conductance increases with hyperpolarization and external K+
    rectification = 1 / (1 + exp((v - ek - vhalf) / k))
    
    : Ko dependence (square root relationship)
    gk = gkbar * rectification * sqrt(ko / 5.4)
    
    ik = gk * (v - ek)
}
