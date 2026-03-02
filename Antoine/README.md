# Exercice Execution à distance : 
# 1. Objectifs
- Mettre en œuvre PowerShell Remoting pour exécuter une commande sur une machine distante unique.
- Lister les services en cours d’exécution sur la machine distante.
- Vérifier les prérequis et comprendre la logique conditionnelle de l’exécution distante.
- Exporter les résultats pour audit/documentation.
# 2 Point Théorique — Gestion à Distance (PowerShell Remoting)
# 2.1 Définition
PowerShell Remoting permet d’exécuter des commandes sur un ordinateur distant via WinRM (Windows Remote Management), basé sur le protocole WS-Management.
# 2.1 Modes de fonctionnement

# 2.1.1 One-to-One :

- Exécution ponctuelle (Invoke-Command).
- Session interactive (Enter-PSSession).


# 2.1.2 One-to-Many :

- Exécution sur plusieurs machines simultanément.



# 2.2 Fonctionnement

- Le client envoie un ScriptBlock à la machine distante via WinRM.
- La machine distante exécute les commandes.
- Les résultats sont renvoyés sous forme d’objets PowerShell.

# 2.3 Sécurité

- Authentification (Kerberos, NTLM, Basic+HTTPS).
- Chiffrement (HTTPS recommandé).
- Possibilité de restreindre les actions via JEA (Just Enough Administration).

# 2.4  Avantages

- Automatisation des tâches.
- Inventaire matériel/logique.
- Surveillance (services, journaux, performances).
- Déploiement de scripts et configurations.
# 3. Environnement et prérequis 
# 3.1 Postes nécessaires

- Un poste d’administration (local).
- Une machine distante (ex. PC01).

# 3.2 Conditions techniques 
- La machine distante doit avoir WinRM activé :
  - "Enable-PSRemoting -Force"
- Connectivité réseau OK (ping, résolution DNS ou IP).
- L’utilisateur doit avoir les droits nécessaires sur la machine distante (lecteur des services ou admin local).
# 3.2.1 Cas hors domaine 
- Si l’hôte distant n’est pas dans le même domaine :
  - "Set-Item WSMan:\localhost\Client\TrustedHosts -Value "PC01" -Force"
- En production, préférer WinRM en HTTPS plutôt que TrustedHosts.
# 4. Explication de ce que fait le script
# 4.1 Paramètres

- $Target : machine distante ciblée.
- $Cred : fenêtre de saisie des identifiants.

# 4.2 Vérification WinRM
"Test-WSMan -ComputerName $Target"
- Condition :
  - Si WinRM répond → on peut continuer.
  - Sinon → arrêt : problème réseau, pare-feu, service WinRM inactif.
# 4.3 Exécution distante avec Invoke-Command
"Invoke-Command -ComputerName $Target -Credential $Cred -ScriptBlock { ... }"
- À l’intérieur du ScriptBlock :
  - Get-Service → récupère tous les services.
  - Where-Object { $_.Status -eq 'Running' }

- Condition logique : garder uniquement les services dont l’état = Running.


- Tri alphabétique (Sort-Object).
- Sélection des colonnes utiles (Select-Object).

# 4.4 Export CSV
Utile pour audit, rapport, ou preuve d’exécution.
# 5 Conditions impliquées dans l’exercice (One-to-One)
# 5.1 Condition 1 — WinRM disponible
- Si Test-WSMan échoue → l’exécution distante est impossible.

# 5.2 Condition 2 — Droits suffisants
- L’utilisateur fourni via Get-Credential doit pouvoir lire les services.
# 5.3 Condition 3 — Machine accessible
- Ping
- DNS
- Port WinRM (5985 HTTP / 5986 HTTPS)

# 5.4 Condition 4 — Filtrage des services
- Le script n’affiche que les services dont :
- Status = "Running"
- C’est une condition interne appliquée via Where-Object.
# 6 Procédure de Test

- Tester WinRM :

  - "Test-WSMan PC01"

- Lancer le script.
- Vérifier que la liste des services en cours apparaît.
- Vérifier la présence d’un fichier CSV dans le dossier courant.
- (Optionnel) Comparer avec :
  - "Get-Service | Where Status -eq 'Running'"
- Exécuté directement sur la machine distante.
# 7 Dépannage
# 7.1 Erreur : WinRM inaccessible
- Lancer sur la cible :
  - "Enable-PSRemoting -Force``"
# 7.2 Erreur : Accès refusé
- Vérifier droits administrateur ou utilisateur distant autorisé.
# 7.3 Erreur : TrustedHosts
- En Workgroup :
  - "Set-Item WSMan:\localhost\Client\TrustedHosts -Value "PC01" -Force"
# 7.4 Services retournés vides
- Tester sur la cible :
  - "Get-Service"

# 8. Résultats Attendus

- Liste des services en cours d’exécution sur la machine distante.
- Fichier CSV exporté contenant ces informations.
- Script fonctionnel avec vérification WinRM, authentification et gestion d’erreurs.
# 9 Corrigé : 
# === Paramètres ===
$Target = 'PC01'             # Nom NetBIOS, FQDN, ou adresse IP
$Cred   = Get-Credential     # Identifiants ayant les droits sur la machine distante

 # === Vérifications (rapides) ===
Write-Host "Vérification de la disponibilité WinRM sur $Target..." -ForegroundColor Cyan
if (-not (Test-WSMan -ComputerName $Target -ErrorAction SilentlyContinue)) {
    Write-Error "WinRM indisponible ou inaccessible sur $Target. Vérifie Enable-PSRemoting, le pare-feu et la connectivité."
    return
}

# === Exécution distante ===
Write-Host "Connexion à $Target et récupération des services en cours..." -ForegroundColor Cyan
try {
    $runningServices = Invoke-Command -ComputerName $Target -Credential $Cred -ScriptBlock {
        Get-Service | Where-Object { $_.Status -eq 'Running' } |
            Sort-Object -Property DisplayName |
            Select-Object DisplayName, Name, Status, StartType
    } -ErrorAction Stop

    # Affichage lisible
    $runningServices | Format-Table -AutoSize
}
catch {
    Write-Error "Échec de l'exécution à distance sur $Target : $($_.Exception.Message)"
    return
}

# === Export optionnel ===
$timestamp = Get-Date -Format 'yyyyMMdd_HHmm'
$outFile   = ".\services_en_cours_$($Target)_$timestamp.csv"
$runningServices | Export-Csv -Path $outFile -NoTypeInformation -Encoding UTF8
Write-Host "Export effectué : $outFile" -ForegroundColor Green
