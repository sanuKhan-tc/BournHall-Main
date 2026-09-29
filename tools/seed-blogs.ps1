param(
    [ValidateSet("local", "remote")][string]$Target = "local",
    [switch]$Execute,
    [switch]$Replace,
    [string]$SshKey,
    [string]$RemoteHost = "brounhallwpdev@brounhallwpdev.ssh.wpengine.net",
    [string]$RemoteWpPath = "~/sites/brounhallwpdev"
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$seed = Join-Path $root "tools/blog-content.seed.json"
node (Join-Path $root "tools/generate-blog-seed.mjs") $seed
$executeArg = if ($Execute) { " --execute" } else { "" }
$replaceArg = if ($Replace) { " --replace" } else { "" }

if ($Target -eq "local") {
    $phpArgs = @((Join-Path $root "tools/seed-blogs.php"), $seed)
    if ($Execute) { $phpArgs += "--execute" }; if ($Replace) { $phpArgs += "--replace" }
    & php @phpArgs
    exit $LASTEXITCODE
}

$remoteFile = "/tmp/brounhall-blog-content-$([guid]::NewGuid().ToString('N')).json"
$remoteExecuteArg = if ($Execute) { " --execute=1" } else { "" }
$remoteReplaceArg = if ($Replace) { " --replace=1" } else { "" }
$encoded = [Convert]::ToBase64String([IO.File]::ReadAllBytes($seed))
$remoteCommand = "base64 -d > $remoteFile && cd $RemoteWpPath && wp brounhall locale migrate --file=$remoteFile$remoteExecuteArg$remoteReplaceArg; exitCode=`$?; rm -f $remoteFile; exit `$exitCode"
$sshArgs = @(); if ($SshKey) { $sshArgs += @("-i", $SshKey, "-o", "IdentitiesOnly=yes") }
$sshArgs += @($RemoteHost, $remoteCommand)
$sshProcess = [Diagnostics.Process]::new()
$sshProcess.StartInfo.FileName = "ssh"
$sshProcess.StartInfo.UseShellExecute = $false
$sshProcess.StartInfo.RedirectStandardInput = $true
$sshProcess.StartInfo.RedirectStandardOutput = $true
$sshProcess.StartInfo.RedirectStandardError = $true
$sshProcess.StartInfo.Arguments = (($sshArgs | ForEach-Object { '"' + $_.Replace('"', '\"') + '"' }) -join " ")
[void]$sshProcess.Start()
$payload = [Text.Encoding]::ASCII.GetBytes($encoded)
$sshProcess.StandardInput.BaseStream.Write($payload, 0, $payload.Length)
$sshProcess.StandardInput.Close()
$sshProcess.WaitForExit()
$output = $sshProcess.StandardOutput.ReadToEnd(); if ($output) { Write-Output $output }
$errorOutput = $sshProcess.StandardError.ReadToEnd(); if ($errorOutput) { Write-Error $errorOutput }
exit $sshProcess.ExitCode
