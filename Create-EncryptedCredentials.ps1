# Script for generating a private key with encrypted key and password

$KeyFilePath = "C:\beheer\key\Online.key"
$PasswordFilePath = "c:\Beheer\key\Password.txt"
$CustomPWD = "15645466"
$Username = "<domain>\<username>"
[int]$Bit = 32
$ExportPathXMLcred = "c:\beheer\key\Creds.xml"

#################################################################################################################################################################################
# Step 1 Function for creating encrypted key
Function Create-AESKey {
    Param($KeyFilePath, [int]$Bit)
    #$KeyFilePath = "\\Machine1\SharedPath\AES.key"
    $Key = New-Object Byte[] $Bit   # You can use 16, 24, or 32 for AES
    [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
    $Key | out-file $KeyFilePath
} 
#Create-AESKey -KeyFilePath "\\Machine1\SharedPath\AES.key"
#################################################################################################################################################################################

#################################################################################################################################################################################
# Step 2 Exporting Credentials to a file:
Function Export-Credential(
    [string]$KeyFilePath,
    [string]$ExportPath) {

    $creds = Get-Credential     #Ask for Password interactively
    $keyContent = Get-Content $KeyFilePath
    $ExportObject = New-Object psobject -Property @{
        UserName = $creds.UserName
        Password = ConvertFrom-SecureString -SecureString $creds.Password -Key $keyContent
    }
    # Export encrypted contents into XML file for later use 
    $ExportObject | Export-Clixml $ExportPath
}
#Export-Credential -KeyFilePath $KeyFilePath -ExportPath $ExportPathXMLcred

#################################################################################################################################################################################
# Step 3 Function for creating an encrypted password object
Function Create-EncryptedPScredentialObject {
    Param($Username, $PasswordFilePath, $KeyFilePath)
    $KeyContent = Get-Content $KeyFilePath
    $MyCredential = New-Object -TypeName System.Management.Automation.PSCredential `
    -ArgumentList $Username, (Get-Content $PasswordFilePath | ConvertTo-SecureString -Key $KeyContent)
}
#################################################################################################################################################################################

# Run the following functions one at a time to create a private key and Encrypted credentials to a file:
<#
#Uncomment only when a new private key is needed!
Create-AESKey -KeyFilePathPath $KeyFilePath -bit $bit

Start-Sleep 5
Create-SecureStringPassword -PasswordFilePathPath $PasswordFilePath -KeyFilePathPath $KeyFilePath -Password $CustomPWD
start-sleep 5
Create-EncryptedPScredentialObject -Username $Username -PasswordFilePath $PasswordFilePath -KeyFilePath $PasswordFilePath
#>


#################################################################################################################################################################################
# Test these credentials with the following code (logs into Exchange Online)
<#
$CredPath = "c:\beheer\key\Creds.xml"
$KeyFilePath = "C:\beheer\key\Online.key"
$Key = Get-Content $KeyFilePath
$credXML = Import-Clixml $CredPath
$secureStringPWD = ConvertTo-SecureString -String $credXML.Password -Key $key
$Credential = New-Object System.Management.Automation.PsCredential($credXML.UserName, $secureStringPWD) # Create PScredential Object

$URL = "https://ps.outlook.com/powershell"  
$EXOSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $URL -Credential $Credential -Authentication Basic -AllowRedirection -Name "Exchange Online"
        Import-PSSession $EXOSession
#>
#################################################################################################################################################################################


#################################################################################################################################################################################
# Decrypt credentials if needed (reverse the process (using the same key)):
<#
$importObject = Import-Clixml -Path .\savedCreds.xml
$secureString = ConvertTo-SecureString -String $importObject.Password -Key $key
$savedCreds = New-Object System.Management.Automation.PSCredential($importObject.UserName, $secureString)
#>
#################################################################################################################################################################################


#################################################################################################################################################################################
# Function for creating SecureString object with custom Password
Function Create-SecureStringPassword {
    Param($PasswordFilePath, $KeyFilePath, $Password)

    #$PasswordFilePath = "\\Machine1\SharedPath\Password.txt"
    #$KeyFilePath = "\\Machine1\SharedPath\AES.key"
    $Key = Get-Content $KeyFilePath
    $PasswordSecureString = $CustomPWD | ConvertTo-SecureString -AsPlainText -Force
    $PasswordSecureString | ConvertFrom-SecureString -key $Key | Out-File $PasswordFilePath
} 
#Create-SecureStringPassword -PasswordFilePath $PasswordFilePath -KeyFilePath $KeyFilePath -Password $CustomPWD
#################################################################################################################################################################################
