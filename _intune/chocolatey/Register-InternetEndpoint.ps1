# You can run this script on your endpoints to enroll them into Central Management
# The variables below are populated for you, based on your Internet-enabling of QDE
# IMPORTANT: The below data is sensitive, so please remove this script from endpoints once on-boarding is complete.
$ClientCommunicationSalt = '/z^#;[F^N{Gf6&Fl4_k3(G;%^oIo+E&*'
$ServiceCommunicationSalt = 'vnG_onB-4%0n):X!]z=q;n.*}DH^N#./'
$FQDN = 'chocolatey.healthstream.com'
$NexusUserPW = 'o%*x!Pd-*-UH[$=I)>Ya-iPRy}A)A}Y{'

# Touch NOTHING below this line
$User = 'chocouser'
$SecurePassword = $NexusUserPW | ConvertTo-SecureString -AsPlainText -Force
$RepositoryUrl = "https://$($fqdn):8443/repository/ChocolateyInternal/"

$credential = [pscredential]::new($user, $securePassword)

$downloader = [System.Net.WebClient]::new()
$downloader.Credentials = $credential

$script =  $downloader.DownloadString("https://$($FQDN):8443/repository/choco-install/ClientSetup.ps1")

$params = @{
    Credential      = $Credential
    ClientSalt      = $ClientCommunicationSalt
    ServerSalt      = $ServiceCommunicationSalt
    InternetEnabled = $true
    RepositoryUrl   = $RepositoryUrl
}

& ([scriptblock]::Create($script)) @params
