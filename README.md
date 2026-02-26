<p align="center">
  <img src="logo.ico" width="150" title="Mike's Unboxing Logo">
</p>

# Mike's Unboxing Pre-BIOS Check Utility v4.5.8.4
**Ensure your system is ready for a BIOS update with one click.**

[![Version](https://img.shields.io/badge/version-4.5.8.4-cyan)](https://github.com/YourUsername/PreBIOSCheck/releases)
[![License](https://img.shields.io/badge/license-Non--Commercial-orange)](#-disclaimer--terms-of-use)
[![Platform](https://img.shields.io/badge/platform-Windows-blue)](https://github.com/YourUsername/PreBIOSCheck)

---

## 🚀 Key Features
- **Universal BIOS Date Fix:** Enhanced Regex-based scraping for accurate date detection on **Z890**, **X870**, and **Core Ultra** platforms.
- **Partition Style Check:** Instantly identifies if you are on **MBR** or **GPT**.
- **CSM Warning System:** Alerts you if a BIOS flash might hide your MBR drives.
- **BitLocker Detection:** Reminds you to suspend encryption to prevent recovery key lockouts.
- **Power Analysis:** Safety check for battery levels and AC source (required for laptops).
- **Windows Update Monitor:** Detects pending reboots that could interfere with the flashing process.
- **UEFI CA 2023 Analysis:** Checks readiness for Microsoft’s new Secure Boot certificate rollout.

---

## 📥 How to Run (Direct Copy & Paste)
We have transitioned to a **Direct Execution** method to bypass "file blocked" errors and SmartScreen warnings. No download is required.

1. **Open PowerShell as Admin:** Right-click the **Start Button** and select **Terminal (Admin)** or **PowerShell (Admin)**.
2. **Copy the Command:** Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; irm "https://pastebin.com/raw/2XkDXrfP" | iex
3. **Paste and Run:** Right-click in the PowerShell window to paste the command, then press **Enter**.
4. **View Results:** The utility will pull the latest version from Pastebin and display your system audit instantly.
5. **Save Report:** Follow the on-screen prompt to save a copy of the results to your Desktop for future reference.

---

## 🛠️ Internal Debugging
Version 4.5.8.4 now includes a **Detection Method** field under the Motherboard section. This informs you if the data was pulled via **CIM (Modern)**, **WMI (Legacy)**, or the new **Regex Scraper**, ensuring you know exactly how the script is interacting with your firmware.

---

## 🛑 Usage Restrictions
This tool is **FREE** for the community. If you paid for this software, you have been scammed. 
**Commercial redistribution or resale of this utility is strictly prohibited.**

---

## ⚠️ Disclaimer & Terms of Use
**Do not entirely rely on this information. Always perform your own due diligence.** Mike's Unboxing and Community are here to help, but any BIOS updates are performed at **YOUR OWN RISK**. We are in no way responsible for any issues, "bricks," or data loss that may occur during the process.

---
