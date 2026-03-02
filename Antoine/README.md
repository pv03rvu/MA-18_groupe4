<<<<<<< HEAD
Exercice execution à distance one to one 
1. Point théorique — Gestion à distance avec PowerShell (WinRM)
PowerShell Remoting permet d’exécuter des commandes à distance via le protocole WS‑Management (WS‑Man / WinRM).

1.1 : les Modes de gestion à distance
- Mode 1:1 : session interactive (Enter-PSSession) ou exécution ponctuelle (Invoke-Command -ComputerName).
- Mode 1:N : même commande exécutée en parallèle sur plusieurs hôtes (agrégation des retours).

1.2 : Transports :
  - HTTP/HTTPS (WinRM natif, PowerShell 5.1+)
  - SSH (optionnel, surtout avec PowerShell 7+).

1.3 : Couches de sécurité :
  - Authentification (Kerberos en domaine, NTLM en workgroup, ou Basic sur HTTPS).
  - Chiffrement (HTTPS recommandé, sinon HTTP chiffré au niveau message selon contexte).
  - Contrôles d’accès (groupes locaux “Remote Management Users”, JEA – Just Enough Administration – pour restreindre les cmdlets et actions).

1.4 : Activation : Enable-PSRemoting -Force crée les listeners WinRM, configure le service et les règles pare‑feu.
Objets, pas du texte : les résultats sont des objets PowerShell (filtrables, exportables), ce qui est idéal pour l’automatisation, l’inventaire et les rapports.
Cas d’usage fréquents : inventaires (WMI/CIM), gestion des services/processus, collecte de performances (Get-Counter), gestion de fichiers/logs, tâches planifiées, déploiement de scripts.

1.5 Remarque pédagogique : Dans notre exercice, le filtrage Where-Object { $_.Status -eq 'Running' } constitue la condition logique centrale du traitement « one-to-one ».

2 Partie pratique

2.1. Objectifs
- Mettre en œuvre PowerShell Remoting pour exécuter une commande sur une machine distante unique.
- Lister les services en cours d’exécution sur la cible et exporter le résultat.
- Vérifier les prérequis, diagnostiquer les erreurs courantes et appliquer des bonnes pratiques.

2.2. Environnement & prérequis
- Deux postes : un poste d’admin (local) et un hôte cible (ex. PC01).
- Compte avec droits d’administrateur local (ou équivalents) sur la cible.
- WinRM activé sur la cible :
- Sur la cible (une fois) : Enable-PSRemoting -Force
- Réseau OK (ping/nom/DNS ou IP).
- Hors domaine (workgroup) : ajouter la cible en TrustedHosts côté admin si nécessaire :
  "Set-Item WSMan:\localhost\Client\TrustedHosts -Value "PC01" -Force"
  (En production, préférer WinRM en HTTPS et certifs plutôt que TrustedHosts.)

2.3. Procédure (étapes)
- Ouvrir PowerShell en tant qu’administrateur sur le poste d’admin.
- Tester WinRM vers la cible :
  "Test-WSMan -ComputerName PC01"
  - Si erreur → vérifier pare-feu, service WinRM, nom/résolution réseau.
- Exécuter le script (ci-dessus) en adaptant $Target.
- Vérifier la sortie (tableau des services en cours).
- Consulter l’export CSV généré dans le répertoire courant.

2.4. Explication ligne par ligne du script
- Get-Credential : invite l’utilisateur à saisir nom d’utilisateur / mot de passe pour s’authentifier sur la cible.
- Test-WSMan -ComputerName $Target : vérifie que WinRM répond (prérequis du remoting).
- Invoke-Command -ComputerName $Target -Credential $Cred -ScriptBlock { ... } :
- Envoie le bloc de script à la machine cible et l’exécute à distance.
À l’intérieur du bloc :
  - Get-Service récupère tous les services.
  - Where-Object { $_.Status -eq 'Running' } filtre uniquement les services en cours.
  - Sort-Object DisplayName trie alphabétiquement.
  - Select-Object ... sélectionne les colonnes utiles (nom affiché, nom technique, statut, type de démarrage).
- Export-Csv : enregistre les résultats pour preuve / reporting (horodatage dans le nom de fichier).
- try { ... } catch { ... } : gère les erreurs (droits insuffisants, hôte inaccessible, etc.).

2.5. Vérifications & validation
- Sortie console lisible (au moins quelques services, ex. Windows Update, WinRM, etc.).
- Le fichier services_en_cours_PC01_YYYYMMDD_HHMM.csv est présent et ouvrable (UTF-8).
- Si possible, comparer avec un Get-Service exécuté localement sur la cible (cohérence).

2.6. Dépannage (erreurs fréquentes)
- Test-WSMan échoue :
  - Lancer sur la cible : Enable-PSRemoting -Force
  - Vérifier le pare-feu (profils Private/Domain/Public).
  - Vérifier l’IP/nom DNS (essayer l’IP si le nom ne marche pas).
- Accès refusé / Authentification :
  - Utiliser un compte admin local ou domaine autorisé.
  - Hors domaine : TrustedHosts requis côté client (ou configurer WinRM HTTPS).
- Timeout/pas de réponse :
  - La cible est peut‑être éteinte, en veille ou hors réseau.
- Liste vide inattendue :
  - Peut être normal si très peu de services sont démarrés ; tester sans filtre
    "Invoke-Command -ComputerName $Target -Credential $Cred -ScriptBlock { Get-Service }"

2.7. Bonnes pratiques (sécurité & exploitation)
- Moindre privilège : n’utiliser que les droits nécessaires.
- Audit : journaliser la session pour prouver les actions
"Start-Transcript -Path .\session_remoting.log -Append
# ... exécution ...
Stop-Transcript"
- HTTPS recommandé en production (WinRM avec certificat) au lieu de TrustedHosts *.
- Sessions persistantes (New-PSSession) si tu enchaînes plusieurs commandes (performance).

2.8. Résultats attendus
- Tableau des services en cours d’exécution sur la machine cible.
- Export CSV des résultats, horodaté.
- Log d’audit optionnel (session_remoting.log).

3. Corrigé
  # === Paramètres ===
$Target = 'PC01'             # Nom NetBIOS, FQDN, ou adresse IP
$Cred   = Get-Credential     # Identifiants ayant les droits sur la machine distante

# === Vérifications (rapides) ===
Write-Host "Vérification de la disponibilité WinRM sur $Target..." -ForegroundColor Cyan
if (-not (Test-WSMan -ComputerName $Target -ErrorAction SilentlyContinue)) {
    Write-Error "WinRM indisponible ou inaccessible sur $Target. Vérifie Enable-PSRemoting, le pare-feu et la connectivité."
=======
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

if (-not (Test-WSMan -ComputerName $Target -ErrorAction SilentlyContinue))

{

    Write-Error "WinRM indisponible ou inaccessible sur $Target. Vérifie Enable-PSRemoting, le pare-feu et la connectivité."
    
>>>>>>> refs/remotes/origin/main
    return
}

# === Exécution distante ===
<<<<<<< HEAD
Write-Host "Connexion à $Target et récupération des services en cours..." -ForegroundColor Cyan
=======

Write-Host "Connexion à $Target et récupération des services en cours..." -ForegroundColor Cyan

>>>>>>> refs/remotes/origin/main
try {
    $runningServices = Invoke-Command -ComputerName $Target -Credential $Cred -ScriptBlock {
    
        Get-Service | Where-Object { $_.Status -eq 'Running' } |
<<<<<<< HEAD
            Sort-Object -Property DisplayName |
            Select-Object DisplayName, Name, Status, StartType
=======
        
            Sort-Object -Property DisplayName |
            
            Select-Object DisplayName, Name, Status, StartType
            
>>>>>>> refs/remotes/origin/main
    } -ErrorAction Stop

    # Affichage lisible
    $runningServices | Format-Table -AutoSize
}
catch {
    Write-Error "Échec de l'exécution à distance sur $Target : $($_.Exception.Message)"
    
    return
<<<<<<< HEAD
=======

>>>>>>> refs/remotes/origin/main
}

# === Export optionnel ===

$timestamp = Get-Date -Format 'yyyyMMdd_HHmm'

$outFile   = ".\services_en_cours_$($Target)_$timestamp.csv"

$runningServices | Export-Csv -Path $outFile -NoTypeInformation -Encoding UTF8

Write-Host "Export effectué : $outFile" -ForegroundColor Green

<<<<<<< HEAD

=======
>>>>>>> refs/remotes/origin/main
