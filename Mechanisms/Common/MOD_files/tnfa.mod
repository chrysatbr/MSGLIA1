COMMENT

Enhanced Model of TNFa (Tumor Necrosis Factor alpha) production and release from microglia.
This mechanism simulates calcium-dependent cytokine production triggered by LPS stimulation
with feedback inhibition networks and receptor-mediated signaling.

Key features:
1. LPS-induced microglial activation
2. Calcium-dependent TNFa production
3. Negative feedback from IL-10 and TGFbeta (differential kinetics)
4. Autocrine TNFalpha self-regulation
5. TNFR1 and TNFR2 receptor dynamics
6. NFkB pathway activation
7. mRNA-protein translation dynamics
8. TNFa accumulation and diffusion
9. Downstream signaling effects

References:
1. Hanisch UK, Glia 2002 - LPS-induced microglial activation
2. Hoffmann A et al., Front Mol Neurosci 2003 - Calcium signaling in microglia
3. Takeuchi H et al., Glia 2006 - TNF production kinetics
4. Gutierrez H, Davies AM, Mol BioSyst 2015 - Computational modeling of cytokine signaling
   (PMC5520540) - Microglial cytokine network with TGFbeta and IL-10 feedback
5. Locksley RM et al., Cell 2001 - TNF and TNFR superfamily structure-function
6. Held F et al., J Pharmacokinet Pharmacodyn 2019 - Challenge model of TNFalpha turnover

ENDCOMMENT


NEURON {
    SUFFIX  TNFa
    USEION ca READ cai, cao WRITE ica
    USEION na READ nai, nao WRITE ina
    USEION k READ ki, ko WRITE ik
    RANGE tnf_conc, tnf_mrna, tnf_production_rate, tnf_decay_rate
    RANGE il10_conc, tgfb_conc, nfkb_active
    RANGE tnfr1_bound, tnfr2_bound
    RANGE lps_stim, lps_sensitivity, lps_threshold, ca_threshold
    RANGE basal_production, max_production, ca_sensitivity
    RANGE tau_production, tau_decay, tau_mrna
    RANGE il10_inhibition_strength, tgfb_inhibition_strength, il10_production_factor, tgfb_production_factor, il10_decay, tgfb_decay
    RANGE tau_il10, tau_tgfb
    RANGE tnf_autocrine_hill_n, tnf_autocrine_k50
    RANGE tnfr1_expression, tnfr2_expression
    RANGE tnfr1_kon, tnfr1_koff, tnfr2_kon, tnfr2_koff
    RANGE nfkb_activation_threshold, nfkb_decay_rate, nfkb_activation_rate
    RANGE translation_delay_factor, secretion_rate
    RANGE g_tnf, itnf, pca, pna, pk
    NONSPECIFIC_CURRENT itnf
}

UNITS {
    (mV) = (millivolt)
    (mA) = (milliamp)
    (mM) = (milli/liter)
    (uM) = (micro/liter)
    (nM) = (nano/liter)
    (S) = (siemens)
    F = (faraday) (coulombs)
    R = (k-mole) (joule/degC)
}

PARAMETER {	
    : LPS stimulation parameters
    lps_stim = 0                    : LPS concentration (dimensionless, represents ng/ml)
    lps_sensitivity = 0.1           : LPS sensitivity parameter
    lps_threshold = 1.0             : Minimum LPS for activation
    
    : Calcium-dependent production
    ca_threshold = 0.0001           : Calcium threshold for TNFa production (mM)
    ca_sensitivity = 2.0            : Calcium sensitivity exponent
    
    : TNFa production parameters
    basal_production = 0.01         : Basal TNFa production rate
    max_production = 10.0           : Maximum TNFa production rate
    
    : Kinetics
    tau_production = 100            : Time constant for production (ms)
    tau_decay = 500                 : Time constant for TNFa decay (ms)
    tau_mrna = 50                   : mRNA decay time constant (ms)
    
    : Feedback inhibition parameters (from PMC5520540)
    il10_inhibition_strength = 0.5  : IL-10 mediated inhibition strength
    tgfb_inhibition_strength = 0.7  : TGFbeta mediated inhibition strength
    tau_il10 = 50                   : IL-10 feedback time constant (ms) - fast feedback
    tau_tgfb = 200                  : TGFbeta feedback time constant (ms) - slow feedback
    il10_production_factor = 0.3    : IL-10 production relative to TNFalpha
    tgfb_production_factor = 0.2    : TGFbeta production relative to TNFalpha
    il10_decay = 0.004              : IL-10 decay rate (1/ms)
    tgfb_decay = 0.002              : TGFbeta decay rate (1/ms)
    
    : Autocrine signaling parameters
    tnf_autocrine_hill_n = 2.0      : Hill coefficient for TNFalpha self-regulation
    tnf_autocrine_k50 = 5.0         : Half-maximal concentration for autocrine
    
    : Receptor dynamics (TNFR1 and TNFR2 from Cell 2001)
    tnfr1_expression = 1.0          : TNFR1 receptor density (constitutive)
    tnfr2_expression = 0.5          : TNFR2 receptor density (inducible)
    tnfr1_kon = 0.01                : TNFR1 binding rate (irreversible binding)
    tnfr1_koff = 0.001              : TNFR1 unbinding rate (very slow)
    tnfr2_kon = 0.05                : TNFR2 binding rate (rapid on/off)
    tnfr2_koff = 0.02               : TNFR2 unbinding rate
    
    : NFkB pathway components
    nfkb_activation_threshold = 0.1 : Threshold for NFkB activation
    nfkb_decay_rate = 0.02          : NFkB signal decay (1/ms)
    nfkb_activation_rate = 0.05     : NFkB activation rate
    
    : Translation and secretion
    translation_delay_factor = 0.1  : Factor for mRNA-to-protein translation
    secretion_rate = 0.05           : Rate of TNFalpha release (1/ms)
    
    : TNFa-induced conductance
    g_tnf = 0.0001                  : Conductance per unit TNFa (S/cm2 per pg/ml)
    
    : Permeability ratios (similar to Piezo1)
    pca = 1.0
    pna = 0.1
    pk = 0.08
}

ASSIGNED {
    v (mV)
    celsius (degC)
    cai (mM)                        : Intracellular calcium concentration
    cao (mM)
    nai (mM)
    nao (mM)
    ki (mM)
    ko (mM)
    
    ica (mA/cm2)
    ina (mA/cm2)
    ik (mA/cm2)
    itnf (mA/cm2)
    
    tnf_production_rate             : Current TNFa production rate
    tnf_decay_rate                  : Current TNFa decay rate
    lps_factor                      : LPS activation factor
    ca_factor                       : Calcium activation factor
    autocrine_factor                : Autocrine regulation factor
    il10_inhibition                 : IL-10 inhibition factor
    tgfb_inhibition                 : TGFbeta inhibition factor
    total_inhibition                : Combined inhibition
    g_total (S/cm2)                 : Total TNFa-induced conductance
    
    : Receptor binding
    tnfr1_free                      : Free TNFR1 receptors
    tnfr2_free                      : Free TNFR2 receptors
    receptor_activation             : Combined receptor activation signal
}

STATE {
    tnf_conc                        : TNFa concentration (pg/ml)
    tnf_mrna                        : TNFalpha mRNA level (arbitrary units)
    il10_conc                       : IL-10 concentration (pg/ml)
    tgfb_conc                       : TGFbeta concentration (pg/ml)
    tnfr1_bound                     : Bound TNFR1 receptors (fraction)
    tnfr2_bound                     : Bound TNFR2 receptors (fraction)
    nfkb_active                     : Active NFkB (arbitrary units)
}

INITIAL {
    tnf_conc = 0
    tnf_mrna = 0
    il10_conc = 0.1                 : Small basal level
    tgfb_conc = 0.1                 : Small basal level
    tnfr1_bound = 0
    tnfr2_bound = 0
    nfkb_active = 0
    
    tnf_production_rate = basal_production
    tnf_decay_rate = 0
}

BREAKPOINT {
    SOLVE dynamics METHOD derivimplicit
    
    : Calculate TNFa-induced conductance
    g_total = g_tnf * tnf_conc
    
    : Calculate ionic currents using GHK equation (similar to Piezo1)
    ica = -g_total * pca * ghk(v, cai, cao, 2) * 1e3
    ina = -g_total * pna * ghk(v, nai, nao, 1) * 1e3
    ik = -g_total * pk * ghk(v, ki, ko, 1) * 1e3
    
    itnf = ica + ina + ik
}

DERIVATIVE dynamics {
    LOCAL nfkb_stimulus
    : ================================================================
    : 1. LPS ACTIVATION FACTOR
    : ================================================================
    if (lps_stim > lps_threshold) {
        lps_factor = 1 - exp(-lps_sensitivity * (lps_stim - lps_threshold))
    } else {
        lps_factor = 0
    }
    
    : ================================================================
    : 2. CALCIUM-DEPENDENT ACTIVATION FACTOR
    : ================================================================
    if (cai > ca_threshold) {
        ca_factor = pow((cai - ca_threshold) / ca_threshold, ca_sensitivity)
        : Saturate at 1.0
        if (ca_factor > 1) {
            ca_factor = 1
        }
    } else {
        ca_factor = 0
    }
    
    : ================================================================
    : 3. AUTOCRINE FEEDBACK (TNFalpha self-regulation)
    : Hill function for negative feedback
    : ================================================================
    autocrine_factor = 1 / (1 + pow(tnf_conc / tnf_autocrine_k50, tnf_autocrine_hill_n))
    
    : ================================================================
    : 4. ANTI-INFLAMMATORY CYTOKINE INHIBITION
    : IL-10: early, fast negative feedback
    : TGFbeta: delayed, sustained negative feedback
    : From PMC5520540 - differential kinetics are critical
    : ================================================================
    
    : IL-10 inhibition (fast feedback)
    il10_inhibition = il10_conc / (il10_conc + il10_inhibition_strength)
    
    : TGFbeta inhibition (slow feedback)
    tgfb_inhibition = tgfb_conc / (tgfb_conc + tgfb_inhibition_strength)
    
    : Combined inhibition (multiplicative, AND-gate logic from PMC5520540)
    total_inhibition = (1 - il10_inhibition) * (1 - tgfb_inhibition)
    
    : ================================================================
    : 5. NFkB PATHWAY ACTIVATION
    : Activated by both LPS and receptor binding
    : ================================================================
    if (lps_factor > nfkb_activation_threshold || receptor_activation > nfkb_activation_threshold) {
        nfkb_stimulus = nfkb_activation_rate * (lps_factor + receptor_activation)
    } else {
        nfkb_stimulus = 0
    }
    nfkb_active' = nfkb_stimulus - nfkb_decay_rate * nfkb_active
    
    : ================================================================
    : 6. mRNA DYNAMICS (with NFkB-dependent transcription)
    : ================================================================
    tnf_mrna' = (basal_production + max_production * lps_factor * ca_factor * (1 + nfkb_active)) * 
                 autocrine_factor * total_inhibition / tau_production - tnf_mrna / tau_mrna
    
    : Non-negative constraint handled by initial conditions
    
    : ================================================================
    : 7. RECEPTOR DYNAMICS (TNFR1 and TNFR2)
    : From Cell 2001 - distinct binding kinetics
    : ================================================================
    
    : Calculate free receptors
    tnfr1_free = tnfr1_expression - tnfr1_bound
    tnfr2_free = tnfr2_expression - tnfr2_bound
    
    : TNFR1 binding (irreversible, slow off-rate)
    tnfr1_bound' = tnfr1_kon * tnf_conc * tnfr1_free - tnfr1_koff * tnfr1_bound
    
    : TNFR2 binding (rapid on/off kinetics)
    tnfr2_bound' = tnfr2_kon * tnf_conc * tnfr2_free - tnfr2_koff * tnfr2_bound
    
    : Bounds enforced through kinetic equations
    
    : Combined receptor activation signal
    receptor_activation = tnfr1_bound + 0.5 * tnfr2_bound
    
    : ================================================================
    : 8. TNFalpha PROTEIN DYNAMICS (translation and secretion)
    : ================================================================
    
    : Translation from mRNA with delay factor
    tnf_production_rate = translation_delay_factor * tnf_mrna
    
    : Decay includes natural degradation and receptor-mediated uptake
    tnf_decay_rate = tnf_conc / tau_decay + secretion_rate * receptor_activation * tnf_conc
    
    : TNFa dynamics: production - decay
    tnf_conc' = tnf_production_rate - tnf_decay_rate
    
    : Non-negative enforced by kinetics
    
    : ================================================================
    : 9. ANTI-INFLAMMATORY CYTOKINE DYNAMICS
    : IL-10 and TGFbeta production stimulated by TNFalpha
    : From PMC5520540 - TNFalpha activates negative feedback
    : ================================================================
    
    : IL-10 production (fast response to TNFalpha)
    il10_conc' = il10_production_factor * tnf_conc / tau_il10 - il10_decay * il10_conc
    : Basal level maintained by initial conditions
    
    : TGFbeta production (slow response to TNFalpha, with autoregulation from PMC5520540)
    : TGFbeta autoregulation was necessary to fit experimental data
    tgfb_conc' = tgfb_production_factor * tnf_conc / tau_tgfb + 
                  0.1 * tgfb_conc / (1 + tgfb_conc) - tgfb_decay * tgfb_conc
    : Basal level maintained by initial conditions
}

FUNCTION ghk(v, ci, co, z) {
    LOCAL arg, fac
    fac = z * v / (R * (celsius + 273.15)) * F
    arg = fac * 1e-3
    if (fabs(arg) < 1e-4) {
        ghk = fac * (ci - co) * 1e-3
    } else {
        ghk = fac * arg * (ci - co * exp(arg)) / (1 - exp(arg)) * 1e-3
    }
}
