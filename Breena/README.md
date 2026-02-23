# BREENA - POWERSHELL
## Hardware Monitoring
(Pour le professeur, c'est un sketch de ma idee et je dois voir si c'est possible de faire. Et je vais traduire a francais apres, maintenant ecrire en anglais est plus facile)
<p>
Powershell base:
Get-CimInstance
</p>

CPU, RAM, DISKs

## Exercises Concept
### Getting the hist of it
- Check RAM usage from your own computer by using powershell.

- Check CPU usage from your own computer by using powershell.

- Check DISK usage and name of your own computer by using powershell.

### Real exercise
#### WindowsFetch
<p>
Make a program like Fastfetch/Neofetch in Powershell using what we learnt before, the program must check for the name of the computer, check for CPU, RAM, DISKs AND their usage (Meaning that we can see the max cores or GBs and what is being used right now.) and the target can be an IP (#CHECK IF THIS IS POSSIBLE) so we could check the status of a potential server or distant PC.
</p>

<p>
For more information or an image representation of what you must do, you can search "Fastfetch" in Google.
</p>

## Exercises (concept) solution
### Getting the hist of it
#### RAM USAGE
```powershell
Get-CimInstance Win32_OperatingSystem | Select-Object TotalVisibleMemorySize, FreePhysicalMemory
```
#### CPU USAGE
```powershell
Get-CimInstance Win32_Processor | Select-Object Name, LoadPercentage
```

#### DISK USAGE AND PC NAME
```powershell
Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | Select-Object DeviceID, Size, FreeSpace
```
```powershell
Get-CimInstance Win32_ComputerSystem | Select-Object Name
```

### Real Exercise (Concept) solution
```powershell
# WindowsFetch.ps1

# This parameter allows the user to specify an IP or hostname. 
# If nothing is typed, it targets the local PC ("localhost").
param (
    [string]$TargetPC = "localhost"
)

try {
    # Set up parameters to pass to our CIM queries
    $cimParams = @{ ErrorAction = "Stop" }
    if ($TargetPC -ne "localhost") {
        $cimParams.Add("ComputerName", $TargetPC)
    }

    # 1. Fetching the Data
    $sys  = Get-CimInstance Win32_ComputerSystem @cimParams
    $os   = Get-CimInstance Win32_OperatingSystem @cimParams
    $cpu  = Get-CimInstance Win32_Processor @cimParams
    $disks = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" @cimParams

    # 2. Calculating RAM (Win32_OperatingSystem returns KB, so we divide by 1MB to get GB)
    $totalRamGB = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $freeRamGB  = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
    $usedRamGB  = $totalRamGB - $freeRamGB

    # 3. Formatting CPU (Handling potential dual-CPU setups and grabbing load percentage)
    $cpuName = ($cpu.Name) -join ", "
    $cpuLoad = ($cpu | Measure-Object -Property LoadPercentage -Average).Average

    # 4. Displaying the Output (Neofetch/Fastfetch style)
    Write-Host ""
    Write-Host "   _  _        " -ForegroundColor Cyan -NoNewline; Write-Host "$($os.CSName)" -ForegroundColor White
    Write-Host "  | || |       " -ForegroundColor Cyan -NoNewline; Write-Host "--------------------" -ForegroundColor Gray
    Write-Host "  | || |       " -ForegroundColor Cyan -NoNewline; Write-Host "OS:   " -ForegroundColor Cyan -NoNewline; Write-Host "$($os.Caption)"
    Write-Host "  | || |       " -ForegroundColor Cyan -NoNewline; Write-Host "CPU:  " -ForegroundColor Cyan -NoNewline; Write-Host "$cpuName ($cpuLoad% Load)"
    Write-Host "   \__/        " -ForegroundColor Cyan -NoNewline; Write-Host "RAM:  " -ForegroundColor Cyan -NoNewline; Write-Host "$usedRamGB GB / $totalRamGB GB"
    
    # Loop through each disk to calculate Bytes to GB and display
    foreach ($disk in $disks) {
        $totalDiskGB = [math]::Round($disk.Size / 1GB, 2)
        $freeDiskGB  = [math]::Round($disk.FreeSpace / 1GB, 2)
        $usedDiskGB  = $totalDiskGB - $freeDiskGB
        
        Write-Host "               " -NoNewline; Write-Host "Disk ($($disk.DeviceID)): " -ForegroundColor Cyan -NoNewline; Write-Host "$usedDiskGB GB / $totalDiskGB GB"
    }
    Write-Host ""

} catch {
    Write-Error "Could not connect to $TargetPC. Please check if the IP is correct and if WinRM is enabled on the target."
}
```

## Testing Platform
- Oracle VirtualBox
- Windows 10 VM
- Powershell version : MAJ 5, MIN 1, BUILD 19041 REVISION 6456

(Or for friends : 5.1.19041.6456)


## Source
https://learn.microsoft.com/fr-fr/powershell/module/cimcmdlets/get-ciminstance?view=powershell-7.5