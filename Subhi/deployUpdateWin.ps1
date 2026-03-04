###debut et premiere version du script. 

<#
.SYNOPSIS
    Deploiment de mise à jours windows a distance  
.DESCRIPTION
    Demande a l'ordinateur cible si il est present si oui il se connecte, si y a besoin de mise à joue il la deploie 
.AUTHOR
    Chalhoub Subhi
.VERSION
    1.1 - 04.03.2026
#>


$target = "10.229.32.51"
$success = $false


function PingTarget {
for ($i = 1; $i -le 4; $i++) { #TODO: 
Write-Host "Passage $i : Test de la connectivité pour $target..." #TODO: put all masseges in ENGLISH PLEASE (*/ω＼*)
    
    
    if (Test-Connection -ComputerName $target -Count 1 -Quiet) { #TODO: put all the "if" in one function 
        Write-Host " the PC is dead !!!!" -ForegroundColor Green 
        $success = $true
        break 
    } else {
        Write-Host "Le PC est mort." -ForegroundColor red
        
       
        if ($i -eq 4) {
            Write-Host "ÉCHEC FINAL : Après 4 tentatives tu est l'erreur ." -ForegroundColor Yellow
        } else {
            
            Start-Sleep -Seconds 2 
        }
    }
}

}

function ConnectToTarget {
# TODO: connect to target, if it can't connect, send error message
# TODO: otherwise, continue the script.   
}
# TODO: do all the todo about the other function and the TODO
PingTarget

ConnectToTarget





