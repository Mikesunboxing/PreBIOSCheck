# Mike's Unboxing Pre BIOS Flash Utility
# Version 4.5.8.4 (Universal BIOS Date Fix + Detection Debugging)
$Version = "4.5.8.4"

# --- 1. FIXED-WIDTH SAFETY WRAPPER ---
$MaxW = 90
$Pad  = " " * 8
$ReportBuffer = @()

try {
    $rawUI = $Host.UI.RawUI
    $currentWidth = $rawUI.WindowSize.Width
    if ($currentWidth -lt $MaxW) { $MaxW = $currentWidth }
    $PadSize = [math]::Max(2, [math]::Floor($MaxW * 0.08))
    $Pad = " " * $PadSize

    if ($Host.Name -eq 'ConsoleHost') {
        $MaxH = $rawUI.MaxWindowSize.Height
        $ActualH = if (65 -gt $MaxH) { $MaxH - 1 } else { 65 }
        $Size = New-Object System.Management.Automation.Host.Size($MaxW, $ActualH)
        $rawUI.WindowSize = $Size
        $Buff = New-Object System.Management.Automation.Host.Size($MaxW, 3000)
        $rawUI.BufferSize = $Buff
    }
} catch { }

$Host.UI.RawUI.WindowTitle = "Mikesunboxing - PreBIOSCheck Tool v$Version"

# --- 2. UI FUNCTIONS ---
$FunctionList = @{
    "Out-Both" = {
        param([string]$Text, [string]$Color = "White")
        Write-Host "$Pad$Text" -ForegroundColor $Color
        $script:ReportBuffer += "$Pad$Text"
    }
    "Write-Centered" = {
        param($Text, $Color="White")
        $Space = [math]::Max(0, [math]::Floor(($MaxW - ($Pad.Length * 2) - $Text.Length) / 2))
        Out-Both ((" " * $Space) + $Text) $Color
    }
    "Write-Aligned" = {
        param($Label, $Value, $ValueColor="White")
        Write-Host "$Pad» " -NoNewline -ForegroundColor White
        Write-Host ($Label).PadRight(23) -NoNewline -ForegroundColor White
        Write-Host ": " -NoNewline -ForegroundColor White
        Write-Host $Value -ForegroundColor $ValueColor
        $script:ReportBuffer += "$Pad» " + ($Label).PadRight(23) + ": " + $Value
    }
    "Write-Wrapped-Centered" = {
        param([string]$Text, [string]$Color = "Gray")
        $MaxWidth = $MaxW - ($Pad.Length * 2)
        if ($MaxWidth -lt 20) { $MaxWidth = 20 }
        $Words = $Text -split ' '
        $Lines = @(); $CurrentLine = ""
        foreach ($Word in $Words) {
            if (($CurrentLine + $Word).Length -le $MaxWidth) { $CurrentLine += "$Word " } 
            else { $Lines += $CurrentLine.Trim(); $CurrentLine = "$Word " }
        }
        if ($CurrentLine.Trim().Length -gt 0) { $Lines += $CurrentLine.Trim() }
        foreach ($Line in $Lines) {
            $Space = [math]::Max(0, [math]::Floor(($MaxW - ($Pad.Length * 2) - $Line.Length) / 2))
            Out-Both ((" " * $Space) + $Line) $Color
        }
    }
}

foreach ($func in $FunctionList.Keys) {
    New-Item -Path "function:Global:$func" -Value $FunctionList[$func] -Options Constant -ErrorAction SilentlyContinue | Out-Null
}

# --- 2.5 OEM BIOS SUPPORT URL LOGIC ---
function Get-BiosSupportUrl {
    param([string]$Manufacturer, [string]$BoardProduct, [string]$SerialNumber, [string]$SystemProduct, [string]$SystemVersion)
    $manu = ($Manufacturer -replace '\s+', ' ').Trim().ToLower()
    $model = ($BoardProduct -replace '\s+', ' ').Trim()
    function _enc([string]$s) { return [System.Uri]::EscapeDataString($s) }
    switch -regex ($manu) {
        'dell' { if ($SerialNumber) { return "https://www.dell.com/support/home/en-uk/product-support/servicetag/$SerialNumber/overview" } }
        'hewlett-packard|hp' { if ($model) { return "https://support.hp.com/us-en/search?q=$(_enc($model))" } }
        'lenovo' { if ($SystemProduct) { return "https://pcsupport.lenovo.com/us/en/search?query=$(_enc($SystemProduct))" } }
        'asus' { if ($model) { return "https://www.asus.com/supportonly/$(_enc($model))/HelpDesk_BIOS/" } }
        'msi' { if ($model) { return "https://www.msi.com/search/$(_enc($model))#?category=Motherboard&subcategory=BIOS" } }
        'gigabyte' { if ($model) { return "https://www.gigabyte.com/Search?kw=$(_enc($model))" } }
        default { return $null }
    }
    return $null
}

# --- 3. UNIVERSAL DATA GATHERING ---
$Base   = Get-CimInstance Win32_BaseBoard
$BIOS   = Get-CimInstance Win32_BIOS
$Batt   = Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue
$TPM    = Get-CimInstance -Namespace root\cimv2\security\microsofttpm -ClassName Win32_Tpm -ErrorAction SilentlyContinue
$CSProd = Get-CimInstance Win32_ComputerSystemProduct

$CPU_Name = (Get-CimInstance Win32_Processor).Name.Trim()
$TotalRAM = [math]::Round((Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB, 0)
$GPU = (Get-CimInstance Win32_VideoController | Select-Object -ExpandProperty Name | Select-Object -First 1)
$BoardRev = if ($Base.Version) { $Base.Version } else { "N/A" }

# UNIVERSAL BIOS DATE FAILOVER ENGINE
$FormattedDate = "Unknown"
$DetectMethod = "None"
try {
    if ($BIOS.ReleaseDate) {
        $RawDate = $BIOS.ReleaseDate; $DetectMethod = "CIM (Modern)"
    } else {
        $RawDate = (Get-WmiObject Win32_BIOS).ReleaseDate; $DetectMethod = "WMI (Legacy)"
    }

    if ($RawDate) {
        try {
            $DateObj = [Management.ManagementDateTimeConverter]::ToDateTime($RawDate)
            $FormattedDate = $DateObj.ToString("MM/dd/yyyy") + " (M/D/Y)"
        } catch {
            if ($RawDate -match "(\d{4})(\d{2})(\d{2})") {
                $FormattedDate = "$($Matches[2])/$($Matches[3])/$($Matches[1])"; $DetectMethod += " + Regex Scraped"
            } else {
                $FormattedDate = "$($RawDate.ToString().Substring(0,10))"; $DetectMethod += " + Raw String"
            }
        }
    }
} catch { $FormattedDate = "Not Reported" }

$SysDrive = Get-Disk | Where-Object { $_.IsSystem -eq $true }
$PartStyle = $SysDrive.PartitionStyle
$Part_Col = if ($PartStyle -eq "GPT") { "Green" } else { "Yellow" }

$OSReg = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
$Build = [int](Get-ItemProperty $OSReg).CurrentBuild
$OSVer = (Get-ItemProperty $OSReg).DisplayVersion
$OSEdition = if ($Build -ge 22000) { (Get-ItemProperty $OSReg).ProductName -replace "Windows 10", "Windows 11" } else { (Get-ItemProperty $OSReg).ProductName }

$Reboot = Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired"
$Upd_Txt = if ($Reboot) { "Pending Restart" } else { "Up to Date" }
$Upd_Col = if ($Reboot) { "Yellow" } else { "Green" }

$SB = (Confirm-SecureBootUEFI) 2>$null
$SB_Txt = if ($SB) { "Enabled" } else { "Disabled" }; $SB_Col = if ($SB) { "Green" } else { "Red" }

$TPM_Ok = if ($TPM -and $TPM.IsEnabled_InitialValue) { $true } else { $false }
$TPM_Txt = if ($TPM_Ok) { "Ready" } else { "Missing" }; $TPM_Col = if ($TPM_Ok) { "Green" } else { "Red" }

$BL = (Get-BitLockerVolume -MountPoint "C:" -ErrorAction SilentlyContinue).ProtectionStatus
$BL_Txt = if ($BL -eq 1) { "Encrypted" } else { "Unencrypted" }; $BL_Col = if ($BL -eq 1) { "Red" } else { "Green" }
$CSpace = [math]::Round((Get-PSDrive C).Free / 1GB, 2)

# UEFI CA Probes
$OS_Cert = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot\Servicing" -Name "UEFICA2023Status" -ErrorAction SilentlyContinue).UEFICA2023Status
if (!$OS_Cert) { $OS_Cert = "NotStarted" }
$HW_Cert = "Old/Missing (2011)"; $HW_Col = "Yellow"
try {
    $DBBytes = (Get-SecureBootUEFI db).bytes
    if ([System.Text.Encoding]::ASCII.GetString($DBBytes) -match "Windows UEFI CA 2023") { $HW_Cert = "Updated (2023)"; $HW_Col = "Green" }
} catch { $HW_Cert = "Access Blocked"; $HW_Col = "Red" }
$OS_Col = if ($OS_Cert -eq "Updated") { "Green" } else { "Yellow" }

$Pwr = "Mains (AC)"; $P_Col = "White"; $Lvl = "N/A (Desktop)"; $L_Col = "White"
if ($Batt) {
    $Pwr = if ($Batt.BatteryStatus -eq 1) { "Battery (DC)" } else { "Mains (AC)" }
    $P_Col = if ($Pwr -match "Battery") { "Yellow" } else { "White" }
    $Lvl = "$($Batt.EstimatedChargeRemaining)%"; $L_Col = if ($Batt.EstimatedChargeRemaining -lt 50) { "Red" } else { "Green" }
}

# --- 4. ANALYSIS ENGINE ---
$WarningFlags = @()
$SuitColor = "Green"
if ($PartStyle -eq "MBR") { $WarningFlags += "[!] WARNING: Legacy MBR Partition detected."; $SuitColor = "Yellow" }
if ($BL -eq 1) { $WarningFlags += "[!] CRITICAL: Drive is Encrypted."; $SuitColor = "Red" }
if ($Pwr -match "Battery") { $WarningFlags += "[!] WARNING: Running on Battery."; $SuitColor = "Red" }
if ($Reboot) { $WarningFlags += "[!] WARNING: Pending Windows Update."; if ($SuitColor -ne "Red") { $SuitColor = "Yellow" } }
$SuitReport = if ($WarningFlags.Count -eq 0) { "[+] System meets all safety requirements. Ready for BIOS update." } else { $WarningFlags -join " `n`n" }

$CertReport = "[?] INFO: 'NotStarted' or 'Old' status is normal; Microsoft is using a controlled rollout for the UEFI CA 2023 certificates."
$CertColor = "Gray"
if ($OS_Cert -eq "Updated" -and $HW_Cert -match "Updated") {
    $CertReport = "[+] SUCCESS: Both System OS and Motherboard Hardware trust the 2023 Certificates."
    $CertColor = "Green"
}

# --- 5. DISPLAY ---
Clear-Host
Write-Host "`n"
Out-Both "╔$($("═" * ($MaxW - ($Pad.Length * 2) - 2)))╗" "Cyan"
Write-Centered "Mike's Unboxing Pre-BIOS Check Utility" "Cyan"
Write-Centered "Version $Version | Copyright (c) 2026" "White"
Write-Centered "Licensed for personal & Non profit use only" "White"
Out-Both "╚$($("═" * ($MaxW - ($Pad.Length * 2) - 2)))╝" "Cyan"
Out-Both ("─" * ($MaxW - ($Pad.Length * 2))) "Gray"

Out-Both "[MOTHERBOARD & BIOS]" "Cyan"
Write-Aligned "Manufacturer" $Base.Manufacturer
Write-Aligned "Board Model" $Base.Product
Write-Aligned "Board Revision" $BoardRev
Write-Aligned "BIOS Version" $BIOS.SMBIOSBIOSVersion
Write-Aligned "BIOS Date" $FormattedDate
Write-Aligned "Detection Method" $DetectMethod "Gray"

Write-Host "`n"; $ReportBuffer += "`r`n"
Out-Both "[OS & SYSTEM STATS]" "Cyan"
Write-Aligned "Processor" $CPU_Name
Write-Aligned "Installed RAM" "$TotalRAM GB"
Write-Aligned "Graphics Card" $GPU
Write-Aligned "Windows Edition" $OSEdition
Write-Aligned "Feature Version" $OSVer
Write-Aligned "Partition Style" $PartStyle $Part_Col
Write-Aligned "Windows Update" $Upd_Txt $Upd_Col
Write-Aligned "Secure Boot" $SB_Txt $SB_Col
Write-Aligned "TPM 2.0" $TPM_Txt $TPM_Col
Write-Aligned "Drive Encryption" $BL_Txt $BL_Col
Write-Aligned "C: Free Space" "$CSpace GB"

Write-Host "`n"; $ReportBuffer += "`r`n"
Out-Both "[UEFI CERTIFICATE PROBE]" "Cyan"
Write-Aligned "Hardware (2023 CA)" $HW_Cert $HW_Col
Write-Aligned "Windows OS (2023 CA)" $OS_Cert $OS_Col

Write-Host "`n"; $ReportBuffer += "`r`n"
Out-Both "[POWER STATUS]" "Cyan"
Write-Aligned "Source" $Pwr $P_Col
Write-Aligned "Level" $Lvl $L_Col

Write-Host "`n"; $ReportBuffer += "`r`n"
Out-Both "[ANALYSIS: BIOS UPDATE SUITABILITY]" "Cyan"
Write-Wrapped-Centered $SuitReport $SuitColor

Write-Host "`n"; $ReportBuffer += "`r`n"
Out-Both "[ANALYSIS: UEFI CA 2023 STATUS]" "Cyan"
Write-Wrapped-Centered $CertReport $CertColor

Write-Host "`n"; $ReportBuffer += "`r`n"
Out-Both ("─" * ($MaxW - ($Pad.Length * 2))) "Gray"
Write-Centered "[DISCLAIMER]" "Cyan"
Write-Wrapped-Centered "This utility provides information for system preparation only. BIOS flashing is a high-risk operation. The author assumes no liability for hardware failure or data loss resulting from use." "Gray"

# --- 6. ACTIONS ---
Write-Host "`n"
Write-Host "$Pad» Save report to Desktop? [Y/N]: " -NoNewline
if ((Read-Host).ToUpper() -eq "Y") {
    $Path = "$([Environment]::GetFolderPath('Desktop'))\Mikes_BIOS_Report.txt"
    $ReportBuffer | Out-File $Path -Encoding UTF8
    Write-Host "$Pad[✔] Success! Saved to: $Path" -ForegroundColor Green
}

Write-Host "$Pad» Search for BIOS drivers? [Y/N]: " -NoNewline
if ((Read-Host).ToUpper() -eq "Y") {
    $SupportUrl = Get-BiosSupportUrl -Manufacturer $Base.Manufacturer -BoardProduct $Base.Product -SerialNumber $BIOS.SerialNumber -SystemProduct $CSProd.Name
    if (-not $SupportUrl) { $SupportUrl = "https://www.google.com/search?q=$($Base.Manufacturer)+$($Base.Product)+BIOS+drivers" }
    Start-Process $SupportUrl
}

Write-Host "`n$Pad Execution Complete. Press ENTER to close..." -ForegroundColor Gray
$null = Read-Host
