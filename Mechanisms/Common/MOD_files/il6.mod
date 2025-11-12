COMMENT

Enhanced Model of IL-6 (Interleukin-6) production and release from microglia.
This mechanism simulates calcium-dependent cytokine production triggered by LPS stimulation
with feedback regulation and signaling dynamics.

Key features:
1. LPS-induced microglial activation
2. Calcium-dependent IL-6 production
3. Cross-regulation with TNFa and IL-1b
4. IL-6 stimulation of IL-10 production (critical anti-inflammatory pathway)
5. Autocrine IL-6 self-regulation
6. IL-6R (gp80) and gp130 receptor dynamics
7. STAT3 pathway activation
8. mRNA-protein translation dynamics
9. IL-6 accumulation and diffusion
10. Downstream signaling effects

References:
1. Hanisch UK, Glia 2002 - LPS-induced microglial activation
2. Hoffmann A et al., Front Mol Neurosci 2003 - Calcium signaling in microglia
3. Zhang Y et al., J Neurosci 2014 - Purified microglia RNA-seq analysis
4. Gutierrez H, Davies AM, Mol BioSyst 2015 - Computational modeling of cytokine signaling
   (PMC5520540) - Microglial cytokine network with IL-6 activating IL-10
5. Heinrich PC et al., Biochem J 2003 - Principles of IL-6-type cytokine signaling
6. Rose-John S, Nat Rev Immunol 2018 - IL-6 trans-signaling via soluble IL-6R

ENDCOMMENT


NEURON {
    SUFFIX  IL6
    USEION ca READ cai, cao WRITE ica
    USEION na READ nai, nao WRITE ina
    USEION k READ ki, ko WRITE ik
    RANGE il6_conc, il6_mrna, il6_production_rate, il6_decay_rate
    RANGE il10_conc, stat3_active
    RANGE il6r_bound, gp130_bound
    RANGE lps_stim, lps_sensitivity, lps_threshold, ca_threshold
    RANGE basal_production, max_production, ca_sensitivity
    RANGE tau_production, tau_decay, tau_mrna
    RANGE il10_production_factor, il10_decay, tau_il10
    RANGE tnfa_activation_strength, il1b_activation_strength
    RANGE il6_autocrine_hill_n, il6_autocrine_k50
    RANGE il6r_expression, gp130_expression
    RANGE il6r_kon, il6r_koff, gp130_kon, gp130_koff
    RANGE stat3_activation_threshold, stat3_decay_rate, stat3_activation_rate
    RANGE translation_delay_factor, secretion_rate
    RANGE g_il6, iil6, pca, pna, pk
    NONSPECIFIC_CURRENT iil6
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
    ca_threshold = 0.0001           : Calcium threshold for IL-6 production (mM)
    ca_sensitivity = 2.0            : Calcium sensitivity exponent
    
    : IL-6 production parameters
    basal_production = 0.01         : Basal IL-6 production rate
    max_production = 8.0            : Maximum IL-6 production rate
    
    : Kinetics
    tau_production = 120            : Time constant for production (ms)
    tau_decay = 400                 : Time constant for IL-6 decay (ms)
    tau_mrna = 60                   : mRNA decay time constant (ms)
    
    : IL-10 production parameters (from PMC5520540 - IL-6 activates IL-10)
    il10_production_factor = 0.4    : IL-10 production relative to IL-6
    il10_decay = 0.004              : IL-10 decay rate (1/ms)
    tau_il10 = 50                   : IL-10 feedback time constant (ms)
    
    : Cross-cytokine activation parameters
    tnfa_activation_strength = 0.3  : TNFa activation of IL-6 production
    il1b_activation_strength = 0.4  : IL-1b activation of IL-6 production
    
    : Autocrine signaling parameters
    il6_autocrine_hill_n = 2.0      : Hill coefficient for IL-6 self-regulation
    il6_autocrine_k50 = 5.0         : Half-maximal concentration for autocrine
    
    : Receptor dynamics (IL-6R and gp130 from Biochem J 2003)
    il6r_expression = 1.0           : IL-6R (gp80) receptor density
    gp130_expression = 1.2          : gp130 signal transducer density
    il6r_kon = 0.015                : IL-6R binding rate
    il6r_koff = 0.005               : IL-6R unbinding rate
    gp130_kon = 0.02                : gp130 binding rate (to IL-6:IL-6R complex)
    gp130_koff = 0.002              : gp130 unbinding rate
    
    : STAT3 pathway components (JAK/STAT pathway)
    stat3_activation_threshold = 0.1 : Threshold for STAT3 activation
    stat3_decay_rate = 0.015         : STAT3 signal decay (1/ms)
    stat3_activation_rate = 0.06     : STAT3 activation rate
    
    : Translation and secretion
    translation_delay_factor = 0.1  : Factor for mRNA-to-protein translation
    secretion_rate = 0.04           : Rate of IL-6 release (1/ms)
    
    : IL-6-induced conductance
    g_il6 = 0.00008                 : Conductance per unit IL-6 (S/cm2 per pg/ml)
    
    : Permeability ratios
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
    iil6 (mA/cm2)
    
    il6_production_rate             : Current IL-6 production rate
    il6_decay_rate                  : Current IL-6 decay rate
    lps_factor                      : LPS activation factor
    ca_factor                       : Calcium activation factor
    autocrine_factor                : Autocrine regulation factor
    cross_cytokine_activation       : TNFa and IL-1b activation factor
    g_total (S/cm2)                 : Total IL-6-induced conductance
    
    : Receptor binding
    il6r_free                       : Free IL-6R receptors
    gp130_free                      : Free gp130 receptors
    receptor_complex                : IL-6:IL-6R:gp130 signaling complex
}

STATE {
    il6_conc                        : IL-6 concentration (pg/ml)
    il6_mrna                        : IL-6 mRNA level (arbitrary units)
    il10_conc                       : IL-10 concentration (pg/ml)
    il6r_bound                      : Bound IL-6R receptors (fraction)
    gp130_bound                     : Bound gp130 in signaling complex (fraction)
    stat3_active                    : Active STAT3 (arbitrary units)
}

INITIAL {
    il6_conc = 0
    il6_mrna = 0
    il10_conc = 0.1                 : Small basal level
    il6r_bound = 0
    gp130_bound = 0
    stat3_active = 0
    
    il6_production_rate = basal_production
    il6_decay_rate = 0
}

BREAKPOINT {
    SOLVE dynamics METHOD derivimplicit
    
    : Calculate IL-6-induced conductance
    g_total = g_il6 * il6_conc
    
    : Calculate ionic currents using GHK equation
    ica = -g_total * pca * ghk(v, cai, cao, 2) * 1e3
    ina = -g_total * pna * ghk(v, nai, nao, 1) * 1e3
    ik = -g_total * pk * ghk(v, ki, ko, 1) * 1e3
    
    iil6 = ica + ina + ik
}

DERIVATIVE dynamics {
    LOCAL stat3_stimulus
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
    : 3. AUTOCRINE FEEDBACK (IL-6 self-regulation)
    : Hill function for negative feedback
    : ================================================================
    autocrine_factor = 1 / (1 + pow(il6_conc / il6_autocrine_k50, il6_autocrine_hill_n))
    
    : ================================================================
    : 4. CROSS-CYTOKINE ACTIVATION
    : TNFa and IL-1b enhance IL-6 production (from PMC5520540)
    : Note: These would be passed from TNFa and IL-1b mechanisms in full model
    : For standalone use, set to 0
    : ================================================================
    cross_cytokine_activation = 0
    
    : ================================================================
    : 5. STAT3 PATHWAY ACTIVATION
    : Activated by receptor complex formation
    : ================================================================
    if (receptor_complex > stat3_activation_threshold) {
        stat3_stimulus = stat3_activation_rate * receptor_complex
    } else {
        stat3_stimulus = 0
    }
    stat3_active' = stat3_stimulus - stat3_decay_rate * stat3_active
    
    : ================================================================
    : 6. mRNA DYNAMICS (with STAT3-dependent transcription)
    : ================================================================
    il6_mrna' = (basal_production + max_production * lps_factor * ca_factor * 
                 (1 + stat3_active + cross_cytokine_activation)) * 
                 autocrine_factor / tau_production - il6_mrna / tau_mrna
    
    : Non-negative constraint handled by initial conditions
    
    : ================================================================
    : 7. RECEPTOR DYNAMICS (IL-6R and gp130)
    : From Biochem J 2003 - two-step binding mechanism
    : ================================================================
    
    : Calculate free receptors
    il6r_free = il6r_expression - il6r_bound
    gp130_free = gp130_expression - gp130_bound
    
    : Step 1: IL-6 binds to IL-6R
    il6r_bound' = il6r_kon * il6_conc * il6r_free - il6r_koff * il6r_bound
    
    : Step 2: IL-6:IL-6R complex recruits gp130 for signaling
    gp130_bound' = gp130_kon * il6r_bound * gp130_free - gp130_koff * gp130_bound
    
    : Signaling complex (IL-6:IL-6R:gp130)
    receptor_complex = gp130_bound
    
    : ================================================================
    : 8. IL-6 PROTEIN DYNAMICS (translation and secretion)
    : ================================================================
    
    : Translation from mRNA with delay factor
    il6_production_rate = translation_delay_factor * il6_mrna
    
    : Decay includes natural degradation and receptor-mediated internalization
    il6_decay_rate = il6_conc / tau_decay + secretion_rate * receptor_complex * il6_conc
    
    : IL-6 dynamics: production - decay
    il6_conc' = il6_production_rate - il6_decay_rate
    
    : Non-negative enforced by kinetics
    
    : ================================================================
    : 9. IL-10 PRODUCTION BY IL-6
    : From PMC5520540 - IL-6 activates IL-10 (anti-inflammatory feedback)
    : This is a critical pathway for resolving inflammation
    : ================================================================
    
    : IL-10 production stimulated by IL-6
    il10_conc' = il10_production_factor * il6_conc / tau_il10 - il10_decay * il10_conc
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
