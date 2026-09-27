
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$map = Get-Content (Join-Path $root "site-map.json") -Raw | ConvertFrom-Json
$errors = 0
$htmlCount = 0

function Check-File($relative) {
    $path = Join-Path $root $relative
    if (!(Test-Path $path)) {
        Write-Host "[HATA] $relative" -ForegroundColor Red
        return $false
    }
    return $true
}

Check-File "index.html" | Out-Null
Check-File "login.html" | Out-Null

foreach ($term in $map.donemler) {
    foreach ($course in $term.dersler) {
        if (!(Check-File $course.ana_sayfa)) { $errors++ }

        foreach ($m in $course.materyaller) {
            $files = @($m.konu, $m.sunum, $m.sorular)
            foreach ($f in $files) {
                $relative = Join-Path $course.klasor $f
                $htmlCount++
                if (!(Check-File $relative)) { $errors++ }
            }
        }
    }
}

Write-Host ""
Write-Host "HTML materyal sayısı: $htmlCount"
if ($errors -eq 0) {
    Write-Host "SONUÇ: TÜM DOSYALAR VE HARİTALANAN HEDEFLER HAZIR." -ForegroundColor Green
} else {
    Write-Host "SONUÇ: $errors eksik hedef bulundu." -ForegroundColor Red
}
