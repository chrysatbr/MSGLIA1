TITLE TRPC6 - DAG-gated cation channel (microglia)
COMMENT
===========================================================================
DAG pathway: TNFa -> PLC -> DAG -> channel open.
Low constitutive baseline, higher Ca selectivity than TRPC3.

35 pS (Hofmann 1999). PCa:PNa:PK = 5:1:1 (Hsu 2015).
Stronger CDI than TRPC3, slower activation kinetics.
1 ms = 1 min real time.

Geometry scaling (same design as trpc1.mod, trpc3.mod, Piezo1.mod):
  effective_g_max = calculate_effective_g(g_max, diam, density_scale_mode, density_scale_factor)
  effective_plc_k = calculate_effective_g(plc_k, diam, density_scale_mode, density_scale_factor)
  ref_diam = 1.0 um

FIX LOG:
  [Fix 1] itotal is RANGE only -- NOT NONSPECIFIC_CURRENT (no double-counting).
  [Fix 2] effective_g_max and effective_plc_k scale with local diam per segment.
===========================================================================
ENDCOMMENT

NEURON {
    SUFFIX TRPC6
    USEION ca READ cai, cao WRITE ica
    USEION na READ nai, nao WRITE ina
    USEION k  READ ki,  ko  WRITE ik
    RANGE g_max, pca, pna, pk
    RANGE tnfa, m, h, dag
    RANGE tau_m, tau_h, ca_half, dag_tau, plc_k, m0
    RANGE density_scale_mode, density_scale_factor
    RANGE effective_g_max, effective_plc_k
    RANGE itotal
}

UNITS {
    (mV) = (millivolt)
    (mA) = (milliamp)
    (mM) = (milli/liter)
    (S)  = (siemens)
    (um) = (micron)
    R    = (k-mole) (joule/degC)
    F    = (faraday) (coulombs)
}

PARAMETER {
    g_max               = 0.001   (S/cm2)  : base at diam=1.0 um (35pS vs 66pS TRPC3 -> ~half)
    pca                 = 0.71              : Ca fraction (5/7)
    pna                 = 0.14              : Na fraction (1/7)
    pk                  = 0.14              : K  fraction (1/7)
    tau_m               = 2.0     (ms)      : slower than TRPC3 (2 min real)
    tau_h               = 1.0     (ms)      : CDI tau -- stronger than TRPC3
    ca_half             = 0.0005  (mM)      : CDI half-max (500 nM -- lower, stronger CDI)
    dag_tau             = 1.5     (ms)      : DAG dynamics (slightly slower than TRPC3)
    plc_k               = 0.3               : base PLC-DAG coupling at diam=1.0 um
    m0                  = 0.01              : low constitutive open prob (less than TRPC3)
    density_scale_mode  = 0                 : 0=uniform 1=linear 2=inverse
    density_scale_factor= 1.0
    tnfa                = 0                 : set by HOC each step
}

ASSIGNED {
    v               (mV)
    celsius         (degC)
    diam            (um)
    cai cao         (mM)
    nai nao         (mM)
    ki  ko          (mM)
    ica ina ik      (mA/cm2)
    itotal          (mA/cm2)
    effective_g_max (S/cm2)
    effective_plc_k
}

STATE { dag m h }

INITIAL {
    dag = 0
    m   = m0
    h   = 1
    effective_g_max = calculate_effective_g(g_max, diam, density_scale_mode, density_scale_factor)
    effective_plc_k = calculate_effective_g(plc_k, diam, density_scale_mode, density_scale_factor)
}

BREAKPOINT {
    LOCAL eca, ena, ek, g_open

    SOLVE states METHOD cnexp

    effective_g_max = calculate_effective_g(g_max, diam, density_scale_mode, density_scale_factor)
    effective_plc_k = calculate_effective_g(plc_k, diam, density_scale_mode, density_scale_factor)

    if (cai > 1e-8) {
        eca = 1000 * R * (celsius + 273.15) / (2 * F) * log(cao / cai)
    } else {
        eca = 120
    }
    ena = 1000 * R * (celsius + 273.15) / (1 * F) * log(nao / nai)
    ek  = 1000 * R * (celsius + 273.15) / (1 * F) * log(ko  / ki)

    g_open = effective_g_max * m * h
    ica    = g_open * pca * (v - eca)
    ina    = g_open * pna * (v - ena)
    ik     = g_open * pk  * (v - ek)
    itotal = ica + ina + ik
}

DERIVATIVE states {
    LOCAL plc, m_inf, h_inf

    plc  = tnfa / (tnfa + 2)

    dag' = (plc * effective_plc_k - dag * 0.3) / dag_tau

    : Hill gating by DAG -- steeper than TRPC3 (exponent 3 vs 2)
    m_inf = m0 + (1 - m0) * dag*dag*dag / (dag*dag*dag + 0.027)
    m'    = (m_inf - m) / tau_m

    : Stronger CDI (lower ca_half, faster tau)
    h_inf = 1 / (1 + pow(cai / ca_half, 2))
    h'    = (h_inf - h) / tau_h
}

FUNCTION calculate_effective_g(base_g, diameter, scale_mode, scale_factor) {
    LOCAL ref_diam, result
    ref_diam = 1.0

    if (scale_mode == 1) {
        result = base_g * (diameter / ref_diam) * scale_factor
    } else if (scale_mode == 2) {
        if (diameter > 0.01) {
            result = base_g * (ref_diam / diameter) * scale_factor
        } else {
            result = base_g * scale_factor
        }
    } else if (scale_mode == 3) {
        if (diameter > 0.01) {
            result = base_g * (ref_diam / diameter) * scale_factor
        } else {
            result = base_g * scale_factor
        }
    } else {
        result = base_g * scale_factor
    }

    if (result < 0)           { result = 0 }
    if (result > base_g * 10) { result = base_g * 10 }

    calculate_effective_g = result
}
