###debut et premiere version du script. 


$pcCible = "10.229.32.51"
$succes = $false

for ($passage = 1; $passage -le 4; $passage++) {
    Write-Host "Passage $passage : Test de la connectivité pour $pcCible..."
    
    
    if (Test-Connection -ComputerName $pcCible -Count 1 -Quiet) {
        Write-Host " Le PC est en vie !" -ForegroundColor Green
        $succes = $true
        break 
    } else {
        Write-Host "Le PC est mort." -ForegroundColor red
        
       
        if ($passage -eq 4) {
            Write-Host "ÉCHEC FINAL : Après 4 tentatives tu est l'erreur ." -ForegroundColor Yellow
        } else {
            
            Start-Sleep -Seconds 2 
        }
    }
}

