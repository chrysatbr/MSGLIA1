COMMENT

Geometry-Aware Piezo1 Mechanosensitive Ion Channel

This is an improved version of the Piezo1 model that scales with cell morphology,
similar to how cadifus handles calcium dynamics.

Key improvements:
1. density is now RANGE (can be set per segment) instead of PARAMETER
2. Added diameter-dependent scaling for more realistic channel distribution
3. Added optional calcium-dependent modulation of channel kinetics
4. Maintains all original Markov state kinetics

MODIFICATIONS:
- Made density a RANGE variable (can be different in each segment)
- Added diam as ASSIGNED variable to access segment diameter
- Added density_scale_factor for diameter-dependent scaling
- Added optional Ca2+-dependent modulation of opening rates

USAGE:
In your Python/HOC code, you can now set density per segment:
    for seg in section:
        seg.density_Piezo1 = calculate_density(seg.diam)

Or use automatic diameter scaling by setting density_scale_mode

ENDCOMMENT


NEURON {
    SUFFIX  Piezo1
    USEION ca READ cao, cai WRITE ica
    USEION na READ nao, nai WRITE ina  
    USEION k READ ko, ki WRITE ik
    RANGE P1, P2, P3, P4, P5, P6, P7, P8, Po
    GLOBAL k12, k21, k23, k32, k34, k43, k45, k54, k56, k65, k67, k76, k78, k87, k81, k18
    RANGE ipiezo, density, mforce, force_sensitivity, force_threshold, g_single, pca, pna, pk
    RANGE density_scale_mode, density_scale_factor, ca_modulation_strength, ca_half, scaled_density
    NONSPECIFIC_CURRENT ipiezo
}

UNITS {
    (mV) = (millivolt)
    (mA) = (milliamp)
    (mM) = (milli/liter)
    (pN) = (piconewton)
    (pS) = (picosiemens)
    (um) = (micron)
    F = (faraday) (coulombs)
    R = (k-mole) (joule/degC)
}

PARAMETER {	
    mforce = 0                  : Applied mechanical force (pN)
    force_sensitivity = 0.05    : Force sensitivity parameter (reduced from 1.0)
    force_threshold = 0.5       : Minimum force threshold (pN)
    g_single = 27e-12           : Single channel conductance (27 pS)
    
    : Kinetic rate constants (per ms)
    k12 = 0.5
    k21 = 0.05
    k23 = 0.4
    k32 = 0.04
    k34 = 0.3
    k43 = 0.03
    k45 = 0.2
    k54 = 0.02
    k56 = 0.25
    k65 = 0.025
    k67 = 0.15
    k76 = 0.015
    k78 = 4.0                   : Increased for faster activation
    k87 = 0.4
    k81 = 0.001
    k18 = 0.0005

    : Permeability ratios
    pca = 1.0
    pna = 0.1
    pk = 0.08
    
    : Channel density (channels per cm2) - NOW A RANGE VARIABLE (see below)
    : This default will be used unless you set it per segment
    density = 1e8               : Default base density
    
    : Density scaling parameters
    density_scale_mode = 0      : 0=no scaling, 1=linear with diam, 2=inverse with diam, 3=surface-to-volume
    density_scale_factor = 1.0  : Scaling factor (multiplier for density)
    
    : Calcium modulation parameters
    ca_modulation_strength = 0.0  : 0=no modulation, positive values increase sensitivity to Ca2+
    ca_half = 0.0005          : Half-maximal Ca2+ for modulation (500 nM)
}

ASSIGNED {
    v (mV)
    celsius (degC)
    diam (um)                   : Segment diameter - automatically available
    cao (mM)
    cai (mM)
    nao (mM)
    nai (mM)
    ko (mM)
    ki (mM)
    
    ica (mA/cm2)
    ina (mA/cm2)
    ik (mA/cm2)
    ipiezo (mA/cm2)
    Po                          : Open probability (P7 + P8)
    
    k12_eff
    k23_eff
    k34_eff
    k45_eff
    k56_eff
    k67_eff
    k78_eff
    temp_factor
    force_factor
    effective_force
    effective_density           : Actual density after geometry scaling
    ca_modulation_factor        : Calcium-dependent modulation
    scaled_density
}

STATE {
    P1
    P2
    P3
    P4
    P5
    P6
    P7
    P8
}

INITIAL {
    P1 = 0.90
    P2 = 0.05
    P3 = 0.025
    P4 = 0.01
    P5 = 0.005
    P6 = 0.005
    P7 = 0.003
    P8 = 0.002
    
    : Calculate initial effective density
    effective_density = calculate_effective_density(density, diam, density_scale_mode, density_scale_factor)
}

BREAKPOINT {
    SOLVE kstates METHOD sparse
    
    temp_factor = exp((celsius - 22) * 0.1)
    
    : Calculate effective density based on geometry
    effective_density = calculate_effective_density(density, diam, density_scale_mode, density_scale_factor)
    
    : Apply force threshold - only forces above threshold are effective
    if (mforce > force_threshold) {
        effective_force = mforce - force_threshold
    } else {
        effective_force = 0
    }
    
    : Calcium-dependent modulation (Hill equation)
    if (ca_modulation_strength > 0) {
        ca_modulation_factor = 1.0 + ca_modulation_strength * (cai^2 / (cai^2 + ca_half^2))
    } else {
        ca_modulation_factor = 1.0
    }
    
    : Force-dependent rate constants with reduced sensitivity
    : Now also modulated by calcium if enabled
    k12_eff = k12 * temp_factor * ca_modulation_factor * exp(effective_force * force_sensitivity * 0.5)
    k23_eff = k23 * temp_factor * ca_modulation_factor * exp(effective_force * force_sensitivity * 0.6)
    k34_eff = k34 * temp_factor * ca_modulation_factor * exp(effective_force * force_sensitivity * 0.7)
    k45_eff = k45 * temp_factor * ca_modulation_factor * exp(effective_force * force_sensitivity * 0.8)
    k56_eff = k56 * temp_factor * ca_modulation_factor * exp(effective_force * force_sensitivity * 0.9)
    k67_eff = k67 * temp_factor * ca_modulation_factor * exp(effective_force * force_sensitivity * 1.0)
    k78_eff = k78 * temp_factor * ca_modulation_factor * exp(effective_force * force_sensitivity * 1.2)
    
    : Current calculations using EFFECTIVE density (geometry-aware)
    ica = -effective_density * P8 * pca * g_single * ghk(v, cai, cao, 2) * 1e3
    ina = -effective_density * P8 * pna * g_single * ghk(v, nai, nao, 1) * 1e3
    ik = -effective_density * P8 * pk * g_single * ghk(v, ki, ko, 1) * 1e3
    
    ipiezo = ica + ina + ik
    
    : Calculate open probability (sum of open states P7 and P8)
    Po = P7 + P8
    scaled_density = effective_density
}

KINETIC kstates {
    ~ P1 <-> P2     (k12_eff, k21 * temp_factor)
    ~ P2 <-> P3     (k23_eff, k32 * temp_factor)
    ~ P3 <-> P4     (k34_eff, k43 * temp_factor)
    ~ P4 <-> P5     (k45_eff, k54 * temp_factor)
    ~ P5 <-> P6     (k56_eff, k65 * temp_factor)
    ~ P6 <-> P7     (k67_eff, k76 * temp_factor)
    ~ P7 <-> P8     (k78_eff, k87 * temp_factor)
    ~ P8 <-> P1     (k81 * temp_factor, k18 * temp_factor)
    
    CONSERVE P1 + P2 + P3 + P4 + P5 + P6 + P7 + P8 = 1
}

FUNCTION calculate_effective_density(base_density, diameter, scale_mode, scale_factor) {
    : Calculates the effective channel density based on geometry
    : 
    : scale_mode:
    :   0 = no scaling (constant density)
    :   1 = linear with diameter (more channels in thicker segments)
    :   2 = inverse with diameter (more channels per area in thinner segments)
    :   3 = surface-to-volume ratio scaling
    
    LOCAL scaled_density, reference_diam
    reference_diam = 1.0  : Reference diameter in microns
    
    if (scale_mode == 0) {
        : No scaling - constant density
        scaled_density = base_density
        
    } else if (scale_mode == 1) {
        : Linear scaling with diameter
        : Thicker sections have proportionally more channels
        scaled_density = base_density * (diameter / reference_diam) * scale_factor
        
    } else if (scale_mode == 2) {
        : Inverse scaling with diameter  
        : Thinner sections have higher density per unit area
        scaled_density = base_density * (reference_diam / diameter) * scale_factor
        
    } else if (scale_mode == 3) {
        : Surface-to-volume ratio scaling
        : Based on the principle that thinner processes have higher surface-to-volume ratio
        : For a cylinder: SA/V = 2/r + 2/L, approximated as 4/diameter
        scaled_density = base_density * (reference_diam / diameter) * scale_factor
        
    } else {
        : Default to no scaling if invalid mode
        scaled_density = base_density
    }
    
    : Ensure density stays positive
    if (scaled_density < 0) {
        scaled_density = base_density
    }
    
    calculate_effective_density = scaled_density
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
