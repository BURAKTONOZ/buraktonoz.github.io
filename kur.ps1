<#
    TONOZ - MERKEZİ KURULUM ASİSTANI v4.0
#>

try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    [Console]::InputEncoding  = [System.Text.Encoding]::UTF8
    $OutputEncoding = [System.Text.Encoding]::UTF8
    chcp 65001 > $null
} catch {}

$Surum    = '4.0'$Genislik = 62

$Moduller = @(
    @{ Ad = 'NPYS';     Aciklama = 'Numarataj Personel Yönetim Sistemi'; Dosya = 'NPYS.exe';     Url = 'https://github.com/BURAKTONOZ/personel/releases/latest/download/NPYS.exe' }
    @{ Ad = 'TonoLink'; Aciklama = 'Kısayol Dock Programı';              Dosya = 'TonoLink.exe'; Url = '' }
    @{ Ad = 'PayTak';   Aciklama = 'Ödeme Takip Programı';               Dosya = 'PayTak.exe';   Url = '' }
)

$Katalog = [ordered]@{
    'Tarayıcılar' = @(
        @{ Ad = 'Google Chrome';  Id = 'Google.Chrome';    Aciklama = 'En yaygın web tarayıcısı' }
        @{ Ad = 'Mozilla Firefox'; Id = 'Mozilla.Firefox'; Aciklama = 'Gizlilik odaklı tarayıcı' }
    )
    'Ofis ve Üretkenlik' = @(
        @{ Ad = 'Microsoft 365 (Office)'; Id = 'Microsoft.Office'; Aciklama = 'Lisans gerektirir' }
        @{ Ad = 'LibreOffice';       Id = 'TheDocumentFoundation.LibreOffice'; Aciklama = 'Ücretsiz alternatif' }
        @{ Ad = 'Adobe Acrobat Reader'; Id = 'Adobe.Acrobat.Reader.64-bit';    Aciklama = 'PDF okuyucu' }
        @{ Ad = 'WinRAR';            Id = 'RARLab.WinRAR';          Aciklama = 'Arşiv yöneticisi' }
    )
    'Geliştirici Araçları' = @(
        @{ Ad = 'Visual Studio Code'; Id = 'Microsoft.VisualStudioCode'; Aciklama = 'Kod editörü' }
        @{ Ad = 'Git';                Id = 'Git.Git';                    Aciklama = 'Sürüm kontrol' }
        @{ Ad = 'Node.js (LTS)';      Id = 'OpenJS.NodeJS.LTS';          Aciklama = 'JavaScript ortamı' }
    )
}

$Paketler = [ordered]@{
    'Temel Paket' = @('Google.Chrome', 'RARLab.WinRAR', 'Adobe.Acrobat.Reader.64-bit')
    'Geliştirici' = @('Microsoft.VisualStudioCode', 'Git.Git', 'OpenJS.NodeJS.LTS')
}

function Write-Cizgi { Write-Host (' ' + ('─' * $Genislik)) -ForegroundColor DarkGray }

function Write-Baslik {
    param([string]$Baslik)$ic  = $Genislik - 2$sol = [math]::Floor(($ic -$Baslik.Length) / 2)
    $sag =$ic - $Baslik.Length -$sol
    Write-Host (' ╔' + ('═' * $ic) + '╗') -ForegroundColor DarkGray
    Write-Host ' ║' -ForegroundColor DarkGray -NoNewline
    Write-Host ((' ' * $sol) + $Baslik + (' ' *$sag)) -ForegroundColor Yellow -NoNewline
    Write-Host '║' -ForegroundColor DarkGray
    Write-Host (' ╚' + ('═' * $ic) + '╝') -ForegroundColor DarkGray
}

function Write-Mesaj {
    param([string]$Tip, [string]$Metin)
    switch ($Tip) {
        'bilgi' { $s = '[i]';$r = 'Cyan' }
        'ok'    { $s = '[+]';$r = 'Green' }
        'uyari' { $s = '[!]';$r = 'Yellow' }
        'hata'  { $s = '[-]';$r = 'Red' }
        default { $s = '[>]';$r = 'Gray' }
    }
    Write-Host " $s $Metin" -ForegroundColor $r
}

function Write-MenuSatir {
    param([string]$Tus, [string]$Ad, [string]$Aciklama, [string]$TusRenk = 'Green', [bool]$Aktif = $true)$adRenk = 'White'
    if (-not $Aktif) { $TusRenk = 'DarkGray';$adRenk = 'DarkGray' }
    Write-Host '  ' -NoNewline
    Write-Host ('[{0}]' -f $Tus) -ForegroundColor$TusRenk -NoNewline
    Write-Host (' ' + $Ad.PadRight(28)) -ForegroundColor$adRenk -NoNewline
    Write-Host $Aciklama -ForegroundColor DarkGray
}

function Wait-Enter {
    Write-Host "`n Menüye dönmek için Enter tuşuna basın..." -ForegroundColor DarkGray
    $null = Read-Host
}

function Test-Admin {
    try {
        $id = [Security.Principal.WindowsIdentity]::GetCurrent()
        return (New-Object Security.Principal.WindowsPrincipal $id).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } catch { return $false }
}

function Test-Winget { return [bool](Get-Command winget -ErrorAction SilentlyContinue) }

function Show-Logo {
    $logo = @(
        '    _____ ___  _   _ ___  _____ ',
        '   |_   _/ _ \| \ | |/ _ \|__  / ',
        '     | || | | |  \| | | | | / /  ',
        '     | || |_| | |\  | |_| |/ /_  ',
        '     |_| \___/|_| \_|\___//____| '
    )
    $renkler = @('Cyan', 'Cyan', 'Cyan', 'DarkCyan', 'DarkCyan')
    Write-Host ''
    for ($i = 0; $i -lt $logo.Count; $i++) { Write-Host $logo[$i] -ForegroundColor $renkler[$i] }
    Write-Host ''
}

function Show-DurumSatiri {
    $admin  = if (Test-Admin)  { 'Evet' } else { 'Hayır' }
    $winget = if (Test-Winget) { 'Hazır' } else { 'Bulunamadı' }
    Write-Host '  Yönetici: ' -ForegroundColor DarkGray -NoNewline
    Write-Host $admin -ForegroundColor $(if($admin -eq 'Evet'){'Green'}else{'Yellow'}) -NoNewline
    Write-Host '   winget: ' -ForegroundColor DarkGray -NoNewline
    Write-Host $winget -ForegroundColor $(if($winget -eq 'Hazır'){'Green'}else{'Red'}) -NoNewline
    Write-Host ("   " + (Get-Date -Format 'dd.MM.yyyy HH:mm')) -ForegroundColor DarkGray
}

function Write-Ilerleme {
    param([long]$Indirilen, [long]$Toplam, [double]$Sure)
    $mb  = $Indirilen / 1MB
    $hiz = if ($Sure -gt 0) { $mb / $Sure } else { 0 }
    if ($Toplam -gt 0) {
        $yuzde = [int][math]::Floor($Indirilen * 100 / $Toplam)
        $dolu  = [int][math]::Floor(30 * $yuzde / 100)
        $bar   = ('█' * $dolu) + ('░' * (30 - $dolu))
        $satir = ' {0} %{1,3}  {2:N1}/{3:N1} MB  {4:N1} MB/s' -f $bar, $yuzde, $mb, ($Toplam / 1MB), $hiz
    } else {
        $satir = ' {0:N1} MB indirildi  {1:N1} MB/s' -f $mb, $hiz
    }
    Write-Host ("`r" + $satir.PadRight(78)) -ForegroundColor Cyan -NoNewline
}

function Invoke-Indirme {
    param([string]$Url, [string]$Hedef)
    $gecici = "$Hedef.part"
    $yanit =$null; $akis =$null; $dosya =$null
    try {
        $istek = [System.Net.HttpWebRequest]::Create($Url)
        $istek.UserAgent = "TonozKurulum/$Surum"
        $istek.AllowAutoRedirect = $true$istek.Timeout = 30000
        $yanit  =$istek.GetResponse()
        $toplam =$yanit.ContentLength
        $akis   =$yanit.GetResponseStream()
        $dosya  = [System.IO.File]::Create($gecici)

        $tampon    = New-Object byte[] 81920$indirilen = 0L
        $sw        = [System.Diagnostics.Stopwatch]::StartNew()$sonCizim  = 0

        while (($okunan = $akis.Read($tampon, 0, $tampon.Length)) -gt 0) {$dosya.Write($tampon, 0,$okunan)
            $indirilen +=$okunan
            if (($sw.ElapsedMilliseconds -$sonCizim) -ge 100) {
                $sonCizim =$sw.ElapsedMilliseconds
                Write-Ilerleme $indirilen $toplam$sw.Elapsed.TotalSeconds
            }
        }
        Write-Ilerleme $indirilen $toplam$sw.Elapsed.TotalSeconds
        Write-Host ''

        $dosya.Close(); $akis.Close();$yanit.Close()

        if ($indirilen -le 0) { throw 'Boş dosya indirildi.' }
        if (Test-Path $Hedef) { Remove-Item$Hedef -Force }
        Move-Item -Path $gecici -Destination$Hedef -Force
        return $true
    } catch {
        if ($dosya) {$dosya.Dispose() }
        if (Test-Path $gecici) { Remove-Item$gecici -Force -ErrorAction SilentlyContinue }
        Write-Host ''
        Write-Mesaj 'hata' "İndirme başarısız oldu! Hata: $($_.Exception.Message)"
        return $false
    } finally {
        if ($dosya) {$dosya.Dispose() }
        if ($akis)  {$akis.Dispose() }
        if ($yanit) {$yanit.Dispose() }
    }
}

function Start-ModulIndir {
    param($Modul)
    if ([string]::IsNullOrWhiteSpace($Modul.Url)) {
        Write-Mesaj 'uyari' "$($Modul.Ad) henüz aktif değil."
        Start-Sleep -Seconds 2
        return
    }
    $hedef = Join-Path ([Environment]::GetFolderPath('Desktop'))$Modul.Dosya
    Write-Host "`n [i] Uygulama: $($Modul.Ad) | Hedef: $hedef" -ForegroundColor Cyan
    Write-Mesaj 'adim' 'Bağlantı kuruluyor...'
    
    if (Invoke-Indirme -Url $Modul.Url -Hedef $hedef) {
        Write-Mesaj 'ok' "İşlem başarılı! Masaüstüne kaydedildi."
        if ((Read-Host '  > Çalıştırılsın mı? (E/H)') -match '^[eE]') { Start-Process $hedef }
    }
    Wait-Enter
}

function Get-ProgramById {
    param([string]$Id)
    foreach ($k in $Katalog.Keys) { foreach ($p in $Katalog[$k]) { if ($p.Id -eq $Id) { return $p } } }
    return @{ Ad = $Id; Id = $Id }
}

function Install-Program {
    param($Program)
    Write-Host "`n [>] $($Program.Ad) kuruluyor..." -ForegroundColor Yellow
    $arg = @('install', '--id',$Program.Id, '-e', '--silent', '--accept-package-agreements', '--accept-source-agreements')
    & winget @arg
    if ($LASTEXITCODE -eq 0 -or$LASTEXITCODE -in @(-1978335189, -1978335135)) { Write-Mesaj 'ok' "$($Program.Ad) kuruldu!" }
    else { Write-Mesaj 'hata' "$($Program.Ad) kurulamadı." }
}

function Install-Liste {
    param([object[]]$Programlar)
    Write-Host ''
    foreach ($p in$Programlar) { Write-Host "     - $($p.Ad)" -ForegroundColor White }
    if ((Read-Host "`n  > Kurulumu onaylıyor musunuz? (E/H)") -match '^[eE]') {
        foreach ($p in $Programlar) { Install-Program $p }
    }
    Wait-Enter
}

function Show-KategoriMenu {
    param([string]$Kategori)
    $liste = @($Katalog[$Kategori])
    while ($true) {
        Clear-Host; Write-Baslik $Kategori; Write-Host ''
        for ($i = 0; $i -lt $liste.Count; $i++) { Write-MenuSatir ($i+1) $liste[$i].Ad $liste[$i].Aciklama }
        Write-Host "`n  [B] Geri" -ForegroundColor Cyan
        $g = (Read-Host "`n  > Seçim").Trim()
        if ($g -match '^[bB]$') { break }
        if ($g -match '^\d+$' -and [int]$g -le $liste.Count) { Install-Liste @($liste[[int]$g - 1]) }
    }
}

function Show-PaketMenu {
    $keys = @($Paketler.Keys)
    while ($true) {
        Clear-Host; Write-Baslik 'HAZIR PAKETLER'; Write-Host ''
        for ($i = 0; $i -lt $keys.Count; $i++) { Write-MenuSatir ($i+1) $keys[$i] "" }
        Write-Host "`n  [B] Geri" -ForegroundColor Cyan
        $g = (Read-Host "`n  > Seçim").Trim()
        if ($g -match '^[bB]$') { break }
        if ($g -match '^\d+$' -and [int]$g -le $keys.Count) {
            Install-Liste @($Paketler[$keys[[int]$g - 1]] | ForEach-Object { Get-ProgramById $_ })
        }
    }
}

function Show-YazilimMenu {
    $keys = @($Katalog.Keys)
    while ($true) {
        Clear-Host; Write-Baslik 'YAZILIM KURULUM MERKEZİ'; Write-Host ''
        for ($i = 0; $i -lt $keys.Count; $i++) { Write-MenuSatir ($i+1) $keys[$i] "($(@($Katalog[$keys[$i]]).Count) program)" }
        Write-Host ''; Write-MenuSatir 'P' 'Hazır Paketler' '' 'Yellow'
        Write-MenuSatir 'B' 'Geri Dön' '' 'Cyan'; Write-Host ''
        $g = (Read-Host '  > Seçim').Trim()
        if ($g -match '^[bB]$') { break }
        if ($g -match '^[pP]$') { Show-PaketMenu }
        if ($g -match '^\d+$' -and [int]$g -le $keys.Count) { Show-KategoriMenu $keys[[int]$g - 1] }
    }
}

while ($true) {
    Clear-Host; Show-Logo; Write-Baslik "MERKEZİ KURULUM ASİSTANI v$Surum"
    Show-DurumSatiri; Write-Host "`n  Programlarım" -ForegroundColor Cyan; Write-Cizgi
    for ($i = 0; $i -lt $Moduller.Count; $i++) {
        $m =$Moduller[$i]; Write-MenuSatir ($i+1) $m.Ad $(if($m.Url){$m.Aciklama}else{'(Yakında)'}) 'Green' $([bool]$m.Url)
    }
    Write-Host "`n  Araçlar" -ForegroundColor Cyan; Write-Cizgi
    Write-MenuSatir 'K' 'Yazılım Kurulum Merkezi' '' 'Yellow'
    Write-MenuSatir 'Q' 'Çıkış' '' 'Red'; Write-Host ''
    
    $secim = (Read-Host '  > Seçim').Trim().ToUpper()
    if ($secim -match '^\d+$' -and [int]$secim -le $Moduller.Count) { Start-ModulIndir $Moduller[[int]$secim - 1] }
    elseif ($secim -eq 'K') { Show-YazilimMenu }
    elseif ($secim -eq 'Q') { Write-Host " Çıkılıyor...`n"; break }
}
