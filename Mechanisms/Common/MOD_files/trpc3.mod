TITLE TRPC3 - DAG-gated cation channel (microglia)
COMMENT
===========================================================================
DAG pathway: TNFa -> PLC -> DAG -> channel open. Constitutive baseline.

66 pS (Amaral 2020). PCa:PNa:PK = 1.5:1:1 (less Ca-selective than TRPC1).
Weak CDI -> semi-sustained current.
1 ms = 1 min real time.

Geometry scaling (same design as trpc1.mod and Piezo1.mod):
  effective_g_max = calculate_effective_g(g_max, diam, density_scale_mode, density_scale_factor)
  effective_plc_k = calculate_effective_g(plc_k, diam, density_scale_mode, density_scale_factor)

  density_scale_mode:
    0 = uniform  (no scaling)
    1 = linear   (g_eff = g_max * diam/ref_diam)  -- activated/amoeboid
    2 = inverse  (g_eff = g_max * ref_diam/diam)  -- reserved
  ref_diam = 1.0 um

FIX LOG:
  [Fix 1] Removed NONSPECIFIC_CURRENT itotal -- was double-counting all currents.
          itotal is now ASSIGNED/RANGE for monitoring only.
  [Fix 2] Added density_scale_mode / density_scale_factor / calculate_effective_g()
          identical in design to trpc1.mod.
  [Fix 3] effective_plc_k scales DAG dynamics with local segment diam.
===========================================================================
ENDCOMMENT

NEURON {
    SUFFIX TRPC3
    USEION ca READ cai, cao WRITE ica
    USEION na READ nai, nao WRITE ina
    USEION k  READ ki,  ko  WRITE ik
    RANGE g_max, pca, pna, pk
    RANGE tnfa, m, h, dag
    RANGE tau_m, tau_h, ca_half, dag_tau, plc_k, m0
    RANGE density_scale_mode, density_scale_factor
    RANGE effective_g_max, effective_plc_k
    RANGE itotal
    : itotal is monitoring ONLY -- NOT NONSPECIFIC_CURRENT (would double-count)
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
    g_max               = 0.002   (S/cm2)  : base conductance at diam=1.0 um
    pca                 = 0.43              : Ca fraction (1.5/3.5)
    pna                 = 0.29              : Na fraction
    pk                  = 0.28              : K fraction
    tau_m               = 0.5     (ms)      : gating tau (0.5 min -- fast)
    tau_h               = 2.0     (ms)      : CDI tau (slow -> weak CDI)
    ca_half             = 0.001   (mM)      : CDI half-max (1 uM -- high threshold)
    dag_tau             = 1.0     (ms)      : DAG dynamics tau
    plc_k               = 0.3               : base PLC-DAG coupling at diam=1.0 um
    m0                  = 0.03              : constitutive open prob (Trebak 2009)
    density_scale_mode  = 0                 : 0=uniform 1=linear 2=inverse
    density_scale_factor= 1.0               : extra multiplier
    tnfa                = 0                 : TNFa (pg/ml), set by HOC each step
}

ASSIGNED {
    v               (mV)
    celsius         (degC)
    diam            (um)              : local segment diam -- automatic in NEURON
    cai cao         (mM)
    nai nao         (mM)
    ki  ko          (mM)
    ica ina ik      (mA/cm2)
    itotal          (mA/cm2)          : monitoring only, NOT NONSPECIFIC_CURRENT
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

    : Geometry-scaled conductance and PLC coupling (per-segment, per-timestep)
    effective_g_max = calculate_effective_g(g_max, diam, density_scale_mode, density_scale_factor)
    effective_plc_k = calculate_effective_g(plc_k, diam, density_scale_mode, density_scale_factor)

    : Reversal potentials
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

    : DAG dynamics -- use effective_plc_k (scales with diam)
    dag' = (plc * effective_plc_k - dag * 0.3) / dag_tau

    : DAG directly gates channel + constitutive baseline
    m_inf = m0 + (1 - m0) * dag*dag / (dag*dag + 0.09)
    m'    = (m_inf - m) / tau_m

    : Weak CDI (high ca_half, slow tau)
    h_inf = 1 / (1 + pow(cai / ca_half, 2))
    h'    = (h_inf - h) / tau_h
}

: =============================================================================
: calculate_effective_g -- geometry scaling function
: Identical design to trpc1.mod and Piezo1.mod.
: ref_diam = 1.0 um
: =============================================================================
FUNCTION calculate_effective_g(base_g, diameter, scale_mode, scale_factor) {
    LOCAL ref_diam, result
    ref_diam = 1.0

    if (scale_mode == 1) {
        : Linear: thicker segments have more channels (amoeboid/activated)
        result = base_g * (diameter / ref_diam) * scale_factor
    } else if (scale_mode == 2) {
        : Inverse: thinner segments have higher density (reserved)
        if (diameter > 0.01) {
            result = base_g * (ref_diam / diameter) * scale_factor
        } else {
            result = base_g * scale_factor
        }
    } else {
        : Mode 0 or unknown: uniform
        result = base_g * scale_factor
    }

    if (result < 0)           { result = 0 }
    if (result > base_g * 10) { result = base_g * 10 }

    calculate_effective_g = result
}
