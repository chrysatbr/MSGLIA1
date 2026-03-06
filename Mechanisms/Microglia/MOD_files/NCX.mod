TITLE Na+/Ca2+ Exchanger (NCX) for Microglia
: Electrogenic exchanger: 3 Na+ : 1 Ca2+

NEURON {
    SUFFIX NCX
    USEION ca READ cai WRITE ica
    USEION na READ nai
    RANGE incx_max, ica
}

UNITS {
    (mA) = (milliamp)
    (mV) = (millivolt)
    (mM) = (milli/liter)
}

PARAMETER {
    incx_max = 0.0002 (mA/cm2)
    Kmca = 0.00125 (mM)
    Kmna = 12 (mM)
    nao = 140 (mM)
    cao = 2 (mM)
    gamma = 0.35
}

ASSIGNED {
    v (mV)
    cai (mM)
    nai (mM)
    ica (mA/cm2)
    fv
    num
    denom
}

BREAKPOINT {
    fv = exp(gamma * v / 25)
    num = nai^3 * cao * fv - nao^3 * cai * exp((gamma - 1) * v / 25)
    denom = (Kmca + cai) * (Kmna^3 + nao^3)
    ica = incx_max * num / denom
}
