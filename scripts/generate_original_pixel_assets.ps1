param(
    [string]$ProjectRoot = (Split-Path -Parent $PSScriptRoot)
)

Add-Type -AssemblyName System.Drawing

$pixelFormat = [System.Drawing.Imaging.PixelFormat]::Format32bppArgb

function New-PixelBitmap([int]$Width, [int]$Height) {
    $bitmap = [System.Drawing.Bitmap]::new($Width, $Height, $pixelFormat)
    $bitmap.SetResolution(96, 96)
    return $bitmap
}

function Get-Color([string]$Hex) {
    return [System.Drawing.ColorTranslator]::FromHtml($Hex)
}

function Add-Rect($Graphics, [int]$X, [int]$Y, [int]$Width, [int]$Height, [string]$Hex) {
    $brush = [System.Drawing.SolidBrush]::new((Get-Color $Hex))
    $Graphics.FillRectangle($brush, $X, $Y, $Width, $Height)
    $brush.Dispose()
}

function Add-Pixel($Bitmap, [int]$X, [int]$Y, [string]$Hex) {
    if ($X -ge 0 -and $Y -ge 0 -and $X -lt $Bitmap.Width -and $Y -lt $Bitmap.Height) {
        $Bitmap.SetPixel($X, $Y, (Get-Color $Hex))
    }
}

function Save-Png($Bitmap, [string]$RelativePath) {
    $path = Join-Path $ProjectRoot $RelativePath
    $directory = Split-Path -Parent $path
    New-Item -ItemType Directory -Force -Path $directory | Out-Null
    $Bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $Bitmap.Dispose()
    Write-Host "GENERATED $RelativePath"
}

function Add-GrassTile($Bitmap, [int]$TileX, [int]$TileY, [bool]$Variant = $false) {
    $x = $TileX * 16
    $y = $TileY * 16
    $graphics = [System.Drawing.Graphics]::FromImage($Bitmap)
    Add-Rect $graphics $x $y 16 16 '#72B84F'
    $graphics.Dispose()
    $spots = if ($Variant) { @(@(2,3),@(11,2),@(6,10),@(14,13),@(3,14)) } else { @(@(4,4),@(12,7),@(7,13)) }
    foreach ($spot in $spots) {
        Add-Pixel $Bitmap ($x + $spot[0]) ($y + $spot[1]) '#4F963F'
        if (($spot[0] + 1) -lt 16) { Add-Pixel $Bitmap ($x + $spot[0] + 1) ($y + $spot[1] - 1) '#9BD267' }
    }
}

# Terrain atlas: 8 columns x 3 rows, each tile is 16x16.
$terrain = New-PixelBitmap 128 48
Add-GrassTile $terrain 0 0 $false
Add-GrassTile $terrain 1 0 $true
$g = [System.Drawing.Graphics]::FromImage($terrain)
Add-Rect $g 32 0 16 16 '#D8BC75'
Add-Rect $g 33 1 14 14 '#E9D28E'
Add-Rect $g 35 4 3 2 '#C8A65E'
Add-Rect $g 42 11 4 2 '#C8A65E'
Add-Rect $g 48 0 16 16 '#89572F'
Add-Rect $g 49 1 14 14 '#A66C3C'
for ($line = 3; $line -lt 16; $line += 4) { Add-Rect $g 49 $line 14 1 '#6F4328' }
Add-Rect $g 64 0 16 16 '#4B9EB0'
Add-Rect $g 64 1 16 2 '#78C9C0'
Add-Rect $g 67 7 5 1 '#78C9C0'
Add-Rect $g 74 12 4 1 '#2F7F92'
Add-Rect $g 80 0 16 16 '#72B84F'
Add-Rect $g 80 0 16 4 '#E8D39A'
Add-Rect $g 80 4 16 2 '#B7C67A'
Add-Rect $g 96 0 16 16 '#72B84F'
Add-Rect $g 96 6 16 4 '#7A4A2D'
Add-Rect $g 96 7 16 2 '#A66C3C'
Add-Rect $g 99 3 2 10 '#5C3A27'
Add-Rect $g 107 3 2 10 '#5C3A27'
Add-Rect $g 112 0 16 16 '#72B84F'
Add-Rect $g 118 0 4 16 '#7A4A2D'
Add-Rect $g 119 0 2 16 '#A66C3C'
Add-Rect $g 115 3 10 2 '#5C3A27'
Add-Rect $g 115 11 10 2 '#5C3A27'

# Second row: flowers, stones, gate, dark soil, path edge and three detail variants.
Add-Rect $g 0 16 16 16 '#72B84F'
foreach ($flower in @(@(3,5,'#FFF0B0'),@(9,3,'#E98275'),@(12,11,'#FFF0B0'),@(5,13,'#E98275'))) {
    Add-Rect $g ($flower[0]-1) ($flower[1]+15) 3 3 '#4F963F'
    Add-Pixel $terrain $flower[0] ($flower[1]+16) $flower[2]
}
Add-Rect $g 16 16 16 16 '#72B84F'
Add-Rect $g 20 22 8 6 '#73746C'
Add-Rect $g 21 20 6 3 '#A6A58E'
Add-Rect $g 23 21 3 1 '#D4D0AB'
Add-Rect $g 32 16 16 16 '#72B84F'
Add-Rect $g 32 22 16 4 '#7A4A2D'
Add-Rect $g 32 23 6 2 '#A66C3C'
Add-Rect $g 42 23 6 2 '#A66C3C'
Add-Rect $g 37 18 2 11 '#5C3A27'
Add-Rect $g 41 18 2 11 '#5C3A27'
Add-Rect $g 48 16 16 16 '#6D422B'
Add-Rect $g 49 17 14 14 '#805036'
for ($line = 19; $line -lt 32; $line += 4) { Add-Rect $g 49 $line 14 1 '#553324' }
Add-Rect $g 64 16 16 16 '#72B84F'
Add-Rect $g 68 16 8 16 '#D8BC75'
Add-Rect $g 69 16 6 16 '#E9D28E'
Add-Rect $g 80 16 16 16 '#72B84F'
Add-Rect $g 83 19 2 5 '#4F963F'
Add-Rect $g 88 25 2 4 '#4F963F'
Add-Rect $g 93 18 1 4 '#9BD267'
Add-Rect $g 96 16 16 16 '#72B84F'
Add-Rect $g 98 26 12 3 '#447E36'
Add-Rect $g 100 23 8 4 '#5FA345'
Add-Rect $g 103 20 3 4 '#8AC65C'
Add-Rect $g 112 16 16 16 '#72B84F'
Add-Rect $g 115 18 10 10 '#4F963F'
Add-Rect $g 117 17 6 10 '#8BC95E'
Add-Rect $g 119 20 3 5 '#A9DA75'

# Third row: four complementary water tiles. Their wave bands deliberately cross
# tile edges so a pond does not read as a repeated static checkerboard.
Add-Rect $g 0 32 16 16 '#367D95'
Add-Rect $g 0 33 16 7 '#4D9FB1'
Add-Rect $g 0 40 16 8 '#2F7189'
Add-Rect $g 2 36 7 1 '#91D1CE'
Add-Rect $g 10 44 5 1 '#70B8C2'
Add-Rect $g 16 32 16 16 '#367D95'
Add-Rect $g 16 33 16 7 '#55AABB'
Add-Rect $g 16 40 16 8 '#347D96'
Add-Rect $g 16 43 4 1 '#91D1CE'
Add-Rect $g 23 36 8 1 '#B4E2D6'
Add-Rect $g 32 32 16 16 '#367D95'
Add-Rect $g 32 33 16 7 '#4C9CAF'
Add-Rect $g 32 40 16 8 '#2E6F88'
Add-Rect $g 32 38 5 1 '#7EC5C7'
Add-Rect $g 40 45 6 1 '#A9DDD4'
Add-Rect $g 48 32 16 16 '#367D95'
Add-Rect $g 48 33 16 7 '#58ADBA'
Add-Rect $g 48 40 16 8 '#327A93'
Add-Rect $g 49 45 7 1 '#86C9CA'
Add-Rect $g 58 37 4 1 '#B9E6D9'
$g.Dispose()
Save-Png $terrain 'assets/art/tilesets/home_terrain.png'

function Draw-CharacterFrame($Bitmap, [int]$OriginX, [int]$OriginY, [string]$Direction, [int]$Frame) {
    $g = [System.Drawing.Graphics]::FromImage($Bitmap)
    $step = @(-1,0,1,0)[$Frame]
    $dark = '#3B332D'; $hair = '#72452E'; $hairLight = '#A5643C'; $skin = '#F2C69B'
    $shirt = '#D6A83D'; $shirtLight = '#F0C95B'; $vest = '#245C5B'; $vestLight = '#347977'
    $cream = '#F3E1B6'; $pants = '#55463D'; $boot = '#4A3025'
    # Shadow and boots define a consistent foot anchor at y=30.
    Add-Rect $g ($OriginX+7) ($OriginY+29) 10 2 '#467C3B'
    if ($Direction -eq 'side') {
        Add-Rect $g ($OriginX+8+$step) ($OriginY+24) 4 6 $pants
        Add-Rect $g ($OriginX+12-$step) ($OriginY+24) 4 6 $pants
        Add-Rect $g ($OriginX+7+$step) ($OriginY+29) 5 2 $boot
        Add-Rect $g ($OriginX+12-$step) ($OriginY+29) 5 2 $boot
        Add-Rect $g ($OriginX+7) ($OriginY+13) 10 12 $dark
        Add-Rect $g ($OriginX+8) ($OriginY+13) 8 11 $vest
        Add-Rect $g ($OriginX+7) ($OriginY+14) 3 8 $shirt
        Add-Rect $g ($OriginX+15) ($OriginY+15) 3 7 $shirtLight
        Add-Rect $g ($OriginX+9) ($OriginY+3) 9 10 $dark
        Add-Rect $g ($OriginX+10) ($OriginY+4) 8 8 $skin
        Add-Rect $g ($OriginX+9) ($OriginY+3) 8 4 $hair
        Add-Rect $g ($OriginX+10) ($OriginY+2) 6 2 $hairLight
        Add-Pixel $Bitmap ($OriginX+17) ($OriginY+7) '#302A28'
        Add-Rect $g ($OriginX+10) ($OriginY+12) 5 2 $cream
    } else {
        Add-Rect $g ($OriginX+6+$step) ($OriginY+24) 5 6 $pants
        Add-Rect $g ($OriginX+13-$step) ($OriginY+24) 5 6 $pants
        Add-Rect $g ($OriginX+5+$step) ($OriginY+29) 6 2 $boot
        Add-Rect $g ($OriginX+13-$step) ($OriginY+29) 6 2 $boot
        Add-Rect $g ($OriginX+6) ($OriginY+13) 12 12 $dark
        Add-Rect $g ($OriginX+7) ($OriginY+14) 10 10 $vest
        Add-Rect $g ($OriginX+5) ($OriginY+15) 3 8 $shirt
        Add-Rect $g ($OriginX+17) ($OriginY+15) 3 8 $shirtLight
        Add-Rect $g ($OriginX+7) ($OriginY+3) 10 10 $dark
        Add-Rect $g ($OriginX+8) ($OriginY+4) 8 8 $skin
        Add-Rect $g ($OriginX+7) ($OriginY+3) 10 4 $hair
        Add-Rect $g ($OriginX+9) ($OriginY+2) 6 2 $hairLight
        if ($Direction -eq 'down') {
            Add-Pixel $Bitmap ($OriginX+10) ($OriginY+8) '#302A28'
            Add-Pixel $Bitmap ($OriginX+15) ($OriginY+8) '#302A28'
            Add-Rect $g ($OriginX+10) ($OriginY+12) 4 2 $cream
            Add-Rect $g ($OriginX+11) ($OriginY+14) 2 7 $shirtLight
        } else {
            Add-Rect $g ($OriginX+8) ($OriginY+4) 8 7 $hair
            Add-Rect $g ($OriginX+10) ($OriginY+12) 4 2 $cream
            Add-Rect $g ($OriginX+11) ($OriginY+14) 2 7 $vestLight
        }
    }
    $g.Dispose()
}

$player = New-PixelBitmap 96 96
for ($frame = 0; $frame -lt 4; $frame++) {
    Draw-CharacterFrame $player ($frame*24) 0 'down' $frame
    Draw-CharacterFrame $player ($frame*24) 32 'up' $frame
    Draw-CharacterFrame $player ($frame*24) 64 'side' $frame
}
Save-Png $player 'assets/art/characters/player_walk.png'

# Original farmhouse exterior.
$farmhouse = New-PixelBitmap 160 112
$g = [System.Drawing.Graphics]::FromImage($farmhouse)
Add-Rect $g 22 38 116 66 '#49362C'
Add-Rect $g 25 41 110 60 '#F0D5A0'
for ($y = 47; $y -lt 100; $y += 9) { Add-Rect $g 25 $y 110 1 '#D9B87D' }
Add-Rect $g 12 30 136 12 '#633B2C'
Add-Rect $g 19 20 122 12 '#A94F3C'
Add-Rect $g 29 10 102 11 '#C76049'
Add-Rect $g 42 3 76 9 '#D97855'
Add-Rect $g 54 0 52 5 '#E58A61'
for ($x = 28; $x -lt 136; $x += 10) { Add-Rect $g $x 13 2 18 '#8E3E32' }
Add-Rect $g 116 2 13 24 '#4B342B'
Add-Rect $g 118 0 9 21 '#8A5B45'
Add-Rect $g 66 66 28 38 '#4B342B'
Add-Rect $g 69 68 22 34 '#805238'
Add-Rect $g 73 71 14 29 '#A66C45'
Add-Rect $g 84 84 3 3 '#F2C75B'
foreach ($wx in @(34,108)) {
    Add-Rect $g $wx 55 25 24 '#4B342B'
    Add-Rect $g ($wx+3) 58 19 17 '#3C7773'
    Add-Rect $g ($wx+5) 60 7 13 '#90C5B2'
    Add-Rect $g ($wx+14) 60 6 13 '#B6D9C3'
    Add-Rect $g ($wx+11) 58 2 17 '#F2E0B4'
}
Add-Rect $g 18 98 124 6 '#704934'
Add-Rect $g 58 103 44 5 '#D8BC75'
$g.Dispose()
Save-Png $farmhouse 'assets/art/buildings/farmhouse.png'

# Original chicken coop exterior, smaller and more utilitarian than the farmhouse.
$coop = New-PixelBitmap 96 80
$g = [System.Drawing.Graphics]::FromImage($coop)
Add-Rect $g 12 31 72 43 '#4B342B'
Add-Rect $g 15 34 66 37 '#D6B276'
for ($x = 20; $x -lt 80; $x += 9) { Add-Rect $g $x 35 1 35 '#B78A55' }
Add-Rect $g 5 26 86 9 '#633B2C'
Add-Rect $g 13 17 70 10 '#9A4938'
Add-Rect $g 24 9 48 9 '#C26046'
Add-Rect $g 35 4 26 6 '#DB8058'
Add-Rect $g 36 46 24 28 '#4B342B'
Add-Rect $g 39 49 18 25 '#805238'
Add-Rect $g 45 52 6 5 '#E8D39A'
Add-Rect $g 18 45 12 12 '#4B342B'
Add-Rect $g 20 47 8 8 '#83B7A3'
Add-Rect $g 64 40 9 20 '#6A4A33'
Add-Rect $g 66 42 5 16 '#EEE0B6'
Add-Rect $g 8 71 80 5 '#704934'
$g.Dispose()
Save-Png $coop 'assets/art/buildings/chicken_coop.png'

# Original starter hen. It stays a simple visual adapter: care, products and
# quality remain owned by ChickenCoop's data-driven domain state.
$hen = New-PixelBitmap 32 24
$g = [System.Drawing.Graphics]::FromImage($hen)
Add-Rect $g 7 20 18 2 '#467C3B'
Add-Rect $g 8 8 16 12 '#41362D'
Add-Rect $g 10 7 13 12 '#F1E5C0'
Add-Rect $g 14 4 9 11 '#41362D'
Add-Rect $g 16 5 7 9 '#F4E6C7'
Add-Rect $g 22 8 5 4 '#E5A847'
Add-Rect $g 18 2 4 3 '#C95D4D'
Add-Pixel $hen 21 8 '#302A28'
Add-Rect $g 10 15 9 3 '#D9B87D'
Add-Rect $g 12 18 3 4 '#D58A3F'
Add-Rect $g 20 18 3 4 '#D58A3F'
Add-Rect $g 6 10 4 7 '#D9B87D'
$g.Dispose()
Save-Png $hen 'assets/art/animals/starter_hen.png'

# Original spring tree and a small prop sheet.
$tree = New-PixelBitmap 48 64
$g = [System.Drawing.Graphics]::FromImage($tree)
Add-Rect $g 20 40 9 21 '#5B3A28'
Add-Rect $g 24 42 7 18 '#815236'
Add-Rect $g 16 55 19 5 '#406F35'
Add-Rect $g 8 20 32 27 '#315F39'
Add-Rect $g 3 25 42 14 '#315F39'
Add-Rect $g 12 10 25 33 '#4C8E45'
Add-Rect $g 18 4 14 37 '#67AA4D'
Add-Rect $g 9 15 11 15 '#79BC58'
Add-Rect $g 25 10 9 14 '#8AC75F'
Add-Rect $g 15 7 5 5 '#A3D36E'
Add-Rect $g 32 23 5 6 '#A3D36E'
$g.Dispose()
Save-Png $tree 'assets/art/props/tree.png'

# Original crop stages: a compact 4-frame 16px strip for the first functional
# farm plot. The shared silhouette keeps the prototype readable; individual
# crop varieties can later supply alternate mature frames without changing code.
$cropStages = New-PixelBitmap 64 16
$g = [System.Drawing.Graphics]::FromImage($cropStages)
for ($tile = 0; $tile -lt 4; $tile++) {
    $x = $tile * 16
    Add-Rect $g $x 0 16 16 '#5B3828'
    Add-Rect $g ($x+1) 1 14 14 '#865238'
    Add-Rect $g ($x+2) 4 12 1 '#A66C45'
    Add-Rect $g ($x+2) 10 12 1 '#6E422F'
}
# Tilled soil: no crop yet.
Add-Rect $g 2 7 3 2 '#B67B4C'; Add-Rect $g 10 3 3 2 '#B67B4C'
# Tender sprout.
Add-Rect $g 22 8 2 5 '#315F39'; Add-Rect $g 19 7 4 3 '#62A94D'; Add-Rect $g 23 5 4 4 '#79BC58'
# Growing leafy crop.
Add-Rect $g 37 5 3 8 '#315F39'; Add-Rect $g 33 6 5 5 '#4C8E45'; Add-Rect $g 40 3 6 6 '#68AE50'; Add-Rect $g 36 2 4 4 '#8AC75F'
# Mature spring crop, warm yellow roots under a full leafy top.
Add-Rect $g 53 5 3 8 '#315F39'; Add-Rect $g 49 5 6 6 '#4C8E45'; Add-Rect $g 55 2 5 7 '#72B84F'; Add-Rect $g 58 6 3 4 '#98CA56'; Add-Rect $g 52 11 5 3 '#E6B858'; Add-Rect $g 57 11 3 3 '#F0CE6B'
$g.Dispose()
Save-Png $cropStages 'assets/art/crops/spring_crop_stages.png'

$props = New-PixelBitmap 64 32
$g = [System.Drawing.Graphics]::FromImage($props)
Add-Rect $g 1 8 14 20 '#4B342B'; Add-Rect $g 3 10 10 17 '#9A633E'; Add-Rect $g 3 16 10 2 '#D29A57'; Add-Rect $g 7 10 2 17 '#72442E'
Add-Rect $g 18 18 12 12 '#4B342B'; Add-Rect $g 20 20 8 8 '#C98B43'; Add-Rect $g 22 16 4 5 '#5C8D43'
Add-Rect $g 35 11 10 19 '#4B342B'; Add-Rect $g 37 13 6 15 '#E5D9A8'; Add-Rect $g 38 15 4 2 '#355C58'; Add-Rect $g 38 20 4 1 '#8D7754'
Add-Rect $g 49 23 14 7 '#3D6F39'; Add-Rect $g 52 18 8 10 '#73B752'; Add-Rect $g 54 15 4 6 '#F1D76A'; Add-Pixel $props 56 16 '#E47B65'
$g.Dispose()
Save-Png $props 'assets/art/props/home_props.png'

Write-Host 'ORIGINAL_PIXEL_ASSETS_READY'
