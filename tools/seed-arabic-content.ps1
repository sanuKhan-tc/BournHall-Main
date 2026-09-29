param(
    [Parameter(Mandatory = $true)]
    [string]$SeedFile,
    [ValidateSet("local", "remote")]
    [string]$Target = "local",
    [switch]$Execute,
    [string]$SshKey,
    [string]$RemoteHost = "brounhallwpdev@brounhallwpdev.ssh.wpengine.net",
    [string]$RemoteWpPath = "~/sites/brounhallwpdev"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $SeedFile -PathType Leaf)) {
    throw "Seed file not found: $SeedFile"
}

$seed = Get-Content -LiteralPath $SeedFile -Raw | ConvertFrom-Json
foreach ($key in @("pages", "treatments", "doctors")) {
    if ($null -eq $seed.$key) {
        throw "Seed file must contain '$key'."
    }
}

$executeArg = if ($Execute) { " --execute=1" } else { "" }

if ($Target -eq "local") {
    wp brounhall locale migrate --file="$SeedFile"$executeArg
    exit $LASTEXITCODE
}

$remoteFile = "/tmp/brounhall-arabic-content-$([guid]::NewGuid().ToString('N')).json"
$sshOptions = @()
if ($SshKey) { $sshOptions += @("-i", $SshKey, "-o", "IdentitiesOnly=yes") }
$encoded = [Convert]::ToBase64String([IO.File]::ReadAllBytes((Resolve-Path -LiteralPath $SeedFile)))
$sshProcess = [Diagnostics.Process]::new()
$sshProcess.StartInfo.FileName = "ssh"
$sshProcess.StartInfo.UseShellExecute = $false
$sshProcess.StartInfo.RedirectStandardInput = $true
$sshProcess.StartInfo.RedirectStandardOutput = $true
$sshProcess.StartInfo.RedirectStandardError = $true
foreach ($option in $sshOptions) { [void]$sshProcess.StartInfo.ArgumentList.Add($option) }
[void]$sshProcess.StartInfo.ArgumentList.Add($RemoteHost)
[void]$sshProcess.StartInfo.ArgumentList.Add("base64 -d > $remoteFile && cd $RemoteWpPath && wp brounhall locale migrate --file=$remoteFile$executeArg; exitCode=`$?; rm -f $remoteFile; exit `$exitCode")
[void]$sshProcess.Start()
$payload = [Text.Encoding]::ASCII.GetBytes($encoded)
$sshProcess.StandardInput.BaseStream.Write($payload, 0, $payload.Length)
$sshProcess.StandardInput.Close()
$sshProcess.WaitForExit()
if ($sshProcess.StandardOutput.BaseStream.CanRead) { $output = $sshProcess.StandardOutput.ReadToEnd(); if ($output) { Write-Output $output } }
if ($sshProcess.StandardError.BaseStream.CanRead) { $errorOutput = $sshProcess.StandardError.ReadToEnd(); if ($errorOutput) { Write-Error $errorOutput } }
exit $sshProcess.ExitCode
