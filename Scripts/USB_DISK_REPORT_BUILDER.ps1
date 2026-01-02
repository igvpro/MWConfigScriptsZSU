# Function to get Serial Number from Win32_PhysicalMedia
function Get-DiskSerial {
    param($diskNumber)
    $disk = Get-WmiObject Win32_PhysicalMedia | Where-Object { $_.Tag -eq "\\.\PHYSICALDRIVE$diskNumber" -and $_.SerialNumber -ne $null }
    if ($disk) { return $disk.SerialNumber.Trim() }
    else { return "N/A" }
}

# Get computer name
$computerName = $env:COMPUTERNAME

# Get current date and time
$date = Get-Date -Format "ddMMyyyy"
$time = Get-Date -Format "HH_mm_ss"

# Output HTML file path on Desktop
$outputFile = "$([Environment]::GetFolderPath('Desktop'))\$computerName-USB-$date-$time.html"

# HTML Header
$html = @"
<html>
<head>
    <title>USB Report - $computerName</title>
    <style>
        body { font-family: Arial; }
        table { border-collapse: collapse; width: 50%; }
        th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
        th { background-color: #eee; }
    </style>
</head>
<body>
<h1>USB Report - $computerName</h1>
<table>
<tr><th>Property</th><th>Value</th></tr>
"@

# Get all USB disks
$usbDisks = Get-Disk | Where-Object BusType -eq 'USB'

foreach ($disk in $usbDisks) {
    $uniqueId = if ($disk.UniqueId) { $disk.UniqueId } else { "N/A" }
    $serial = Get-DiskSerial -diskNumber $disk.Number

    # Console output
    Write-Host "`nDisk $($disk.Number) - $($disk.FriendlyName)"
    Write-Host "Unique ID: $uniqueId"
    Write-Host "Serial Number: $serial"

    # HTML table rows (two rows per disk)
    $html += "<tr><td>Disk $($disk.Number) Unique ID</td><td>$uniqueId</td></tr>"
    $html += "<tr><td>Disk $($disk.Number) Serial Number</td><td>$serial</td></tr>"
}

$html += "</table></body></html>"

# Save HTML to desktop
$html | Out-File -FilePath $outputFile -Encoding UTF8

Write-Host "`nHTML report saved to $outputFile" -ForegroundColor Green
