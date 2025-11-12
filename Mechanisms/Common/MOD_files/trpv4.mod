COMMENT

Model of TRPV4 channel expression, activation, and downstream signaling in brain endothelial cells.
This mechanism simulates the calcium-permeable TRPV4 channel based on Hansen et al. 2024 
(J Neuroinflammation 21:72) findings in multiple sclerosis blood-brain barrier dysfunction.

Key features:
1. TNFa-induced TRPV4 expression upregulation
2. Multi-modal channel activation:
   - Inflammatory mediators (TNFa, ATP autocrine)
   - Mechanical/shear stress activation
   - Agonist-mediated activation (GSK1016790A)
   - Calcium-dependent sensitization
3. Calcium influx via GHK formalism
4. Downstream signaling cascades:
   - NFkB pathway activation
   - Tight junction protein regulation (Claudin-5, VE-cadherin)
   - Cell adhesion molecule expression (ICAM1, VCAM1, E-selectin)
   - Pro-inflammatory cytokine production (CCL2, CCL5)
5. Pharmacological modulation (antagonist effects)
6. Barrier dysfunction mechanisms

Reference: Hansen et al. (2024) J Neuroinflammation 21:72
https://doi.org/10.1186/s12974-024-03069-9

ENDCOMMENT


NEURON {
    SUFFIX TRPV4
    USEION ca READ cai, cao WRITE ica
    USEION na READ nai, nao WRITE ina
    USEION k READ ki, ko WRITE ik
    
    RANGE trpv4_expression, trpv4_baseline
    RANGE trpv4_open_prob, channel_conductance
    RANGE tnfa_conc_ext, tnfa_induced_expression
    RANGE agonist_conc, antagonist_conc
    RANGE mechanical_stimulus, shear_stress
    RANGE atp_autocrine
    RANGE max_expression_fold
    
    : Downstream signaling
    RANGE nfkb_active, cldn5_expression, vecad_expression
    RANGE icam1_expression, vcam1_expression, sele_expression
    RANGE ccl2_expression, ccl5_expression, cav1_expression
    
    : Channel activation factors
    RANGE inflammatory_activation, mechanical_activation
    RANGE calcium_sensitization, agonist_activation
    RANGE total_activation
    
    : Conductance and currents
    RANGE g_trpv4, itrpv4
    RANGE pca_trpv4, pna_trpv4, pk_trpv4
    
    : Kinetic parameters
    RANGE tau_expression, tau_activation, tau_deactivation
    RANGE tau_nfkb, tau_junction_proteins, tau_adhesion_molecules
    
    : Sensitivity parameters
    RANGE tnfa_sensitivity, ca_sensitivity_trpv4, shear_sensitivity
    RANGE tnfa_threshold_trpv4, agonist_ec50, antagonist_ic50
    
    : Signaling parameters
    RANGE nfkb_activation_rate, nfkb_decay_rate
    RANGE junction_baseline, junction_trpv4_dependence
    RANGE adhesion_baseline, adhesion_inflammatory_gain
    RANGE cytokine_production_rate
     
    RANGE agonist_hill, antagonist_hill, atp_decay_rate, atp_production_rate, atp_sensitivity, ca_threshold_trpv4, cav1_baseline, cav1_inflammatory_gain, cav1_trpv4_dependence, ccl2_baseline
    RANGE ccl2_decay_rate, ccl2_nfkb_dependence, ccl5_baseline, ccl5_decay_rate, ccl5_inflammatory_gain, cldn5_baseline, cldn5_inflammatory_loss, cldn5_trpv4_dependence, g_trpv4_max, icam1_baseline
    RANGE icam1_inflammatory_gain, icam1_trpv4_modulation, inflammatory_sensitivity, nfkb_threshold, sele_baseline, sele_inflammatory_gain, sele_trpv4_modulation, shear_threshold, vcam1_baseline, vcam1_inflammatory_gain
    RANGE vcam1_trpv4_modulation, vecad_baseline, vecad_inflammatory_loss, vecad_trpv4_dependence
    
    : The following variables were causing C compilation errors because they were 
    : used in DERIVATIVE but not declared in ASSIGNED. They have been moved 
    : to ASSIGNED below.
    : RANGE tnfa_expression_effect, nfkb_stimulus, inflammatory_signal
    : RANGE agonist_effect, antagonist_effect, shear_effect, atp_effect
    : RANGE ca_sensitization_factor, activation_stimulus
    : RANGE cldn5_target, vecad_target
    : RANGE icam1_target, vcam1_target, sele_target
    NONSPECIFIC_CURRENT itrpv4
}

UNITS {
    (mV) = (millivolt)
    (mA) = (milliamp)
    (mM) = (milli/liter)
    (uM) = (micro/liter)
    (nM) = (nano/liter)
    (S) = (siemens)
    (dyn) = (dyne)
    F = (faraday) (coulombs)
    R = (k-mole) (joule/degC)
}

PARAMETER {
    : ================================================================
    : TRPV4 EXPRESSION PARAMETERS
    : ================================================================
    trpv4_baseline = 1.0            : Baseline TRPV4 expression level
    tau_expression = 10000          : Time constant for expression changes 
    tnfa_sensitivity = 0.5          : Sensitivity to TNFa-induced upregulation
    tnfa_threshold_trpv4 = 1.0      : TNFa threshold for expression increase (pg/ml)
    max_expression_fold = 3.0       
    
    : ================================================================
    : CHANNEL ACTIVATION PARAMETERS
    : ================================================================
    : Agonist parameters (GSK1016790A)
    agonist_conc = 0                : Agonist concentration (nM)
    agonist_ec50 = 5.0              : EC50 for agonist (nM)
    agonist_hill = 2.0              : Hill coefficient for agonist
    
    : Antagonist parameters (GSK2193874)
    antagonist_conc = 0             : Antagonist concentration (nM)
    antagonist_ic50 = 40.0          : IC50 for antagonist (nM)
    antagonist_hill = 1.5           : Hill coefficient for antagonist
    
    : Inflammatory activation
    tnfa_conc_ext = 1               : External TNFa concentration (pg/ml)
    inflammatory_sensitivity = 0.3   : Sensitivity to inflammatory mediators
    
    : Mechanical/shear stress activation
    shear_stress = 0                : Shear stress level (dyn/cm2)
    shear_sensitivity = 0.02        : Sensitivity to shear stress
    shear_threshold = 5.0           : Threshold for shear activation (dyn/cm2)
    
    : ATP autocrine signaling
    atp_production_rate = 0.01      : ATP production rate with TNFa
    atp_decay_rate = 0.05           : ATP decay rate (1/ms)
    atp_sensitivity = 0.4           : ATP-mediated TRPV4 activation
    
    : Calcium-dependent sensitization
    ca_sensitivity_trpv4 = 1.5      : Calcium sensitization exponent
    ca_threshold_trpv4 = 0.0001     : Calcium threshold (mM)
    
    : Activation kinetics
    tau_activation = 10            : Time constant for activation (ms)
    tau_deactivation = 500          : Time constant for deactivation (ms)
    
    : ================================================================
    : CHANNEL CONDUCTANCE PARAMETERS
    : ================================================================
    g_trpv4_max = 0.0005            : Maximum TRPV4 conductance (S/cm2)
    
    : Ion permeabilities (Ca2+ > Na+ > K+)
    pca_trpv4 = 10.0                : Calcium permeability (high)
    pna_trpv4 = 1.0                 : Sodium permeability
    pk_trpv4 = 0.8                  : Potassium permeability
    
    : ================================================================
    : NFkB SIGNALING PARAMETERS
    : ================================================================
    nfkb_activation_rate = 0.08     : NFkB activation rate
    nfkb_decay_rate = 0.015         : NFkB decay rate (1/ms)
    nfkb_threshold = 0.05           : Threshold for NFkB activation
    tau_nfkb = 1000                 : NFkB signaling time constant 
    
    : ================================================================
    : TIGHT JUNCTION PROTEIN PARAMETERS
    : ================================================================
    : Claudin-5 regulation
    cldn5_baseline = 1.0            : Baseline Claudin-5 expression
    cldn5_trpv4_dependence = 0.6    : TRPV4 dependence for Cldn5
    cldn5_inflammatory_loss = 0.3   : Cldn5 loss during inflammation
    tau_junction_proteins = 7200000 : Junction protein time constant (2h in ms)
    
    : VE-Cadherin regulation
    vecad_baseline = 1.0            : Baseline VE-Cad expression
    vecad_trpv4_dependence = 0.4    : TRPV4 dependence for VE-Cad
    vecad_inflammatory_loss = 0.2   : VE-Cad loss during inflammation
    
    : ================================================================
    : CELL ADHESION MOLECULE PARAMETERS
    : ================================================================
    tau_adhesion_molecules = 14400000 : Adhesion molecule time constant (4h in ms)
    
    : ICAM1 (intercellular adhesion molecule-1)
    icam1_baseline = 0.3            : Baseline ICAM1 expression
    icam1_inflammatory_gain = 5.0   : Inflammatory induction factor
    icam1_trpv4_modulation = 0.4    : TRPV4-dependent modulation
    
    : VCAM1 (vascular cell adhesion molecule-1)
    vcam1_baseline = 0.2            : Baseline VCAM1 expression
    vcam1_inflammatory_gain = 8.0   : Inflammatory induction factor
    vcam1_trpv4_modulation = 0.5    : TRPV4-dependent modulation
    
    : E-selectin (SELE)
    sele_baseline = 0.1             : Baseline E-selectin expression
    sele_inflammatory_gain = 15.0   : Inflammatory induction factor
    sele_trpv4_modulation = 0.6     : TRPV4-dependent modulation
    
    : ================================================================
    : CYTOKINE/CHEMOKINE PARAMETERS
    : ================================================================
    : CCL2 (MCP-1)
    ccl2_baseline = 0.1             : Baseline CCL2 expression
    ccl2_nfkb_dependence = 2.0      : NFkB-dependent production
    ccl2_decay_rate = 0.0001        : CCL2 decay rate (1/ms)
    
    : CCL5 (RANTES)
    ccl5_baseline = 0.05            : Baseline CCL5 expression
    ccl5_inflammatory_gain = 3.0    : Inflammatory induction
    ccl5_decay_rate = 0.0001        : CCL5 decay rate (1/ms)
    
    : Caveolin-1 (barrier dysfunction marker)
    cav1_baseline = 0.5             : Baseline Cav1 expression
    cav1_inflammatory_gain = 10.0   : Inflammatory induction
    cav1_trpv4_dependence = 0.3     : TRPV4-dependent increase
}

ASSIGNED {
    v (mV)
    celsius (degC)
    
    : Ion concentrations
    cai (mM)
    cao (mM)
    nai (mM)
    nao (mM)
    ki (mM)
    ko (mM)
    
    : Ionic currents
    ica (mA/cm2)
    ina (mA/cm2)
    ik (mA/cm2)
    itrpv4 (mA/cm2)
    
    : Channel properties
    g_trpv4 (S/cm2)                 : TRPV4 conductance
    channel_conductance             : Single channel conductance
    
    : Activation factors
    agonist_activation              : Agonist-mediated activation
    antagonist_inhibition           : Antagonist inhibition
    inflammatory_activation         : Inflammatory mediator activation
    mechanical_activation           : Mechanical/shear stress activation
    calcium_sensitization           : Calcium-dependent sensitization
    total_activation                : Combined activation
    
    : TNFa-induced expression
    tnfa_induced_expression         : TNFa-mediated expression increase
    
    : Inflammatory state
    inflammatory_state              : Combined inflammatory signal

    
    : --- INTERMEDIATE CALCULATION VARIABLES (FIXED ERRORS) ---
    tnfa_expression_effect          : Effect of TNFa on expression
    nfkb_stimulus                   : NFkB activation driving force
    inflammatory_signal             : Sum of TNFa and ATP contributions
    agonist_effect                  : Hill equation output for agonist
    antagonist_effect               : Hill equation output for antagonist
    shear_effect                    : Output of shear stress calculation
    atp_effect                      : Placeholder (was in range, keeping here)
    ca_sensitization_factor         : Calcium modulation factor
    activation_stimulus             : Driving force for trpv4_open_prob
    cldn5_target                    : Target expression level for Claudin-5
    vecad_target                    : Target expression level for VE-Cadherin
    icam1_target                    : Target expression level for ICAM1
    vcam1_target                    : Target expression level for VCAM1
    sele_target                     : Target expression level for E-selectin
    : ----------------------------------------------------------------
}

STATE {
    : ================================================================
    : TRPV4 EXPRESSION AND ACTIVATION
    : ================================================================
    trpv4_expression                : Current TRPV4 expression level (fold of baseline)
    trpv4_open_prob                 : Channel open probability (0-1)
    
    : ================================================================
    : AUTOCRINE SIGNALING
    : ================================================================
    atp_autocrine                       
    : ================================================================
    : NFkB PATHWAY
    : ================================================================
    nfkb_active                     : Active NFkB (arbitrary units)
    
    : ================================================================
    : TIGHT JUNCTION PROTEINS
    : ================================================================
    cldn5_expression                : Claudin-5 expression level
    vecad_expression                : VE-Cadherin expression level
    
    : ================================================================
    : CELL ADHESION MOLECULES
    : ================================================================
    icam1_expression                : ICAM1 expression level
    vcam1_expression                : VCAM1 expression level
    sele_expression                 : E-selectin expression level
    
    : ================================================================
    : CYTOKINES/CHEMOKINES
    : ================================================================
    ccl2_expression                 : CCL2 expression level
    ccl5_expression                 : CCL5 expression level
    cav1_expression                 : Caveolin-1 expression level
}

INITIAL {
    : Initialize TRPV4 expression and activation
    trpv4_expression = trpv4_baseline
    trpv4_open_prob = 0
    
    : Initialize autocrine signaling
    atp_autocrine = 0
    
    : Initialize NFkB
    nfkb_active = 0
    
    : Initialize tight junction proteins (homeostatic levels)
    cldn5_expression = cldn5_baseline
    vecad_expression = vecad_baseline
    
    : Initialize cell adhesion molecules (low baseline)
    icam1_expression = icam1_baseline
    vcam1_expression = vcam1_baseline
    sele_expression = sele_baseline
    
    : Initialize cytokines/chemokines
    ccl2_expression = ccl2_baseline
    ccl5_expression = ccl5_baseline
    cav1_expression = cav1_baseline
}

BREAKPOINT {
    SOLVE dynamics METHOD derivimplicit
    
    : Calculate TRPV4 conductance
    g_trpv4 = g_trpv4_max * trpv4_expression * trpv4_open_prob
    
    : Calculate ionic currents using GHK equation
    ica = -g_trpv4 * pca_trpv4 * ghk(v, cai, cao, 2) * 1e3
    ina = -g_trpv4 * pna_trpv4 * ghk(v, nai, nao, 1) * 1e3
    ik = -g_trpv4 * pk_trpv4 * ghk(v, ki, ko, 1) * 1e3
    
    itrpv4 = ica + ina + ik
}

DERIVATIVE dynamics {
    
    : ================================================================
    : 1. TNFa-INDUCED TRPV4 EXPRESSION UPREGULATION
    : ================================================================
    if (tnfa_conc_ext > tnfa_threshold_trpv4) {
        tnfa_expression_effect = tnfa_sensitivity * (tnfa_conc_ext - tnfa_threshold_trpv4)
        tnfa_induced_expression = 1 + (max_expression_fold - 1) * (1 - exp(-tnfa_expression_effect))
    } else {
        tnfa_induced_expression = 1
    }
    
    : TRPV4 expression dynamics (slow, ~24h time scale)
    trpv4_expression' = (tnfa_induced_expression - trpv4_expression) / tau_expression
    
    : ================================================================
    : 2. AUTOCRINE ATP SIGNALING (TNFa-stimulated)
    : ================================================================
    atp_autocrine' = atp_production_rate * tnfa_conc_ext - atp_decay_rate * atp_autocrine
    
    : ================================================================
    : 3. CHANNEL ACTIVATION MECHANISMS
    : ================================================================
    
    : A. Agonist-mediated activation (GSK1016790A)
    if (agonist_conc > 0) {
        agonist_effect = pow(agonist_conc / agonist_ec50, agonist_hill)
        agonist_activation = agonist_effect / (1 + agonist_effect)
    } else {
        agonist_activation = 0
    }
    
    : B. Antagonist inhibition (GSK2193874)
    if (antagonist_conc > 0) {
        antagonist_effect = pow(antagonist_conc / antagonist_ic50, antagonist_hill)
        antagonist_inhibition = antagonist_effect / (1 + antagonist_effect)
    } else {
        antagonist_inhibition = 0
    }
    
    : C. Inflammatory mediator activation (TNFa and ATP)
    inflammatory_signal = tnfa_conc_ext * inflammatory_sensitivity + atp_autocrine * atp_sensitivity
    inflammatory_activation = inflammatory_signal / (1 + inflammatory_signal)
    
    : D. Mechanical/shear stress activation
    if (shear_stress > shear_threshold) {
        shear_effect = (shear_stress - shear_threshold) * shear_sensitivity
        mechanical_activation = shear_effect / (1 + shear_effect)
    } else {
        mechanical_activation = 0
    }
    
    : E. Calcium-dependent sensitization
    if (cai > ca_threshold_trpv4) {
        ca_sensitization_factor = 1 + pow((cai - ca_threshold_trpv4) / ca_threshold_trpv4, ca_sensitivity_trpv4)
    } else {
        ca_sensitization_factor = 1
    }
    
    : Combined activation (additive contributions, modulated by antagonist and Ca2+)
    total_activation = (agonist_activation + inflammatory_activation + mechanical_activation) * 
                       (1 - antagonist_inhibition) * ca_sensitization_factor
    
    : Limit to physiological range
    if (total_activation > 1) {
        total_activation = 1
    }
    
    : TRPV4 open probability dynamics
    activation_stimulus = (total_activation - trpv4_open_prob) / tau_activation
    trpv4_open_prob' = activation_stimulus
    
    : ================================================================
    : 4. NFkB PATHWAY ACTIVATION
    : Activated by calcium influx and receptor signaling
    : ================================================================
    if (trpv4_open_prob > nfkb_threshold || tnfa_conc_ext > tnfa_threshold_trpv4) {
        nfkb_stimulus = nfkb_activation_rate * (trpv4_open_prob + 0.1 * tnfa_conc_ext)
    } else {
        nfkb_stimulus = 0
    }
    
    nfkb_active' = nfkb_stimulus - nfkb_decay_rate * nfkb_active
    
    : ================================================================
    : 5. TIGHT JUNCTION PROTEIN REGULATION
    : Homeostatic: TRPV4 promotes junction formation
    : Inflammatory: TRPV4 activation contributes to barrier loss
    : ================================================================
    
    : Determine inflammatory state
    inflammatory_state = tnfa_conc_ext / (tnfa_conc_ext + 1)
    
    : Claudin-5 regulation
    : Baseline: promoted by TRPV4 expression (structural role)
    : Inflammatory: degraded by TRPV4 activity (calcium-dependent)
    cldn5_target = cldn5_baseline * (1 + cldn5_trpv4_dependence * trpv4_expression) * 
                   (1 - cldn5_inflammatory_loss * inflammatory_state * trpv4_open_prob)
    
    cldn5_expression' = (cldn5_target - cldn5_expression) / tau_junction_proteins
    
    : VE-Cadherin regulation (similar mechanism)
    vecad_target = vecad_baseline * (1 + vecad_trpv4_dependence * trpv4_expression) * 
                   (1 - vecad_inflammatory_loss * inflammatory_state * trpv4_open_prob)
    
    vecad_expression' = (vecad_target - vecad_expression) / tau_junction_proteins
    
    : ================================================================
    : 6. CELL ADHESION MOLECULE EXPRESSION
    : Induced by inflammation and potentiated by TRPV4 activity
    : ================================================================
    
    : ICAM1 (NFkB-dependent, TRPV4-modulated)
    icam1_target = icam1_baseline + 
                   icam1_inflammatory_gain * inflammatory_state * 
                   (1 + icam1_trpv4_modulation * trpv4_open_prob)
    
    icam1_expression' = (icam1_target - icam1_expression) / tau_adhesion_molecules
    
    : VCAM1 (strongly inflammatory and TRPV4-dependent)
    vcam1_target = vcam1_baseline + 
                   vcam1_inflammatory_gain * inflammatory_state * 
                   (1 + vcam1_trpv4_modulation * trpv4_open_prob)
    
    vcam1_expression' = (vcam1_target - vcam1_expression) / tau_adhesion_molecules
    
    : E-selectin (most sensitive to TRPV4, important for T cell migration)
    sele_target = sele_baseline + 
                  sele_inflammatory_gain * inflammatory_state * 
                  (1 + sele_trpv4_modulation * trpv4_open_prob)
    
    sele_expression' = (sele_target - sele_expression) / tau_adhesion_molecules
    
    : ================================================================
    : 7. CYTOKINE/CHEMOKINE PRODUCTION
    : NFkB-dependent, influenced by TRPV4 signaling
    : ================================================================
    
    : CCL2 (MCP-1) - NFkB-dependent
    ccl2_expression' = ccl2_baseline + ccl2_nfkb_dependence * nfkb_active - 
                       ccl2_decay_rate * ccl2_expression
    
    : CCL5 (RANTES) - inflammatory induction
    ccl5_expression' = ccl5_baseline + 
                       ccl5_inflammatory_gain * inflammatory_state * trpv4_open_prob - 
                       ccl5_decay_rate * ccl5_expression
    
    : Caveolin-1 (barrier dysfunction marker)
    cav1_expression' = (cav1_baseline + 
                        cav1_inflammatory_gain * inflammatory_state * 
                        (1 + cav1_trpv4_dependence * trpv4_open_prob) - 
                        cav1_expression) / tau_adhesion_molecules
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