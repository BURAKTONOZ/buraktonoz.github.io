[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

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
    Write-Host "        MERKEZI KURULUM ASISTANI v3.1      " -ForegroundColor Yellow
    Write-Host " ==========================================" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host " [ Lutfen bir islem secin ]`n" -Footer -ForegroundColor White
    
    Write-Host "  [1] " -ForegroundColor Green -NoNewline; Write-Host "NPYS (Numarataj Personel) " -ForegroundColor White -NoNewline; Write-Host "(Masaustune Akilli Indirici)" -ForegroundColor DarkGray
    Write-Host "  [2] " -ForegroundColor DarkGray -NoNewline; Write-Host "TonoLink " -ForegroundColor DarkGray -NoNewline; Write-Host "(Yakinda Eklenecek)" -ForegroundColor DarkGray
    Write-Host "  [3] " -ForegroundColor DarkGray -NoNewline; Write-Host "PayTak   " -ForegroundColor DarkGray -NoNewline; Write-Host "(Yakinda Eklenecek)" -ForegroundColor DarkGray
    Write-Host "  [4] " -ForegroundColor Yellow -NoNewline; Write-Host "Yazilim Kurulum Menusu " -ForegroundColor White -NoNewline; Write-Host "(Tekli Secimler)" -ForegroundColor DarkGray
    Write-Host "  [Q] " -ForegroundColor Red -NoNewline; Write-Host "Cikis`n" -ForegroundColor White
    
    $secim = Read-Host "  > Seciminiz (1-4 veya Q)"
    Write-Host "`n ==========================================" -ForegroundColor DarkGray

    switch ($secim) {
        '1' {
            Write-Host ""
            Write-Host " [i] Uygulama Bilgileri:" -ForegroundColor Cyan
            Write-Host "     - Yazilim Adi : Numarataj Personel Yonetim Sistemi (NPYS)" -ForegroundColor White
            Write-Host "     - Kaynak      : GitHub Releases (Son Surüm / Latest)" -ForegroundColor White
            Write-Host "     - Hedef       : Masaustu" -ForegroundColor White
            Write-Host ""
            Write-Host " [>] Baglanti kuruluyor ve dosya indiriliyor..." -ForegroundColor Yellow
            
            $masaustu = [Environment]::GetFolderPath("Desktop")
            $hedef = "$masaustu\NPYS.exe"
            $indirmeLinki = "https://github.com/BURAKTONOZ/personel/releases/download/latest/NPYS.exe"
            
            try {
                $webClient = New-Object System.Net.WebClient
                
                # Konsol tabanlı akıcı dolum çubuğu için event
                Register-ObjectEvent -InputObject $webClient -EventName DownloadProgressChanged -Action {
                    $yuzde = $EventArgs.ProgressPercentage
                    $barUzunlugu = 30
                    $dolu = [math]::Floor($barUzunlugu * $yuzde / 100)
                    $bos = $barUzunlugu - $dolu
                    $bar = "[" + ("#" * $dolu) + ("-" * $bos) + "]"
                    
                    # Satır üstüne yazarak akıcı ilerleme efekti verme
                    Write-Host -NoNewline "`r Indiriliyor... $bar$yuzde% " -ForegroundColor Cyan
                } | Out-Null

                $webClient.DownloadFileTaskAsync($indirmeLinki,$hedef).Wait()
                
                Unregister-Event -SourceIdentifier $webClient -ErrorAction SilentlyContinue
                Write-Host ""
                Write-Host " [+] Islem Basarili! NPYS.exe basariyla masaustune kaydedildi." -ForegroundColor Green
            } catch {
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
            $altDevam = $true
            while ($altDevam) {
                Clear-Host
                Write-Host " ==========================================" -ForegroundColor DarkGray
                Write-Host "          YAZILIM KURULUM MENUSU           " -ForegroundColor Yellow
                Write-Host " ==========================================" -ForegroundColor DarkGray
                Write-Host "  [1] Google Chrome Kur" -ForegroundColor White
                Write-Host "  [2] Microsoft Office Kur" -ForegroundColor White
                Write-Host "  [3] WinRAR Kur" -ForegroundColor White
                Write-Host "  [4] Visual Studio Code Kur" -ForegroundColor White
                Write-Host "  [5] Node.js Kur" -ForegroundColor White
                Write-Host "  [B] Onceki Menuye Don" -ForegroundColor Cyan
                Write-Host ""
                $altSecim = Read-Host "  > Seciminiz (1-5 veya B)"

                switch ($altSecim) {
                    '1' {
                        Write-Host " [>] Google Chrome kuruluyor..." -ForegroundColor Cyan
                        winget install --id Google.Chrome -e --silent --accept-package-agreements --accept-source-agreements
                        Write-Host " [+] Chrome kuruldu!" -ForegroundColor Green
                        Start-Sleep -Seconds 2
                    }
                    '2' {
                        Write-Host " [>] Microsoft Office kuruluyor..." -ForegroundColor Cyan
                        winget install --id Microsoft.Office -e --silent --accept-package-agreements --accept-source-agreements
                        Write-Host " [+] Office kuruldu!" -ForegroundColor Green
                        Start-Sleep -Seconds 2`
                    }
                    '3' {
                        Write-Host " [>] WinRAR kuruluyor..." -ForegroundColor Cyan
                        winget install --id RARLab.WinRAR -e --silent --accept-package-agreements --accept-source-agreements
                        Write-Host " [+] WinRAR kuruldu!" -ForegroundColor Green
                        Start-Sleep -Seconds 2
                    }
                    '4' {
                        Write-Host " [>] VS Code kuruluyor..." -ForegroundColor Cyan
                        winget install --id Microsoft.VisualStudioCode -e --silent --accept-package-agreements
                        Write-Host " [+] VS Code kuruldu!" -ForegroundColor Green
                        Start-Sleep -Seconds 2
                    }
                    '5' {
                        Write-Host " [>] Node.js kuruluyor..." -ForegroundColor Cyan
                        winget install --id OpenJS.NodeJS -e --silent --accept-package-agreements
                        Write-Host " [+] Node.js kuruldu!" -ForegroundColor Green
                        Start-Sleep -Seconds 2
                    }
                    'B' { $altDevam =$false }
                    Default { Write-Host " [!] Hatali secim!" -ForegroundColor Red; Start-Sleep -Seconds 1 }
                }
            }
        }
        
        'Q' { Write-Host " Sistemden cikiliyor. Iyi calismalar!" -ForegroundColor DarkGray; $devam =$false; Start-Sleep -Seconds 1 }
        Default { Write-Host " [!] Hatali secim yaptiniz." -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }
}
