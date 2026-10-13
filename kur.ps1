[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Onceki hatali calismalardan kalan arka plan gorevlerini temizle
Get-EventSubscriber -ErrorAction SilentlyContinue | Where-Object { $_.SourceIdentifier -match "IndirmeEvent" } | Unregister-Event

# Kurulum islemlerini temiz yapmak icin kucuk bir yardimci fonksiyon
function Kur-Uygulama {
    param([string]$Id, [string]$Ad, [string]$Kaynak="winget")
    Write-Host " [>] $Ad kuruluyor. Lutfen bekleyin..." -ForegroundColor Cyan
    winget install --id $Id -e --silent --accept-package-agreements --accept-source-agreements --source$Kaynak
    if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq -1978335189 -or$LASTEXITCODE -eq -1978335135) {
        Write-Host " [+] $Ad hazir!" -ForegroundColor Green
    } else {
        Write-Host " [-] $Ad kurulamadi (Hata:$LASTEXITCODE). Winget guncel olmayabilir." -ForegroundColor Red
    }
}

$devam =$true

while ($devam) {
    Clear-Host
    Write-Host ""
    Write-Host "    _____ ___  _   _ ___  _____ " -ForegroundColor Cyan
    Write-Host "   |_   _/ _ \| \ | |/ _ \|__  / " -ForegroundColor Cyan
    Write-Host "     | || | | |  \| | | | | / /  " -ForegroundColor Cyan
    Write-Host "     | || |_| | |\  | |_| |/ /_  " -ForegroundColor Cyan
    Write-Host "     |_| \___/|_| \_|\___//____| " -ForegroundColor Cyan
    Write-Host "                                 " -ForegroundColor Cyan
    Write-Host " ==========================================" -ForegroundColor DarkGray
    Write-Host "        MERKEZI KURULUM ASISTANI v3.5      " -ForegroundColor Yellow
    Write-Host " ==========================================" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host " [ Lutfen bir islem secin ]`n" -ForegroundColor White
    
    Write-Host "  [1] " -ForegroundColor Green -NoNewline; Write-Host "NPYS (Numarataj Personel) " -ForegroundColor White -NoNewline; Write-Host "(Masaustune Akilli Indirici)" -ForegroundColor DarkGray
    Write-Host "  [2] " -ForegroundColor DarkGray -NoNewline; Write-Host "TonoLink " -ForegroundColor DarkGray -NoNewline; Write-Host "(Yakinda Eklenecek)" -ForegroundColor DarkGray
    Write-Host "  [3] " -ForegroundColor DarkGray -NoNewline; Write-Host "PayTak   " -ForegroundColor DarkGray -NoNewline; Write-Host "(Yakinda Eklenecek)" -ForegroundColor DarkGray
    Write-Host "  [4] " -ForegroundColor Yellow -NoNewline; Write-Host "Yazilim Kurulum Merkezi " -ForegroundColor White -NoNewline; Write-Host "(Tekli ve Paket Kurulum)" -ForegroundColor DarkGray
    Write-Host "  [Q] " -ForegroundColor Red -NoNewline; Write-Host "Cikis`n" -ForegroundColor White
    
    $secim = Read-Host "  > Seciminiz (1-4 veya Q)"
    Write-Host "`n ==========================================" -ForegroundColor DarkGray

    switch ($secim) {
        '1' {
            Write-Host ""
            Write-Host " [i] Uygulama Bilgileri:" -ForegroundColor Cyan
            Write-Host "     - Yazilim Adi : Numarataj Personel Yonetim Sistemi (NPYS)" -ForegroundColor White
            Write-Host "     - Kaynak      : GitHub Releases (Son Surum)" -ForegroundColor White
            Write-Host "     - Hedef       : Masaustu" -ForegroundColor White
            Write-Host ""
            Write-Host " [>] Baglanti kuruluyor ve dosya indiriliyor..." -ForegroundColor Yellow
            
            $masaustu = [Environment]::GetFolderPath("Desktop")
            $hedef = "$masaustu\NPYS.exe"
            $indirmeLinki = "https://github.com/BURAKTONOZ/personel/releases/download/latest/NPYS.exe"
            
            try {
                $webClient = New-Object System.Net.WebClient
                
                # Yuzdeyi arka planda guvenle tutmak icin degisken olusturuyoruz
                $syncHash = [hashtable]::Synchronized(@{ Yuzde = 0 })
                
                # Arka plan sadece sayiyi gunceller, ekrana yazi YAZMAZ
                $action = { $syncHash.Yuzde = $EventArgs.ProgressPercentage }
                $job = Register-ObjectEvent -InputObject $webClient -EventName DownloadProgressChanged -SourceIdentifier "IndirmeEvent" -Action $action
                
                # Indirmeyi baslat
                $task = $webClient.DownloadFileTaskAsync($indirmeLinki, $hedef)
                
                # Ekrana yazma islemini ana dongu yapar (Yazilar birbirine girmez)
                while (-not $task.IsCompleted) {
                    $yuzde = $syncHash.Yuzde
                    $barUzunlugu = 30
                    $dolu = [math]::Floor($barUzunlugu * $yuzde / 100)
                    $bos = $barUzunlugu - $dolu
                    $bar = "[" + ("#" * $dolu) + ("-" * $bos) + "]"
                    
                    Write-Host -NoNewline "`r Indiriliyor... $bar$yuzde% " -ForegroundColor Cyan
                    Start-Sleep -Milliseconds 50
                }
                
                # Indirme bitince tam dolu bari goster ve temizle
                Write-Host -NoNewline "`r Indiriliyor... [##############################] 100% " -ForegroundColor Cyan
                Write-Host ""
                
                Unregister-Event -SourceIdentifier "IndirmeEvent" -ErrorAction SilentlyContinue
                $webClient.Dispose()
                
                Write-Host " [+] Islem Basarili! NPYS.exe basariyla masaustune kaydedildi." -ForegroundColor Green
            } catch {
                Unregister-Event -SourceIdentifier "IndirmeEvent" -ErrorAction SilentlyContinue
                Write-Host ""
                Write-Host " [-] Indirme basarisiz oldu!" -ForegroundColor Red
                Write-Host "     Hata Detayi: $($_.Exception.Message)" -ForegroundColor DarkGray
            }
            
            Write-Host "`n Menuye donmek icin Enter tusuna basin..." -ForegroundColor DarkGray
            $null = Read-Host
        }
        
        '2' { Write-Host " [!] TonoLink modulu henuz aktif degil." -ForegroundColor DarkGray; Start-Sleep -Seconds 2 }
        '3' { Write-Host " [!] PayTak modulu henuz aktif degil." -ForegroundColor DarkGray; Start-Sleep -Seconds 2 }
        '4' {
            $altDevam =$true
            while ($altDevam) {
                Clear-Host
                Write-Host " ========================================================" -ForegroundColor DarkGray
                Write-Host "                YAZILIM KURULUM MERKEZI                  " -ForegroundColor Yellow
                Write-Host " ========================================================" -ForegroundColor DarkGray
                
                Write-Host "  [ TARAYICILAR ]" -ForegroundColor Cyan
                Write-Host "  [1] Google Chrome       [2] Mozilla Firefox     [3] Brave" -ForegroundColor White
                
                Write-Host "`n  [ OFIS VE ARACLAR ]" -ForegroundColor Cyan
                Write-Host "  [4] Microsoft 365       [5] LibreOffice         [6] Adobe Acrobat (PDF)" -ForegroundColor White
                Write-Host "  [7] WinRAR              [8] 7-Zip               [9] AnyDesk" -ForegroundColor White
                
                Write-Host "`n  [ GELISTIRICI ]" -ForegroundColor Cyan
                Write-Host "  [10] VS Code            [11] Git                [12] Node.js" -ForegroundColor White
                Write-Host "  [13] Python 3.13        [14] GitHub Desktop     [15] Notepad++" -ForegroundColor White
                
                Write-Host "`n  [ MEDYA VE ILETISIM ]" -ForegroundColor Cyan
                Write-Host "  [16] VLC Player         [17] Spotify            [18] Discord" -ForegroundColor White
                
                Write-Host "`n ========================================================" -ForegroundColor DarkGray
                Write-Host "  [ HAZIR PAKETLER ]" -ForegroundColor Yellow
                Write-Host "  [P1] Yeni PC Paketi (Chrome, WinRAR, VLC, Acrobat)" -ForegroundColor White
                Write-Host "  [P2] Gelistirici Paketi (VS Code, Git, Node.js, GitHub Desktop)" -ForegroundColor White
                
                Write-Host "`n  [B] Onceki Menuye Don" -ForegroundColor Red
                Write-Host ""
                $altSecim = Read-Host "  > Seciminiz"

                Write-Host ""
                switch ($altSecim.ToUpper()) {
                    # Tekli Kurulumlar
                    '1'  { Kur-Uygulama "Google.Chrome" "Google Chrome" }
                    '2'  { Kur-Uygulama "Mozilla.Firefox" "Mozilla Firefox" }
                    '3'  { Kur-Uygulama "Brave.Brave" "Brave Tarayici" }
                    '4'  { Kur-Uygulama "Microsoft.Office" "Microsoft 365 (Office)" }
                    '5'  { Kur-Uygulama "TheDocumentFoundation.LibreOffice" "LibreOffice" }
                    '6'  { Kur-Uygulama "Adobe.Acrobat.Reader.64-bit" "Adobe Acrobat Reader" }
                    '7'  { Kur-Uygulama "RARLab.WinRAR" "WinRAR" }
                    '8'  { Kur-Uygulama "7zip.7zip" "7-Zip" }
                    '9'  { Kur-Uygulama "AnyDesk.AnyDesk" "AnyDesk" }
                    '10' { Kur-Uygulama "Microsoft.VisualStudioCode" "Visual Studio Code" }
                    '11' { Kur-Uygulama "Git.Git" "Git" }
                    '12' { Kur-Uygulama "OpenJS.NodeJS" "Node.js" }
                    '13' { Kur-Uygulama "Python.Python.3.13" "Python 3.13" }
                    '14' { Kur-Uygulama "GitHub.GitHubDesktop" "GitHub Desktop" }
                    '15' { Kur-Uygulama "Notepad++.Notepad++" "Notepad++" }
                    '16' { Kur-Uygulama "VideoLAN.VLC" "VLC Media Player" }
                    '17' { Kur-Uygulama "Spotify.Spotify" "Spotify" }
                    '18' { Kur-Uygulama "Discord.Discord" "Discord" }

                    # Paketler
                    'P1' {
                        Write-Host " [*] Yeni PC Paketi baslatiliyor..." -ForegroundColor Yellow
                        Kur-Uygulama "Google.Chrome" "Google Chrome"
                        Kur-Uygulama "RARLab.WinRAR" "WinRAR"
                        Kur-Uygulama "VideoLAN.VLC" "VLC Media Player"
                        Kur-Uygulama "Adobe.Acrobat.Reader.64-bit" "Adobe Acrobat Reader"
                        Write-Host " [+] Yeni PC Paketi tamamlandi!" -ForegroundColor Green
                    }
                    'P2' {
                        Write-Host " [*] Gelistirici Paketi baslatiliyor..." -ForegroundColor Yellow
                        Kur-Uygulama "Microsoft.VisualStudioCode" "Visual Studio Code"
                        Kur-Uygulama "Git.Git" "Git"
                        Kur-Uygulama "OpenJS.NodeJS" "Node.js"
                        Kur-Uygulama "GitHub.GitHubDesktop" "GitHub Desktop"
                        Write-Host " [+] Gelistirici Paketi tamamlandi!" -ForegroundColor Green
                    }

                    'B'  { $altDevam = $false }
                    Default { Write-Host " [!] Hatali secim!" -ForegroundColor Red }
                }
                if ($altDevam) { 
                    Write-Host "`n Menuye donmek icin Enter'a basin..." -ForegroundColor DarkGray
                    $null = Read-Host 
                }
            }
        }
        
        'Q' { Write-Host " Sistemden cikiliyor. Iyi calismalar!" -ForegroundColor DarkGray; $devam =$false; Start-Sleep -Seconds 1 }
        Default { Write-Host " [!] Hatali secim yaptiniz." -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }
}
