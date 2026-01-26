COMMENT
================================================================================
TRPV4 Channel Model for Microglia - CORRECTED VERSION
================================================================================

Model of TRPV4 channel expression, activation, and downstream signaling in 
microglia cells. Based on multiple studies:

1. Redmon et al. (2021) - TRPV4 mediates mechanoresponse in retinal microglia
   (PMC8989051)
2. Nishimoto et al. (2021) - Thermosensitive TRPV4 mediates temperature-dependent 
   microglia movement (PNAS 118:e2012894118)
3. Kumar et al. (2023) - TRPV4-dependent neuroimmune axis in spinal cord
   (J Clin Invest 133:e161507)

CORRECTIONS in this version:
1. Fixed CCL2/CCL5 ODEs - changed from accumulator to proper relaxation equations
2. Lowered nfkb_threshold from 0.05 to 0.01 for realistic activation
3. Adjusted tau_expression for observable changes in simulation timeframe
4. Added tau_cytokines parameter for proper cytokine dynamics
5. Balanced all decay/production rates

TIME SCALING: 1 ms simulation = 1 minute real time
- Channel kinetics: 0.5-10 ms (30 sec - 10 min real)
- NFkB activation: 30-60 ms (30-60 min real)
- Junction proteins: 120-240 ms (2-4 hours real)
- Expression changes: 360-720 ms (6-12 hours real)

================================================================================
ENDCOMMENT

NEURON {
    SUFFIX TRPV4
    USEION ca READ cai, cao WRITE ica
    USEION na READ nai, nao WRITE ina
    USEION k READ ki, ko WRITE ik
    
    : Expression and activation
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
    RANGE tau_cytokines
    RANGE density_scale_mode, density_scale_factor
    RANGE scaled_g_trpv4
    
    : Sensitivity parameters
    RANGE tnfa_sensitivity, ca_sensitivity_trpv4, shear_sensitivity
    RANGE tnfa_threshold_trpv4, agonist_ec50, antagonist_ic50
    
    : Signaling parameters
    RANGE nfkb_activation_rate, nfkb_decay_rate
    RANGE junction_baseline, junction_trpv4_dependence
    RANGE adhesion_baseline, adhesion_inflammatory_gain
    RANGE cytokine_production_rate
    
    : All other range variables
    RANGE agonist_hill, antagonist_hill, atp_decay_rate, atp_production_rate
    RANGE atp_sensitivity, ca_threshold_trpv4, cav1_baseline
    RANGE cav1_inflammatory_gain, cav1_trpv4_dependence, ccl2_baseline
    RANGE ccl2_decay_rate, ccl2_nfkb_dependence, ccl5_baseline
    RANGE ccl5_decay_rate, ccl5_inflammatory_gain, cldn5_baseline
    RANGE cldn5_inflammatory_loss, cldn5_trpv4_dependence, g_trpv4_max
    RANGE icam1_baseline, icam1_inflammatory_gain, icam1_trpv4_modulation
    RANGE inflammatory_sensitivity, nfkb_threshold, sele_baseline
    RANGE sele_inflammatory_gain, sele_trpv4_modulation, shear_threshold
    RANGE vcam1_baseline, vcam1_inflammatory_gain, vcam1_trpv4_modulation
    RANGE vecad_baseline, vecad_inflammatory_loss, vecad_trpv4_dependence
    
    : Microglia-specific parameters
    RANGE microglia_activation_state
    RANGE phagocytic_activity, motility_index
    RANGE ros_production, glutamate_release
    
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
    : GEOMETRY-AWARE SCALING
    : Mode: 0=off, 1=linear(ramified), 2=sqrt(intermediate), 3=inverse(amoeboid)
    : ================================================================
    density_scale_mode = 1
    density_scale_factor = 1.0
    
    : ================================================================
    : TRPV4 EXPRESSION PARAMETERS
    : Time scaling: 1 ms = 1 min real time
    : CORRECTED: Reduced tau_expression for observable dynamics
    : ================================================================
    trpv4_baseline = 1.0            : Baseline TRPV4 expression level
    tau_expression = 480            : Expression change time constant (8h real) - was 1440
    tnfa_sensitivity = 0.8          : Sensitivity to TNFa-induced upregulation - increased
    tnfa_threshold_trpv4 = 0.5      : TNFa threshold for expression (pg/ml) - lowered
    max_expression_fold = 3.0       : Maximum fold increase
    
    : ================================================================
    : CHANNEL ACTIVATION PARAMETERS
    : Ultra-rapid activation based on Matthews et al. (2010)
    : ================================================================
    : Agonist parameters (GSK1016790A)
    agonist_conc = 0                : Agonist concentration (nM)
    agonist_ec50 = 5.0              : EC50 for agonist (nM)
    agonist_hill = 2.0              : Hill coefficient
    
    : Antagonist parameters (GSK2193874, HC-067047)
    antagonist_conc = 0             : Antagonist concentration (nM)
    antagonist_ic50 = 40.0          : IC50 for antagonist (nM)
    antagonist_hill = 1.5           : Hill coefficient
    
    : Inflammatory activation - INCREASED SENSITIVITY
    tnfa_conc_ext = 0               : External TNFa concentration (pg/ml)
    inflammatory_sensitivity = 0.5  : Sensitivity to inflammatory mediators - was 0.3
    
    : Mechanical/shear stress activation
    shear_stress = 0                : Shear stress level (dyn/cm2)
    shear_sensitivity = 0.02        : Sensitivity to shear stress
    shear_threshold = 5.0           : Threshold for shear activation
    
    : ATP autocrine signaling
    atp_production_rate = 0.02      : ATP production rate with TNFa - increased
    atp_decay_rate = 0.03           : ATP decay rate (1/ms) - reduced for longer effect
    atp_sensitivity = 0.5           : ATP-mediated TRPV4 activation - increased
    
    : Calcium-dependent sensitization
    ca_sensitivity_trpv4 = 1.5      : Calcium sensitization exponent
    ca_threshold_trpv4 = 0.0001     : Calcium threshold (mM)
    
    : Activation kinetics (fast, ms scale)
    tau_activation = 0.5            : Activation time constant (30 sec real)
    tau_deactivation = 5            : Deactivation time constant (5 min real)
    
    : ================================================================
    : CHANNEL CONDUCTANCE PARAMETERS
    : ================================================================
    g_trpv4_max = 0.0005            : Maximum TRPV4 conductance (S/cm2)
    pca_trpv4 = 10.0                : Calcium permeability (high)
    pna_trpv4 = 1.0                 : Sodium permeability
    pk_trpv4 = 0.8                  : Potassium permeability
    
    : ================================================================
    : NFkB SIGNALING PARAMETERS
    : CORRECTED: Lowered threshold for realistic activation
    : ================================================================
    nfkb_activation_rate = 0.15     : NFkB activation rate - increased
    nfkb_decay_rate = 0.008         : NFkB decay rate (1/ms) - reduced for sustained response
    nfkb_threshold = 0.01           : Threshold for NFkB activation - was 0.05
    tau_nfkb = 45                   : NFkB signaling time constant (45 min real)
    
    : ================================================================
    : TIGHT JUNCTION PROTEIN PARAMETERS
    : Claudin-5, VE-Cadherin - changes over 2-4 hours
    : ================================================================
    cldn5_baseline = 1.0
    cldn5_trpv4_dependence = 0.6
    cldn5_inflammatory_loss = 0.4   : Increased for visible effect
    tau_junction_proteins = 180     : Junction protein time constant (3h real)
    
    vecad_baseline = 1.0
    vecad_trpv4_dependence = 0.4
    vecad_inflammatory_loss = 0.3   : Increased
    
    : ================================================================
    : CELL ADHESION MOLECULE PARAMETERS
    : ICAM1, VCAM1, E-selectin - peak at 4-6 hours
    : ================================================================
    tau_adhesion_molecules = 240    : Adhesion molecule time constant (4h real) - was 300
    
    icam1_baseline = 0.3
    icam1_inflammatory_gain = 8.0   : Increased from 5.0
    icam1_trpv4_modulation = 0.5    : Increased from 0.4
    
    vcam1_baseline = 0.2
    vcam1_inflammatory_gain = 10.0  : Increased from 8.0
    vcam1_trpv4_modulation = 0.6    : Increased from 0.5
    
    sele_baseline = 0.1
    sele_inflammatory_gain = 15.0
    sele_trpv4_modulation = 0.6
    
    : ================================================================
    : CYTOKINE/CHEMOKINE PARAMETERS
    : CORRECTED: Added proper time constant, removed decay from derivative
    : ================================================================
    tau_cytokines = 120             : NEW: Cytokine response time constant (2h real)
    
    ccl2_baseline = 0.2             : Baseline CCL2
    ccl2_nfkb_dependence = 5.0      : NFkB-dependent fold increase
    ccl2_decay_rate = 0.001         : Kept for backward compatibility (not used in new ODE)
    
    ccl5_baseline = 0.1             : Baseline CCL5
    ccl5_inflammatory_gain = 4.0    : Inflammation-dependent increase
    ccl5_decay_rate = 0.001         : Kept for backward compatibility (not used in new ODE)
    
    : Caveolin-1 (barrier dysfunction marker)
    cav1_baseline = 0.5
    cav1_inflammatory_gain = 10.0
    cav1_trpv4_dependence = 0.3
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
    g_trpv4 (S/cm2)
    channel_conductance
    
    : Activation factors
    agonist_activation
    antagonist_inhibition
    inflammatory_activation
    mechanical_activation
    calcium_sensitization
    total_activation
    
    : TNFa-induced expression
    tnfa_induced_expression
    
    : Inflammatory state
    inflammatory_state
    
    : Intermediate calculation variables
    tnfa_expression_effect
    nfkb_stimulus
    inflammatory_signal
    agonist_effect
    antagonist_effect
    shear_effect
    atp_effect
    ca_sensitization_factor
    activation_stimulus
    cldn5_target
    vecad_target
    icam1_target
    vcam1_target
    sele_target
    ccl2_target
    ccl5_target
    
    : Geometry
    diam (um)
    scaled_g_trpv4 (S/cm2)
    geometry_scale
    
    : Microglia-specific outputs
    microglia_activation_state
    phagocytic_activity
    motility_index
    ros_production
    glutamate_release
}

STATE {
    : TRPV4 expression and activation
    trpv4_expression
    trpv4_open_prob
    
    : Autocrine signaling
    atp_autocrine
    
    : NFkB pathway
    nfkb_active
    
    : Tight junction proteins
    cldn5_expression
    vecad_expression
    
    : Cell adhesion molecules
    icam1_expression
    vcam1_expression
    sele_expression
    
    : Cytokines/chemokines
    ccl2_expression
    ccl5_expression
    cav1_expression
}

INITIAL {
    : Initialize TRPV4 expression and activation
    trpv4_expression = trpv4_baseline
    trpv4_open_prob = 0
    
    : Initialize autocrine signaling
    atp_autocrine = 0
    
    : Initialize NFkB
    nfkb_active = 0
    
    : Initialize tight junction proteins
    cldn5_expression = cldn5_baseline
    vecad_expression = vecad_baseline
    
    : Initialize cell adhesion molecules
    icam1_expression = icam1_baseline
    vcam1_expression = vcam1_baseline
    sele_expression = sele_baseline
    
    : Initialize cytokines/chemokines
    ccl2_expression = ccl2_baseline
    ccl5_expression = ccl5_baseline
    cav1_expression = cav1_baseline
    
    : Calculate geometry scaling
    if (diam > 0) {
        geometry_scale = calculate_geometry_scale(diam, density_scale_mode, density_scale_factor)
    } else {
        geometry_scale = 1.0
    }
    scaled_g_trpv4 = g_trpv4_max * geometry_scale
    
    : Initialize microglia-specific outputs
    microglia_activation_state = 0
    phagocytic_activity = 0.1
    motility_index = 1.0
    ros_production = 0
    glutamate_release = 0
}

BREAKPOINT {
    SOLVE dynamics METHOD derivimplicit
    
    : Calculate TRPV4 conductance with geometry scaling
    g_trpv4 = scaled_g_trpv4 * trpv4_expression * trpv4_open_prob
    
    : Calculate ionic currents using GHK equation
    ica = -g_trpv4 * pca_trpv4 * ghk(v, cai, cao, 2) * 1e3
    ina = -g_trpv4 * pna_trpv4 * ghk(v, nai, nao, 1) * 1e3
    ik = -g_trpv4 * pk_trpv4 * ghk(v, ki, ko, 1) * 1e3
    
    itrpv4 = ica + ina + ik
    
    : Update microglia-specific outputs
    microglia_activation_state = (nfkb_active + inflammatory_activation) / 2
    phagocytic_activity = 0.1 + 0.9 * microglia_activation_state
    motility_index = 1.0 + 2.0 * trpv4_open_prob
    ros_production = nfkb_active * 0.5
    glutamate_release = trpv4_open_prob * cai * 1000
}

DERIVATIVE dynamics {
    LOCAL tau_open
    
    : ================================================================
    : 1. TNFa-INDUCED TRPV4 EXPRESSION UPREGULATION
    : ================================================================
    if (tnfa_conc_ext > tnfa_threshold_trpv4) {
        tnfa_expression_effect = tnfa_sensitivity * (tnfa_conc_ext - tnfa_threshold_trpv4)
        tnfa_induced_expression = 1 + (max_expression_fold - 1) * (1 - exp(-tnfa_expression_effect))
    } else {
        tnfa_induced_expression = 1
    }
    
    trpv4_expression' = (tnfa_induced_expression - trpv4_expression) / tau_expression
    
    : ================================================================
    : 2. AUTOCRINE ATP SIGNALING
    : CORRECTED: Proper relaxation dynamics
    : ================================================================
    atp_autocrine' = (atp_production_rate * tnfa_conc_ext - atp_autocrine) / 10
    
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
    
    : C. Inflammatory mediator activation
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
    
    : Combined activation
    total_activation = (agonist_activation + inflammatory_activation + mechanical_activation) * 
                       (1 - antagonist_inhibition) * ca_sensitization_factor
    
    if (total_activation > 1) {
        total_activation = 1
    }
    
    : Dynamic tau based on activation/deactivation
    if (total_activation > trpv4_open_prob) {
        tau_open = tau_activation
    } else {
        tau_open = tau_deactivation
    }
    
    trpv4_open_prob' = (total_activation - trpv4_open_prob) / tau_open
    
    : ================================================================
    : 4. NFkB PATHWAY ACTIVATION
    : CORRECTED: Lower threshold, better sustained response
    : ================================================================
    : NFkB activates from BOTH TRPV4 opening AND direct TNFa signaling
    nfkb_stimulus = nfkb_activation_rate * (trpv4_open_prob + 0.2 * tnfa_conc_ext)
    
    : Relaxation ODE toward stimulus-dependent steady state
    nfkb_active' = (nfkb_stimulus - nfkb_active) / tau_nfkb
    
    : ================================================================
    : 5. TIGHT JUNCTION PROTEIN REGULATION
    : ================================================================
    inflammatory_state = tnfa_conc_ext / (tnfa_conc_ext + 1)
    
    cldn5_target = cldn5_baseline * (1 + cldn5_trpv4_dependence * (trpv4_expression - 1)) * 
                   (1 - cldn5_inflammatory_loss * inflammatory_state * (1 + trpv4_open_prob))
    
    : Ensure cldn5 doesn't go negative
    if (cldn5_target < 0.1) {
        cldn5_target = 0.1
    }
    
    cldn5_expression' = (cldn5_target - cldn5_expression) / tau_junction_proteins
    
    vecad_target = vecad_baseline * (1 + vecad_trpv4_dependence * (trpv4_expression - 1)) * 
                   (1 - vecad_inflammatory_loss * inflammatory_state * (1 + trpv4_open_prob))
    
    if (vecad_target < 0.1) {
        vecad_target = 0.1
    }
    
    vecad_expression' = (vecad_target - vecad_expression) / tau_junction_proteins
    
    : ================================================================
    : 6. CELL ADHESION MOLECULE EXPRESSION
    : ================================================================
    icam1_target = icam1_baseline + 
                   icam1_inflammatory_gain * inflammatory_state * 
                   (1 + icam1_trpv4_modulation * trpv4_open_prob)
    
    icam1_expression' = (icam1_target - icam1_expression) / tau_adhesion_molecules
    
    vcam1_target = vcam1_baseline + 
                   vcam1_inflammatory_gain * inflammatory_state * 
                   (1 + vcam1_trpv4_modulation * trpv4_open_prob)
    
    vcam1_expression' = (vcam1_target - vcam1_expression) / tau_adhesion_molecules
    
    sele_target = sele_baseline + 
                  sele_inflammatory_gain * inflammatory_state * 
                  (1 + sele_trpv4_modulation * trpv4_open_prob)
    
    sele_expression' = (sele_target - sele_expression) / tau_adhesion_molecules
    
    : ================================================================
    : 7. CYTOKINE/CHEMOKINE PRODUCTION
    : CORRECTED: Proper relaxation ODEs instead of accumulators
    : ================================================================
    
    : CCL2 (MCP-1): NFkB-dependent production
    : Target = baseline * (1 + NFkB-dependent fold increase)
    ccl2_target = ccl2_baseline * (1 + ccl2_nfkb_dependence * nfkb_active)
    ccl2_expression' = (ccl2_target - ccl2_expression) / tau_cytokines
    
    : CCL5 (RANTES): Inflammation and TRPV4-dependent
    ccl5_target = ccl5_baseline * (1 + ccl5_inflammatory_gain * inflammatory_state * (1 + trpv4_open_prob))
    ccl5_expression' = (ccl5_target - ccl5_expression) / tau_cytokines
    
    : Caveolin-1
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

FUNCTION calculate_geometry_scale(diameter, mode, factor) (1) {
    LOCAL scale_ratio, scaling
    
    if (diameter <= 0) {
        diameter = 1.0
    }
    
    : Different scaling modes for different microglia morphologies:
    : Mode 1: Linear - for ramified microglia (larger surface area = more channels)
    : Mode 2: Square root - intermediate scaling
    : Mode 3: Inverse - for amoeboid microglia (smaller, concentrated channels)
    
    if (mode == 0) {
        calculate_geometry_scale = 1.0
    } else if (mode == 1) {
        : Ramified microglia: scale with surface area
        scale_ratio = diameter / 0.5  : normalized to 0.5um reference
        scaling = scale_ratio * factor
        if (scaling < 0.1) {
            scaling = 0.1
        }
        if (scaling > 3.0) {
            scaling = 3.0
        }
        calculate_geometry_scale = scaling
    } else if (mode == 2) {
        : Intermediate: sqrt scaling
        scale_ratio = sqrt(diameter / 0.5)
        scaling = scale_ratio * factor
        if (scaling < 0.1) {
            scaling = 0.1
        }
        if (scaling > 3.0) {
            scaling = 3.0
        }
        calculate_geometry_scale = scaling
    } else if (mode == 3) {
        : Amoeboid: inverse relationship (smaller soma, more concentrated)
        scale_ratio = 0.5 / diameter
        scaling = scale_ratio * factor
        if (scaling < 0.1) {
            scaling = 0.1
        }
        if (scaling > 3.0) {
            scaling = 3.0
        }
        calculate_geometry_scale = scaling
    } else {
        calculate_geometry_scale = 1.0
    }
}
