TITLE ER Calcium Dynamics for Microglia
: Endoplasmic reticulum calcium store
: Includes IP3 receptor (IP3R) and SERCA pump

NEURON {
    SUFFIX CaER
    USEION ca READ cai
    RANGE caer, IP3, Jip3r, Jserca, Jleak
    RANGE IP3R_max, SERCA_max, leak_rate
}

UNITS {
    (mM) = (milli/liter)
}

PARAMETER {
    fer = 0.1
    IP3R_max = 0.5 (/ms)
    Kip3 = 0.0001 (mM)
    Kact = 0.0003 (mM)
    Kinh = 0.0002 (mM)
    SERCA_max = 0.001 (mM/ms)
    Kserca = 0.0002 (mM)
    leak_rate = 0.0001 (/ms)
    caer0 = 0.4 (mM)
}

ASSIGNED {
    cai (mM)
    IP3 (mM)
    Jip3r (mM/ms)
    Jserca (mM/ms)
    Jleak (mM/ms)
}

STATE {
    caer (mM)
    h
}

INITIAL {
    caer = caer0
    IP3 = 0.0001
    h = 1 / (1 + (cai/Kinh)^4)
}

BREAKPOINT {
    SOLVE states METHOD cnexp
}

DERIVATIVE states {
    LOCAL mip3, mact, oinf, hinf
    
    mip3 = IP3^3 / (IP3^3 + Kip3^3)
    mact = cai^3 / (cai^3 + Kact^3)
    oinf = mip3 * mact * h
    
    Jip3r = IP3R_max * oinf * (caer - cai)
    Jserca = SERCA_max * cai^2 / (cai^2 + Kserca^2)
    Jleak = leak_rate * (caer - cai)
    
    hinf = Kinh^4 / (cai^4 + Kinh^4)
    h' = (hinf - h) / 500
    
    caer' = -(Jip3r + Jleak - Jserca) / fer
}
