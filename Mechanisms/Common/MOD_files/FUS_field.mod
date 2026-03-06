TITLE Analytical Focused Ultrasound Acoustic Field

COMMENT
Computes local acoustic pressure, intensity, acoustic radiation force,
membrane tension proxy, and shear stress proxy at each compartment
based on an analytical Gaussian beam model.

ENVELOPE CONVENTION:
  p_input is PRESSURE AMPLITUDE in Pa, set from HOC as P(t) = P0*E(t).
  I = p^2/(2*rho*c).  I is proportional to E(t)^2, NOT E(t).

GEOMETRY-AWARE ARF:
  V_seg = pi*(d/2)^2*L computed from seg_diam, seg_L (set from HOC).
  F_seg = arf_density * V_seg (pN).

MECHANICAL BRIDGE:
  membrane_tension = kappa_tension * p_local  (mN/m)
  shear_stress     = kappa_shear * p_local    (Pa)
  Defaults calibrated to Piezo1/TRPV4 activation at 0.5 MPa.

REFERENCES:
  O'Neil 1949, Kino 1987, Nyborg 1965, Dalecki 2004,
  Coste 2010 (Piezo1), Syeda 2016, Liedtke 2005 (TRPV4)
ENDCOMMENT

NEURON {
    SUFFIX FUS_field
    RANGE p_input
    RANGE x_comp, y_comp, z_comp
    RANGE x_focus, y_focus, z_focus
    RANGE freq, pressure_source
    RANGE focal_length, aperture_diam, f_number
    RANGE attenuation, sound_speed, tissue_density
    RANGE p_local, intensity_local
    RANGE arf_density, force_seg, force_arf
    RANGE spatial_factor
    RANGE membrane_tension, shear_stress
    RANGE seg_diam, seg_L
    RANGE kappa_tension, kappa_shear
    RANGE wavelength_um, w0_um, zR_um
    RANGE fwhm_lat_amp_um, fwhm_ax_amp_um
    RANGE fwhm_lat_int_um, fwhm_ax_int_um
}

PARAMETER {
    freq            = 500       : ultrasound frequency (kHz)
    pressure_source = 0.5       : peak source pressure at focus (MPa)
    focal_length    = 50        : transducer focal length (mm)
    aperture_diam   = 25        : transducer aperture diameter (mm)
    attenuation     = 0.3       : absorption coefficient (Np/cm/MHz)
    sound_speed     = 1540      : speed of sound in tissue (m/s)
    tissue_density  = 1040      : tissue density (kg/m^3)
    x_focus = 0     : (um)
    y_focus = 0     : (um)
    z_focus = 0     : (um)
    x_comp  = 0     : (um)
    y_comp  = 0     : (um)
    z_comp  = 0     : (um)
    p_input = 0     : instantaneous pressure envelope (Pa)
    seg_diam = 1.0  : segment diameter (um) - set from HOC
    seg_L    = 1.0  : segment length (um) - set from HOC
    kappa_tension = 1e-5  : mN/m per Pa (at 0.5 MPa -> 5 mN/m)
    kappa_shear   = 1e-6  : Pa per Pa (at 0.5 MPa -> 0.5 Pa)
}

ASSIGNED {
    p_local
    intensity_local
    arf_density
    force_seg
    force_arf
    spatial_factor
    membrane_tension
    shear_stress
    f_number
    wavelength_um
    w0_um
    zR_um
    fwhm_lat_amp_um
    fwhm_ax_amp_um
    fwhm_lat_int_um
    fwhm_ax_int_um
}

INITIAL {
    compute_beam_params()
    compute_spatial_factor()
    p_local = 0
    intensity_local = 0
    arf_density = 0
    force_seg = 0
    force_arf = 0
    membrane_tension = 0
    shear_stress = 0
}

BREAKPOINT {
    LOCAL alpha_m, V_seg_m3

    p_local = p_input * spatial_factor

    intensity_local = (p_local * p_local) / (2.0 * tissue_density * sound_speed)

    alpha_m = attenuation * (freq / 1000.0) * 100.0
    arf_density = 2.0 * alpha_m * intensity_local / sound_speed

    V_seg_m3 = 3.14159265 * (seg_diam * 0.5) * (seg_diam * 0.5) * seg_L * 1e-18
    force_seg = arf_density * V_seg_m3 * 1e12
    force_arf = force_seg

    membrane_tension = kappa_tension * p_local
    shear_stress = kappa_shear * p_local
}

PROCEDURE compute_beam_params() {
    LOCAL lambda_m, w0_m, zR_m
    if (aperture_diam > 0) {
        f_number = focal_length / aperture_diam
    } else {
        f_number = 2.0
    }
    if (freq > 0) {
        lambda_m = sound_speed / (freq * 1000.0)
    } else {
        lambda_m = 0.00308
    }
    wavelength_um = lambda_m * 1e6
    w0_m = lambda_m * f_number
    w0_um = w0_m * 1e6
    if (lambda_m > 0) {
        zR_m = 3.14159265 * w0_m * w0_m / lambda_m
    } else {
        zR_m = 1.0
    }
    zR_um = zR_m * 1e6

    : Pressure amplitude FWHM:
    :   Lateral: 2*w0*sqrt(ln2) = 1.6651*w0
    :   Axial:   2*sqrt(3)*zR   = 3.4641*zR
    : Intensity FWHM (-6 dB):
    :   Lateral: w0*sqrt(2*ln2)  = 1.1774*w0
    :   Axial:   2*zR
    fwhm_lat_amp_um = w0_um * 1.6651
    fwhm_ax_amp_um  = zR_um * 3.4641
    fwhm_lat_int_um = w0_um * 1.1774
    fwhm_ax_int_um  = zR_um * 2.0
}

PROCEDURE compute_spatial_factor() {
    LOCAL dx_m, dy_m, dz_m, r_m, z_m, w0_m, zR_m, wz_m, alpha_total, zr_ratio
    dx_m = (x_comp - x_focus) * 1e-6
    dy_m = (y_comp - y_focus) * 1e-6
    dz_m = (z_comp - z_focus) * 1e-6
    r_m = sqrt(dx_m * dx_m + dy_m * dy_m)
    z_m = dz_m
    w0_m = w0_um * 1e-6
    zR_m = zR_um * 1e-6
    if (w0_m <= 0) {
        spatial_factor = 1.0
    } else if (zR_m <= 0) {
        spatial_factor = 1.0
    } else {
        zr_ratio = z_m / zR_m
        wz_m = w0_m * sqrt(1.0 + zr_ratio * zr_ratio)
        if (wz_m > 0) {
            spatial_factor = (w0_m / wz_m) * exp(-(r_m * r_m) / (wz_m * wz_m))
        } else {
            spatial_factor = 1.0
        }
        if (z_m < 0) {
            alpha_total = attenuation * (freq / 1000.0) * (-z_m) * 100.0
        } else {
            alpha_total = attenuation * (freq / 1000.0) * z_m * 100.0
        }
        spatial_factor = spatial_factor * exp(-alpha_total)
    }
    if (spatial_factor > 1.0) {
        spatial_factor = 1.0
    }
    if (spatial_factor < 0.0) {
        spatial_factor = 0.0
    }
}
