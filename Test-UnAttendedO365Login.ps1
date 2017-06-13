# Test unattended login functionality

$CredPath = "C:\Beheer\key\O365Cred.xml"
$KeyFilePath = "C:\Beheer\key\O365.key"

Function Connect-EXOnline {
    param($Credentials)
    $URL = "https://ps.outlook.com/powershell"     
    $EXOSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $URL -Credential $Credentials -Authentication Basic -AllowRedirection -Name "Exchange Online"
        Import-PSSession $EXOSession -AllowClobber
}


$Key = Get-Content $KeyFilePath
$credXML = Import-Clixml $CredPath #Import encrypted credential file into XML format
$secureStringPWD = ConvertTo-SecureString -String $credXML.Password -Key $key
$Credentials = New-Object System.Management.Automation.PsCredential($credXML.UserName, $secureStringPWD) # Create PScredential Object


#Connect-EXOnline -Credentials $Credentials
Connect-MsolService -Credential $Credentials


$AccountSKUidCollection = Get-MsolAccountSku | select -ExpandProperty accountskuid

ForEach ($AccountSKUid in $AccountSKUidCollection) {
    Write-Output "Serviceplans within [$AccountSKUID]:"
	Write-Output (Get-MsolAccountSku | where {$_.AccountSkuId -eq $AccountSKUid}).ServiceStatus.ServicePlan.ServiceName
}
