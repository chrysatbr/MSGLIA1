@echo off
REM Build script for Microglia-specific NEURON mechanisms
REM Run this from the Mechanisms/Microglia directory

echo Building Microglia mechanisms...
cd MOD_files
nrnivmodl
echo Done!
pause
