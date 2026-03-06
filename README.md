<p align="center">
  <img src="logo.ico" width="150" title="Mike's Unboxing Logo">
</p>

# Mike's Unboxing Pre-BIOS Check Utility v4.5.8.7
**Comprehensive hardware audit and UEFI safety tool for BIOS updates.**

[![Version](https://img.shields.io/badge/version-4.5.8.7-cyan)](https://github.com/YourUsername/PreBIOSCheck/releases)
[![License](https://img.shields.io/badge/license-Non--Commercial-orange)](#-disclaimer--terms-of-use)
[![Platform](https://img.shields.io/badge/platform-Windows-blue)](https://github.com/YourUsername/PreBIOSCheck)

---

## 🚀 Key Features
- **Universal BIOS Date Fix:** Intelligent scraping engine for **Z890**, **X870**, and **Core Ultra** platforms.
- **OEM String Recovery:** Fixed truncation issues on **Dell** and other OEM systems (e.g., "2024" no longer appears as "202").
- **UEFI CA 2023 Remediation:** **[NEW]** Detects if Windows is blocking the new 2023 Secure Boot certificates and offers a one-click manual force-update.
- **Partition Style Check:** Identifies **MBR** vs **GPT** to prevent boot-loops after flashing.
- **Security Audit:** Real-time status for **TPM 2.0**, **Secure Boot**, and **BitLocker** encryption.
- **Power & Update Guard:** Verifies AC power connectivity and checks for pending Windows Updates.

---

## 📥 How to Run (Direct Copy & Paste)
To bypass Windows "File Blocked" errors and SmartScreen warnings, we recommend running the utility directly via PowerShell.

1. **Open PowerShell as Admin:** Right-click the **Start Button** and select **Terminal (Admin)** or **PowerShell (Admin)**.
2. **Copy the Command:** Highlight and copy the entire code block below:

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; irm "https://pastebin.com/raw/2XkDXrfP" | iex

Paste and Run: Right-click in the PowerShell window to paste, then press Enter.

View Results: The utility will fetch the latest v4.5.8.7 logic and display your audit instantly.

Save Report: Follow the on-screen prompt to save a copy of the results to your Desktop for future reference.

🛠️ Important: UEFI CA 2023 Fix
If the utility offers to force-deploy the 2023 Certificates:

Two (2) Restarts are Required: You must restart your computer twice for the update to register in the firmware and for the utility to show a "Green" status.

Why? The first restart applies the variables; the second allows the Windows Servicing Stack to verify the change.

🛑 Usage Restrictions
This tool is FREE for the community. If you paid for this software, you have been scammed.
Commercial redistribution or resale of this utility is strictly prohibited.

⚠️ Disclaimer & Terms of Use
Do not entirely rely on this information. Always perform your own due diligence. Mike's Unboxing and Community are here to help, but any BIOS updates are performed at YOUR OWN RISK. We are in no way responsible for any hardware failure, "bricks," or data loss.

Would you like me to create a dedicated "Troubleshooting" section for common PowerShell paste errors to add to the bottom of the page?
