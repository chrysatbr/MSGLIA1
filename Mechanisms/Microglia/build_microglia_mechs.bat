@echo off
set modFilesFolderName=MOD_files
set tempFolderName=temp_folder

if exist %tempFolderName% (
    rmdir %tempFolderName% /S /Q
)
mkdir %tempFolderName%
cd %tempFolderName%
echo.
xcopy "..\%modFilesFolderName%\*" /Q
echo.
echo     Building Microglia mechs ...
echo.
call "%NEURONHOME%\bin\mknrndll.bat"
echo.
copy nrnmech.dll "..\..\..\Nanogeometry\Microglia\" 2>nul
move nrnmech.dll "..\"
echo.
if errorlevel 1 goto label1
    cd ..
    rmdir %tempFolderName% /S /Q
:label1
pause
