[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$devam = $true

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
    Write-Host "        MERKEZI KURULUM ASISTANI v2.8      " -ForegroundColor Yellow
    Write-Host " ==========================================" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host " [ Lutfen bir islem secin ]`n" -ForegroundColor White
    
    Write-Host "  [1] " -ForegroundColor Green -NoNewline; Write-Host "TonoLink " -ForegroundColor White -NoNewline; Write-Host "(Masaustune Indir - Portable)" -ForegroundColor DarkGray
    Write-Host "  [2] " -ForegroundColor DarkGray -NoNewline; Write-Host "NPYS     " -ForegroundColor DarkGray -NoNewline; Write-Host "(Yakinda Eklenecek)" -ForegroundColor DarkGray
    Write-Host "  [3] " -ForegroundColor DarkGray -NoNewline; Write-Host "PayTak   " -ForegroundColor DarkGray -NoNewline; Write-Host "(Yakinda Eklenecek)" -ForegroundColor DarkGray
    Write-Host "  [4] " -ForegroundColor Yellow -NoNewline; Write-Host "Standart Yazilimlar " -ForegroundColor White -NoNewline; Write-Host "(Chrome, Office, WinRAR, VS Code, Node.js)" -ForegroundColor DarkGray
    Write-Host "  [Q] " -ForegroundColor Red -NoNewline; Write-Host "Cikis`n" -ForegroundColor White
    
    $secim = Read-Host "  > Seciminiz (1-4 veya Q)"
    Write-Host "`n ==========================================" -ForegroundColor DarkGray

    switch ($secim) {
        '1' {
            Write-Host " [>] TonoLink.exe GitHub'dan indiriliyor, lutfen bekleyin..." -ForegroundColor Yellow
            
            $masaustu = [Environment]::GetFolderPath("Desktop")
            $hedef = "$masaustu\TonoLink.exe"
            
            # GitHub Release indirme linkin
            $indirmeLinki = "https://github.com/BURAKTONOZ/dosya/releases/latest/download/TonoLink.exe"
            
            try {
                Invoke-WebRequest -Uri $indirmeLinki -OutFile$hedef -UseBasicParsing -ErrorAction Stop
                Write-Host " [+] Islem Basarili! TonoLink (.exe) masaustune kaydedildi." -ForegroundColor Green
            } catch {
                Write-Host " [-] Indirme basarisiz oldu!" -ForegroundColor Red
                Write-Host "     Hata Detayi: $($_.Exception.Message)" -ForegroundColor DarkGray
            }
            
            Write-Host "`n Menuye donmek icin Enter tusuna basin..." -ForegroundColor DarkGray
            $null = Read-Host
        }
        
        '2' { Write-Host " [!] NPYS modulu henuz aktif degil." -ForegroundColor DarkGray; Start-Sleep -Seconds 2 }
        '3' { Write-Host " [!] PayTak modulu henuz aktif degil." -ForegroundColor DarkGray; Start-Sleep -Seconds 2 }
        '4' {
            Write-Host " [>] Standart yazilimlar ve gelistirici araclari kuruluyor..." -ForegroundColor Magenta
            
            Write-Host " -> Google Chrome kuruluyor..." -ForegroundColor Cyan
            winget install --id Google.Chrome -e --silent --accept-package-agreements --accept-source-agreements
            
            Write-Host " -> Microsoft Office kuruluyor..." -ForegroundColor Cyan
            winget install --id Microsoft.Office -e --silent --accept-package-agreements --accept-source-agreements
            
            Write-Host " -> WinRAR kuruluyor..." -ForegroundColor Cyan
            winget install --id RARLab.WinRAR -e --silent --accept-package-agreements --accept-source-agreements
            
            Write-Host " -> Visual Studio Code kuruluyor..." -ForegroundColor Cyan
            winget install --id Microsoft.VisualStudioCode -e --silent --accept-package-agreements
            
            Write-Host " -> Node.js kuruluyor..." -ForegroundColor Cyan
            winget install --id OpenJS.NodeJS -e --silent --accept-package-agreements
            
            Write-Host " [+] Tum yazilimlar basariyla kuruldu!" -ForegroundColor Green
            Read-Host "`n Menuye donmek icin Enter tusuna basin..."
        }
        
        'Q' { Write-Host " Sistemden cikiliyor. Iyi calismalar!" -ForegroundColor DarkGray; $devam =$false; Start-Sleep -Seconds 1 }
        Default { Write-Host " [!] Hatali secim yaptiniz." -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }
}
