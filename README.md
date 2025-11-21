# **MS-GLIA**

*A glia-enhanced modification of the BrainCell simulation framework*

MS-GLIA is an extended version of the **BrainCell** computational platform, designed to simulate detailed neuron–glia interactions, nanoscopic extracellular space organisation, and biophysical processes relevant to neurological function and pathology.

The project retains the general structure of BrainCell (HOC/JSON-style organisation, NEURON backend, modular mechanisms), while introducing additional glial modules, new biophysical processes, and support for micro/nano-geometry–dependent computations.

---

## **Repository Structure**

```
MS-GLIA/
│
├── Binary results/          # Simulation output in binary format
├── Biophysics/              # Biophysical parameter sets and configuration files
├── Distance functions/      # Spatial/geometry-dependent routines for diffusion, ECS
├── External simulations/    # Scripts for running non-core or auxiliary simulations
├── Geometry/                # Cell morphologies, ECS geometry, structural definitions
├── Mechanisms/              # NMODL (.mod) files for NEURON mechanisms (glia + neurons)
├── Nanogeometry/            # High-resolution geometry modules (nano-scale structures)
├── Text results/            # Result files in text/CSV formats
│
├── _Code/                   # Main HOC / Python / helper scripts for launching models
├── _RestartApp/             # Scripts for restarting simulations / session recovery
├── _Testing/                # Validation tests and example runs
│
├── build_mechs.bat          # Windows script to compile NMODL mechanisms
├── build_mechs.ps1          # PowerShell version
├── cmd.exe                  # Entry-point executable wrapper (Windows)
├── do_not_put_nrnrmech_dll_here  # NEURON build placeholder
├── init.bat                 # Initial setup for Windows
├── init.hoc                 # Main NEURON initialisation file
│
└── README.md                # This file
```

---

## **Key Features**

* **Extended glial modelling:**
  Astrocytes, microglia, and related biophysical processes (K⁺ buffering, glutamate uptake, gliotransmission, volume dynamics).

* **Nanogeometry-aware simulations:**
  Integration of ultra-fine ECS and membrane geometry to evaluate diffusion, tortuosity, local gradients, and microdomain effects.

* **Mechanisms in NMODL:**
  New NEURON-compatible `.mod` files extending channel/transporter functionality.

* **Custom distance functions:**
  Geometry-based computational routines for space-dependent kinetics, nearest-neighbour queries, 3D distances, surface areas, etc.

* **Compatibility with BrainCell:**
  Inherits BrainCell’s modular folder structure and simulation workflow.

* **Multiple output formats:**
  Binary and text results (good for large extracellular fields and glial variables).

---

## **Installation**

### **1. Clone the repository**

```bash
git clone https://github.com/chrysatbr/msglia1.git
cd msglia1
```

### **2. Compile NEURON mechanisms**

On Windows:

```bash
build_mechs.bat
```

or using PowerShell:

```bash
./build_mechs.ps1
```

On Linux/macOS (if you add a `nrnivmodl` folder):

```bash
cd Mechanisms
nrnivmodl
```

### **3. Ensure NEURON is installed**

NEURON with Python support is recommended:
[https://neuron.yale.edu/neuron/](https://neuron.yale.edu/neuron/)

---

## **Running Simulations**

1. Launch NEURON (GUI or command-line).
2. Run the main startup script:

```bash
nrngui init.hoc
```

or from Python/HOC interface:

```bash
nrniv init.hoc
```

3. Configuration files in:

* `Biophysics/`
* `Geometry/`
* `Nanogeometry/`
* `Distance functions/`

control the simulation environment.

4. Results will appear under:

* `Binary results/`
* `Text results/`

depending on settings.

---

## **Main Components**

### **🧠 Neuronal mechanisms**

Stored under **Mechanisms/**, including:

* Ion channels
* Synaptic models
* Leak & active membrane properties

### **🌿 Glial mechanisms**

Extended glial modules may include:

* Glutamate transporters
* K⁺ buffering
* Volume regulation
* Receptor responses
* Structural microdomain effects

### **📐 Nanogeometry**

The **Nanogeometry/** folder enables:

* High-resolution meshes
* Sub-branch ECS compartments
* Distance-based function calculation
* Spine/astrocyte nanostructure simulations

### **📊 Analysis**

Binary and text outputs allow MATLAB/Python-based analysis outside the NEURON environment.

---

## **Workflow Summary**

1. **Edit configuration files** (Biophysics, Geometry, Nanogeometry).
2. **Compile .mod mechanisms.**
3. **Run init.hoc** or a script in `_Code/`.
4. **Inspect outputs** in Binary/Text results.
5. **Use Python/MATLAB** for plots and post-processing.

---

## **Compatibility With BrainCell**

MS-GLIA is derived from the BrainCell architecture and extends it.
It preserves:

* HOC entry points
* Folder layout
* NMODL build workflow
* Batch script structure

This makes it easy for BrainCell users to transition.

---

## **Citing**

If you use MS-GLIA in published work, please cite:

1. **BrainCell original publication**
   (Savtchenko et al., Nature Communications 2018)

2. **MS-GLIA GitHub repository**

   ```
   chrysatbr (2025). MS-GLIA: Glia-enhanced modification of BrainCell.
   GitHub repository: https://github.com/chrysatbr/msglia1
   ```

(Add a DOI when you publish a release.)

---

## **Contact**


