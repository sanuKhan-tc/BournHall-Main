param(
    [Parameter(Mandatory = $true)]
    [string]$SeedFile,
    [ValidateSet("local", "remote")]
    [string]$Target = "local",
    [switch]$Execute,
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
scp -- "$SeedFile" "${RemoteHost}:$remoteFile"
try {
    $remoteCommand = "cd $RemoteWpPath && wp brounhall locale migrate --file=$remoteFile$executeArg"
    ssh -- $RemoteHost $remoteCommand
    exit $LASTEXITCODE
}
finally {
    ssh -- $RemoteHost "rm -f $remoteFile" | Out-Null
}
