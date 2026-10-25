[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "TONOZ - Merkezi Kurulum ve Gelistirici Asistani v5.0"

# Onceki hatali calismalardan kalan arka plan gorevlerini temizle
Get-EventSubscriber -ErrorAction SilentlyContinue | Where-Object { $_.SourceIdentifier -match "IndirmeEvent" } | Unregister-Event -ErrorAction SilentlyContinue

# Yonetici yetkisi kontrolu
function Test-Yonetici {
    $kimlik = [Security.Principal.WindowsIdentity]::GetCurrent()
    $prensip = New-Object Security.Principal.WindowsPrincipal($kimlik)
    return $prensip.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Winget kontrolu
function Test-Winget {
    return [bool](Get-Command winget -ErrorAction SilentlyContinue)
}

# Canli Sistem Telemetrisi (RAM, Disk, OS)
function Al-SistemBilgisi {
    try {
        $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
        $toplamRam = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
        $bosRam = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
        $kullanilanRam = [math]::Round($toplamRam - $bosRam, 1)

        $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'" -ErrorAction Stop
        $bosDisk = [math]::Round($disk.FreeSpace / 1GB, 0)
        $toplamDisk = [math]::Round($disk.Size / 1GB, 0)

        return @{
            OS   = ($os.Caption -replace "Microsoft ", "")
            RAM  = "$kullanilanRam / $toplamRam GB"
            Disk = "$bosDisk GB Bos (C:)"
        }
    }
    catch {
        return @{
            OS   = "Windows"
            RAM  = "Bilinmiyor"
            Disk = "Bilinmiyor"
        }
    }
}

# Ust Bilgi / Banner Cizimi
function Goster-Banner {
    param([string]$AltBaslik = "MERKEZI KURULUM, GIS & GELISTIRICI ASISTANI v5.0")
    Clear-Host
    $yoneticiMi = Test-Yonetici
    $wingetVarMi = Test-Winget
    $pcAdi = $env:COMPUTERNAME
    $kullanici = $env:USERNAME
    $sistem = Al-SistemBilgisi

    Write-Host ""
    Write-Host "      _____ ___  _   _  ___ _____   " -ForegroundColor Cyan -NoNewline
    Write-Host "   Created by Tonoz | buraktonoz.com" -ForegroundColor DarkGray
    Write-Host "     |_   _/ _ \| \ | |/ _ \__  /   " -ForegroundColor Cyan
    Write-Host "       | || | | |  \| | | | |/ /    " -ForegroundColor Cyan
    Write-Host "       | || |_| | |\  | |_| / /_    " -ForegroundColor DarkCyan
    Write-Host "       |_| \___/|_| \_|\___/____|   " -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host "  +==============================================================================+" -ForegroundColor DarkGray
    Write-Host "  | " -ForegroundColor DarkGray -NoNewline
    Write-Host ("{0,-76}" -f $AltBaslik) -ForegroundColor Yellow -NoNewline
    Write-Host " |" -ForegroundColor DarkGray
    Write-Host "  +==============================================================================+" -ForegroundColor DarkGray

    # Satir 1: Kullanici, Yetki, Winget
    Write-Host "  | " -ForegroundColor DarkGray -NoNewline
    Write-Host "Oturum : " -ForegroundColor Gray -NoNewline
    Write-Host ("{0,-20}" -f "$kullanici@$pcAdi") -ForegroundColor White -NoNewline

    Write-Host "Yetki : " -ForegroundColor Gray -NoNewline
    if ($yoneticiMi) {
        Write-Host ("{0,-15}" -f "[Yonetici]") -ForegroundColor Green -NoNewline
    } else {
        Write-Host ("{0,-15}" -f "[Standart]") -ForegroundColor Yellow -NoNewline
    }

    Write-Host "Winget : " -ForegroundColor Gray -NoNewline
    if ($wingetVarMi) {
        Write-Host ("{0,-16}" -f "[Hazir]") -ForegroundColor Green -NoNewline
    } else {
        Write-Host ("{0,-16}" -f "[Bulunamadi!]") -ForegroundColor Red -NoNewline
    }
    Write-Host " |" -ForegroundColor DarkGray

    # Satir 2: Sistem Telemetrisi
    Write-Host "  | " -ForegroundColor DarkGray -NoNewline
    Write-Host "Sistem : " -ForegroundColor Gray -NoNewline
    Write-Host ("{0,-20}" -f $sistem.OS.Substring(0, [Math]::Min(19, $sistem.OS.Length))) -ForegroundColor Cyan -NoNewline

    Write-Host "BELLEK: " -ForegroundColor Gray -NoNewline
    Write-Host ("{0,-15}" -f $sistem.RAM) -ForegroundColor White -NoNewline

    Write-Host "Depolama: " -ForegroundColor Gray -NoNewline
    Write-Host ("{0,-15}" -f $sistem.Disk) -ForegroundColor White -NoNewline
    Write-Host " |" -ForegroundColor DarkGray
    Write-Host "  +==============================================================================+" -ForegroundColor DarkGray
    Write-Host ""
}

# Ortak Tonoz Uygulama Indirici (NPYS, TonoLink, PayTak)
function Indir-TonozUygulama {
    param(
        [string]$Baslik,
        [string]$TamAd,
        [string]$DosyaAdi,
        [string]$IndirmeUrl,
        [string]$WebSayfasi
    )

    Goster-Banner -AltBaslik $Baslik
    Write-Host "  [i] Uygulama Bilgileri:" -ForegroundColor Cyan
    Write-Host "      - Yazilim Adi : $TamAd" -ForegroundColor White
    Write-Host "      - Kaynak      : GitHub Releases ($IndirmeUrl)" -ForegroundColor Gray
    Write-Host "      - Hedef       : Masaustu ($DosyaAdi)" -ForegroundColor White
    Write-Host ""
    Write-Host "  [>] Baglanti kuruluyor ve dosya indiriliyor..." -ForegroundColor Yellow

    $masaustu = [Environment]::GetFolderPath("Desktop")
    $hedef = Join-Path $masaustu $DosyaAdi

    $webClient = $null
    try {
        $webClient = New-Object System.Net.WebClient
        $webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) TONOZ-Installer/5.0")

        $syncHash = [hashtable]::Synchronized(@{ Yuzde = 0 })
        $action = { $syncHash.Yuzde = $EventArgs.ProgressPercentage }
        $null = Register-ObjectEvent -InputObject $webClient -EventName DownloadProgressChanged -SourceIdentifier "IndirmeEvent" -Action $action

        $task = $webClient.DownloadFileTaskAsync($IndirmeUrl, $hedef)

        while (-not $task.IsCompleted) {
            $yuzde = $syncHash.Yuzde
            $barUzunlugu = 38
            $dolu = [math]::Floor($barUzunlugu * $yuzde / 100)
            $bos = $barUzunlugu - $dolu
            $bar = "[" + ("#" * $dolu) + ("-" * $bos) + "]"

            Write-Host -NoNewline ("`r  Indiriliyor... {0} {1,3}% " -f $bar, $yuzde) -ForegroundColor Cyan
            Start-Sleep -Milliseconds 60
        }

        $task.GetAwaiter().GetResult()

        Write-Host -NoNewline ("`r  Indiriliyor... [{0}] 100% " -f ("#" * 38)) -ForegroundColor Green
        Write-Host "`n"
        Write-Host "  [+] Islem Basarili! $DosyaAdi masaustune kaydedildi:" -ForegroundColor Green
        Write-Host "      Konum: $hedef" -ForegroundColor Gray
    }
    catch {
        Write-Host "`n"
        if (Test-Path $hedef) {
            Remove-Item $hedef -Force -ErrorAction SilentlyContinue
        }
        Write-Host "  [-] Dogrudan indirme tamamlanamadi!" -ForegroundColor Red
        $hataMesaji = if ($_.Exception.InnerException) { $_.Exception.InnerException.Message } else { $_.Exception.Message }
        Write-Host "      Detay: $hataMesaji" -ForegroundColor DarkGray
        if ($WebSayfasi) {
            $acilsinMi = Read-Host "`n  [?] Proje web sayfasini tarayicida acmak ister misiniz? (E/H)"
            if ($acilsinMi.Trim().ToUpper() -eq 'E') {
                Start-Process $WebSayfasi
            }
        }
    }
    finally {
        Unregister-Event -SourceIdentifier "IndirmeEvent" -ErrorAction SilentlyContinue
        if ($webClient) { $webClient.Dispose() }
    }

    Write-Host "`n  Menuye donmek icin Enter tusuna basin..." -ForegroundColor DarkGray
    $null = Read-Host
}

# Gelismis Winget Kurulum Fonksiyonu
function Kur-Uygulama {
    param(
        [Parameter(Mandatory=$true)][string]$Id,
        [Parameter(Mandatory=$true)][string]$Ad,
        [string]$Kaynak = "winget"
    )

    if (-not (Test-Winget)) {
        Write-Host "  [-] HATA: Sistemde 'winget' bulunamadi! Microsoft App Installer guncellenmeli." -ForegroundColor Red
        return
    }

    Write-Host ""
    Write-Host "  +------------------------------------------------------------------------------+" -ForegroundColor DarkGray
    Write-Host "  | [>] Kuruluyor : " -ForegroundColor Cyan -NoNewline
    Write-Host ("{0,-60}" -f "$Ad ($Id)") -ForegroundColor White -NoNewline
    Write-Host " |" -ForegroundColor DarkGray
    Write-Host "  +------------------------------------------------------------------------------+" -ForegroundColor DarkGray

    winget install --id $Id -e --silent --accept-package-agreements --accept-source-agreements --source $Kaynak

    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [+] BASARILI : $Ad basariyla kuruldu!" -ForegroundColor Green
    }
    elseif ($LASTEXITCODE -eq -1978335189 -or $LASTEXITCODE -eq -1978335135) {
        Write-Host "  [i] BILGI    : $Ad zaten bilgisayarda kurulu ve guncel." -ForegroundColor Cyan
    }
    else {
        Write-Host "  [-] HATA     : $Ad kurulamadi (Kod: $LASTEXITCODE)." -ForegroundColor Red
        Write-Host "      Ipucu    : Yonetici olarak calistirmayi veya 'winget source update' komutunu deneyin." -ForegroundColor DarkGray
    }
}

# Coklu paket kurulum yardimcisi
function Kur-PaketListesi {
    param(
        [string]$PaketAdi,
        [array]$Paketler
    )
    Write-Host ""
    Write-Host "  ================================================================================" -ForegroundColor Yellow
    Write-Host "   [*] $PaketAdi Baslatiliyor ($($Paketler.Count) Uygulama)" -ForegroundColor Yellow
    Write-Host "  ================================================================================" -ForegroundColor Yellow

    $sayac = 1
    foreach ($p in $Paketler) {
        Write-Host "`n  --> Adim [$sayac / $($Paketler.Count)]" -ForegroundColor Magenta
        Kur-Uygulama -Id $p.Id -Ad $p.Ad
        $sayac++
    }

    Write-Host ""
    Write-Host "  ================================================================================" -ForegroundColor Green
    Write-Host "   [+] $PaketAdi Tamamlandi!" -ForegroundColor Green
    Write-Host "  ================================================================================" -ForegroundColor Green
}

# 50 Uygulamalik Genisletilmis Katalog
$UygulamaKatalogu = @{
    # 1. IDE & Kod Editorleri
    "1"  = @{ Id = "Microsoft.VisualStudioCode";             Ad = "Visual Studio Code" }
    "2"  = @{ Id = "Anysphere.Cursor";                       Ad = "Cursor (AI Code Editor)" }
    "3"  = @{ Id = "Microsoft.VisualStudio.2022.Community";  Ad = "Visual Studio 2022 Community" }
    "4"  = @{ Id = "JetBrains.Toolbox";                      Ad = "JetBrains Toolbox (IntelliJ, PyCharm vb.)" }
    "5"  = @{ Id = "Notepad++.Notepad++";                    Ad = "Notepad++" }
    "6"  = @{ Id = "Obsidian.Obsidian";                      Ad = "Obsidian (Not & Dokumantasyon)" }

    # 2. Programlama Dilleri, SDK & Runtime
    "7"  = @{ Id = "Git.Git";                                Ad = "Git" }
    "8"  = @{ Id = "OpenJS.NodeJS.LTS";                      Ad = "Node.js (LTS Surumu)" }
    "9"  = @{ Id = "Python.Python.3.13";                     Ad = "Python 3.13" }
    "10" = @{ Id = "Microsoft.DotNet.SDK.9";                 Ad = ".NET SDK 9.0" }
    "11" = @{ Id = "GoLang.Go";                              Ad = "Go (Golang)" }
    "12" = @{ Id = "Rustlang.Rustup";                        Ad = "Rust (Rustup)" }
    "13" = @{ Id = "EclipseAdoptium.Temurin.21.JDK";         Ad = "Java JDK 21 (Temurin LTS)" }

    # 3. Veritabani, API, Konteyner & Terminal Araclari
    "14" = @{ Id = "Docker.DockerDesktop";                   Ad = "Docker Desktop" }
    "15" = @{ Id = "Postman.Postman";                        Ad = "Postman (API Test)" }
    "16" = @{ Id = "usebruno.bruno";                         Ad = "Bruno (Hizli & Git Dostu API Istemcisi)" }
    "17" = @{ Id = "dbeaver.dbeaver";                        Ad = "DBeaver Community (Veritabani Yonetimi)" }
    "18" = @{ Id = "GitHub.GitHubDesktop";                   Ad = "GitHub Desktop" }
    "19" = @{ Id = "GitHub.cli";                             Ad = "GitHub CLI (gh)" }
    "20" = @{ Id = "Microsoft.WindowsTerminal";              Ad = "Windows Terminal" }
    "21" = @{ Id = "Microsoft.PowerShell";                   Ad = "PowerShell 7 (Modern Kabuk)" }
    "22" = @{ Id = "JanDeDobbeleer.OhMyPosh";                Ad = "Oh My Posh (Terminal Tema Motoru)" }
    "23" = @{ Id = "WinSCP.WinSCP";                          Ad = "WinSCP (SFTP / FTP Istemcisi)" }

    # 4. Tarayicilar
    "24" = @{ Id = "Google.Chrome";                          Ad = "Google Chrome" }
    "25" = @{ Id = "Mozilla.Firefox";                        Ad = "Mozilla Firefox" }
    "26" = @{ Id = "Mozilla.Firefox.DeveloperEdition";       Ad = "Firefox Developer Edition" }
    "27" = @{ Id = "Brave.Brave";                            Ad = "Brave Tarayici" }

    # 5. Sistem, Ofis & Verimlilik Araclari
    "28" = @{ Id = "Microsoft.PowerToys";                    Ad = "Microsoft PowerToys (Gelistirici Araclari)" }
    "29" = @{ Id = "7zip.7zip";                              Ad = "7-Zip" }
    "30" = @{ Id = "RARLab.WinRAR";                          Ad = "WinRAR" }
    "31" = @{ Id = "voidtools.Everything";                   Ad = "Everything (Anlik Dosya Arama)" }
    "32" = @{ Id = "ShareX.ShareX";                          Ad = "ShareX (Ekran Goruntusu & Kayit)" }
    "33" = @{ Id = "Microsoft.Office";                       Ad = "Microsoft 365 (Office)" }
    "34" = @{ Id = "TheDocumentFoundation.LibreOffice";      Ad = "LibreOffice" }
    "35" = @{ Id = "Adobe.Acrobat.Reader.64-bit";            Ad = "Adobe Acrobat Reader (64-bit)" }
    "36" = @{ Id = "AnyDeskSoftwareGmbH.AnyDesk";            Ad = "AnyDesk (Uzak Masaustu)" }

    # 6. Medya & Iletisim
    "37" = @{ Id = "VideoLAN.VLC";                           Ad = "VLC Media Player" }
    "38" = @{ Id = "Spotify.Spotify";                        Ad = "Spotify" }
    "39" = @{ Id = "Discord.Discord";                        Ad = "Discord" }
    "40" = @{ Id = "Telegram.TelegramDesktop";               Ad = "Telegram Desktop" }
    "41" = @{ Id = "OBSProject.OBSStudio";                   Ad = "OBS Studio" }

    # 7. Harita/GIS, 3D Modelleme & IoT Donanim (YENI)
    "42" = @{ Id = "OSGeo.QGIS_LTR";                         Ad = "QGIS LTR (Cografi Bilgi Sistemleri)" }
    "43" = @{ Id = "Google.EarthPro";                        Ad = "Google Earth Pro" }
    "44" = @{ Id = "ArduinoSA.IDE.stable";                   Ad = "Arduino IDE 2.x (ESP32 / IoT Gelistirme)" }
    "45" = @{ Id = "BlenderFoundation.Blender";              Ad = "Blender (3D Tasarim & Modelleme)" }
    "46" = @{ Id = "SoftFever.OrcaSlicer";                   Ad = "OrcaSlicer (3D Yazici Dilimleyici)" }
    "47" = @{ Id = "Ultimaker.Cura";                         Ad = "UltiMaker Cura (3D Yazici Dilimleyici)" }
    "48" = @{ Id = "PuTTY.PuTTY";                            Ad = "PuTTY (SSH & Seri Port Terminali)" }
    "49" = @{ Id = "WiresharkFoundation.Wireshark";          Ad = "Wireshark (Ag Analiz Araci)" }
    "50" = @{ Id = "Microsoft.Sysinternals.ProcessExplorer"; Ad = "Sysinternals Process Explorer" }
}

$devam = $true

while ($devam) {
    Goster-Banner

    Write-Host "  [ ANA MENU - TONOZ EKOSISTEMI & SISTEM MERKEZI ]`n" -ForegroundColor Cyan

    Write-Host "    [1] " -ForegroundColor Green -NoNewline
    Write-Host "NPYS (Numarataj Personel)     " -ForegroundColor White -NoNewline
    Write-Host "-> Masaustune Akilli Indirici (GitHub Release)" -ForegroundColor DarkGray

    Write-Host "    [2] " -ForegroundColor Cyan -NoNewline
    Write-Host "TonoLink (Masaustu Dock)      " -ForegroundColor White -NoNewline
    Write-Host "-> Hizli Baslatici Indirici / Web" -ForegroundColor DarkGray

    Write-Host "    [3] " -ForegroundColor Yellow -NoNewline
    Write-Host "PayTak (3D Masaustu Asistani) " -ForegroundColor White -NoNewline
    Write-Host "-> Sanal Asistan Indirici / Web" -ForegroundColor DarkGray

    Write-Host "    [4] " -ForegroundColor Yellow -NoNewline
    Write-Host "Yazilim & Gelistirici Merkezi " -ForegroundColor White -NoNewline
    Write-Host "-> 50 Uygulama (GIS, IoT, 3D, IDE) & Hazir Paketler" -ForegroundColor Cyan

    Write-Host "    [5] " -ForegroundColor Magenta -NoNewline
    Write-Host "Sistem Guncelleme Araci       " -ForegroundColor White -NoNewline
    Write-Host "-> Kurulu Tum Uygulamalari Tek Tikla Guncelle" -ForegroundColor DarkGray

    Write-Host "    [6] " -ForegroundColor Blue -NoNewline
    Write-Host "Sistem Bakim, Onarim & Lisans " -ForegroundColor White -NoNewline
    Write-Host "-> Temp/DNS Temizligi, SFC/DISM, Lisans & Yedekleme" -ForegroundColor DarkGray

    Write-Host "    [7] " -ForegroundColor DarkCyan -NoNewline
    Write-Host "Web Hub (buraktonoz.com)      " -ForegroundColor White -NoNewline
    Write-Host "-> GeoITRF, PDF Editor ve Web Araclarini Ac" -ForegroundColor DarkGray

    if (-not (Test-Yonetici)) {
        Write-Host "`n    [A] " -ForegroundColor Yellow -NoNewline
        Write-Host "Yonetici Olarak Yeniden Baslat (Tam yetki icin onerilir)" -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "    [Q] " -ForegroundColor Red -NoNewline
    Write-Host "Cikis`n" -ForegroundColor White

    Write-Host "  +------------------------------------------------------------------------------+" -ForegroundColor DarkGray
    $secim = Read-Host "  > Seciminiz (1-7, A veya Q)"

    switch ($secim.Trim().ToUpper()) {
        '1' {
            Indir-TonozUygulama `
                -Baslik "NPYS AKILLI INDIRME MODULU" `
                -TamAd "Numarataj Personel Yonetim Sistemi (NPYS)" `
                -DosyaAdi "NPYS.exe" `
                -IndirmeUrl "https://github.com/BURAKTONOZ/personel/releases/download/latest/NPYS.exe" `
                -WebSayfasi "https://buraktonoz.com/personel/"
        }

        '2' {
            Indir-TonozUygulama `
                -Baslik "TONOLINK AKILLI INDIRME MODULU" `
                -TamAd "TonoLink v3.0 Masaustu Uygulama Baslatici" `
                -DosyaAdi "TonoLink-Setup.exe" `
                -IndirmeUrl "https://github.com/BURAKTONOZ/TonoLink/releases/latest/download/TonoLink-Setup.exe" `
                -WebSayfasi "https://github.com/BURAKTONOZ"
        }

        '3' {
            Indir-TonozUygulama `
                -Baslik "PAYTAK 3D MASAUSTU ASISTANI" `
                -TamAd "PayTak 3D Sanal Masaustu Uygulamasi" `
                -DosyaAdi "PayTak-Setup.exe" `
                -IndirmeUrl "https://github.com/BURAKTONOZ/PayTak/releases/latest/download/PayTak-Setup.exe" `
                -WebSayfasi "https://buraktonoz.com/PayTak/"
        }

        '4' {
            $altDevam = $true
            while ($altDevam) {
                Goster-Banner -AltBaslik "YAZILIM, GIS, 3D VE GELISTIRICI KURULUM MERKEZI (50 UYGULAMA)"

                Write-Host "  [ 1. IDE VE KOD EDITORLERI ]" -ForegroundColor Cyan
                Write-Host "    [1]  VS Code                   [2]  Cursor (AI Editor)      [3]  Visual Studio 2022" -ForegroundColor White
                Write-Host "    [4]  JetBrains Toolbox         [5]  Notepad++               [6]  Obsidian" -ForegroundColor White

                Write-Host "`n  [ 2. PROGRAMLAMA DILLERI, SDK VE RUNTIME ]" -ForegroundColor Cyan
                Write-Host "    [7]  Git                       [8]  Node.js (LTS)           [9]  Python 3.13" -ForegroundColor White
                Write-Host "    [10] .NET SDK 9.0              [11] Go (Golang)             [12] Rust (Rustup)" -ForegroundColor White
                Write-Host "    [13] Java JDK 21 (LTS)" -ForegroundColor White

                Write-Host "`n  [ 3. VERITABANI, API, KONTEYNER VE TERMINAL ]" -ForegroundColor Cyan
                Write-Host "    [14] Docker Desktop            [15] Postman                 [16] Bruno (API Client)" -ForegroundColor White
                Write-Host "    [17] DBeaver (Veritabani)      [18] GitHub Desktop          [19] GitHub CLI (gh)" -ForegroundColor White
                Write-Host "    [20] Windows Terminal          [21] PowerShell 7            [22] Oh My Posh" -ForegroundColor White
                Write-Host "    [23] WinSCP (SFTP/FTP)" -ForegroundColor White

                Write-Host "`n  [ 4. TARAYICILAR ]" -ForegroundColor Cyan
                Write-Host "    [24] Google Chrome             [25] Mozilla Firefox         [26] Firefox Dev Edition" -ForegroundColor White
                Write-Host "    [27] Brave Tarayici" -ForegroundColor White

                Write-Host "`n  [ 5. SISTEM, OFIS VE VERIMLILIK ARACLARI ]" -ForegroundColor Cyan
                Write-Host "    [28] Microsoft PowerToys       [29] 7-Zip                   [30] WinRAR" -ForegroundColor White
                Write-Host "    [31] Everything (Arama)        [32] ShareX (Ekran Kayit)    [33] Microsoft 365" -ForegroundColor White
                Write-Host "    [34] LibreOffice               [35] Adobe Acrobat Reader    [36] AnyDesk" -ForegroundColor White

                Write-Host "`n  [ 6. MEDYA VE ILETISIM ]" -ForegroundColor Cyan
                Write-Host "    [37] VLC Media Player          [38] Spotify                 [39] Discord" -ForegroundColor White
                Write-Host "    [40] Telegram Desktop          [41] OBS Studio" -ForegroundColor White

                Write-Host "`n  [ 7. HARITA/GIS, 3D MODELLEME VE IoT DONANIM ]" -ForegroundColor Green
                Write-Host "    [42] QGIS LTR (CBS/GIS)        [43] Google Earth Pro        [44] Arduino IDE 2 (ESP32)" -ForegroundColor White
                Write-Host "    [45] Blender (3D Tasarim)      [46] OrcaSlicer (3Daski)     [47] UltiMaker Cura" -ForegroundColor White
                Write-Host "    [48] PuTTY (Seri Port/SSH)     [49] Wireshark               [50] Process Explorer" -ForegroundColor White

                Write-Host "`n  +==============================================================================+" -ForegroundColor DarkGray
                Write-Host "  | [ HAZIR KURULUM PAKETLERI (Tek Komutla Toplu Kurulum) ]                      |" -ForegroundColor Yellow
                Write-Host "  +==============================================================================+" -ForegroundColor DarkGray
                Write-Host "    [P1] " -ForegroundColor Green -NoNewline
                Write-Host "Yeni PC Temel Paketi     " -ForegroundColor White -NoNewline
                Write-Host "(Chrome, 7-Zip, WinRAR, VLC, Acrobat, Everything, ShareX)" -ForegroundColor Gray

                Write-Host "    [P2] " -ForegroundColor Green -NoNewline
                Write-Host "Full-Stack Gelistirici   " -ForegroundColor White -NoNewline
                Write-Host "(VS Code, Git, Node.js, Python, Docker, Postman, DBeaver, PowerToys)" -ForegroundColor Gray

                Write-Host "    [P3] " -ForegroundColor Green -NoNewline
                Write-Host "Frontend & Web Paketi    " -ForegroundColor White -NoNewline
                Write-Host "(VS Code, Cursor, Git, Node.js, GitHub Desktop, Postman, Chrome)" -ForegroundColor Gray

                Write-Host "    [P4] " -ForegroundColor Green -NoNewline
                Write-Host "Backend & Sistem Paketi  " -ForegroundColor White -NoNewline
                Write-Host "(VS Code, Git, Python, .NET 9, Docker, DBeaver, PowerShell 7, WinSCP)" -ForegroundColor Gray

                Write-Host "    [P5] " -ForegroundColor Cyan -NoNewline
                Write-Host "Harita, GIS & IoT Paketi " -ForegroundColor White -NoNewline
                Write-Host "(QGIS LTR, Google Earth Pro, Arduino IDE, Blender, OrcaSlicer, PuTTY)" -ForegroundColor Gray

                Write-Host "    [P6] " -ForegroundColor Magenta -NoNewline
                Write-Host "Tum Uygulamalari Guncelle" -ForegroundColor White -NoNewline
                Write-Host "(Bilgisayardaki tum winget paketlerini son surume yukseltir)" -ForegroundColor Gray

                Write-Host ""
                Write-Host "    [i] IPUCU: Birden fazla uygulamayi virgul veya aralik ile kurabilirsiniz (Orn: 1,7,8,42 veya 42-46)" -ForegroundColor DarkCyan
                Write-Host "    [B] Ana Menuye Don" -ForegroundColor Red
                Write-Host ""

                $altSecimGirdi = Read-Host "  > Seciminiz (Orn: 1 veya 1,7,42 veya P5)"
                $temizGirdi = $altSecimGirdi.Trim().ToUpper()

                if ([string]::IsNullOrWhiteSpace($temizGirdi)) { continue }
                if ($temizGirdi -eq 'B') { $altDevam = $false; continue }

                switch ($temizGirdi) {
                    'P1' {
                        $paket = @("24", "29", "30", "37", "35", "31", "32") | ForEach-Object { $UygulamaKatalogu[$_] }
                        Kur-PaketListesi -PaketAdi "Yeni PC Temel Paketi" -Paketler $paket
                    }
                    'P2' {
                        $paket = @("1", "7", "8", "9", "14", "15", "17", "18", "20", "28") | ForEach-Object { $UygulamaKatalogu[$_] }
                        Kur-PaketListesi -PaketAdi "Full-Stack Gelistirici Paketi" -Paketler $paket
                    }
                    'P3' {
                        $paket = @("1", "2", "7", "8", "18", "15", "24", "26") | ForEach-Object { $UygulamaKatalogu[$_] }
                        Kur-PaketListesi -PaketAdi "Frontend & Web Gelistirici Paketi" -Paketler $paket
                    }
                    'P4' {
                        $paket = @("1", "7", "9", "10", "14", "17", "15", "21", "23") | ForEach-Object { $UygulamaKatalogu[$_] }
                        Kur-PaketListesi -PaketAdi "Backend & Sistem Gelistirici Paketi" -Paketler $paket
                    }
                    'P5' {
                        $paket = @("42", "43", "44", "45", "46", "48", "1", "7") | ForEach-Object { $UygulamaKatalogu[$_] }
                        Kur-PaketListesi -PaketAdi "Harita, GIS, 3D & IoT Muhendislik Paketi" -Paketler $paket
                    }
                    'P6' {
                        Write-Host "`n  [*] Sistemdeki tum kurulu uygulamalar taranip guncelleniyor..." -ForegroundColor Yellow
                        winget upgrade --all --include-unknown --accept-package-agreements --accept-source-agreements
                        Write-Host "`n  [+] Guncelleme islemi tamamlandi!" -ForegroundColor Green
                    }
                    Default {
                        $secimler = $temizGirdi -split '[,;\s]+' | Where-Object { $_ -ne "" }
                        $gecerliPaketler = @()
                        $hataliSecimler = @()

                        foreach ($s in $secimler) {
                            if ($s -match '^(\d+)-(\d+)$') {
                                $bas = [int]$Matches[1]
                                $bit = [int]$Matches[2]
                                if ($bas -le $bit -and ($bit - $bas) -le 55) {
                                    foreach ($num in $bas..$bit) {
                                        $anahtar = [string]$num
                                        if ($UygulamaKatalogu.ContainsKey($anahtar)) {
                                            $gecerliPaketler += $UygulamaKatalogu[$anahtar]
                                        } else {
                                            $hataliSecimler += $anahtar
                                        }
                                    }
                                } else {
                                    $hataliSecimler += $s
                                }
                            }
                            elseif ($UygulamaKatalogu.ContainsKey($s)) {
                                $gecerliPaketler += $UygulamaKatalogu[$s]
                            }
                            else {
                                $hataliSecimler += $s
                            }
                        }

                        if ($hataliSecimler.Count -gt 0) {
                            Write-Host "`n  [!] Gecersiz secim(ler) atlandi: $($hataliSecimler -join ', ')" -ForegroundColor Red
                        }

                        if ($gecerliPaketler.Count -eq 1) {
                            Kur-Uygulama -Id $gecerliPaketler[0].Id -Ad $gecerliPaketler[0].Ad
                        }
                        elseif ($gecerliPaketler.Count -gt 1) {
                            Kur-PaketListesi -PaketAdi "Ozel Secim Paketi" -Paketler $gecerliPaketler
                        }
                    }
                }

                if ($altDevam) {
                    Write-Host "`n  Menuye donmek icin Enter'a basin..." -ForegroundColor DarkGray
                    $null = Read-Host
                }
            }
        }

        '5' {
            Goster-Banner -AltBaslik "SISTEM UYGULAMA GUNCELLEME ARACI"
            if (-not (Test-Winget)) {
                Write-Host "  [-] Sistemde Winget bulunamadi!" -ForegroundColor Red
            } else {
                Write-Host "  [*] Bilgisayarinizdaki guncellenebilir uygulamalar taraniyor ve guncelleniyor...`n" -ForegroundColor Yellow
                winget upgrade --all --include-unknown --accept-package-agreements --accept-source-agreements
                Write-Host "`n  [+] Tum guncellemeler tamamlandi!" -ForegroundColor Green
            }
            Write-Host "`n  Ana menuye donmek icin Enter tusuna basin..." -ForegroundColor DarkGray
            $null = Read-Host
        }

        '6' {
            $bakimDevam = $true
            while ($bakimDevam) {
                Goster-Banner -AltBaslik "SISTEM BAKIM, ONARIM VE RESMI LISANS MERKEZI"

                Write-Host "  [ SISTEM OPTIMIZASYON VE BAKIM ARACLARI ]`n" -ForegroundColor Cyan
                Write-Host "    [1] Gecici Dosyalari (Temp / %temp%) Temizle" -ForegroundColor White
                Write-Host "    [2] DNS Onbellegini Temizle (FlushDNS) ve Ag Bilgisini Goster" -ForegroundColor White
                Write-Host "    [3] Windows Sistem Dosyalarini Onar (SFC /scannow & DISM) [Yonetici]" -ForegroundColor White
                Write-Host "    [4] Kurulu Uygulama Listesini Masaustune Yedekle (winget export)" -ForegroundColor White
                Write-Host "    [5] Resmi Windows Lisans Durumunu Sorgula (slmgr /xpr & /dli)" -ForegroundColor White
                Write-Host "    [6] Windows Lisans Ayarlarini Ac (Resmi Urun Anahtari Girisi)" -ForegroundColor White
                Write-Host "`n    [B] Ana Menuye Don`n" -ForegroundColor Red

                $bSecim = (Read-Host "  > Seciminiz (1-6 veya B)").Trim().ToUpper()

                switch ($bSecim) {
                    '1' {
                        Write-Host "`n  [*] Gecici klasorler temizleniyor..." -ForegroundColor Yellow
                        Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
                        if (Test-Yonetici) {
                            Remove-Item -Path "$env:windir\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
                        }
                        Write-Host "  [+] Temp temizligi tamamlandi!" -ForegroundColor Green
                        Read-Host "`n  Devam etmek icin Enter'a basin"
                    }
                    '2' {
                        Write-Host "`n  [*] DNS onbellegi sifirlaniyor..." -ForegroundColor Yellow
                        ipconfig /flushdns | Out-Null
                        Write-Host "  [+] DNS onbellegi temizlendi! Aktif IPv4 Adresleriniz:" -ForegroundColor Green
                        Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -ne '127.0.0.1' } | Select-Object InterfaceAlias, IPAddress | Format-Table -AutoSize
                        Read-Host "  Devam etmek icin Enter'a basin"
                    }
                    '3' {
                        if (-not (Test-Yonetici)) {
                            Write-Host "`n  [-] Bu islem icin betigi Yonetici olarak calistirmalisiniz!" -ForegroundColor Red
                        } else {
                            Write-Host "`n  [*] DISM ve SFC sistem taramasi baslatiliyor (Bu islem birkac dakika surebilir)..." -ForegroundColor Yellow
                            DISM.exe /Online /Cleanup-image /Restorehealth
                            sfc /scannow
                            Write-Host "`n  [+] Sistem dosya kontrolu tamamlandi!" -ForegroundColor Green
                        }
                        Read-Host "`n  Devam etmek icin Enter'a basin"
                    }
                    '4' {
                        $yedekYolu = Join-Path ([Environment]::GetFolderPath("Desktop")) "Tonoz-Uygulama-Yedegi.json"
                        Write-Host "`n  [*] Kurulu paketler '$yedekYolu' dosyasina aktariliyor..." -ForegroundColor Yellow
                        winget export -o $yedekYolu --accept-source-agreements
                        Write-Host "  [+] Yedekleme tamamlandi! Yeni bilgisayarda 'winget import -i Tonoz-Uygulama-Yedegi.json' ile kurabilirsiniz." -ForegroundColor Green
                        Read-Host "`n  Devam etmek icin Enter'a basin"
                    }
                    '5' {
                        Write-Host "`n  [*] Resmi Windows Lisans durumu sorgulaniyor (Pencere acilacaktir)..." -ForegroundColor Cyan
                        cscript //Nologo "$env:windir\System32\slmgr.vbs" /dli
                        cscript //Nologo "$env:windir\System32\slmgr.vbs" /xpr
                        Read-Host "`n  Devam etmek icin Enter'a basin"
                    }
                    '6' {
                        Write-Host "`n  [*] Windows Etkinlestirme ayarlari aciliyor..." -ForegroundColor Cyan
                        Start-Process "ms-settings:activation"
                        Start-Sleep -Seconds 1
                    }
                    'B' {
                        $bakimDevam = $false
                    }
                }
            }
        }

        '7' {
            Write-Host "`n  [*] buraktonoz.com portfolyo ve uygulama merkezi tarayicida aciliyor..." -ForegroundColor Cyan
            Start-Process "https://buraktonoz.com"
            Start-Sleep -Seconds 1
        }

        'A' {
            if (-not (Test-Yonetici)) {
                Write-Host "`n  [*] Yonetici yetkisiyle yeniden baslatiliyor..." -ForegroundColor Yellow
                if ($PSCommandPath) {
                    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
                    $devam = $false
                } else {
                    Write-Host "  [!] Betik bellekte calistigi icin PowerShell'i sag tiklayip 'Yonetici Olarak Calistir' secenegiyle acin." -ForegroundColor Red
                    Read-Host "`n  Devam etmek icin Enter'a basin"
                }
            }
        }

        'Q' {
            Write-Host "`n  [+] Sistemden cikiliyor. Iyi calismalar! - Created by Tonoz" -ForegroundColor Cyan
            $devam = $false
            Start-Sleep -Seconds 1
        }

        Default {
            Write-Host "`n  [!] Hatali secim yaptiniz. Lutfen menudeki seceneklerden birini girin." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
}
