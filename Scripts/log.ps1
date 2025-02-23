# log.ps1 : Fonction pour écrire des logs
param (
    [string]$Message
)

$LogPath = "C:\Projet_PFE\Logs\execution.log"
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"$Timestamp - $Message" | Out-File -Append -FilePath $LogPath
