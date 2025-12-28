#==========================
# Full System Info Logger (HTML 3-column layout)
#==========================

# Global variable for output file
$computerName = $env:COMPUTERNAME
$date = Get-Date -Format "yyyyMMdd"
$script:OutputFile = "${computerName}_${date}.html"

# Create or clear the file
New-Item -Path $script:OutputFile -ItemType File -Force | Out-Null

# Start HTML document
$htmlHeader = @"
<!DOCTYPE html>
<html lang='en'>
<head>
<meta charset='UTF-8'>
<title>System Info - $computerName</title>
<style>
    body { font-family: Arial, sans-serif; font-size: 12px; margin: 20px; }
    h1 { text-align: center; }
    table { border-collapse: collapse; width: 100%; margin-bottom: 20px; }
    th, td { border: 1px solid #ddd; padding: 8px; text-align: left; vertical-align: top; }
    th { background-color: #f2f2f2; }
    .preformatted { white-space: pre-wrap; font-family: Consolas, monospace; font-size: 11px; }
</style>
</head>
<body>
<h1>System Info - $computerName</h1>
<table>
<tr>
"@
Add-Content -Path $script:OutputFile -Value $htmlHeader

#==========================
# Collect Data
#==========================

# 1. Basic Info
$dateInfo = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$basicInfo = "Date: $dateInfo`nComputer Name: $computerName"

# 2. CPU Info
$cpus = Get-WmiObject Win32_Processor
$cpuInfo = ""
foreach ($cpu in $cpus) {
    $cpuInfo += "Name: $($cpu.Name)`nCores/Logical: $($cpu.NumberOfCores)/$($cpu.NumberOfLogicalProcessors)`nID: $($cpu.ProcessorId)`n"
}

# 3. Motherboard Info
$boards = Get-WmiObject Win32_BaseBoard
$boardInfo = ""
foreach ($board in $boards) {
    $boardInfo += "Manufacturer: $($board.Manufacturer)`nProduct: $($board.Product)`nSerial: $($board.SerialNumber)`n"
}

# 4. RAM Info
$ramModules = Get-WmiObject Win32_PhysicalMemory
$ramInfo = ""
$totalRAM = 0
foreach ($ram in $ramModules) {
    $sizeGB = [math]::Round($ram.Capacity / 1GB, 2)
    $ramInfo += "Capacity: $sizeGB GB, Speed: $($ram.Speed) MHz`n"
    $totalRAM += $sizeGB
}
$ramInfo += "Total RAM: $totalRAM GB"

# 5. Hard Disk Info
$disks = Get-WmiObject Win32_PhysicalMedia | Where-Object { $_.SerialNumber -ne $null }
$diskInfo = ""
$counter = 1
foreach ($disk in $disks) {
    $diskInfo += "Disk $counter Serial: $($disk.SerialNumber.Trim())`n"
    $counter++
}

# 6. IP Configuration
$ipconfigOutput = ipconfig /all | Out-String

#==========================
# Write 3-column table (top section)
#==========================

# First row: Date | Computername | CPU
Add-Content -Path $script:OutputFile -Value "<tr>"
Add-Content -Path $script:OutputFile -Value "<td class='preformatted'>$dateInfo</td>"
Add-Content -Path $script:OutputFile -Value "<td class='preformatted'>$computerName</td>"
Add-Content -Path $script:OutputFile -Value "<td class='preformatted'>$cpuInfo</td>"
Add-Content -Path $script:OutputFile -Value "</tr>"

# Second row: Motherboard | RAM | Hard disks
Add-Content -Path $script:OutputFile -Value "<tr>"
Add-Content -Path $script:OutputFile -Value "<td class='preformatted'>$boardInfo</td>"
Add-Content -Path $script:OutputFile -Value "<td class='preformatted'>$ramInfo</td>"
Add-Content -Path $script:OutputFile -Value "<td class='preformatted'>$diskInfo</td>"
Add-Content -Path $script:OutputFile -Value "</tr>"

# Close top table
Add-Content -Path $script:OutputFile -Value "</table>"

#==========================
# IP Configuration Section
#==========================

Add-Content -Path $script:OutputFile -Value "<h2>IP Configuration</h2>"
Add-Content -Path $script:OutputFile -Value "<pre class='preformatted'>$ipconfigOutput</pre>"

# Close HTML
Add-Content -Path $script:OutputFile -Value "</body></html>"

Write-Host "Full system info saved to HTML file: $script:OutputFile"
