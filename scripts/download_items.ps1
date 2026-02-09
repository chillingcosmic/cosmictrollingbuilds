param(
  [string]$Locale = "it_IT"
)

$ErrorActionPreference = "Stop"
$base = "https://ddragon.leagueoflegends.com"
$realm = Invoke-RestMethod "$base/realms/euw.json"
$ver = $realm.v
$cdn = $realm.cdn

$dataDir = Join-Path $PSScriptRoot "..\\data"
$iconDir = Join-Path $PSScriptRoot "..\\assets\\items"
New-Item -ItemType Directory -Force -Path $dataDir | Out-Null
New-Item -ItemType Directory -Force -Path $iconDir | Out-Null

Write-Host "Patch: $ver  Locale: $Locale"

$itemsJson = Invoke-RestMethod "$cdn/$ver/data/$Locale/item.json"
$items = @()

foreach ($prop in $itemsJson.data.PSObject.Properties) {
  $item = $prop.Value
  $id = $prop.Name
  $idNum = [int]$id
  if ($idNum -ge 10000) { continue }
  if ($item.hideFromAll) { continue }
  if ($item.gold -and $item.gold.purchasable -eq $false) { continue }
  if (-not $item.inStore -and $item.inStore -ne $null) { continue }
  if (-not $item.gold -or $item.gold.total -lt 700) { continue }
  if ($item.requiredChampion -or $item.requiredAlly) { continue }
  if (-not $item.maps -or -not $item.maps."11") { continue }
  $tags = @($item.tags)
  if ($tags -contains "Consumable" -or $tags -contains "Trinket") { continue }
  if ($tags -contains "Lane") { continue }
  $isBoot = $tags -contains "Boots"
  if ($item.into -and $item.into.Count -gt 0 -and -not $isBoot) { continue }
  if ($isBoot -and $item.gold.total -le 500) { continue }
  $isBootT3 = $false
  if ($isBoot -and (-not $item.into -or $item.into.Count -eq 0)) { $isBootT3 = $true }

  $plain = if ($item.plaintext) { $item.plaintext } else { "" }
  $desc = if ($item.description) { $item.description } else { "" }
  $isMythic = ($plain -match "Mythic") -or ($desc -match "Mythic")
  $isLegendary = ($plain -match "Legendary") -or ($desc -match "Legendary")
  $icon = $item.image.full

  $items += [pscustomobject]@{
    id = $id
    name = $item.name
    plaintext = $plain
    description = $desc
    icon = $icon
    tags = $tags
    isMythic = $isMythic
    isLegendary = $isLegendary
    isBootT3 = $isBootT3
    gold = $item.gold
  }
}

$out = [pscustomobject]@{
  meta = [pscustomobject]@{
    version = $ver
    locale = $Locale
    generatedAt = (Get-Date).ToString("s")
  }
  items = $items
}

$outPath = Join-Path $dataDir "items.json"
$json = $out | ConvertTo-Json -Depth 6
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($outPath, $json, $utf8NoBom)

Write-Host "Scarico icone..."
foreach ($it in $items) {
  $src = "$cdn/$ver/img/item/$($it.icon)"
  $dst = Join-Path $iconDir $it.icon
  if (-not (Test-Path $dst)) {
    Invoke-WebRequest -Uri $src -OutFile $dst | Out-Null
  }
}

Write-Host "Fatto. File: $outPath"
