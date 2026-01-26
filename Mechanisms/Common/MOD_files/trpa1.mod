COMMENT
================================================================================
TRPA1 Channel Model for Microglia - Literature-Based Implementation
================================================================================

Comprehensive model of TRPA1 channel in microglia based on:

1. Zurborg et al. (2007) JBC - Direct Ca2+ gating of TRPA1 (EC50 ~905 nM)
2. Wang et al. (2008) JBC - Ca2+-dependent potentiation and inactivation
3. Jordt et al. (2004) Nature - Electrophile activation via cysteine modification
4. Hinman et al. (2006) PNAS - Covalent modification mechanism
5. Chen et al. (2011) PLOS One - Single channel conductance (~100-150 pS)
6. Karashima et al. (2010) J Physiol - Calcium permeability (PCa/PNa ~6-8)
7. De Logu et al. (2017) Nat Commun - TRPA1/NOX1 ROS feedback in glia
8. Lee et al. (2016) J Neuroinflammation - TRPA1 in Alzheimer's/microglia
9. Santos et al. (2023) Biochem Biophys Res - TRPA1 in BV-2 microglia

Key Features:
1. Literature-based channel biophysics (conductance, permeability)
2. Ca2+-dependent potentiation with subsequent inactivation
3. ROS/oxidative stress activation via cysteine modification
4. NF-kB signaling pathway
5. Cytokine production (TNF-a, IL-1b, IL-6)
6. Microglial activation state modulation
7. ROS production feedback loop
8. Geometry-dependent scaling for ramified vs amoeboid states

TIME SCALING: 1 ms simulation = 1 minute real time
================================================================================
ENDCOMMENT

NEURON {
    SUFFIX trpa1
    USEION ca READ cai, cao WRITE ica
    USEION na READ nai, nao WRITE ina
    USEION k READ ki, ko WRITE ik
    
    : Channel biophysics
    RANGE g, itrpa1
    RANGE pca, pna, pk
    RANGE single_channel_cond
    
    : Channel states
    RANGE open_prob, potentiation, inactivation
    RANGE activation_gate, ca_modulation
    
    : External stimuli
    RANGE oxidative_stress, ros_conc
    RANGE agonist_conc, antagonist_conc
    RANGE h2o2_conc, hne_conc, lps_conc
    
    : Sensitivity parameters
    RANGE agonist_ec50, agonist_hill
    RANGE antagonist_ic50, antagonist_hill
    RANGE ca_ec50_pot, ca_ec50_inact
    RANGE oxidative_sens, ros_threshold
    
    : Kinetic parameters
    RANGE tau_activation, tau_deactivation
    RANGE tau_potentiation, tau_inactivation
    RANGE tau_recovery
    
    : Downstream signaling - NF-kB pathway
    RANGE nfkb_active, nfkb_act_rate, nfkb_decay
    RANGE nfkb_threshold, tau_nfkb
    
    : Cytokine/chemokine production
    RANGE tnfa_production, il1b_production, il6_production
    RANGE ccl2_production, ros_release
    RANGE tnfa_baseline, il1b_baseline, il6_baseline
    RANGE ccl2_baseline
    RANGE cytokine_nfkb_dep, cytokine_decay, tau_cytokines
    
    : Microglia-specific outputs
    RANGE microglia_state
    RANGE phagocytic, motility
    RANGE m1_polar, m2_polar
    
    : Geometry scaling
    RANGE density_scale_mode, density_scale_factor
    RANGE scaled_g
    
    : Expression regulation
    RANGE trpa1_expression, trpa1_baseline
    RANGE expression_ros_sens, tau_expression
    
    : Legacy parameters for compatibility
    RANGE basal_open_prob, max_open_prob
    RANGE tau_desens
    RANGE tau_rise_spotty, tau_decay_spotty
    RANGE spotty_frequency, spotty_amplitude_max, spotty_ca_scale
    RANGE agonist_sensitivity, blocker_sensitivity
    RANGE oxidative_sensitivity, temp_sensitivity, temp_coefficient
    RANGE spotty_amplitude, constitutive_activity
    RANGE ca_modulation_strength
    
    NONSPECIFIC_CURRENT itrpa1
}

UNITS {
    (mV) = (millivolt)
    (mA) = (milliamp)
    (mM) = (milli/liter)
    (uM) = (micro/liter)
    (nM) = (nano/liter)
    (S) = (siemens)
    (pS) = (picosiemens)
    F = (faraday) (coulombs)
    R = (k-mole) (joule/degC)
}

PARAMETER {
    : ================================================================
    : CHANNEL BIOPHYSICS - Literature-based values
    : ================================================================
    : Single channel conductance: 100-150 pS (Chen et al., 2011)
    single_channel_cond = 120 (pS)
    
    : Maximum conductance density (settable from HOC as g_trpa1)
    g = 0.0002 (S/cm2)
    
    : Ion permeabilities - Karashima et al. (2010)
    : PCa/PNa = 5.9-7.9, fractional Ca2+ current ~23%
    pca = 6.5
    pna = 1.0
    pk = 0.9
    
    : ================================================================
    : ACTIVATION KINETICS
    : ================================================================
    tau_activation = 0.5
    tau_deactivation = 5
    
    : ================================================================
    : CALCIUM MODULATION - Zurborg et al. (2007) JBC
    : EC50 for Ca2+ = 905 +/- 249 nM, Hill coefficient ~0.9
    : ================================================================
    ca_ec50_pot = 0.0009
    ca_ec50_inact = 0.005
    tau_potentiation = 0.3
    tau_inactivation = 10
    tau_recovery = 60
    
    : ================================================================
    : AGONIST/ANTAGONIST PHARMACOLOGY
    : ================================================================
    : AITC EC50 ~65 uM (Jordt et al., 2004)
    : HC-030031 IC50 ~6 uM
    agonist_conc = 0
    agonist_ec50 = 65.0
    agonist_hill = 1.8
    
    antagonist_conc = 0
    antagonist_ic50 = 6.0
    antagonist_hill = 1.5
    
    : ================================================================
    : OXIDATIVE STRESS / ROS ACTIVATION
    : CORRECTED: Lowered ros_threshold
    : ================================================================
    oxidative_stress = 0
    ros_conc = 0
    h2o2_conc = 0
    hne_conc = 0
    lps_conc = 0
    
    oxidative_sens = 3.0          : Increased sensitivity
    ros_threshold = 0.01          : Lowered from 0.1
    
    : ================================================================
    : EXPRESSION REGULATION
    : ================================================================
    trpa1_baseline = 1.0
    expression_ros_sens = 0.5
    tau_expression = 720
    
    : ================================================================
    : NF-kB SIGNALING PATHWAY
    : CORRECTED: Lowered thresholds for realistic activation
    : ================================================================
    nfkb_act_rate = 0.15
    nfkb_decay = 0.008
    nfkb_threshold = 0.0002      : 200 nM - was 0.05 mM (50,000 nM)!
    tau_nfkb = 45
    
    : ================================================================
    : CYTOKINE PRODUCTION
    : CORRECTED: Added tau_cytokines, adjusted parameters
    : ================================================================
    tnfa_baseline = 0.2
    il1b_baseline = 0.2
    il6_baseline = 0.1
    ccl2_baseline = 0.2
    cytokine_nfkb_dep = 5.0       : NFkB-dependent fold increase
    cytokine_decay = 0.01         : Kept for backward compatibility
    tau_cytokines = 120           : NEW: Cytokine time constant (2h real)
    
    : ================================================================
    : GEOMETRY SCALING
    : ================================================================
    density_scale_mode = 1
    density_scale_factor = 1.0
    
    : ================================================================
    : LEGACY PARAMETERS (for backward compatibility)
    : ================================================================
    basal_open_prob = 0.05
    max_open_prob = 0.5
    tau_desens = 2000
    tau_rise_spotty = 100
    tau_decay_spotty = 500
    spotty_frequency = 0.49
    spotty_amplitude_max = 2.0
    spotty_ca_scale = 0.0001
    agonist_sensitivity = 2.0
    blocker_sensitivity = 5.0
    oxidative_sensitivity = 1.5
    temp_sensitivity = 0.03
    temp_coefficient = 2.5
    ca_modulation_strength = 0.0
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
    
    : Currents
    ica (mA/cm2)
    ina (mA/cm2)
    ik (mA/cm2)
    itrpa1 (mA/cm2)
    
    : Channel conductance
    g_eff (S/cm2)
    scaled_g (S/cm2)
    
    : Intermediate calculations
    agonist_activation
    antagonist_inhibition
    oxidative_activation
    total_stimulus
    ca_pot_factor
    ca_inact_factor
    ca_modulation
    nfkb_stimulus
    tnfa_target
    il1b_target
    il6_target
    ccl2_target
    
    : Geometry
    diam (um)
    geometry_scale
    
    : Microglia outputs
    microglia_state
    phagocytic
    motility
    m1_polar
    m2_polar
    
    : Legacy outputs
    spotty_amplitude
    constitutive_activity
}

STATE {
    : Channel gating states
    activation_gate
    potentiation
    inactivation
    open_prob
    
    : Expression
    trpa1_expression
    
    : NF-kB pathway
    nfkb_active
    
    : Cytokine production
    tnfa_production
    il1b_production
    il6_production
    ccl2_production
    ros_release
    
    : Legacy state
    spotty_state
}

INITIAL {
    : Initialize channel states
    activation_gate = basal_open_prob
    potentiation = 0
    inactivation = 0
    open_prob = basal_open_prob
    
    : Initialize expression
    trpa1_expression = trpa1_baseline
    
    : Initialize NF-kB
    nfkb_active = 0
    
    : Initialize cytokines
    tnfa_production = tnfa_baseline
    il1b_production = il1b_baseline
    il6_production = il6_baseline
    ccl2_production = ccl2_baseline
    ros_release = 0
    
    : Legacy state
    spotty_state = 0
    
    : Calculate geometry scaling
    if (diam > 0) {
        geometry_scale = calc_geom_scale(diam, density_scale_mode, density_scale_factor)
    } else {
        geometry_scale = 1.0
    }
    scaled_g = g * geometry_scale
    
    : Initialize outputs
    microglia_state = 0
    phagocytic = 0.1
    motility = 1.0
    m1_polar = 0
    m2_polar = 1.0
    spotty_amplitude = 0
    constitutive_activity = basal_open_prob
}

BREAKPOINT {
    SOLVE dynamics METHOD cnexp
    
    : Calculate effective conductance
    g_eff = scaled_g * trpa1_expression * open_prob
    
    : Calculate ionic currents using GHK equation
    ica = -g_eff * pca * ghk(v, cai, cao, 2) * 1e3
    ina = -g_eff * pna * ghk(v, nai, nao, 1) * 1e3
    ik = -g_eff * pk * ghk(v, ki, ko, 1) * 1e3
    
    itrpa1 = ica + ina + ik
    
    : Update microglia-specific outputs
    microglia_state = (nfkb_active + oxidative_activation) / 2
    phagocytic = 0.1 + 0.9 * microglia_state
    motility = 1.0 + 2.0 * open_prob
    
    : M1/M2 polarization
    m1_polar = microglia_state
    m2_polar = 1.0 - 0.8 * microglia_state
    
    : Legacy outputs
    constitutive_activity = activation_gate * (1 - inactivation)
    spotty_amplitude = spotty_state
}

DERIVATIVE dynamics {
    LOCAL tau_gate, agonist_effect, antagonist_effect, oxidative_effect, lps_effect, h2o2_effect, hne_effect, ca_pot_ss, ca_inact_ss, expression_target, spotty_freq_hz, spotty_drive, temp_factor
    
    : Temperature factor
    temp_factor = temp_coefficient * exp((celsius - 23) / 10 * 0.1)
    
    : ================================================================
    : 1. AGONIST ACTIVATION (AITC, cinnamaldehyde, etc.)
    : ================================================================
    if (agonist_conc > 0) {
        agonist_effect = pow(agonist_conc / agonist_ec50, agonist_hill)
        agonist_activation = agonist_effect / (1 + agonist_effect)
    } else {
        agonist_activation = 0
    }
    
    : ================================================================
    : 2. ANTAGONIST INHIBITION (HC-030031, A-967079)
    : ================================================================
    if (antagonist_conc > 0) {
        antagonist_effect = pow(antagonist_conc / antagonist_ic50, antagonist_hill)
        antagonist_inhibition = antagonist_effect / (1 + antagonist_effect)
    } else {
        antagonist_inhibition = 0
    }
    
    : ================================================================
    : 3. OXIDATIVE STRESS ACTIVATION
    : ================================================================
    h2o2_effect = h2o2_conc / (h2o2_conc + 100)
    hne_effect = hne_conc / (hne_conc + 10)
    lps_effect = lps_conc / (lps_conc + 10)
    
    oxidative_effect = oxidative_stress * oxidative_sens
    if (oxidative_effect > 1) {
        oxidative_effect = 1
    }
    
    oxidative_activation = oxidative_effect + h2o2_effect + hne_effect + lps_effect
    if (oxidative_activation > 1) {
        oxidative_activation = 1
    }
    
    : ================================================================
    : 4. TOTAL STIMULUS
    : ================================================================
    total_stimulus = (agonist_activation + oxidative_activation) * (1 - antagonist_inhibition) * temp_factor
    if (total_stimulus > 1) {
        total_stimulus = 1
    }
    if (total_stimulus < basal_open_prob) {
        total_stimulus = basal_open_prob
    }
    
    : ================================================================
    : 5. ACTIVATION GATE DYNAMICS
    : ================================================================
    if (total_stimulus > activation_gate) {
        tau_gate = tau_activation
    } else {
        tau_gate = tau_deactivation
    }
    
    activation_gate' = (total_stimulus - activation_gate) / tau_gate
    
    : ================================================================
    : 6. CALCIUM-DEPENDENT POTENTIATION
    : ================================================================
    ca_pot_ss = pow(cai / ca_ec50_pot, 0.9)
    ca_pot_ss = ca_pot_ss / (1 + ca_pot_ss)
    
    potentiation' = (ca_pot_ss - potentiation) / tau_potentiation
    
    : ================================================================
    : 7. CALCIUM-DEPENDENT INACTIVATION
    : ================================================================
    ca_inact_ss = pow(cai / ca_ec50_inact, 1.5)
    ca_inact_ss = ca_inact_ss / (1 + ca_inact_ss)
    
    inactivation' = (ca_inact_ss - inactivation) / tau_inactivation
    
    : ================================================================
    : 8. CALCULATE OPEN PROBABILITY
    : ================================================================
    ca_pot_factor = 1 + 2.0 * potentiation
    ca_inact_factor = 1 - 0.9 * inactivation
    
    ca_modulation = ca_pot_factor * ca_inact_factor
    
    open_prob' = (activation_gate * ca_modulation - open_prob) / tau_activation
    
    : Clamp open probability
    if (open_prob > max_open_prob) {
        open_prob = max_open_prob
    }
    if (open_prob < 0) {
        open_prob = 0
    }
    
    : ================================================================
    : 9. EXPRESSION REGULATION
    : ================================================================
    expression_target = trpa1_baseline * (1 + expression_ros_sens * oxidative_activation)
    trpa1_expression' = (expression_target - trpa1_expression) / tau_expression
    
    : ================================================================
    : 10. NF-kB PATHWAY ACTIVATION
    : CORRECTED: Using relaxation ODE, lowered threshold
    : ================================================================
    : NFkB activates from both calcium and oxidative stress
    nfkb_stimulus = nfkb_act_rate * (open_prob + 0.5 * oxidative_activation)
    
    : Relaxation ODE toward stimulus-dependent steady state
    nfkb_active' = (nfkb_stimulus - nfkb_active) / tau_nfkb
    
    : ================================================================
    : 11. CYTOKINE PRODUCTION
    : CORRECTED: Using proper relaxation ODEs instead of accumulators
    : ================================================================
    : TNF-alpha: NFkB-dependent production
    tnfa_target = tnfa_baseline * (1 + cytokine_nfkb_dep * nfkb_active)
    tnfa_production' = (tnfa_target - tnfa_production) / tau_cytokines
    
    : IL-1beta: NFkB-dependent with slightly higher sensitivity
    il1b_target = il1b_baseline * (1 + cytokine_nfkb_dep * nfkb_active * 1.2)
    il1b_production' = (il1b_target - il1b_production) / tau_cytokines
    
    : IL-6: NFkB-dependent with lower sensitivity
    il6_target = il6_baseline * (1 + cytokine_nfkb_dep * nfkb_active * 0.8)
    il6_production' = (il6_target - il6_production) / tau_cytokines
    
    : CCL2: NFkB-dependent chemokine
    ccl2_target = ccl2_baseline * (1 + cytokine_nfkb_dep * nfkb_active)
    ccl2_production' = (ccl2_target - ccl2_production) / tau_cytokines
    
    : ================================================================
    : 12. ROS RELEASE FEEDBACK
    : ================================================================
    ros_release' = 0.05 * open_prob * nfkb_active - 0.02 * ros_release
    
    : ================================================================
    : 13. LEGACY SPOTTY SIGNAL (for backward compatibility)
    : ================================================================
    spotty_freq_hz = spotty_frequency / 60
    
    if (antagonist_inhibition < 0.5) {
        spotty_drive = spotty_freq_hz * 0.1
        spotty_state' = spotty_drive * (1 - spotty_state) / tau_rise_spotty - spotty_state / tau_decay_spotty
    } else {
        spotty_state' = -spotty_state / tau_decay_spotty
    }
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

FUNCTION calc_geom_scale(diameter, mode, factor) (1) {
    LOCAL scale_ratio, scaling
    
    if (diameter <= 0) {
        diameter = 1.0
    }
    
    if (mode == 0) {
        calc_geom_scale = 1.0
    } else if (mode == 1) {
        scale_ratio = diameter / 0.5
        scaling = scale_ratio * factor
        if (scaling < 0.1) {
            scaling = 0.1
        }
        if (scaling > 3.0) {
            scaling = 3.0
        }
        calc_geom_scale = scaling
    } else if (mode == 2) {
        scale_ratio = sqrt(diameter / 0.5)
        scaling = scale_ratio * factor
        calc_geom_scale = scaling
    } else if (mode == 3) {
        scale_ratio = 0.5 / diameter
        scaling = scale_ratio * factor
        if (scaling > 3.0) {
            scaling = 3.0
        }
        calc_geom_scale = scaling
    } else {
        calc_geom_scale = 1.0
    }
}
