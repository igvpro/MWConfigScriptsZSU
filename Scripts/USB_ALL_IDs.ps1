Write-Host "=== USB DISK LEVEL IDS ===" -ForegroundColor Cyan

$usbDisks = Get-Disk | Where-Object BusType -eq USB

foreach ($disk in $usbDisks) {
    Write-Host "`n--- Disk $($disk.Number) ---" -ForegroundColor Yellow
    $disk | Select Number,FriendlyName,SerialNumber,UniqueId,PartitionStyle | Format-List
}

Write-Host "`n=== USB PARTITION IDS ===" -ForegroundColor Cyan

Get-Disk | Where-Object BusType -eq USB |
Get-Partition |
Select DiskNumber,PartitionNumber,Type,Guid |
Format-Table -AutoSize

Write-Host "`n=== USB VOLUME IDS ===" -ForegroundColor Cyan

Get-Disk | Where-Object BusType -eq USB |
Get-Partition |
Get-Volume |
Select DriveLetter,FileSystem,FileSystemLabel,UniqueId |
Format-Table -AutoSize

Write-Host "`n=== USB WMI VOLUME IDS ===" -ForegroundColor Cyan

Get-CimInstance Win32_Volume |
Where-Object DriveType -eq 2 |
Select DriveLetter,DeviceID,FileSystem,Capacity |
Format-Table -AutoSize

Write-Host "`n=== USB PNP IDS (ALWAYS PRESENT) ===" -ForegroundColor Cyan

Get-PnpDevice -Class DiskDrive |
Where-Object InstanceId -like "*USB*" |
Select FriendlyName,InstanceId |
Format-List

Write-Host "`n=== USB REGISTRY IDS (USBSTOR) ===" -ForegroundColor Cyan

Get-ChildItem HKLM:\SYSTEM\CurrentControlSet\Enum\USBSTOR -Recurse -ErrorAction SilentlyContinue |
Get-ItemProperty |
Select FriendlyName,SerialNumber |
Format-Table -AutoSize

Write-Host "`n=== DONE ==="
Pause
