COMMENT

Enhanced Model of IL-1beta (Interleukin-1 beta) production and release from microglia.
This mechanism simulates calcium-dependent cytokine production triggered by LPS stimulation
with feedback inhibition networks and receptor-mediated signaling.

Key features:
1. LPS-induced microglial activation
2. Calcium-dependent IL-1beta production
3. Negative feedback from IL-10 and TGFbeta
4. TNFalpha-mediated IL-1beta activation (from PMC5520540)
5. IL-1R1 (Type I) and IL-1R2 (Type II decoy) receptor dynamics
6. NFkappaB pathway activation
7. Inflammasome-dependent processing (NLRP3)
8. Pro-IL-1beta to mature IL-1beta conversion
9. IL-1beta accumulation and diffusion
10. Downstream signaling effects

Key differences from TNFalpha:
- Requires inflammasome activation for maturation
- TNFalpha activates IL-1beta production (from network analysis)
- IL-1R1 (signaling) vs IL-1R2 (decoy receptor)
- IL-1beta has pro-form that requires caspase-1 cleavage
- Different kinetics: faster initial response than TNFalpha

References:
1. Gutierrez H, Davies AM, Mol BioSyst 2015 - Computational modeling of cytokine signaling
   (PMC5520540) - Microglial cytokine network with IL-1beta as activated by TNFalpha
2. Dinarello CA, Blood 2011 - Interleukin-1 family nomenclature
3. Garlanda C et al., Immunity 2013 - The interleukin-1 family
4. Hanisch UK, Glia 2002 - LPS-induced microglial activation
5. Schroder K, Tschopp J, Cell 2010 - The inflammasomes (NLRP3)

ENDCOMMENT


NEURON {
    SUFFIX  IL1b
    USEION ca READ cai, cao WRITE ica
    USEION na READ nai, nao WRITE ina
    USEION k READ ki, ko WRITE ik
    RANGE il1b_conc, il1b_pro, il1b_mature, il1b_mrna
    RANGE il1b_production_rate, il1b_decay_rate
    RANGE il10_conc, tgfb_conc, tnfa_conc, nfkb_active
    RANGE il1r1_bound, il1r2_bound, inflammasome_active
    RANGE lps_stim, lps_sensitivity, lps_threshold, ca_threshold
    RANGE basal_production, max_production, ca_sensitivity
    RANGE tau_production, tau_decay, tau_mrna, tau_processing
    RANGE il10_inhibition_strength, tgfb_inhibition_strength
    RANGE il10_production_factor, tgfb_production_factor
    RANGE il10_decay, tgfb_decay, tnfa_decay
    RANGE tau_il10, tau_tgfb, tau_tnfa
    RANGE tnfa_activation_factor, tnfa_activation_k50, tnfa_hill_n
    RANGE il1b_autocrine_hill_n, il1b_autocrine_k50
    RANGE il1r1_expression, il1r2_expression
    RANGE il1r1_kon, il1r1_koff, il1r2_kon, il1r2_koff
    RANGE nfkb_activation_threshold, nfkb_decay_rate, nfkb_activation_rate
    RANGE inflammasome_threshold, inflammasome_activation_rate, inflammasome_decay_rate
    RANGE caspase1_activity, processing_rate
    RANGE translation_delay_factor, secretion_rate
    RANGE g_il1b, iil1b, pca, pna, pk
    NONSPECIFIC_CURRENT iil1b
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
    lps_sensitivity = 0.12          : LPS sensitivity parameter (slightly higher than TNFalpha)
    lps_threshold = 0.8             : Minimum LPS for activation (lower than TNFalpha)
    
    : Calcium-dependent production
    ca_threshold = 0.00008          : Calcium threshold for IL-1beta production (mM)
    ca_sensitivity = 2.2            : Calcium sensitivity exponent
    
    : IL-1beta production parameters
    basal_production = 0.005        : Basal IL-1beta production rate (lower than TNFalpha)
    max_production = 12.0           : Maximum IL-1beta production rate
    
    : Kinetics
    tau_production = 80             : Time constant for production (ms) - faster than TNFalpha
    tau_decay = 450                 : Time constant for IL-1beta decay (ms)
    tau_mrna = 45                   : mRNA decay time constant (ms)
    tau_processing = 30             : Time constant for pro-IL-1beta processing (ms)
    
    : Feedback inhibition parameters (from PMC5520540)
    il10_inhibition_strength = 0.6  : IL-10 mediated inhibition (stronger than for TNFalpha)
    tgfb_inhibition_strength = 0.5  : TGFbeta mediated inhibition
    tau_il10 = 55                   : IL-10 feedback time constant (ms)
    tau_tgfb = 210                  : TGFbeta feedback time constant (ms)
    il10_production_factor = 0.25   : IL-10 production relative to IL-1beta
    tgfb_production_factor = 0.15   : TGFbeta production relative to IL-1beta
    il10_decay = 0.004              : IL-10 decay rate (1/ms)
    tgfb_decay = 0.002              : TGFbeta decay rate (1/ms)
    
    : TNFalpha activation parameters (from PMC5520540 - IL-1beta activated by TNFalpha)
    tnfa_activation_factor = 0.8    : Strength of TNFalpha-mediated IL-1beta activation
    tnfa_activation_k50 = 3.0       : Half-maximal TNFalpha concentration for IL-1beta activation
    tnfa_hill_n = 2.5               : Hill coefficient for TNFalpha activation
    tau_tnfa = 120                  : TNFalpha production time constant (ms)
    tnfa_decay = 0.003              : TNFalpha decay rate (1/ms)
    
    : Autocrine signaling parameters
    il1b_autocrine_hill_n = 2.2     : Hill coefficient for IL-1beta self-regulation
    il1b_autocrine_k50 = 4.0        : Half-maximal concentration for autocrine
    
    : Receptor dynamics (IL-1R1 and IL-1R2)
    il1r1_expression = 1.0          : IL-1R1 receptor density (Type I, signaling)
    il1r2_expression = 0.3          : IL-1R2 receptor density (Type II, decoy)
    il1r1_kon = 0.015               : IL-1R1 binding rate
    il1r1_koff = 0.002              : IL-1R1 unbinding rate
    il1r2_kon = 0.02                : IL-1R2 binding rate (decoy, higher affinity)
    il1r2_koff = 0.001              : IL-1R2 unbinding rate (very slow)
    
    : NFkappaB pathway components
    nfkb_activation_threshold = 0.08: Threshold for NFkappaB activation
    nfkb_decay_rate = 0.025         : NFkappaB signal decay (1/ms)
    nfkb_activation_rate = 0.06     : NFkappaB activation rate
    
    : Inflammasome parameters (NLRP3)
    inflammasome_threshold = 0.15   : Threshold for inflammasome activation
    inflammasome_activation_rate = 0.08 : Inflammasome activation rate
    inflammasome_decay_rate = 0.015 : Inflammasome decay rate (1/ms)
    caspase1_activity = 1.0         : Caspase-1 activity level
    processing_rate = 0.12          : Rate of pro-IL-1beta to mature IL-1beta conversion (1/ms)
    
    : Translation and secretion
    translation_delay_factor = 0.12 : Factor for mRNA-to-protein translation
    secretion_rate = 0.06           : Rate of IL-1beta release (1/ms)
    
    : IL-1beta-induced conductance
    g_il1b = 0.00012                : Conductance per unit IL-1beta (S/cm2 per pg/ml)
    
    : Permeability ratios
    pca = 1.0
    pna = 0.12
    pk = 0.09
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
    iil1b (mA/cm2)
    
    il1b_production_rate            : Current IL-1beta production rate
    il1b_decay_rate                 : Current IL-1beta decay rate
    lps_factor                      : LPS activation factor
    ca_factor                       : Calcium activation factor
    tnfa_factor                     : TNFalpha activation factor
    autocrine_factor                : Autocrine regulation factor
    il10_inhibition                 : IL-10 inhibition factor
    tgfb_inhibition                 : TGFbeta inhibition factor
    total_inhibition                : Combined inhibition
    g_total (S/cm2)                 : Total IL-1beta-induced conductance
    
    : Receptor binding
    il1r1_free                      : Free IL-1R1 receptors (signaling)
    il1r2_free                      : Free IL-1R2 receptors (decoy)
    receptor_activation             : Net receptor activation signal
    inflammasome_stimulus           : Stimulus for inflammasome activation
}

STATE {
    il1b_conc                       : Total IL-1beta concentration (pg/ml)
    il1b_pro                        : Pro-IL-1beta concentration (immature form)
    il1b_mature                     : Mature IL-1beta concentration (processed form)
    il1b_mrna                       : IL-1beta mRNA level (arbitrary units)
    il10_conc                       : IL-10 concentration (pg/ml)
    tgfb_conc                       : TGFbeta concentration (pg/ml)
    tnfa_conc                       : TNFalpha concentration (pg/ml)
    il1r1_bound                     : Bound IL-1R1 receptors (fraction)
    il1r2_bound                     : Bound IL-1R2 receptors (decoy, fraction)
    nfkb_active                     : Active NFkappaB (arbitrary units)
    inflammasome_active             : Active inflammasome (NLRP3) level
}

INITIAL {
    il1b_conc = 0
    il1b_pro = 0
    il1b_mature = 0
    il1b_mrna = 0
    il10_conc = 0.1                 : Small basal level
    tgfb_conc = 0.1                 : Small basal level
    tnfa_conc = 0.1                 : Small basal level
    il1r1_bound = 0
    il1r2_bound = 0
    nfkb_active = 0
    inflammasome_active = 0
    
    il1b_production_rate = basal_production
    il1b_decay_rate = 0
}

BREAKPOINT {
    SOLVE dynamics METHOD derivimplicit
    
    : Calculate IL-1beta-induced conductance (based on mature IL-1beta)
    g_total = g_il1b * il1b_mature
    
    : Calculate ionic currents using GHK equation
    ica = -g_total * pca * ghk(v, cai, cao, 2) * 1e3
    ina = -g_total * pna * ghk(v, nai, nao, 1) * 1e3
    ik = -g_total * pk * ghk(v, ki, ko, 1) * 1e3
    
    iil1b = ica + ina + ik
}

DERIVATIVE dynamics {
    LOCAL nfkb_stimulus, processing_flux
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
    : 3. TNFalpha-MEDIATED ACTIVATION (from PMC5520540)
    : IL-1beta is activated by TNFalpha in the cytokine network
    : ================================================================
    tnfa_factor = tnfa_activation_factor * pow(tnfa_conc, tnfa_hill_n) / 
                  (pow(tnfa_activation_k50, tnfa_hill_n) + pow(tnfa_conc, tnfa_hill_n))
    
    : ================================================================
    : 4. AUTOCRINE FEEDBACK (IL-1beta self-regulation)
    : Hill function for negative feedback
    : ================================================================
    autocrine_factor = 1 / (1 + pow(il1b_conc / il1b_autocrine_k50, il1b_autocrine_hill_n))
    
    : ================================================================
    : 5. ANTI-INFLAMMATORY CYTOKINE INHIBITION
    : IL-10: early, fast negative feedback
    : TGFbeta: delayed, sustained negative feedback
    : From PMC5520540 - differential kinetics are critical
    : ================================================================
    
    : IL-10 inhibition (fast feedback, stronger on IL-1beta than TNFalpha)
    il10_inhibition = il10_conc / (il10_conc + il10_inhibition_strength)
    
    : TGFbeta inhibition (slow feedback)
    tgfb_inhibition = tgfb_conc / (tgfb_conc + tgfb_inhibition_strength)
    
    : Combined inhibition (multiplicative, AND-gate logic from PMC5520540)
    total_inhibition = (1 - il10_inhibition) * (1 - tgfb_inhibition)
    
    : ================================================================
    : 6. INFLAMMASOME ACTIVATION (NLRP3)
    : Activated by LPS, calcium, and TNFalpha
    : Required for IL-1beta maturation via caspase-1
    : ================================================================
    if (lps_factor > inflammasome_threshold || 
        ca_factor > inflammasome_threshold || 
        tnfa_factor > inflammasome_threshold) {
        inflammasome_stimulus = inflammasome_activation_rate * (lps_factor + ca_factor + tnfa_factor)
    } else {
        inflammasome_stimulus = 0
    }
    inflammasome_active' = inflammasome_stimulus - inflammasome_decay_rate * inflammasome_active
    
    : ================================================================
    : 7. NFkappaB PATHWAY ACTIVATION
    : Activated by LPS, TNFalpha, and receptor binding
    : ================================================================
    if (lps_factor > nfkb_activation_threshold || 
        tnfa_factor > nfkb_activation_threshold ||
        receptor_activation > nfkb_activation_threshold) {
        nfkb_stimulus = nfkb_activation_rate * (lps_factor + tnfa_factor + receptor_activation)
    } else {
        nfkb_stimulus = 0
    }
    nfkb_active' = nfkb_stimulus - nfkb_decay_rate * nfkb_active
    
    : ================================================================
    : 8. mRNA DYNAMICS (with NFkappaB-dependent transcription)
    : Enhanced by TNFalpha activation
    : ================================================================
    il1b_mrna' = (basal_production + max_production * (lps_factor + tnfa_factor) * ca_factor * 
                  (1 + nfkb_active)) * autocrine_factor * total_inhibition / tau_production - 
                  il1b_mrna / tau_mrna
    
    : ================================================================
    : 9. RECEPTOR DYNAMICS (IL-1R1 and IL-1R2)
    : IL-1R1: Type I receptor (signaling)
    : IL-1R2: Type II receptor (decoy, no signaling)
    : ================================================================
    
    : Calculate free receptors
    il1r1_free = il1r1_expression - il1r1_bound
    il1r2_free = il1r2_expression - il1r2_bound
    
    : IL-1R1 binding (signaling receptor)
    il1r1_bound' = il1r1_kon * il1b_mature * il1r1_free - il1r1_koff * il1r1_bound
    
    : IL-1R2 binding (decoy receptor, sequesters IL-1beta)
    il1r2_bound' = il1r2_kon * il1b_mature * il1r2_free - il1r2_koff * il1r2_bound
    
    : Net receptor activation (only IL-1R1 contributes to signaling)
    : IL-1R2 acts as a sink, reducing available IL-1beta
    receptor_activation = il1r1_bound
    
    : ================================================================
    : 10. PRO-IL-1beta DYNAMICS (translation from mRNA)
    : ================================================================
    
    : Translation from mRNA to pro-IL-1beta
    il1b_pro' = translation_delay_factor * il1b_mrna - 
                processing_rate * caspase1_activity * inflammasome_active * il1b_pro - 
                il1b_pro / tau_decay
    
    : ================================================================
    : 11. MATURE IL-1beta DYNAMICS (inflammasome-dependent processing)
    : ================================================================
    
    : Processing flux from pro-IL-1beta to mature IL-1beta (caspase-1 dependent)
    processing_flux = processing_rate * caspase1_activity * inflammasome_active * il1b_pro
    
    : Mature IL-1beta production and decay
    il1b_mature' = processing_flux - il1b_mature / tau_processing - 
                   secretion_rate * receptor_activation * il1b_mature - 
                   il1r2_kon * il1b_mature * il1r2_free
    
    : ================================================================
    : 12. TOTAL IL-1beta CONCENTRATION
    : ================================================================
    il1b_conc = il1b_pro + il1b_mature
    
    : Production and decay rates for monitoring
    il1b_production_rate = processing_flux
    il1b_decay_rate = il1b_mature / tau_processing + 
                      secretion_rate * receptor_activation * il1b_mature
    
    : ================================================================
    : 13. ANTI-INFLAMMATORY CYTOKINE DYNAMICS
    : IL-10 and TGFbeta production stimulated by IL-1beta
    : From PMC5520540 - IL-1beta activates negative feedback
    : ================================================================
    
    : IL-10 production (fast response to IL-1beta)
    il10_conc' = il10_production_factor * il1b_mature / tau_il10 - il10_decay * il10_conc
    
    : TGFbeta production (slow response to IL-1beta, with autoregulation)
    tgfb_conc' = tgfb_production_factor * il1b_mature / tau_tgfb + 
                  0.08 * tgfb_conc / (1 + tgfb_conc) - tgfb_decay * tgfb_conc
    
    : ================================================================
    : 14. TNFalpha DYNAMICS (produced by IL-1beta in reciprocal interaction)
    : From PMC5520540 - mutual activation between TNFalpha and IL-1beta
    : ================================================================
    tnfa_conc' = 0.4 * il1b_mature / tau_tnfa - tnfa_decay * tnfa_conc
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
