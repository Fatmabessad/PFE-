# Fonction pour écrire dans le journal de logs
function Write-Log {
    param (
        [string]$Message
    )
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$TimeStamp - $Message" | Out-File -Append -FilePath "C:\Projet_PFE\Logs\journal.log"
}

# Début du script
Write-Log "Début de l'exécution du script VPN Check."

# Vérification du statut VPN
$VPN_Status = Get-VpnConnection -ErrorAction SilentlyContinue

if ($VPN_Status) {
    Write-Log "✅ VPN actif : $($VPN_Status.ConnectionStatus)"
} else {
    Write-Log "❌ Aucune connexion VPN détectée."
}

# Fin du script
Write-Log "Fin de l'exécution du script VPN Check."

$VPN_Status = Get-VpnConnection

if ($VPN_Status) {
    Write-Host "✅ VPN Actif : " $VPN_Status.ConnectionStatus
    & "C:\Projet_PFE\Scripts\log.ps1" -Message "VPN détecté"
} else {
    Write-Host "❌ Aucune connexion VPN détectée."
    & "C:\Projet_PFE\Scripts\log.ps1" -Message "Pas de VPN"
}
