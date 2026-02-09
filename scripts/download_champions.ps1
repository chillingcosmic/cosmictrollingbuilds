param(
  [string]$Locale = "it_IT"
)

$ErrorActionPreference = "Stop"
$base = "https://ddragon.leagueoflegends.com"
$realm = Invoke-RestMethod "$base/realms/euw.json"
$ver = $realm.v
$cdn = $realm.cdn

$dataDir = Join-Path $PSScriptRoot "..\\data"
$iconDir = Join-Path $PSScriptRoot "..\\assets\\champions"
New-Item -ItemType Directory -Force -Path $dataDir | Out-Null
New-Item -ItemType Directory -Force -Path $iconDir | Out-Null

Write-Host "Patch: $ver  Locale: $Locale"

$champsJson = Invoke-RestMethod "$cdn/$ver/data/$Locale/champion.json"
$champs = @()

foreach ($prop in $champsJson.data.PSObject.Properties) {
  $c = $prop.Value
  $icon = $c.image.full
  $champs += [pscustomobject]@{
    id = $c.id
    name = $c.name
    title = $c.title
    icon = $icon
  }
}

$out = [pscustomobject]@{
  meta = [pscustomobject]@{
    version = $ver
    locale = $Locale
    generatedAt = (Get-Date).ToString("s")
  }
  champions = $champs
}

$outPath = Join-Path $dataDir "champions.json"
$json = $out | ConvertTo-Json -Depth 6
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($outPath, $json, $utf8NoBom)

Write-Host "Scarico icone..."
foreach ($c in $champs) {
  $src = "$cdn/$ver/img/champion/$($c.icon)"
  $dst = Join-Path $iconDir $c.icon
  if (-not (Test-Path $dst)) {
    Invoke-WebRequest -Uri $src -OutFile $dst | Out-Null
  }
}

Write-Host "Fatto. File: $outPath"
