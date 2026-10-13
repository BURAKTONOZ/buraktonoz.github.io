<#
    TONOZ - MERKEZİ KURULUM ASİSTANI v4.0
    Windows PowerShell 5.1 ve PowerShell 7 ile tam uyumludur.
    ÖNEMLİ: Menü çizgilerinin ve Türkçe karakterlerin düzgün görünmesi için
    bu dosyayı kesinlikle "UTF-8 with BOM" olarak kaydetmelisiniz!
#>

# ============================================================
#  AYARLAR VE KODLAMA (ENCODING) DÜZELTMELERİ
# ============================================================
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

# Konsolun hem çıktı hem girdi kodlamasını UTF-8'e zorluyoruz
try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    [Console]::InputEncoding  = [System.Text.Encoding]::UTF8
    $OutputEncoding = [System.Text.Encoding]::UTF8
    chcp 65001 > $null
} catch {}

$Surum    = '4.0'
$Genislik = 62

# ------------------------------------------------------------
#  ANA MENÜDEKİ MODÜLLER (Masaüstüne indirilen kendi programların)
#  Url boş bırakılırsa "Yakında" olarak görünür.
# ------------------------------------------------------------
$Moduller = @(
    @{ Ad = 'NPYS';     Aciklama = 'Numarataj Personel Yönetim Sistemi'; Dosya = 'NPYS.exe';     Url = 'https://github.com/BURAKTONOZ/personel/releases/latest/download/NPYS.exe' }
    @{ Ad = 'TonoLink'; Aciklama = 'Kısayol Dock Programı';              Dosya = 'TonoLink.exe'; Url = '' }
    @{ Ad = 'PayTak';   Aciklama = 'Ödeme Takip Programı';               Dosya = 'PayTak.exe';   Url = '' }
)

# ------------------------------------------------------------
#  YAZILIM KATALOĞU (winget)
# ------------------------------------------------------------
$Katalog = [ordered]@{
    'Tarayıcılar' = @(
        @{ Ad = 'Google Chrome';  Id = 'Google.Chrome';    Aciklama = 'En yaygın web tarayıcısı' }
        @{ Ad = 'Mozilla Firefox'; Id = 'Mozilla.Firefox'; Aciklama = 'Gizlilik odaklı tarayıcı' }
        @{ Ad = 'Brave';          Id = 'Brave.Brave';      Aciklama = 'Reklam engelleyicili tarayıcı' }
    )
    'Ofis ve Üretkenlik' = @(
        @{ Ad = 'Microsoft 365 (Office)'; Id = 'Microsoft.Office'; Aciklama = 'Lisans gerektirir' }
        @{ Ad = 'LibreOffice';       Id = 'TheDocumentFoundation.LibreOffice'; Aciklama = 'Ücretsiz Office alternatifi' }
        @{ Ad = 'Adobe Acrobat Reader'; Id = 'Adobe.Acrobat.Reader.64-bit';    Aciklama = 'PDF okuyucu' }
        @{ Ad = 'SumatraPDF';        Id = 'SumatraPDF.SumatraPDF';  Aciklama = 'Hafif PDF okuyucu' }
        @{ Ad = 'Notepad++';         Id = 'Notepad++.Notepad++';    Aciklama = 'Gelişmiş metin editörü' }
    )
    'Sistem Araçları' = @(
        @{ Ad = 'WinRAR';       Id = 'RARLab.WinRAR';          Aciklama = 'Arşiv yöneticisi' }
        @{ Ad = '7-Zip';        Id = '7zip.7zip';              Aciklama = 'Ücretsiz arşiv yöneticisi' }
        @{ Ad = 'PowerToys';    Id = 'Microsoft.PowerToys';    Aciklama = 'Microsoft güç araçları' }
        @{ Ad = 'Everything';   Id = 'voidtools.Everything';   Aciklama = 'Anında dosya arama' }
        @{ Ad = 'ShareX';       Id = 'ShareX.ShareX';          Aciklama = 'Ekran görüntüsü / kayıt' }
        @{ Ad = 'Rufus';        Id = 'Rufus.Rufus';            Aciklama = 'Önyüklenebilir USB hazırlama' }
        @{ Ad = 'AnyDesk';      Id = 'AnyDesk.AnyDesk';        Aciklama = 'Uzaktan masaüstü' }
        @{ Ad = 'TeamViewer';   Id = 'TeamViewer.TeamViewer';  Aciklama = 'Uzaktan destek' }
    )
    'Geliştirici Araçları' = @(
        @{ Ad = 'Visual Studio Code'; Id = 'Microsoft.VisualStudioCode'; Aciklama = 'Kod editörü' }
        @{ Ad = 'Git';                Id = 'Git.Git';                    Aciklama = 'Sürüm kontrol' }
        @{ Ad = 'Node.js (LTS)';      Id = 'OpenJS.NodeJS.LTS';          Aciklama = 'JavaScript çalışma ortamı' }
        @{ Ad = 'Python 3.13';        Id = 'Python.Python.3.13';         Aciklama = 'Python dili' }
        @{ Ad = 'Windows Terminal';   Id = 'Microsoft.WindowsTerminal';  Aciklama = 'Modern terminal' }
        @{ Ad = 'PowerShell 7';       Id = 'Microsoft.PowerShell';       Aciklama = 'Yeni nesil PowerShell' }
        @{ Ad = 'GitHub Desktop';     Id = 'GitHub.GitHubDesktop';       Aciklama = 'Git arayüzü' }
        @{ Ad = 'Postman';            Id = 'Postman.Postman';            Aciklama = 'API test aracı' }
        @{ Ad = 'Docker Desktop';     Id = 'Docker.DockerDesktop';       Aciklama = 'Konteyner platformu' }
    )
    'Medya ve Tasarım' = @(
        @{ Ad = 'VLC Media Player'; Id = 'VideoLAN.VLC';            Aciklama = 'Her formatı oynatır' }
        @{ Ad = 'Spotify';          Id = 'Spotify.Spotify';         Aciklama = 'Müzik' }
        @{ Ad = 'OBS Studio';       Id = 'OBSProject.OBSStudio';    Aciklama = 'Yayın ve ekran kaydı' }
        @{ Ad = 'Audacity';         Id = 'Audacity.Audacity';       Aciklama = 'Ses düzenleme' }
        @{ Ad = 'HandBrake';        Id = 'HandBrake.HandBrake';     Aciklama = 'Video dönüştürücü' }
        @{ Ad = 'Paint.NET';        Id = 'dotPDN.PaintDotNet';      Aciklama = 'Resim düzenleme' }
        @{ Ad = 'IrfanView';        Id = 'IrfanSkiljan.IrfanView';  Aciklama = 'Hızlı resim görüntüleyici' }
    )
    'İletişim' = @(
        @{ Ad = 'WhatsApp';         Id = '9NKSQGP7F2NH';            Aciklama = 'Mağaza sürümü'; Kaynak = 'msstore' }
        @{ Ad = 'Telegram';         Id = 'Telegram.TelegramDesktop'; Aciklama = 'Mesajlaşma' }
        @{ Ad = 'Discord';          Id = 'Discord.Discord';         Aciklama = 'Sesli / yazılı sohbet' }
        @{ Ad = 'Zoom';             Id = 'Zoom.Zoom';               Aciklama = 'Görüntülü toplantı' }
        @{ Ad = 'Microsoft Teams';  Id = 'Microsoft.Teams';         Aciklama = 'İş görüşmeleri' }
        @{ Ad = 'Slack';            Id = 'SlackTechnologies.Slack'; Aciklama = 'Ekip iletişimi' }
    )
    'Oyun' = @(
        @{ Ad = 'Steam';            Id = 'Valve.Steam';                     Aciklama = 'Oyun platformu' }
        @{ Ad = 'Epic Games';       Id = 'EpicGames.EpicGamesLauncher';     Aciklama = 'Epic oyun başlatıcı' }
        @{ Ad = 'GOG Galaxy';       Id = 'GOG.Galaxy';                      Aciklama = 'GOG oyun başlatıcı' }
        @{ Ad = 'Battle.net';       Id = 'Blizzard.BattleNet';              Aciklama = 'Blizzard oyunları' }
    )
    'Sürücü ve Çalışma Kitaplıkları' = @(
        @{ Ad = 'Visual C++ Redistributable'; Id = 'Microsoft.VCRedist.2015+.x64';      Aciklama = 'Birçok program için gerekli' }
        @{ Ad = '.NET Desktop Runtime 8';     Id = 'Microsoft.DotNet.DesktopRuntime.8'; Aciklama = '.NET uygulamaları için' }
        @{ Ad = 'DirectX Çalışma Zamanı';     Id = 'Microsoft.DirectX';                 Aciklama = 'Oyun / grafik bileşenleri' }
        @{ Ad = 'CPU-Z';                      Id = 'CPUID.CPU-Z';                       Aciklama = 'İşlemci bilgisi' }
        @{ Ad = 'GPU-Z';                      Id = 'TechPowerUp.GPU-Z';                 Aciklama = 'Ekran kartı bilgisi' }
    )
}

# ------------------------------------------------------------
#  HAZIR PAKETLER
# ------------------------------------------------------------
$Paketler = [ordered]@{
    'Yeni PC - Temel Paket' = @('Google.Chrome', '7zip.7zip', 'VideoLAN.VLC', 'Notepad++.Notepad++', 'Adobe.Acrobat.Reader.64-bit', 'Microsoft.VCRedist.2015+.x64')
    'Geliştirici Paketi'    = @('Microsoft.VisualStudioCode', 'Git.Git', 'OpenJS.NodeJS.LTS', 'Python.Python.3.13', 'Microsoft.WindowsTerminal')
    'Ofis Paketi'           = @('Google.Chrome', 'TheDocumentFoundation.LibreOffice', 'Adobe.Acrobat.Reader.64-bit', '7zip.7zip')
}

# ============================================================
#  YARDIMCI FONKSİYONLAR
# ============================================================
function Write-Cizgi {
    Write-Host (' ' + ('─' * $Genislik)) -ForegroundColor DarkGray
}

function Write-Baslik {
    param([string]$Baslik)
    $ic  = $Genislik - 2
    $sol = [math]::Floor(($ic - $Baslik.Length) / 2)
    $sag = $ic - $Baslik.Length - $sol
    Write-Host (' ╔' + ('═' * $ic) + '╗') -ForegroundColor DarkGray
    Write-Host ' ║' -ForegroundColor DarkGray -NoNewline
    Write-Host ((' ' * $sol) + $Baslik + (' ' * $sag)) -ForegroundColor Yellow -NoNewline
    Write-Host '║' -ForegroundColor DarkGray
    Write-Host (' ╚' + ('═' * $ic) + '╝') -ForegroundColor DarkGray
}

function Write-Mesaj {
    param([string]$Tip, [string]$Metin)
    switch ($Tip) {
        'bilgi' { $s = '[i]'; $r = 'Cyan' }
        'ok'    { $s = '[+]'; $r = 'Green' }
        'uyari' { $s = '[!]'; $r = 'Yellow' }
        'hata'  { $s = '[-]'; $r = 'Red' }
        default { $s = '[>]'; $r = 'Gray' }
    }
    Write-Host " $s $Metin" -ForegroundColor $r
}

function Write-MenuSatir {
    param([string]$Tus, [string]$Ad, [string]$Aciklama, [string]$TusRenk = 'Green', [bool]$Aktif = $true)
    $adRenk = 'White'
    if (-not $Aktif) { $TusRenk = 'DarkGray'; $adRenk = 'DarkGray' }
    Write-Host '  ' -NoNewline
    Write-Host ('[{0}]' -f $Tus) -ForegroundColor $TusRenk -NoNewline
    Write-Host (' ' + $Ad.PadRight(28)) -ForegroundColor $adRenk -NoNewline
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

function Test-Winget {
    return [bool](Get-Command winget -ErrorAction SilentlyContinue)
}

function Show-Logo {
    $logo = @( '    _____ ___  _   _ ___  _____ ', '   \vert{}_   _/ _ \Vert{} \ \vert{} \vert{}/ _ \Vert{}__  / ', '     \vert{} \vert{}\vert{} \vert{} \vert{} \vert{}  \Vert{} \vert{} \vert{} \vert{} \vert{} / /  ', '     \vert{} \vert{}\vert{} \vert{}_\vert{} \vert{} \vert{}\  \vert{} \vert{}_\vert{} \vert{}/ /_  ', '     \vert{}_\vert{} \___/\vert{}_\vert{} \_\vert{}\___//____\vert{} ' )$renkler = @('Cyan', 'Cyan', 'Cyan', 'DarkCyan', 'DarkCyan')
    Write-Host ''
    for ($i = 0; $i -lt $logo.Count; $i++) {
        Write-Host $logo[$i] -ForegroundColor $renkler[$i]
    }
    Write-Host ''
}

function Show-DurumSatiri {
    $admin  = if (Test-Admin)  { 'Evet' } else { 'Hayır' }
    $winget = if (Test-Winget) { 'Hazır' } else { 'Bulunamadı' }
    $adminRenk  = if ($admin -eq 'Evet')    { 'Green' } else { 'Yellow' }
    $wingetRenk = if ($winget -eq 'Hazır')  { 'Green' } else { 'Red' }
    Write-Host '  Yönetici: ' -ForegroundColor DarkGray -NoNewline
    Write-Host $admin -ForegroundColor$adminRenk -NoNewline
    Write-Host '   winget: ' -ForegroundColor DarkGray -NoNewline
    Write-Host $winget -ForegroundColor$wingetRenk -NoNewline
    Write-Host ('   {0}' -f (Get-Date -Format 'dd.MM.yyyy HH:mm')) -ForegroundColor DarkGray
}

# ============================================================
#  İNDİRME (Hatasız ilerleme çubuğu - Olay kullanmaz)
# ============================================================
function Write-Ilerleme {
    param([long]$Indirilen, [long]$Toplam, [double]$Sure)$mb  = $Indirilen / 1MB$hiz = 0
    if ($Sure -gt 0) {$hiz = $mb / $Sure }
    if ($Toplam -gt 0) {
        $yuzde = [int][math]::Floor($Indirilen * 100 / $Toplam)$dolu  = [int][math]::Floor(30 * $yuzde / 100)$bar   = ('█' * $dolu) + ('░' * (30 -$dolu))
        $satir = ' {0} \%{1,3}  {2:N1}/{3:N1} MB  {4:N1} MB/s' -f$bar, $yuzde,$mb, ($Toplam / 1MB),$hiz
    } else {
        $satir = ' {0:N1} MB indirildi  {1:N1} MB/s' -f $mb,$hiz
    }
    Write-Host ("`r" + $satir.PadRight(78)) -ForegroundColor Cyan -NoNewline
}

function Invoke-Indirme {
    param([string]$Url, [string]$Hedef)
    $gecici = "$Hedef.part"
    $yanit = $null; $akis = $null; $dosya = $null
    try {
        $istek = [System.Net.HttpWebRequest]::Create($Url)
        $istek.UserAgent = "TonozKurulum/$Surum"
        $istek.AllowAutoRedirect = $true
        $istek.Timeout = 30000
        $yanit  = $istek.GetResponse()
        $toplam = $yanit.ContentLength
        $akis   = $yanit.GetResponseStream()
        $dosya  = [System.IO.File]::Create($gecici)

        $tampon    = New-Object byte[] 81920
        $indirilen = 0L
        $sw        = [System.Diagnostics.Stopwatch]::StartNew()
        $sonCizim  = 0

        while (($okunan = $akis.Read($tampon, 0, $tampon.Length)) -gt 0) {
            $dosya.Write($tampon, 0, $okunan)
            $indirilen += $okunan
            if (($sw.ElapsedMilliseconds - $sonCizim) -ge 100) {
                $sonCizim = $sw.ElapsedMilliseconds
                Write-Ilerleme $indirilen $toplam $sw.Elapsed.TotalSeconds
            }
        }
        Write-Ilerleme $indirilen $toplam $sw.Elapsed.TotalSeconds
        Write-Host ''

        $dosya.Close(); $akis.Close(); $yanit.Close()

        if ($indirilen -le 0) { throw 'Boş dosya indirildi.' }
        if (Test-Path $Hedef) { Remove-Item $Hedef -Force }
        Move-Item -Path $gecici -Destination $Hedef -Force
        return $true
    }
    catch {
        if ($dosya) { $dosya.Dispose() }
        if (Test-Path $gecici) { Remove-Item $gecici -Force -ErrorAction SilentlyContinue }
        Write-Host ''
        Write-Mesaj 'hata' 'İndirme başarısız oldu!'
        Write-Host "     Hata Detayı: $($_.Exception.Message)" -ForegroundColor DarkGray
        return $false
    }
    finally {
        if ($dosya) { $dosya.Dispose() }
        if ($akis)  { $akis.Dispose() }
        if ($yanit) { $yanit.Dispose() }
    }
}

function Start-ModulIndir {
    param($Modul)
    if ([string]::IsNullOrWhiteSpace($Modul.Url)) {
        Write-Mesaj 'uyari' "$($Modul.Ad) modülü henüz aktif değil."
        Start-Sleep -Seconds 2
        return
    }
    $masaustu = [Environment]::GetFolderPath('Desktop')
    $hedef    = Join-Path $masaustu $Modul.Dosya

    Write-Host ''
    Write-Mesaj 'bilgi' 'Uygulama Bilgileri:'
    Write-Host "     - Yazılım Adı : $($Modul.Ad) - $($Modul.Aciklama)" -ForegroundColor White
    Write-Host '     - Kaynak      : GitHub Releases (Son Sürüm)' -ForegroundColor White
    Write-Host "     - Hedef       : $hedef" -ForegroundColor White
    Write-Host ''
    Write-Mesaj 'adim' 'Bağlantı kuruluyor ve dosya indiriliyor...'
    Write-Host ''

    if (Invoke-Indirme -Url $Modul.Url -Hedef $hedef) {
        Write-Host ''
        Write-Mesaj 'ok' "İşlem başarılı! $($Modul.Dosya) masaüstüne kaydedildi."
        $cevap = Read-Host '  > Şimdi çalıştırılsın mı? (E/H)'
        if ($cevap -match '^[eE]') {
            try { Start-Process -FilePath $hedef } catch { Write-Mesaj 'hata' "Çalıştırılamadı: $($_.Exception.Message)" }
        }
    }
    Wait-Enter
}

# ============================================================
#  YAZILIM KURULUMU (winget)
# ============================================================
function Get-Secimler {
    param([string]$Girdi, [int]$Max)
    $sonuc = New-Object System.Collections.Generic.List[int]
    foreach ($parca in ($Girdi -split '[,\s;]+' | Where-Object { $_ })) {
        if ($parca -match '^(\d+)-(\d+)$') {
            $a = [int]$Matches[1]; $b = [int]$Matches[2]
            if ($a -gt $b) { $a, $b = $b, $a }
            for ($i = $a; $i -le $b; $i++) {
                if ($i -ge 1 -and $i -le $Max -and -not $sonuc.Contains($i)) { $sonuc.Add($i) }
            }
        }
        elseif ($parca -match '^\d+$') {
            $i = [int]$parca
            if ($i -ge 1 -and $i -le $Max -and -not $sonuc.Contains($i)) { $sonuc.Add($i) }
        }
    }
    return $sonuc.ToArray()
}

function Get-ProgramById {
    param([string]$Id)
    foreach ($k in $Katalog.Keys) {
        foreach ($p in $Katalog[$k]) {
            if ($p.Id -eq $Id) { return $p }
        }
    }
    return @{ Ad = $Id; Id = $Id }
}

function Install-Program {
    param($Program)
    Write-Host ''
    Write-Mesaj 'adim' "$($Program.Ad) kuruluyor..."
    $kaynak = 'winget'
    if ($Program.Kaynak) { $kaynak = $Program.Kaynak }
    $arg = @('install', '--id', $Program.Id, '-e', '--silent', '--source', $kaynak,
             '--accept-package-agreements', '--accept-source-agreements')
    & winget @arg
    $kod = $LASTEXITCODE
    if ($kod -eq 0) {
        Write-Mesaj 'ok' "$($Program.Ad) kuruldu!"
        return $true
    }
    elseif ($kod -in @(-1978335189, -1978335135)) {
        Write-Mesaj 'bilgi' "$($Program.Ad) zaten kurulu."
        return $true
    }
    else {
        Write-Mesaj 'hata' "$($Program.Ad) kurulamadı. (Çıkış kodu: $kod)"
        return $false
    }
}

function Install-Liste {
    param([object[]]$Programlar)
    if (-not $Programlar -or $Programlar.Count -eq 0) { return }

    Write-Host ''
    Write-Mesaj 'bilgi' 'Kurulacak programlar:'
    foreach ($p in $Programlar) { Write-Host "     - $($p.Ad)" -ForegroundColor White }
    if (-not (Test-Admin)) {
        Write-Host ''
        Write-Mesaj 'uyari' 'Yönetici olarak çalışmıyorsunuz; kurulumlar izin (UAC) isteyebilir.'
    }
    $onay = Read-Host "`n  > Onaylıyor musunuz? (E/H)"
    if ($onay -notmatch '^[eE]') {
        Write-Mesaj 'uyari' 'İptal edildi.'
        Start-Sleep -Seconds 1
        return
    }

    $basarili = 0
    $hatalilar = New-Object System.Collections.Generic.List[string]$sira = 0
    foreach ($p in $Programlar) {$sira++
        Write-Cizgi
        Write-Host (" [{0}/{1}]" -f $sira,$Programlar.Count) -ForegroundColor DarkGray -NoNewline
        if (Install-Program $p) {$basarili++ } else { $hatalilar.Add($p.Ad) }
    }

    Write-Cizgi
    Write-Host ''
    Write-Mesaj 'ok' "Tamamlandı: $basarili / $($Programlar.Count) başarılı."
    if ($hatalilar.Count -gt 0) {
        Write-Mesaj 'hata' ('Başarısız olanlar: ' + ($hatalilar -join ', '))
    }
    Wait-Enter
}

function Show-KategoriMenu {
    param([string]$Kategori)$liste = @($Katalog[$Kategori])
    $geri  =$false
    while (-not $geri) {
        Clear-Host
        Write-Baslik $Kategori
        Write-Host ''
        if ($liste.Count -eq 0) {
            Write-Mesaj 'uyari' 'Bu kategori şu an boş.'
            Wait-Enter
            return
        }
        for ($i = 0; $i -lt $liste.Count; $i++) {
            Write-Host ('  [{0,2}] ' -f ($i + 1)) -ForegroundColor Green -NoNewline
            Write-Host $liste[$i].Ad.PadRight(32) -ForegroundColor White -NoNewline
            Write-Host $liste[$i].Aciklama -ForegroundColor DarkGray
        }
        Write-Host ''
        Write-Cizgi
        Write-Host '  Çoklu seçim: 1,3,5 veya 1-4' -ForegroundColor DarkGray
        Write-Host '  [T] ' -ForegroundColor Yellow -NoNewline; Write-Host 'Tümünü kur    ' -ForegroundColor White -NoNewline
        Write-Host '[B] ' -ForegroundColor Cyan -NoNewline;   Write-Host 'Geri' -ForegroundColor White
        Write-Host ''
        $girdi = (Read-Host '  > Seçiminiz').Trim()

        if ($girdi -match '^[bB]$') { $geri =$true; continue }
        if ($girdi -match '^[tT]$') {
            $secilen =$liste
        } else {
            $idx = @(Get-Secimler $girdi$liste.Count)
            $secilen = @($idx | ForEach-Object { $liste[$_ - 1] })
        }
        if ($secilen.Count -eq 0) {
            Write-Mesaj 'uyari' 'Geçerli bir seçim yapmadınız.'
            Start-Sleep -Seconds 1
            continue
        }
        Install-Liste -Programlar $secilen
    }
}

function Show-PaketMenu {
    $anahtarlar = @($Paketler.Keys)
    $geri =$false
    while (-not $geri) {
        Clear-Host
        Write-Baslik 'HAZIR PAKETLER'
        Write-Host ''
        for ($i = 0; $i -lt$anahtarlar.Count; $i++) {$adlar = ($Paketler[$anahtarlar[$i]] \vert{} ForEach-Object { (Get-ProgramById$_).Ad }) -join ', '
            Write-Host ('  [{0}] ' -f ($i + 1)) -ForegroundColor Green -NoNewline
            Write-Host $anahtarlar[$i] -ForegroundColor White
            Write-Host "      $adlar" -ForegroundColor DarkGray
        }
        Write-Host ''
        Write-Cizgi
        Write-Host '  [B] ' -ForegroundColor Cyan -NoNewline; Write-Host 'Geri' -ForegroundColor White
        Write-Host ''
        $girdi = (Read-Host '  > Seçiminiz').Trim()
        if ($girdi -match '^[bB]$') {$geri = $true; continue }$idx = @(Get-Secimler $girdi$anahtarlar.Count)
        if ($idx.Count -eq 0) {
            Write-Mesaj 'uyari' 'Geçerli bir seçim yapmadınız.'
            Start-Sleep -Seconds 1
            continue
        }
        $secilen = @($Paketler[$anahtarlar[$idx[0] - 1]] \vert{} ForEach-Object { Get-ProgramById$_ })
        Install-Liste -Programlar $secilen
    }
}

function Show-YazilimMenu {
    if (-not (Test-Winget)) {
        Write-Host ''
        Write-Mesaj 'hata' 'winget bulunamadı.'
        Write-Host "     Microsoft Store'dan 'Uygulama Yükleyicisi' (App Installer) paketini güncelleyin." -ForegroundColor DarkGray
        Wait-Enter
        return
    }
    $kategoriler = @($Katalog.Keys)
    $geri =$false
    while (-not $geri) {
        Clear-Host
        Write-Baslik 'YAZILIM KURULUM MERKEZİ'
        Write-Host ''
        for ($i = 0; $i -lt $kategoriler.Count; $i++) {
            $adet = @($Katalog[$kategoriler[$i]]).Count
            Write-MenuSatir -Tus ('{0,2}' -f ($i + 1)) -Ad$kategoriler[$i] -Aciklama "($adet program)"
        }
        Write-Host ''
        Write-MenuSatir -Tus ' P' -Ad 'Hazır Paketler' -Aciklama '(Tek seçimle çoklu kurulum)' -TusRenk 'Yellow'
        Write-MenuSatir -Tus ' B' -Ad 'Önceki Menüye Dön' -Aciklama '' -TusRenk 'Cyan'
        Write-Host ''
        $girdi = (Read-Host '  > Seçiminiz').Trim()

        if ($girdi -match '^[bB]$') { $geri =$true }
        elseif ($girdi -match '^[pP]$') { Show-PaketMenu }
        elseif ($girdi -match '^\d+$' -and [int]$girdi -ge 1 -and [int]$girdi -le$kategoriler.Count) {
            Show-KategoriMenu -Kategori $kategoriler[[int]$girdi - 1]
        }
        else {
            Write-Mesaj 'hata' 'Hatalı seçim!'
            Start-Sleep -Seconds 1
        }
    }
}

function Update-Hepsi {
    if (-not (Test-Winget)) {
        Write-Mesaj 'hata' 'winget bulunamadı.'
        Start-Sleep -Seconds 2
        return
    }
    Clear-Host
    Write-Baslik 'TÜM PROGRAMLARI GÜNCELLE'
    Write-Host ''
    $onay = Read-Host '  > Kurulu tüm programlar güncellenecek. Devam? (E/H)'
    if ($onay -notmatch '^[eE]') { return }
    Write-Host ''
    Write-Mesaj 'adim' 'Güncellemeler denetleniyor ve uygulanıyor...'
    & winget upgrade --all --silent --accept-package-agreements --accept-source-agreements
    Write-Host ''
    Write-Mesaj 'ok' 'Güncelleme işlemi tamamlandı.'
    Wait-Enter
}

function Show-SistemBilgisi {
    Clear-Host
    Write-Baslik 'SİSTEM BİLGİSİ'
    Write-Host ''
    try {
        $os   = Get-CimInstance Win32_OperatingSystem$cpu  = Get-CimInstance Win32_Processor | Select-Object -First 1
        $cs   = Get-CimInstance Win32_ComputerSystem$disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
        $satirlar = [ordered]@{
            'Bilgisayar'      = $env:COMPUTERNAME
            'Kullanıcı'       = $env:USERNAME
            'İşletim Sistemi' = "$($os.Caption) ($($os.OSArchitecture))"
            'İşlemci'         = $cpu.Name.Trim()
            'RAM'             = ('{0:N1} GB' -f ($cs.TotalPhysicalMemory / 1GB))
            'Disk (C:)'       = ('{0:N0} GB boş / {1:N0} GB' -f ($disk.FreeSpace / 1GB), ($disk.Size / 1GB))
        }
        foreach ($k in$satirlar.Keys) {
            Write-Host ('  {0}: ' -f $k.PadRight(16)) -ForegroundColor DarkGray -NoNewline
            Write-Host $satirlar[$k] -ForegroundColor White
        }
    } catch {
        Write-Mesaj 'hata' "Bilgi alınamadı: $($_.Exception.Message)"
    }
    Wait-Enter
}

# ============================================================
#  ANA MENÜ
# ============================================================
$devam =$true
while ($devam) {
    Clear-Host
    Show-Logo
    Write-Baslik "MERKEZİ KURULUM ASİSTANI v$Surum"
    Show-DurumSatiri
    Write-Host ''
    Write-Host '  Programlarım' -ForegroundColor Cyan
    Write-Cizgi

    for ($i = 0; $i -lt$Moduller.Count; $i++) {$m = $Moduller[$i]
        $aktif = -not [string]::IsNullOrWhiteSpace($m.Url)
        $acik  =$m.Aciklama
        if (-not $aktif) {$acik = '(Yakında Eklenecek)' }
        Write-MenuSatir -Tus ($i + 1) -Ad$m.Ad -Aciklama $acik -Aktif$aktif
    }

    Write-Host ''
    Write-Host '  Araçlar' -ForegroundColor Cyan
    Write-Cizgi
    Write-MenuSatir -Tus 'K' -Ad 'Yazılım Kurulum Merkezi' -Aciklama '(Seçerek veya paket halinde kur)' -TusRenk 'Yellow'
    Write-MenuSatir -Tus 'G' -Ad 'Tüm Programları Güncelle' -Aciklama '(winget upgrade)' -TusRenk 'Yellow'
    Write-MenuSatir -Tus 'S' -Ad 'Sistem Bilgisi' -Aciklama '' -TusRenk 'Yellow'
    Write-MenuSatir -Tus 'Q' -Ad 'Çıkış' -Aciklama '' -TusRenk 'Red'
    Write-Host ''

    $secim = (Read-Host '  > Seçiminiz').Trim().ToUpper([System.Globalization.CultureInfo]::InvariantCulture)

    if ($secim -match '^\d+$' -and [int]$secim -ge 1 -and [int]$secim -le$Moduller.Count) {
        Start-ModulIndir -Modul $Moduller[[int]$secim - 1]
    }
    else {
        switch ($secim) {
            'K' { Show-YazilimMenu }
            'G' { Update-Hepsi }
            'S' { Show-SistemBilgisi }
            'Q' {
                Write-Host ''
                Write-Host ' Sistemden çıkılıyor. İyi çalışmalar!' -ForegroundColor DarkGray
                $devam =$false
                Start-Sleep -Seconds 1
            }
            default {
                Write-Mesaj 'hata' 'Hatalı seçim yaptınız.'
                Start-Sleep -Seconds 1
            }
        }
    }
}
