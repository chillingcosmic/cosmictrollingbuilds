param(
  [string]$Locale = "it_IT"
)

$ErrorActionPreference = "Stop"
$base = "https://ddragon.leagueoflegends.com"
$realm = Invoke-RestMethod "$base/realms/euw.json"
$ver = $realm.v
$cdn = $realm.cdn

$dataDir = Join-Path $PSScriptRoot "..\\data"
$iconDir = Join-Path $PSScriptRoot "..\\assets\\summoners"
New-Item -ItemType Directory -Force -Path $dataDir | Out-Null
New-Item -ItemType Directory -Force -Path $iconDir | Out-Null

Write-Host "Patch: $ver  Locale: $Locale"

$sumJson = Invoke-RestMethod "$cdn/$ver/data/$Locale/summoner.json"
$sums = @()

foreach ($prop in $sumJson.data.PSObject.Properties) {
  $s = $prop.Value
  if ($s.modes -and ($s.modes -notcontains "CLASSIC")) { continue }
  if ($s.map -and $s.map -ne "11") { continue }
  $icon = $s.image.full
  $sums += [pscustomobject]@{
    id = $s.id
    name = $s.name
    icon = $icon
  }
}

$out = [pscustomobject]@{
  meta = [pscustomobject]@{
    version = $ver
    locale = $Locale
    generatedAt = (Get-Date).ToString("s")
  }
  summoners = $sums
}

$outPath = Join-Path $dataDir "summoners.json"
$json = $out | ConvertTo-Json -Depth 6
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($outPath, $json, $utf8NoBom)

Write-Host "Scarico icone..."
foreach ($s in $sums) {
  $src = "$cdn/$ver/img/spell/$($s.icon)"
  $dst = Join-Path $iconDir $s.icon
  if (-not (Test-Path $dst)) {
    Invoke-WebRequest -Uri $src -OutFile $dst | Out-Null
  }
}

Write-Host "Fatto. File: $outPath"
