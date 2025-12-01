TITLE TRPA1 Channel in Astrocytes - Calcium Dynamics Model
:
: Based on Shigetomi et al., 2012, Nature Neuroscience
: "TRPA1 channels regulate astrocyte resting calcium and inhibitory synapse efficacy through GAT-3"
:
: This model represents:
: 1. Constitutive/basal TRPA1 activity
: 2. Ca2+ influx through TRPA1 channels
: 3. Spotty Ca2+ transient generation
: 4. Response to agonists (e.g., AITC, oxidative stress)
: 5. Pharmacological blockade (e.g., HC030031)


NEURON {
    SUFFIX trpa1
    USEION ca READ cai, cao WRITE ica
    USEION na READ nai, nao WRITE ina
    USEION k READ ki, ko WRITE ik
    RANGE g, ica, ina, ik
    RANGE ca_basal, ca_transient, ca_total
    RANGE constitutive_activity, agonist_level, blocker_level
    RANGE spotty_frequency, spotty_amplitude
    RANGE open_probability, desensitization
    RANGE oxidative_stress, agonist_conc, antagonist_conc
    RANGE pca, pna, pk
    RANGE tau_activation, tau_deactivation, tau_desens
    RANGE tau_rise_spotty, tau_decay_spotty
    RANGE basal_open_prob, spotty_frequency
    RANGE agonist_sensitivity, blocker_sensitivity
    RANGE oxidative_sensitivity, temp_sensitivity
    RANGE max_open_prob, spotty_amplitude_max, temp_coefficient
    RANGE spotty_ca_scale
}

UNITS {
    (mV) = (millivolt)
    (mA) = (milliamp)
    (mM) = (milli/liter)
    (S)  = (siemens)
    (pS) = (picosiemens)
    FARADAY = 96485 (coulombs)
    R = 8.314 (joule/kelvin)
}

PARAMETER {
    : Channel conductance (from Shigetomi 2012: ~70 pS single channel)
    g = 0.0001 (S/cm2)    : Total conductance density
    
    : Relative permeabilities (non-selective cation channel)
    pca = 1.0                    : Ca2+ permeability (normalized)
    pna = 0.1                    : Na+ permeability relative to Ca2+
    pk  = 0.08                   : K+ permeability relative to Ca2+
    
    : Constitutive/basal activity parameters
    basal_open_prob = 0.05       : Baseline open probability (~5%)
    max_open_prob = 0.8          : Maximum open probability with agonist
    
    : Temporal dynamics (from literature time-course data)
    tau_activation = 50 (ms)     : Activation time constant
    tau_deactivation = 200 (ms)  : Deactivation time constant
    tau_desens = 2000 (ms)       : Slow desensitization (minimal for TRPA1)
    
    : Spotty Ca2+ signal parameters (Shigetomi 2012, Figure 1)
    tau_rise_spotty = 100 (ms)   : Rise time of spotty signals
    tau_decay_spotty = 500 (ms)  : Decay time of spotty signals
    spotty_frequency = 0.49      : Baseline frequency (events/min)
    spotty_amplitude_max = 2.0   : Maximum dF/F amplitude
    spotty_ca_scale = 0.0001     : Scaling factor for spotty signal to Ca2+ concentration (mM)
    
    : Sensitivity parameters
    agonist_sensitivity = 2.0    : Sensitivity to agonists (AITC, 4-HNE, H2O2)
    blocker_sensitivity = 5.0    : Sensitivity to blockers (HC030031)
    oxidative_sensitivity = 1.5  : Sensitivity to oxidative stress
    temp_sensitivity = 0.03      : Temperature sensitivity (per degC above threshold)
    
    : External modulators (set by HOC)
    oxidative_stress = 0         : Oxidative stress level (0-1)
    agonist_conc = 0             : Agonist concentration (uM)
    antagonist_conc = 0          : Antagonist concentration (uM)
    
    : Temperature sensitivity (Q10 = 2-3 for most ion channels)
    temp_coefficient = 2.5       : Q10 value for temperature dependence
    
    : Desensitization note: TRPA1 shows minimal desensitization in sustained
    : oxidative stress (unlike TRPV1), hence the weak desensitization (10% max)
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
    
    : Channel states
    open_probability
    constitutive_activity
    
    : Calcium dynamics
    ca_basal (mM)
    ca_transient (mM)
    ca_total (mM)
    
    : Spotty signal tracking
    spotty_amplitude
    
    : Temperature factor
    temp_factor
}

STATE {
    : Channel gating
    O           : Open state fraction
    D           : Desensitized state fraction
    
    : Agonist/blocker state variables
    agonist_level      : Agonist concentration effect (0-1)
    blocker_level      : Blocker concentration effect (0-1)
    
    : Spotty Ca2+ signal generator (simple oscillator)
    spotty_state       : State variable for spontaneous transients
}

INITIAL {
    : Initialize states
    O = basal_open_prob
    D = 0
    agonist_level = 0
    blocker_level = 0
    spotty_state = 0
    
    : Initialize calcium
    ca_basal = 0.00007  : ~70 nM baseline (from Shigetomi 2012)
    ca_transient = 0
    ca_total = ca_basal
    
    : Temperature factor using NEURON's celsius
    temp_factor = temp_coefficient^((celsius - 23)/10)
    
    : Initial values
    open_probability = basal_open_prob
    constitutive_activity = basal_open_prob
    spotty_amplitude = 0
}

BREAKPOINT {
    SOLVE states METHOD cnexp
    
    : Update temperature factor dynamically
    temp_factor = temp_coefficient^((celsius - 23)/10)
    
    : Calculate effective open probability
    : Includes constitutive activity, agonist response, and blocker inhibition
    open_probability = (O * (1 - D) * (1 - blocker_level) + 
                       agonist_level * (max_open_prob - basal_open_prob)) * temp_factor
    
    : Limit to valid range
    if (open_probability > max_open_prob) {
        open_probability = max_open_prob
    }
    if (open_probability < 0) {
        open_probability = 0
    }
    
    : Calculate total calcium with explicit scaling parameter
    ca_total = ca_basal + ca_transient + spotty_state * spotty_amplitude_max * spotty_ca_scale
    
    : Calculate ionic currents through TRPA1 using GHK equation
    ica = g * open_probability * pca * ghk(v, cai, cao, 2)
    ina = g * open_probability * pna * ghk(v, nai, nao, 1)
    ik  = g * open_probability * pk * ghk(v, ki, ko, 1)
    
    : Update constitutive activity for monitoring
    constitutive_activity = O * (1 - D)
    
    : Update spotty amplitude for recording
    spotty_amplitude = spotty_state
}

DERIVATIVE states {
    LOCAL spotty_freq_hz, spotty_drive
    
    : Basal open state - constitutive activity
    : Influenced by oxidative stress and agonists
    O' = (basal_open_prob * (1 + oxidative_stress * oxidative_sensitivity + 
                                    agonist_conc * agonist_sensitivity * 0.01) - O) / tau_deactivation
    
    : Slow desensitization - minimal for TRPA1
    : At steady state: D = 0.1 * O (10% maximum desensitization)
    : This reflects sustained TRPA1 responses observed in literature
    D' = (0.1 * O - D) / tau_desens
    
    : Agonist level dynamics (driven by oxidative stress and agonist concentration)
    agonist_level' = ((agonist_conc * agonist_sensitivity * 0.01 + 
                      oxidative_stress * oxidative_sensitivity) - agonist_level) / tau_activation
    
    : Blocker level dynamics (driven by antagonist concentration)
    blocker_level' = (antagonist_conc * blocker_sensitivity * 0.01 - blocker_level) / tau_deactivation
    
    : Simplified spotty Ca2+ signal generator
    : Uses continuous oscillator approximation (deterministic)
    : Frequency from Shigetomi 2012: ~0.49 events/min = 0.0082 Hz
    spotty_freq_hz = spotty_frequency / 60  : Convert events/min to events/sec
    
    : Oscillator with spontaneous activation when blocker is low
    if (blocker_level < 0.5) {
        : Drive term proportional to frequency
        spotty_drive = spotty_freq_hz * 0.1
        spotty_state' = spotty_drive * (1 - spotty_state) / tau_rise_spotty - spotty_state / tau_decay_spotty
    } else {
        : Decay only when blocked
        spotty_state' = -spotty_state / tau_decay_spotty
    }
}

PROCEDURE apply_agonist(level) {
    : Apply TRPA1 agonist (AITC, 4-HNE, H2O2, etc.)
    : level: 0-1, where 1 = maximal agonist concentration
    agonist_level = agonist_level + level * agonist_sensitivity
    if (agonist_level > 1) {
        agonist_level = 1
    }
}

PROCEDURE apply_blocker(level) {
    : Apply TRPA1 blocker (HC030031, etc.)
    : level: 0-1, where 1 = complete block
    blocker_level = blocker_level + level * blocker_sensitivity
    if (blocker_level > 1) {
        blocker_level = 1
    }
}

PROCEDURE set_spotty_frequency(freq) {
    : Set the frequency of spotty Ca2+ events (events/min)
    : From Shigetomi 2012: control = 0.49, blocked = 0.025 events/min
    spotty_frequency = freq
}

FUNCTION ghk(v (mV), ci (mM), co (mM), z) (mA/cm2) {
    : Goldman-Hodgkin-Katz current equation
    : Returns current density in mA/cm2
    LOCAL e, w, zfrt
    
    : z*F/(R*T) with proper unit conversion
    zfrt = 0.001 * z * FARADAY / (R * (celsius + 273.15))
    
    : Dimensionless exponential argument
    e = zfrt * v
    
    if (fabs(e) < 1e-4) {
        : Linear approximation for small voltages
        ghk = 0.001 * z * FARADAY / (R * (celsius + 273.15)) * (1 - e/2) * (ci - co)
    } else {
        : Full GHK equation
        w = e / (1 - exp(e))
        ghk = 0.001 * z * FARADAY / (R * (celsius + 273.15)) * w * (ci - co * exp(e))
    }
}
