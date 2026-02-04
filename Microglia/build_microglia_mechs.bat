@echo off
REM Build script for Microglia-specific NEURON mechanisms

echo ========================================
echo Building Microglia mechanisms...
echo ========================================
echo.
echo Current directory: %cd%

REM Go to script's directory first
cd /d "%~dp0"
echo Script directory: %cd%

REM Check if MOD_files exists
if not exist "MOD_files" (
    echo.
    echo ERROR: MOD_files folder not found!
    echo Make sure this script is in Mechanisms\Microglia\
    pause
    exit /b 1
)

cd MOD_files
echo Now in: %cd%
echo.

REM List MOD files
echo Found MOD files:
dir /b *.mod 2>nul
if errorlevel 1 (
    echo ERROR: No .mod files found!
    pause
    exit /b 1
)
echo.

REM Check if nrnivmodl exists
where nrnivmodl >nul 2>nul
if errorlevel 1 (
    echo ERROR: nrnivmodl not found in PATH!
    echo Make sure NEURON is installed and added to PATH
    echo.
    echo Try running from NEURON's mingw terminal instead
    pause
    exit /b 1
)

echo Running nrnivmodl...
echo ========================================
nrnivmodl
echo ========================================

if errorlevel 1 (
    echo.
    echo ERROR: nrnivmodl failed!
) else (
    echo.
    echo Build completed successfully!
)

echo.
pause
