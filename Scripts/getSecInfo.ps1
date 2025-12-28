Write-Host "===== WINDOWS SECURITY STATUS AUDIT =====" -ForegroundColor Cyan

# --- Windows Defender / Antivirus ---
Write-Host "`n[Windows Defender]" -ForegroundColor Yellow
if (Get-Command Get-MpComputerStatus -ErrorAction SilentlyContinue) {
    Get-MpComputerStatus | Select `
        AMServiceEnabled,
        AntispywareEnabled,
        AntivirusEnabled,
        BehaviorMonitorEnabled,
        RealTimeProtectionEnabled,
        IoavProtectionEnabled,
        NISEnabled,
        IsTamperProtected,
        OnAccessProtectionEnabled,
        FullScanAge,
        QuickScanAge
} else {
    Write-Host "Defender cmdlets not available"
}

# --- Defender Preferences ---
Write-Host "`n[Defender Preferences]" -ForegroundColor Yellow
Get-MpPreference | Select `
    DisableRealtimeMonitoring,
    DisableBehaviorMonitoring,
    DisableIOAVProtection,
    DisableScriptScanning,
    EnableControlledFolderAccess,
    PUAProtection

# --- Firewall Status ---
Write-Host "`n[Windows Firewall]" -ForegroundColor Yellow
Get-NetFirewallProfile | Select Name, Enabled, DefaultInboundAction, DefaultOutboundAction

# --- SmartScreen ---
Write-Host "`n[SmartScreen]" -ForegroundColor Yellow
Get-ItemProperty `
"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" `
-Name SmartScreenEnabled -ErrorAction SilentlyContinue

# --- User Account Control (UAC) ---
Write-Host "`n[UAC]" -ForegroundColor Yellow
Get-ItemProperty `
"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" |
Select EnableLUA, ConsentPromptBehaviorAdmin, PromptOnSecureDesktop

# --- BitLocker ---
Write-Host "`n[BitLocker]" -ForegroundColor Yellow
if (Get-Command Get-BitLockerVolume -ErrorAction SilentlyContinue) {
    Get-BitLockerVolume | Select MountPoint, VolumeStatus, ProtectionStatus, EncryptionPercentage
} else {
    Write-Host "BitLocker not available"
}

# --- Secure Boot ---
Write-Host "`n[Secure Boot]" -ForegroundColor Yellow
try {
    Confirm-SecureBootUEFI
} catch {
    Write-Host "Secure Boot not supported or legacy BIOS"
}

# --- Core Security Services ---
Write-Host "`n[Security Services]" -ForegroundColor Yellow
$services = "WinDefend","wscsvc","SecurityHealthService","mpssvc"
Get-Service $services | Select Name, Status, StartType

# --- Windows Update ---
Write-Host "`n[Windows Update]" -ForegroundColor Yellow
Get-Service wuauserv | Select Status, StartType

# --- VBS / Credential Guard ---
Write-Host "`n[VBS / Credential Guard]" -ForegroundColor Yellow
Get-ItemProperty `
"HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard" `
-ErrorAction SilentlyContinue |
Select EnableVirtualizationBasedSecurity, RequirePlatformSecurityFeatures

# --- Exploit Protection ---
Write-Host "`n[Exploit Protection]" -ForegroundColor Yellow
Get-ProcessMitigation -System

# --- LSASS Protection ---
Write-Host "`n[LSA Protection]" -ForegroundColor Yellow
Get-ItemProperty `
"HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" `
-Name RunAsPPL -ErrorAction SilentlyContinue

# --- PAUSE ---
Write-Host "`n===== AUDIT COMPLETE =====" -ForegroundColor Green
Write-Host "Press any key to exit..." -ForegroundColor Cyan
[void][System.Console]::ReadKey($true)
