#  Début de l'automatisation...
Write-Host " Début de l'automatisation..."

#  Définition des chemins des logs
$journalLog = "C:\Projet_PFE\Logs\journal.log"
$executionLog = "C:\Projet_PFE\Logs\execution.log"

#  Fonction pour écrire dans les logs
function Write-Log {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File -Append -FilePath $journalLog
}

#  Fonction pour afficher une notification Windows en cas d’échec
function Show-WindowsNotification {
    param (
        [string]$message
    )
    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
    $template = [Windows.UI.Notifications.ToastTemplateType]::ToastText01
    $toastXml = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent($template)
    $toastText = $toastXml.GetElementsByTagName("text").Item(0)
    $toastText.AppendChild($toastXml.CreateTextNode($message)) | Out-Null
    $toast = [Windows.UI.Notifications.ToastNotification]::new($toastXml)
    $notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("Automatisation")
    $notifier.Show($toast)
}

#  Fonction pour envoyer une alerte email en cas d'échec
function Send-EmailAlert {
    param (
        [string]$subject,
        [string]$body
    )
    
    # Configuration du serveur SMTP
    $smtpServer = "smtp.votre-serveur.com"  # Remplace avec ton vrai serveur SMTP
    $smtpPort = 587  # Port SMTP (465 si SSL)
    $smtpUser = "bessadfatma9@gmail.com"  # Identifiant SMTP
    $smtpPassword = "ton-mot-de-passe"  #  Attention : ne stocke pas le mot de passe en dur, utilise des variables d'environnement !
    
    # Expéditeur et destinataire
    $from = "alert@votre-domaine.com"
    $to = "admin@votre-domaine.com"

    # Création de l'objet SMTP
    $smtp = New-Object System.Net.Mail.SmtpClient($smtpServer, $smtpPort)
    $smtp.Credentials = New-Object System.Net.NetworkCredential($smtpUser, $smtpPassword)
    $smtp.EnableSsl = $true  # Active SSL/TLS pour sécuriser la connexion
    
    # Création de l'e-mail
    $msg = New-Object System.Net.Mail.MailMessage($from, $to, $subject, $body)

    # Gestion des erreurs
    Try {
        $smtp.Send($msg)
        Write-Host " Alerte e-mail envoyée avec succès !" -ForegroundColor Green
    } Catch {
        Write-Host " Erreur lors de l'envoi de l'alerte e-mail : $_" -ForegroundColor Red
    }
}


# Exécution des scripts et gestion des erreurs
$scriptList = @(
    "C:\Projet_PFE\Scripts\verification_utilisateurs.ps1",
    "C:\Projet_PFE\Scripts\verification_vpn.ps1",
    "C:\Projet_PFE\Scripts\verification_admins.ps1"
)

Write-Log " Début des vérifications..."
Write-Host " Exécution des scripts..."

foreach ($script in $scriptList) {
    try {
        Write-Log " Exécution du script : $script"
        Write-Host " Exécution de : $script"
        
        & $script

        Write-Log "Exécution réussie de : $script"
        Write-Host "Succès : $script"

    } catch {
        Write-Log " Échec du script : $script"
        Write-Host " Erreur lors de l'exécution de : $script"

        Show-WindowsNotification -message " Échec de l'exécution de $script"
        Send-EmailAlert -subject " Alerte : Script en échec" -body "Le script $script a échoué. Vérifiez les logs."

        "$script - Échec" | Out-File -Append -FilePath $executionLog
    }
}

Write-Log "Vérifications terminées !"
Write-Host " Vérifications terminées !"

# Finalisation du script
Write-Host " Fin de l'automatisation."
Write-Log "Fin de l'automatisation."
