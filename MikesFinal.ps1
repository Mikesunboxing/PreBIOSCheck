# Mike's Unboxing Pre BIOS check utility
# Version 3.2 - Final Release (Animated + MBR/GPT Logic)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- 1. Administrator Rights Check ---
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    [System.Windows.Forms.MessageBox]::Show("This utility requires Administrator rights.`n`nPlease right-click and 'Run as Administrator'.", "Admin Rights Required", "OK", "Error")
    exit
}

Clear-Host

# --- 2. Animated Typewriter Header ---
$header = @"
**********************************************
* Mike's Unboxing Pre BIOS check utility     *
**********************************************
"@
foreach ($char in $header.ToCharArray()) {
    Write-Host $char -NoNewline -ForegroundColor Cyan
    Start-Sleep -Milliseconds 5
}
Write-Host "`n"
Write-Host "[!] Initializing System Scan..." -ForegroundColor Yellow
Start-Sleep -Milliseconds 500

# --- 3. Dramatic Scanning Section (Progress Bar) ---
$tasks = "Scanning Motherboard...", "Checking BIOS Version...", "Evaluating Security...", "Analyzing Partition Style...", "Checking Power & Storage..."
for ($i = 0; $i -lt 100; $i++) {
    $taskIndex = [math]::Floor($i / 20)
    Write-Progress -Activity "Mike's Unboxing: Analyzing System" -Status ($tasks[$taskIndex]) -PercentComplete $i
    # 70ms creates a smooth, high-tech movement speed for camera
    Start-Sleep -Milliseconds 70 
}
Write-Progress -Activity "Analyzing System" -Completed

# --- 4. Data Gathering ---
$board = Get-CimInstance Win32_BaseBoard
$boardMake = if ($board.Manufacturer -and $board.Manufacturer -notmatch "To be filled") { $board.Manufacturer } else { "Not Available" }
$boardModel = if ($board.Product -and $board.Product -notmatch "To be filled") { $board.Product } else { "Not Available" }
$bios = Get-CimInstance Win32_BIOS
$tpm = Get-Tpm
$systemDrive = Get-Disk | Where-Object { $_.IsSystem -eq $true }
$cDrive = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
$freeSpaceGB = [math]::Round($cDrive.FreeSpace / 1GB, 2)
$pendingUpdate = Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired"

# Power Logic
$battery = Get-CimInstance Win32_Battery
$powerSource = "Mains (AC Power)"; $batteryLevel = "N/A (Desktop)"; $powerWarning = ""
if ($null -ne $battery) {
    $charge = $battery.EstimatedChargeRemaining
    $batteryLevel = "$charge%"
    if ($battery.BatteryStatus -eq 1) {
        $powerSource = "Battery"
        if ($charge -lt 50) { $powerWarning = "[!] CRITICAL: Battery below 50%. Connect to MAINS POWER!" }
        else { $powerWarning = "[-] RECOMMENDATION: Plug in AC power for safety." }
    }
}

# Encryption Check
try {
    $encryption = Get-CimInstance -Namespace "Root\Microsoft\Windows\BitLocker" -ClassName Win32_EncryptableVolume -ErrorAction Stop | Where-Object { $_.DriveLetter -eq "C:" }
    $encryptionStatus = if ($null -ne $encryption -and $encryption.ProtectionStatus -eq 1) { "Disks are encrypted" } else { "Unencrypted" }
} catch { $encryptionStatus = "Unencrypted/Unavailable" }

# --- 5. Build Report ---
$stats = @"
[MOTHERBOARD INFO]
Manufacturer: $boardMake | Model: $boardModel
[SYSTEM STATS]
BIOS Version: $($bios.SMBIOSBIOSVersion) ($($bios.ReleaseDate.ToShortDateString()))
TPM 2.0:      $(if($tpm.TpmPresent){'Ready'}else{'No'})
Encryption:   $encryptionStatus | Partition Style: $($systemDrive.PartitionStyle)
C: Free Space: $freeSpaceGB GB
[POWER STATUS]
Source: $powerSource | Level: $batteryLevel
"@

# --- 6. Analysis & MBR/GPT Logic ---
$warningsFound = $false
$analysisOutput = ""

if ($powerWarning) { $analysisOutput += "$powerWarning`r`n"; $warningsFound = $true }
if ($pendingUpdate) { $analysisOutput += "[!] ALERT: Pending Windows Update. RESTART first!`r`n"; $warningsFound = $true }
if ($freeSpaceGB -lt 5) { $analysisOutput += "[-] WARNING: Low disk space.`r`n"; $warningsFound = $true }

# The MBR Critical Warning
if ($systemDrive.PartitionStyle -eq 'MBR') { 
    $analysisOutput += "[!] CRITICAL: Disk is MBR format. Modern BIOS updates often enable UEFI-only mode, meaning your drives may NOT be accessible after the update.`r`n"
    $analysisOutput += "    FIX: You may need to enable 'CSM Mode' in your BIOS settings after flashing to see your drives again, or convert to GPT.`r`n"
    $warningsFound = $true 
}

if (-not $warningsFound) { 
    $analysisOutput = "[+] SUCCESS: Safe to update. It appears your system meets the requirements for a modern BIOS update.`r`n" 
}

# --- 7. Output & Disclaimer ---
Write-Host $stats
Write-Host "`n--- ANALYSIS ---" -ForegroundColor White
$color = if ($systemDrive.PartitionStyle -eq 'MBR') { "Red" } elseif ($warningsFound) { "Yellow" } else { "Green" }
Write-Host $analysisOutput -ForegroundColor $color

$disclaimer = @"
---------------------------------------------------------------------------
DISCLAIMER: Do not entirely rely on this information. Always perform your 
own due diligence. MikesUnboxing and Community are here to help, but any 
BIOS updates are performed at YOUR OWN RISK. We are in no way responsible 
for any issues that may occur during the process.
---------------------------------------------------------------------------
"@
Write-Host "`n$disclaimer" -ForegroundColor Gray

$ReportContent = "Mike's Unboxing BIOS Check v3.2`r`n" + ("-"*30) + "`r`n" + $stats + "`r`n`r`n[ANALYSIS]`r`n" + $analysisOutput + "`r`n" + $disclaimer

if ([System.Windows.Forms.MessageBox]::Show("Save report as .txt file?", "Save", "YesNo") -eq "Yes") {
    $fd = New-Object System.Windows.Forms.SaveFileDialog; $fd.Filter = "Text Files (*.txt)|*.txt"; $fd.FileName = "Mikes_BIOS_Check.txt"
    if ($fd.ShowDialog() -eq "OK") { $ReportContent | Out-File -FilePath $fd.FileName -Encoding utf8 }
}

Write-Host "`nComplete. Press any key to exit..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Stop-Process -Id $PID