<p align="center">
  <img src="logo.ico" alt="Mike's Unboxing Logo" width="200">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-4.6.1.3-00f2ff" alt="Version 4.6.1.3">
  <img src="https://img.shields.io/badge/license-Non--Commercial-orange" alt="Non-Commercial License">
  <img src="https://img.shields.io/badge/platform-Windows-0078d4" alt="Platform Windows">
</p>

# Mike's Unboxing Pre-BIOS Check Utility

**Comprehensive hardware audit and UEFI safety tool for BIOS updates.**

This specialized PowerShell diagnostic tool verifies system readiness before performing a BIOS/UEFI firmware update. It automates the process of checking hardware age, security states, and power requirements to prevent "bricked" motherboards or BitLocker recovery loops.

| Feature | Logic / Threshold |
| :--- | :--- |
| **BIOS Age** | Green (<6m), Yellow (6-12m), Red (>12m) |
| **OEM Links** | Dynamic Serial/Service Tag lookup (Dell, HP, Lenovo, Acer, etc.) |
| **Security** | UEFI CA 2023 Signature Database (db) Probe |
| **Safety** | BitLocker Status, AC/DC Power, GPT/MBR, Pending Updates |

## 🎯 What This Tool Does
This utility performs a deep-scan of the local WMI and CIM namespaces to provide a "Go/No-Go" status for firmware maintenance. 

### 1. Precision BIOS Date Engine
The tool solves common "broken date" or "Check BIOS" errors found in standard scripts. It parses both native `DateTime` objects and manual 8-digit strings to calculate a precise age in months.

### 2. Universal OEM Support Engine
The script dynamically builds support URLs. For brands like Dell, HP, Lenovo, and Acer, it prioritizes the **System Serial Number** or **Service Tag** to land you on the exact "as-configured" support page.

### 3. UEFI CA 2023 Security Probe
A critical check for Windows 11 systems, probing the `Allowed Signature Database (db)` for the latest Microsoft certificates to prevent Secure Boot violations after a flash.

---

## 🚀 How To Run
To ensure the tool can access Secure Boot variables and BitLocker status, follow these steps:

1. **Open PowerShell as Administrator** (Right-click the Start button > Terminal/PowerShell Admin).
2. **Copy and Paste** the following command block into the window and press **Enter**:

```Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; irm "https://pastebin.com/raw/2XkDXrfP" | iex```

---

## 📂 Interactive Actions & Reporting
Upon completion, the tool offers context-aware actions based on your system's live telemetry:

* **BitLocker Suspension:** If encryption is active, the tool offers to **Suspend BitLocker** for one reboot cycle to prevent recovery key lockouts.
* **Certificate Force Update:** Option to **Force Windows to the new UEFI CA 2023 certificate** if the system is out of sync.
* **OEM Support Access:** Automatically opens your browser to the **manufacturer's support site** for your specific serial number.
* **Desktop Report:** Saves the full telemetry and analysis as a **.txt file on your Desktop**. 
    
---
**Disclaimer:** Licensed for personal & non-profit use only. (c) 2026 Mike's Unboxing.
