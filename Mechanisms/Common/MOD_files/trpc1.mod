TITLE TRPC1 - Store-operated cation channel for microglia
COMMENT
===========================================================================
SOCE model with proper calcium handling and geometry-dependent scaling.

  TNFa -> PLC -> IP3 -> ER depletion -> STIM1 -> channel open -> Ca influx

Two Ca pools:
  ca_local  : fast microdomain near pore -> drives CDI (fast feedback)
  cai_eff   : slow buffered bulk Ca -> drives Nernst/Eca (slow gradient change)

Geometry scaling (same design as Piezo1.mod):
  effective_g_max = calculate_effective_g(g_max, diam, density_scale_mode, density_scale_factor)

  density_scale_mode:
    0 = uniform  (no scaling, rested default)
    1 = linear   (g_eff = g_max * diam/ref_diam, activated/amoeboid)
    2 = inverse  (g_eff = g_max * ref_diam/diam, reserved)
    3 = S/V      (same as 2, reserved)
  density_scale_factor = extra multiplier (default 1.0)
  ref_diam = 1.0 um

16 pS single channel (Owsianik 2006). PCa:PNa:PK=1.8:1:0.9 (Luo 2020).
1 ms simulation = 1 minute real time.

FIX LOG:
  [Fix 1] Removed NONSPECIFIC_CURRENT itotal (double-counting bug).
  [Fix 2] Moved stim1 from DERIVATIVE to BREAKPOINT (ASSIGNED variable
          must be computed after SOLVE, not at solver substeps).
  [Fix 3] Added density_scale_mode / density_scale_factor /
          calculate_effective_g() -- identical design to Piezo1.mod.
  [Fix 4] Defaults match rested-state JSON.
===========================================================================
ENDCOMMENT

NEURON {
    SUFFIX TRPC1
    USEION ca READ cai, cao WRITE ica
    USEION na READ nai, nao WRITE ina
    USEION k  READ ki,  ko  WRITE ik
    RANGE g_max, pca, pna, pk
    RANGE tnfa, m, h, er, stim1, ca_local, cai_eff
    RANGE tau_m, tau_h, ca_half
    RANGE er_tau, er_refill, plc_k, stim1_th
    RANGE ca_local_tau, ca_local_gain, cai_eff_tau
    RANGE density_scale_mode, density_scale_factor, effective_g_max, effective_plc_k
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
    g_max               = 0.0002 (S/cm2) : nominal conductance; HOC overrides
    pca                 = 0.49            : Ca fraction (1.8/3.7)
    pna                 = 0.27            : Na fraction
    pk                  = 0.24            : K  fraction
    tau_m               = 3.0   (ms)      : SOCE gating tau
    tau_h               = 1.0   (ms)      : CDI tau
    ca_half             = 0.0005 (mM)     : CDI half-max local Ca
    ca_local_tau        = 0.5   (ms)      : microdomain decay tau
    ca_local_gain       = 0.005           : ica -> ca_local gain
    cai_eff_tau         = 500.0 (ms)      : bulk Ca buffering tau
    er_tau              = 2.0   (ms)      : ER dynamics tau
    er_refill           = 0.06            : SERCA refill rate
    plc_k               = 0.15            : PLC-ER coupling; HOC overrides
    stim1_th            = 0.26             : ER threshold for STIM1
    density_scale_mode  = 0               : 0=uniform 1=linear 2=inverse 3=S/V
    density_scale_factor= 1.0             : extra multiplier
    tnfa                = 0               : TNFa (pg/ml), set by HOC each step
}

ASSIGNED {
    v               (mV)
    celsius         (degC)
    diam            (um)         : local segment diam -- automatic in NEURON
    cai cao         (mM)
    nai nao         (mM)
    ki  ko          (mM)
    ica ina ik      (mA/cm2)
    itotal          (mA/cm2)     : monitoring only, NOT NONSPECIFIC_CURRENT
    stim1                        : algebraic, set in BREAKPOINT after SOLVE
    effective_g_max (S/cm2)      : g_max after geometry scaling
    effective_plc_k              : plc_k after geometry scaling
}

STATE {
    er              : ER Ca content (0=empty 1=full)
    m               : open probability
    h               : CDI gate (1=open)
    ca_local        : fast Ca microdomain (mM)
    cai_eff         : slow buffered bulk Ca (mM)
}

INITIAL {
    er          = 1.0
    m           = 0.0
    h           = 1.0
    ca_local    = cai
    cai_eff     = cai
    stim1       = 0.0
    itotal      = 0.0
    effective_g_max = calculate_effective_g(g_max,  diam, density_scale_mode, density_scale_factor)
    effective_plc_k = calculate_effective_g(plc_k, diam, density_scale_mode, density_scale_factor)
}

BREAKPOINT {
    LOCAL eca, ena, ek, g_open

    SOLVE states METHOD cnexp

    : stim1 -- ASSIGNED, computed here after SOLVE so er is current
    if (er < stim1_th) {
        stim1 = 1 - er / stim1_th
    } else {
        stim1 = 0
    }

    : Geometry-scaled conductance and PLC coupling (per-segment, per-timestep)
    effective_g_max = calculate_effective_g(g_max,  diam, density_scale_mode, density_scale_factor)
    effective_plc_k = calculate_effective_g(plc_k, diam, density_scale_mode, density_scale_factor)

    : Nernst reversal potentials
    if (cai_eff > 1e-8) {
        eca = 1000 * R * (celsius + 273.15) / (2 * F) * log(cao / cai_eff)
    } else {
        eca = 130
    }
    ena = 1000 * R * (celsius + 273.15) / (1 * F) * log(nao / nai)
    ek  = 1000 * R * (celsius + 273.15) / (1 * F) * log(ko  / ki)

    : Currents
    g_open = effective_g_max * m * h
    ica    = g_open * pca * (v - eca)
    ina    = g_open * pna * (v - ena)
    ik     = g_open * pk  * (v - ek)
    itotal = ica + ina + ik
}

DERIVATIVE states {
    LOCAL plc, h_inf

    plc  = tnfa / (tnfa + 2)

    er'  = (-plc * effective_plc_k * er + (1 - er) * er_refill) / er_tau

    : stim1 computed in BREAKPOINT -- m' uses previous-step value (lag negligible)
    m'   = (stim1 - m) / tau_m

    ca_local' = (-ica * ca_local_gain - (ca_local - cai)) / ca_local_tau

    cai_eff'  = (cai - cai_eff) / cai_eff_tau

    h_inf = 1 / (1 + pow(ca_local / ca_half, 2))
    h'    = (h_inf - h) / tau_h
}

: =============================================================================
: calculate_effective_g -- geometry scaling function
: Identical design to calculate_effective_density() in Piezo1.mod.
: ref_diam = 1.0 um
: =============================================================================
FUNCTION calculate_effective_g(base_g, diameter, scale_mode, scale_factor) {
    LOCAL ref_diam, result
    ref_diam = 1.0

    if (scale_mode == 1) {
        : Linear: thicker segments have more channels (amoeboid/activated)
        result = base_g * (diameter / ref_diam) * scale_factor
    } else if (scale_mode == 2) {
        : Inverse: thinner segments have higher density (ramified, reserved)
        if (diameter > 0.01) {
            result = base_g * (ref_diam / diameter) * scale_factor
        } else {
            result = base_g * scale_factor
        }
    } else if (scale_mode == 3) {
        : Surface-to-volume (cylinder approximation, reserved)
        if (diameter > 0.01) {
            result = base_g * (ref_diam / diameter) * scale_factor
        } else {
            result = base_g * scale_factor
        }
    } else {
        : Mode 0 or any unknown: uniform
        result = base_g * scale_factor
    }

    if (result < 0)            { result = 0 }
    if (result > base_g * 10)  { result = base_g * 10 }

    calculate_effective_g = result
}
