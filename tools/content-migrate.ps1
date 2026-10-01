param(
    [Parameter(Mandatory = $true)]
    [string]$SeedFile,
    [ValidateSet("local", "remote")]
    [string]$Target = "local",
    [switch]$Execute,
    [switch]$TemporaryPlaceholders,
    [string]$SshKey,
    [string]$RemoteHost = "brounhallwpdev@brounhallwpdev.ssh.wpengine.net",
    [string]$RemoteWpPath = "~/sites/brounhallwpdev"
)

$ErrorActionPreference = "Stop"
if (-not (Test-Path -LiteralPath $SeedFile -PathType Leaf)) { throw "Seed file not found: $SeedFile" }
$seed = Get-Content -LiteralPath $SeedFile -Raw | ConvertFrom-Json
foreach ($key in @("pages", "treatments", "doctors")) {
    if ($null -eq $seed.$key) { throw "Seed file must contain '$key'." }
}

$wpArgs = @("brounhall", "content", "migrate", "--locale=all", "--file=$SeedFile")
if ($Execute) { $wpArgs += "--execute" }
if ($TemporaryPlaceholders) { $wpArgs += "--temporary-placeholders" }

if ($Target -eq "local") {
    & wp @wpArgs
    exit $LASTEXITCODE
}

$remoteFile = "/tmp/brounhall-content-$([guid]::NewGuid().ToString('N')).json"
$encoded = [Convert]::ToBase64String([IO.File]::ReadAllBytes((Resolve-Path -LiteralPath $SeedFile)))
$sshArgs = @()
if ($SshKey) { $sshArgs += @("-i", $SshKey, "-o", "IdentitiesOnly=yes") }
$sshArgs += @($RemoteHost, "base64 -d > $remoteFile && cd $RemoteWpPath && wp brounhall content migrate --locale=all --file=$remoteFile" + $(if ($Execute) { " --execute" } else { "" }) + $(if ($TemporaryPlaceholders) { " --temporary-placeholders" } else { "" }) + "; exitCode=`$?; rm -f $remoteFile; exit `$exitCode")
$process = [Diagnostics.Process]::new()
$process.StartInfo.FileName = "ssh"
$process.StartInfo.UseShellExecute = $false
$process.StartInfo.RedirectStandardInput = $true
$process.StartInfo.RedirectStandardOutput = $true
$process.StartInfo.RedirectStandardError = $true
$process.StartInfo.Arguments = (($sshArgs | ForEach-Object { '"' + $_.Replace('"', '\"') + '"' }) -join " ")
[void]$process.Start()
$payload = [Text.Encoding]::ASCII.GetBytes($encoded)
$process.StandardInput.BaseStream.Write($payload, 0, $payload.Length)
$process.StandardInput.Close()
$process.WaitForExit()
$output = $process.StandardOutput.ReadToEnd()
$errors = $process.StandardError.ReadToEnd()
if ($output) { Write-Output $output }
if ($errors) { Write-Error $errors }
exit $process.ExitCode
