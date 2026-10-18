[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

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

# Ust Bilgi / Banner Cizimi
function Goster-Banner {
    param([string]$AltBaslik = "MERKEZI KURULUM VE GELISTIRICI ASISTANI v4.0")
    Clear-Host
    $yoneticiMi = Test-Yonetici
    $wingetVarMi = Test-Winget
    $pcAdi = $env:COMPUTERNAME
    $kullanici = $env:USERNAME

    Write-Host ""
    Write-Host "      _____ ___  _   _  ___ _____ " -ForegroundColor Cyan
    Write-Host "     |_   _/ _ \| \ | |/ _ \__  / " -ForegroundColor Cyan
    Write-Host "       | || | | |  \| | | | |/ /  " -ForegroundColor Cyan
    Write-Host "       | || |_| | |\  | |_| / /_  " -ForegroundColor DarkCyan
    Write-Host "       |_| \___/|_| \_|\___/____| " -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host "  +==========================================================================+" -ForegroundColor DarkGray
    Write-Host "  | " -ForegroundColor DarkGray -NoNewline
    Write-Host ("{0,-72}" -f $AltBaslik) -ForegroundColor Yellow -NoNewline
    Write-Host " |" -ForegroundColor DarkGray
    Write-Host "  +==========================================================================+" -ForegroundColor DarkGray

    Write-Host "  | " -ForegroundColor DarkGray -NoNewline
    Write-Host "Kullanici: " -ForegroundColor Gray -NoNewline
    Write-Host ("{0,-16}" -f "$kullanici@$pcAdi") -ForegroundColor White -NoNewline

    Write-Host "Yetki: " -ForegroundColor Gray -NoNewline
    if ($yoneticiMi) {
        Write-Host ("{0,-16}" -f "[Yonetici]") -ForegroundColor Green -NoNewline
    } else {
        Write-Host ("{0,-16}" -f "[Standart]") -ForegroundColor Yellow -NoNewline
    }

    Write-Host "Winget: " -ForegroundColor Gray -NoNewline
    if ($wingetVarMi) {
        Write-Host ("{0,-14}" -f "[Hazir]") -ForegroundColor Green -NoNewline
    } else {
        Write-Host ("{0,-14}" -f "[Bulunamadi!]") -ForegroundColor Red -NoNewline
    }
    Write-Host " |" -ForegroundColor DarkGray
    Write-Host "  +==========================================================================+" -ForegroundColor DarkGray
    Write-Host ""
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
    Write-Host "  +--------------------------------------------------------------------------+" -ForegroundColor DarkGray
    Write-Host "  | [>] Kuruluyor : " -ForegroundColor Cyan -NoNewline
    Write-Host ("{0,-56}" -f "$Ad ($Id)") -ForegroundColor White -NoNewline
    Write-Host " |" -ForegroundColor DarkGray
    Write-Host "  +--------------------------------------------------------------------------+" -ForegroundColor DarkGray

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
    Write-Host "  ============================================================================" -ForegroundColor Yellow
    Write-Host "   [*] $PaketAdi Baslatiliyor ($($Paketler.Count) Uygulama)" -ForegroundColor Yellow
    Write-Host "  ============================================================================" -ForegroundColor Yellow

    $sayac = 1
    foreach ($p in $Paketler) {
        Write-Host "`n  --> Adim [$sayac / $($Paketler.Count)]" -ForegroundColor Magenta
        Kur-Uygulama -Id $p.Id -Ad $p.Ad
        $sayac++
    }

    Write-Host ""
    Write-Host "  ============================================================================" -ForegroundColor Green
    Write-Host "   [+] $PaketAdi Tamamlandi!" -ForegroundColor Green
    Write-Host "  ============================================================================" -ForegroundColor Green
}

# Uygulama Katalogu (Tum Winget ID'leri dogrulanmis ve gunceldir)
$UygulamaKatalogu = @{
    # 1. IDE & Kod Editorleri
    "1"  = @{ Id = "Microsoft.VisualStudioCode";              Ad = "Visual Studio Code" }
    "2"  = @{ Id = "Anysphere.Cursor";                        Ad = "Cursor (AI Code Editor)" }
    "3"  = @{ Id = "Microsoft.VisualStudio.2022.Community";   Ad = "Visual Studio 2022 Community" }
    "4"  = @{ Id = "JetBrains.Toolbox";                       Ad = "JetBrains Toolbox (IntelliJ, PyCharm vb.)" }
    "5"  = @{ Id = "Notepad++.Notepad++";                     Ad = "Notepad++" }
    "6"  = @{ Id = "Obsidian.Obsidian";                       Ad = "Obsidian (Not & Dokumantasyon)" }

    # 2. Programlama Dilleri, SDK & Runtime
    "7"  = @{ Id = "Git.Git";                                 Ad = "Git" }
    "8"  = @{ Id = "OpenJS.NodeJS.LTS";                       Ad = "Node.js (LTS Surumu)" }
    "9"  = @{ Id = "Python.Python.3.13";                      Ad = "Python 3.13" }
    "10" = @{ Id = "Microsoft.DotNet.SDK.9";                  Ad = ".NET SDK 9.0" }
    "11" = @{ Id = "GoLang.Go";                               Ad = "Go (Golang)" }
    "12" = @{ Id = "Rustlang.Rustup";                         Ad = "Rust (Rustup)" }
    "13" = @{ Id = "EclipseAdoptium.Temurin.21.JDK";          Ad = "Java JDK 21 (Temurin LTS)" }

    # 3. Veritabani, API, Konteyner & Terminal Araclari
    "14" = @{ Id = "Docker.DockerDesktop";                    Ad = "Docker Desktop" }
    "15" = @{ Id = "Postman.Postman";                         Ad = "Postman (API Test)" }
    "16" = @{ Id = "usebruno.bruno";                          Ad = "Bruno (Hizli & Git Dostu API Istemcisi)" }
    "17" = @{ Id = "dbeaver.dbeaver";                         Ad = "DBeaver Community (Veritabani Yonetimi)" }
    "18" = @{ Id = "GitHub.GitHubDesktop";                    Ad = "GitHub Desktop" }
    "19" = @{ Id = "GitHub.cli";                              Ad = "GitHub CLI (gh)" }
    "20" = @{ Id = "Microsoft.WindowsTerminal";               Ad = "Windows Terminal" }
    "21" = @{ Id = "Microsoft.PowerShell";                    Ad = "PowerShell 7 (Modern Kabuk)" }
    "22" = @{ Id = "JanDeDobbeleer.OhMyPosh";                 Ad = "Oh My Posh (Terminal Tema Motoru)" }
    "23" = @{ Id = "WinSCP.WinSCP";                           Ad = "WinSCP (SFTP / FTP Istemcisi)" }

    # 4. Tarayicilar
    "24" = @{ Id = "Google.Chrome";                           Ad = "Google Chrome" }
    "25" = @{ Id = "Mozilla.Firefox";                         Ad = "Mozilla Firefox" }
    "26" = @{ Id = "Mozilla.Firefox.DeveloperEdition";        Ad = "Firefox Developer Edition" }
    "27" = @{ Id = "Brave.Brave";                             Ad = "Brave Tarayici" }

    # 5. Sistem, Ofis & Verimlilik Araclari
    "28" = @{ Id = "Microsoft.PowerToys";                     Ad = "Microsoft PowerToys (Gelistirici Araclari)" }
    "29" = @{ Id = "7zip.7zip";                               Ad = "7-Zip" }
    "30" = @{ Id = "RARLab.WinRAR";                           Ad = "WinRAR" }
    "31" = @{ Id = "voidtools.Everything";                    Ad = "Everything (Anlik Dosya Arama)" }
    "32" = @{ Id = "ShareX.ShareX";                           Ad = "ShareX (Ekran Goruntusu & Kayit)" }
    "33" = @{ Id = "Microsoft.Office";                        Ad = "Microsoft 365 (Office)" }
    "34" = @{ Id = "TheDocumentFoundation.LibreOffice";       Ad = "LibreOffice" }
    "35" = @{ Id = "Adobe.Acrobat.Reader.64-bit";             Ad = "Adobe Acrobat Reader (64-bit)" }
    "36" = @{ Id = "AnyDeskSoftwareGmbH.AnyDesk";             Ad = "AnyDesk (Uzak Masaustu)" }

    # 6. Medya & Iletisim
    "37" = @{ Id = "VideoLAN.VLC";                            Ad = "VLC Media Player" }
    "38" = @{ Id = "Spotify.Spotify";                         Ad = "Spotify" }
    "39" = @{ Id = "Discord.Discord";                         Ad = "Discord" }
    "40" = @{ Id = "Telegram.TelegramDesktop";                Ad = "Telegram Desktop" }
    "41" = @{ Id = "OBSProject.OBSStudio";                    Ad = "OBS Studio" }
}

$devam = $true

while ($devam) {
    Goster-Banner

    Write-Host "  [ ANA MENU - Lutfen Bir Islem Secin ]`n" -ForegroundColor Cyan

    Write-Host "   [1] " -ForegroundColor Green -NoNewline
    Write-Host "NPYS (Numarataj Personel)     " -ForegroundColor White -NoNewline
    Write-Host "-> Masaustune Akilli Indirici" -ForegroundColor DarkGray

    Write-Host "   [2] " -ForegroundColor DarkGray -NoNewline
    Write-Host "TonoLink                      " -ForegroundColor DarkGray -NoNewline
    Write-Host "-> (Yakinda Eklenecek)" -ForegroundColor DarkGray

    Write-Host "   [3] " -ForegroundColor DarkGray -NoNewline
    Write-Host "PayTak                        " -ForegroundColor DarkGray -NoNewline
    Write-Host "-> (Yakinda Eklenecek)" -ForegroundColor DarkGray

    Write-Host "   [4] " -ForegroundColor Yellow -NoNewline
    Write-Host "Yazilim & Gelistirici Merkezi " -ForegroundColor White -NoNewline
    Write-Host "-> 41+ Uygulama, Coklu Secim ve Hazir Paketler" -ForegroundColor Cyan

    Write-Host "   [5] " -ForegroundColor Magenta -NoNewline
    Write-Host "Sistem Guncelleme Araci       " -ForegroundColor White -NoNewline
    Write-Host "-> Kurulu Tum Uygulamalari Tek Tikla Guncelle" -ForegroundColor DarkGray

    Write-Host ""
    Write-Host "   [Q] " -ForegroundColor Red -NoNewline
    Write-Host "Cikis`n" -ForegroundColor White

    Write-Host "  +--------------------------------------------------------------------------+" -ForegroundColor DarkGray
    $secim = Read-Host "  > Seciminiz (1-5 veya Q)"

    switch ($secim.Trim().ToUpper()) {
        '1' {
            Goster-Banner -AltBaslik "NPYS AKILLI INDIRME MODULU"
            Write-Host "  [i] Uygulama Bilgileri:" -ForegroundColor Cyan
            Write-Host "      - Yazilim Adi : Numarataj Personel Yonetim Sistemi (NPYS)" -ForegroundColor White
            Write-Host "      - Kaynak      : GitHub Releases (Son Surum)" -ForegroundColor White
            Write-Host "      - Hedef       : Masaustu (NPYS.exe)" -ForegroundColor White
            Write-Host ""
            Write-Host "  [>] Baglanti kuruluyor ve dosya indiriliyor..." -ForegroundColor Yellow

            $masaustu = [Environment]::GetFolderPath("Desktop")
            $hedef = Join-Path $masaustu "NPYS.exe"
            $indirmeLinki = "https://github.com/BURAKTONOZ/personel/releases/download/latest/NPYS.exe"

            $webClient = $null
            try {
                $webClient = New-Object System.Net.WebClient
                $webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) TONOZ-Installer/4.0")

                $syncHash = [hashtable]::Synchronized(@{ Yuzde = 0 })
                $action = { $syncHash.Yuzde = $EventArgs.ProgressPercentage }
                $null = Register-ObjectEvent -InputObject $webClient -EventName DownloadProgressChanged -SourceIdentifier "IndirmeEvent" -Action $action

                $task = $webClient.DownloadFileTaskAsync($indirmeLinki, $hedef)

                while (-not $task.IsCompleted) {
                    $yuzde = $syncHash.Yuzde
                    $barUzunlugu = 35
                    $dolu = [math]::Floor($barUzunlugu * $yuzde / 100)
                    $bos = $barUzunlugu - $dolu
                    $bar = "[" + ("#" * $dolu) + ("-" * $bos) + "]"

                    Write-Host -NoNewline ("`r  Indiriliyor... {0} {1,3}% " -f $bar, $yuzde) -ForegroundColor Cyan
                    Start-Sleep -Milliseconds 60
                }

                # Hata varsa burada exception firlatir (404 / baglanti kopmasi vb.)
                $task.GetAwaiter().GetResult()

                Write-Host -NoNewline ("`r  Indiriliyor... [{0}] 100% " -f ("#" * 35)) -ForegroundColor Green
                Write-Host "`n"
                Write-Host "  [+] Islem Basarili! NPYS.exe masaustune kaydedildi:" -ForegroundColor Green
                Write-Host "      Konum: $hedef" -ForegroundColor Gray
            }
            catch {
                Write-Host "`n"
                if (Test-Path $hedef) {
                    Remove-Item $hedef -Force -ErrorAction SilentlyContinue
                }
                Write-Host "  [-] Indirme basarisiz oldu!" -ForegroundColor Red
                $hataMesaji = if ($_.Exception.InnerException) { $_.Exception.InnerException.Message } else { $_.Exception.Message }
                Write-Host "      Hata Detayi: $hataMesaji" -ForegroundColor DarkGray
            }
            finally {
                Unregister-Event -SourceIdentifier "IndirmeEvent" -ErrorAction SilentlyContinue
                if ($webClient) { $webClient.Dispose() }
            }

            Write-Host "`n  Menuye donmek icin Enter tusuna basin..." -ForegroundColor DarkGray
            $null = Read-Host
        }

        '2' {
            Write-Host "`n  [!] TonoLink modulu henuz aktif degil. Yakinda eklenecektir." -ForegroundColor Yellow
            Start-Sleep -Seconds 2
        }

        '3' {
            Write-Host "`n  [!] PayTak modulu henuz aktif degil. Yakinda eklenecektir." -ForegroundColor Yellow
            Start-Sleep -Seconds 2
        }

        '4' {
            $altDevam = $true
            while ($altDevam) {
                Goster-Banner -AltBaslik "YAZILIM VE GELISTIRICI KURULUM MERKEZI"

                Write-Host "  [ IDE VE KOD EDITORLERI ]" -ForegroundColor Cyan
                Write-Host "   [1]  VS Code                 [2]  Cursor (AI Editor)      [3]  Visual Studio 2022" -ForegroundColor White
                Write-Host "   [4]  JetBrains Toolbox       [5]  Notepad++               [6]  Obsidian" -ForegroundColor White

                Write-Host "`n  [ PROGRAMLAMA DILLERI, SDK VE RUNTIME ]" -ForegroundColor Cyan
                Write-Host "   [7]  Git                     [8]  Node.js (LTS)           [9]  Python 3.13" -ForegroundColor White
                Write-Host "   [10] .NET SDK 9.0            [11] Go (Golang)             [12] Rust (Rustup)" -ForegroundColor White
                Write-Host "   [13] Java JDK 21 (LTS)" -ForegroundColor White

                Write-Host "`n  [ VERITABANI, API, KONTEYNER VE TERMINAL ]" -ForegroundColor Cyan
                Write-Host "   [14] Docker Desktop          [15] Postman                 [16] Bruno (API Client)" -ForegroundColor White
                Write-Host "   [17] DBeaver (Veritabani)    [18] GitHub Desktop          [19] GitHub CLI (gh)" -ForegroundColor White
                Write-Host "   [20] Windows Terminal        [21] PowerShell 7            [22] Oh My Posh" -ForegroundColor White
                Write-Host "   [23] WinSCP (SFTP/FTP)" -ForegroundColor White

                Write-Host "`n  [ TARAYICILAR ]" -ForegroundColor Cyan
                Write-Host "   [24] Google Chrome           [25] Mozilla Firefox         [26] Firefox Dev Edition" -ForegroundColor White
                Write-Host "   [27] Brave Tarayici" -ForegroundColor White

                Write-Host "`n  [ SISTEM, OFIS VE VERIMLILIK ARACLARI ]" -ForegroundColor Cyan
                Write-Host "   [28] Microsoft PowerToys     [29] 7-Zip                   [30] WinRAR" -ForegroundColor White
                Write-Host "   [31] Everything (Arama)      [32] ShareX (Ekran Kayit)    [33] Microsoft 365" -ForegroundColor White
                Write-Host "   [34] LibreOffice             [35] Adobe Acrobat Reader    [36] AnyDesk" -ForegroundColor White

                Write-Host "`n  [ MEDYA VE ILETISIM ]" -ForegroundColor Cyan
                Write-Host "   [37] VLC Media Player        [38] Spotify                 [39] Discord" -ForegroundColor White
                Write-Host "   [40] Telegram Desktop        [41] OBS Studio" -ForegroundColor White

                Write-Host "`n  +==========================================================================+" -ForegroundColor DarkGray
                Write-Host "  | [ HAZIR KURULUM PAKETLERI (Tek Komutla Toplu Kurulum) ]                  |" -ForegroundColor Yellow
                Write-Host "  +==========================================================================+" -ForegroundColor DarkGray
                Write-Host "   [P1] " -ForegroundColor Green -NoNewline
                Write-Host "Yeni PC Temel Paketi     " -ForegroundColor White -NoNewline
                Write-Host "(Chrome, 7-Zip, WinRAR, VLC, Acrobat, Everything, ShareX)" -ForegroundColor Gray

                Write-Host "   [P2] " -ForegroundColor Green -NoNewline
                Write-Host "Full-Stack Gelistirici   " -ForegroundColor White -NoNewline
                Write-Host "(VS Code, Git, Node.js, Python, Docker, Postman, DBeaver, PowerToys, Terminal)" -ForegroundColor Gray

                Write-Host "   [P3] " -ForegroundColor Green -NoNewline
                Write-Host "Frontend & Web Paketi    " -ForegroundColor White -NoNewline
                Write-Host "(VS Code, Cursor, Git, Node.js, GitHub Desktop, Postman, Chrome, Firefox Dev)" -ForegroundColor Gray

                Write-Host "   [P4] " -ForegroundColor Green -NoNewline
                Write-Host "Backend & Sistem Paketi  " -ForegroundColor White -NoNewline
                Write-Host "(VS Code, Git, Python, .NET 9, Docker, DBeaver, Postman, PowerShell 7, WinSCP)" -ForegroundColor Gray

                Write-Host "   [P5] " -ForegroundColor Magenta -NoNewline
                Write-Host "Tum Uygulamalari Guncelle" -ForegroundColor White -NoNewline
                Write-Host "(Bilgisayardaki tum winget paketlerini son surume yukseltir)" -ForegroundColor Gray

                Write-Host ""
                Write-Host "   [i] IPUCU: Birden fazla uygulamayi virgul ile secerek tek seferde kurabilirsiniz (Orn: 1,7,8,15,28)" -ForegroundColor DarkCyan
                Write-Host "   [B] Ana Menuye Don" -ForegroundColor Red
                Write-Host ""

                $altSecimGirdi = Read-Host "  > Seciminiz (Orn: 1 veya 1,7,8 veya P2)"
                $temizGirdi = $altSecimGirdi.Trim().ToUpper()

                if ([string]::IsNullOrWhiteSpace($temizGirdi)) {
                    continue
                }

                if ($temizGirdi -eq 'B') {
                    $altDevam = $false
                    continue
                }

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
                        Write-Host "`n  [*] Sistemdeki tum kurulu uygulamalar taranip guncelleniyor..." -ForegroundColor Yellow
                        winget upgrade --all --include-unknown --accept-package-agreements --accept-source-agreements
                        Write-Host "`n  [+] Guncelleme islemi tamamlandi!" -ForegroundColor Green
                    }
                    Default {
                        # Coklu secim destegi (Orn: 1, 7, 8 veya 1-5)
                        $secimler = $temizGirdi -split '[,;\s]+' | Where-Object { $_ -ne "" }
                        $gecerliPaketler = @()
                        $hataliSecimler = @()

                        foreach ($s in $secimler) {
                            if ($s -match '^(\d+)-(\d+)$') {
                                $bas = [int]$Matches[1]
                                $bit = [int]$Matches[2]
                                if ($bas -le $bit -and ($bit - $bas) -le 50) {
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

        'Q' {
            Write-Host "`n  [+] Sistemden cikiliyor. Iyi calismalar!" -ForegroundColor Cyan
            $devam = $false
            Start-Sleep -Seconds 1
        }

        Default {
            Write-Host "`n  [!] Hatali secim yaptiniz. Lutfen menudeki seceneklerden birini girin." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
}
