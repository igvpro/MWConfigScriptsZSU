# ================================
# USB Report Script with WMI Serial Numbers
# ================================

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
        body { font-family: Arial; background-color: #f4f4f4; }
        h2 { color: #008B8B; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
        th { background-color: #eee; }
    </style>
</head>
<body>
<h1>USB Report - $computerName</h1>
<h2>Disk Level IDs</h2>
<table>
<tr>
<th>Disk Number</th><th>Friendly Name</th><th>Serial Number</th><th>Unique ID</th><th>Partition Style</th>
</tr>
"@

# Get USB disks
$usbDisks = Get-Disk | Where-Object BusType -eq 'USB'

# Get all physical media serials
$physicalDisks = Get-WmiObject Win32_PhysicalMedia | Where-Object { $_.SerialNumber -ne $null }

foreach ($disk in $usbDisks) {
    # Match disk Path to Win32_PhysicalMedia
    $serialObj = $physicalDisks | Where-Object { $_.Tag -eq $disk.Path }
    $serial = if ($serialObj) { $serialObj.SerialNumber.Trim() } else { "N/A" }

    $uniqueId = if ($disk.UniqueId) { $disk.UniqueId } else { "N/A" }

    # Console output
    Write-Host "`n--- Disk $($disk.Number): $($disk.FriendlyName) ---" -ForegroundColor Yellow
    Write-Host "Serial Number: $serial"
    Write-Host "Unique ID: $uniqueId"
    Write-Host "Partition Style: $($disk.PartitionStyle)"

    # Append to HTML
    $html += "<tr><td>$($disk.Number)</td><td>$($disk.FriendlyName)</td><td>$serial</td><td>$uniqueId</td><td>$($disk.PartitionStyle)</td></tr>"
}

$html += "</table>"

# USB Partition IDs
$html += "<h2>Partition Level IDs</h2>"
$html += "<table><tr><th>Disk Number</th><th>Partition Number</th><th>Type</th><th>GUID</th></tr>"

$partitions = Get-Disk | Where-Object BusType -eq 'USB' | Get-Partition

foreach ($p in $partitions) {
    Write-Host "Disk $($p.DiskNumber) Partition $($p.PartitionNumber) Type $($p.Type) GUID $($p.Guid)"
    $html += "<tr><td>$($p.DiskNumber)</td><td>$($p.PartitionNumber)</td><td>$($p.Type)</td><td>$($p.Guid)</td></tr>"
}

$html += "</table></body></html>"

# Save HTML to desktop
$html | Out-File -FilePath $outputFile -Encoding UTF8

Write-Host "`nHTML report saved to $outputFile" -ForegroundColor Green
