<p align="center">
  <img src="MUL logo.ico" width="150" title="Mike's Unboxing Logo">
</p>

# Mike's Unboxing Pre-BIOS Check Utility v4.5.8.4
**Comprehensive hardware, security, and power audit for safer BIOS updates.**

[![Version](https://img.shields.io/badge/version-4.5.8.4-cyan)](https://github.com/YourUsername/PreBIOSCheck/releases)
[![License](https://img.shields.io/badge/license-Non--Commercial-orange)](#-disclaimer--terms-of-use)
[![Platform](https://img.shields.io/badge/platform-Windows-blue)](https://github.com/YourUsername/PreBIOSCheck)

---

## 🚀 Key Features
- **Universal BIOS Date Fix:** Enhanced Regex-based scraping for accurate date detection on **Z890**, **X870**, and **Core Ultra** platforms.
- **Partition Style Check:** Instantly identifies if you are on **MBR** or **GPT**.
- **CSM Warning System:** Alerts you if a BIOS flash might hide your MBR drives.
- **BitLocker Detection:** Critical reminders to manage encryption to prevent recovery key lockouts.
- **Power Analysis:** Integrated safety check for laptop battery levels and AC source.
- **UEFI CA 2023 Analysis:** Checks your system's readiness for Microsoft's new Secure Boot certificate rollout.
- **Windows Update Monitor:** Detects pending reboots to ensure a clean environment for flashing.

---

## 📥 How to Run (Recommended)
We no longer require you to download and unblock `.exe` or `.ps1` files. You can now run the utility directly via a **PowerShell Stub**.

1. Right-click the **Windows Start Button** and select **Terminal (Admin)** or **PowerShell (Admin)**.
2. Copy the command below and paste it into the window:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('[https://raw.githubusercontent.com/YOUR_GITHUB_USER/YOUR_REPO/main/PreBIOSCheck.ps1](https://raw.githubusercontent.com/YOUR_GITHUB_USER/YOUR_REPO/main/PreBIOSCheck.ps1)'))
