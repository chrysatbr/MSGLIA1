$modFilesFolderName = "MOD_files"
$tempFolderName = "temp_folder"

if (Test-Path $tempFolderName) {
    Remove-Item $tempFolderName -Recurse -Force
}
New-Item -ItemType Directory -Path $tempFolderName | Out-Null
Set-Location $tempFolderName

Write-Host ""
Copy-Item "..\$modFilesFolderName\*" -Destination "." -Force
Write-Host ""
Write-Host "    Building Microglia mechs ..."
Write-Host ""

& "$env:NEURONHOME\bin\mknrndll.bat"

Write-Host ""
Copy-Item "nrnmech.dll" -Destination "..\..\..\Nanogeometry\Microglia\" -Force -ErrorAction SilentlyContinue
Move-Item "nrnmech.dll" -Destination "..\" -Force

Set-Location ..
Remove-Item $tempFolderName -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "Press any key to exit ..."
$null = Read-Host
