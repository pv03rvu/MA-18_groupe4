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
SOLUTION DISK HERE
```
```powershell
SOLUTION PC NAME HERE
```

### Real Exercise (Concept) solution
```powershell
SOLUTION HERE
```

## Testing Platform
- Oracle VirtualBox
- Windows 10 VM
- Powershell version : MAJ 5, MIN 1, BUILD 19041 REVISION 6456

(Or for friends : 5.1.19041.6456)


## Source
https://learn.microsoft.com/fr-fr/powershell/module/cimcmdlets/get-ciminstance?view=powershell-7.5