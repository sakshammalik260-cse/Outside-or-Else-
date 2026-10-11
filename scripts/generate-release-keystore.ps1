param(
    [string]$KeystorePath = "android/release.keystore",
    [string]$PropertiesPath = "android/keystore.properties",
    [string]$Alias = "outsideorelse",
    [switch]$Gui
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $projectRoot

$keytoolExe = if (Test-Path "native/toolchain/jdk-21.0.12.1+1/bin/keytool.exe") {
    (Resolve-Path "native/toolchain/jdk-21.0.12.1+1/bin/keytool.exe").Path
} else {
    "keytool"
}

function Get-PasswordInteractive {
    Write-Host "=== Generate Android Release Keystore Privately ===" -ForegroundColor Cyan
    Write-Host "The password you enter will be masked and will NOT be printed or stored in Git." -ForegroundColor Yellow
    $p1 = Read-Host -Prompt "Enter strong keystore password" -AsSecureString
    $p2 = Read-Host -Prompt "Confirm strong keystore password" -AsSecureString

    $b1 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($p1)
    $s1 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($b1)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($b1)

    $b2 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($p2)
    $s2 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($b2)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($b2)

    if ($s1 -ne $s2) { throw "Passwords do not match." }
    if ($s1.Length -lt 8) { throw "Password must be at least 8 characters long." }
    return $s1
}

function Get-PasswordGui {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Outside or Else - Keystore Password"
    $form.Size = New-Object System.Drawing.Size(420, 240)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false
    $form.TopMost = $true

    $lbl1 = New-Object System.Windows.Forms.Label
    $lbl1.Location = New-Object System.Drawing.Point(20, 20)
    $lbl1.Size = New-Object System.Drawing.Size(360, 20)
    $lbl1.Text = "Enter private release keystore password (min 8 chars):"
    $form.Controls.Add($lbl1)

    $txt1 = New-Object System.Windows.Forms.TextBox
    $txt1.Location = New-Object System.Drawing.Point(20, 45)
    $txt1.Size = New-Object System.Drawing.Size(360, 25)
    $txt1.PasswordChar = '*'
    $form.Controls.Add($txt1)

    $lbl2 = New-Object System.Windows.Forms.Label
    $lbl2.Location = New-Object System.Drawing.Point(20, 80)
    $lbl2.Size = New-Object System.Drawing.Size(360, 20)
    $lbl2.Text = "Confirm keystore password:"
    $form.Controls.Add($lbl2)

    $txt2 = New-Object System.Windows.Forms.TextBox
    $txt2.Location = New-Object System.Drawing.Point(20, 105)
    $txt2.Size = New-Object System.Drawing.Size(360, 25)
    $txt2.PasswordChar = '*'
    $form.Controls.Add($txt2)

    $btnOk = New-Object System.Windows.Forms.Button
    $btnOk.Location = New-Object System.Drawing.Point(220, 150)
    $btnOk.Size = New-Object System.Drawing.Size(80, 30)
    $btnOk.Text = "OK"
    $btnOk.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.Controls.Add($btnOk)
    $form.AcceptButton = $btnOk

    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Location = New-Object System.Drawing.Point(310, 150)
    $btnCancel.Size = New-Object System.Drawing.Size(70, 30)
    $btnCancel.Text = "Cancel"
    $btnCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.Controls.Add($btnCancel)
    $form.CancelButton = $btnCancel

    $dialogResult = $form.ShowDialog()
    if ($dialogResult -ne [System.Windows.Forms.DialogResult]::OK) {
        throw "Password entry cancelled."
    }

    $pass1 = $txt1.Text
    $pass2 = $txt2.Text

    if ($pass1 -ne $pass2) { throw "Passwords do not match." }
    if ($pass1.Length -lt 8) { throw "Password must be at least 8 characters long." }
    return $pass1
}

$pass = if ($Gui) { Get-PasswordGui } else { Get-PasswordInteractive }

if (Test-Path $KeystorePath) {
    Remove-Item $KeystorePath -Force
}

Write-Host "Generating release keystore..." -ForegroundColor Cyan

& $keytoolExe -genkeypair -v -keystore $KeystorePath -alias $Alias -keyalg RSA -keysize 2048 -validity 10000 `
    -storepass $pass -keypass $pass -dname "CN=Outside or Else, OU=Hackathon, O=Outside or Else, L=Bangalore, ST=Karnataka, C=IN"

if ($LASTEXITCODE -ne 0) {
    throw "Keytool failed to generate keystore."
}

$propsContent = @"
storeFile=release.keystore
storePassword=$pass
keyAlias=$Alias
keyPassword=$pass
"@

[System.IO.File]::WriteAllText($PropertiesPath, $propsContent, [System.Text.UTF8Encoding]::new($false))

$pass = $null

Write-Host "=== Success ===" -ForegroundColor Green
Write-Host "New keystore generated at: $KeystorePath"
Write-Host "Signing properties saved at: $PropertiesPath"
Write-Host "Neither file is tracked by Git."

