[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$devam =$true

while ($devam) {
    Clear-Host
    Write-Host ""
    Write-Host "   _____ ___  _   _  ___  _____ " -ForegroundColor Cyan
    Write-Host "  |_   _/ _ \| \ | |/ _ \|__  / " -ForegroundColor Cyan
    Write-Host "    | || | | |  \| | | | | / /  " -ForegroundColor Cyan
    Write-Host "    | || |_| | |\  | |_| |/ /_  " -ForegroundColor Cyan
    Write-Host "    |_| \___/|_| \_|\___//____| " -ForegroundColor Cyan
    Write-Host "                                " -ForegroundColor Cyan
    Write-Host " ==========================================" -ForegroundColor DarkGray
    Write-Host "        MERKEZI KURULUM ASISTANI v2.2      " -ForegroundColor Yellow
    Write-Host " ==========================================" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host " [ Lutfen bir islem secin ]`n" -ForegroundColor White
    
    Write-Host "  [1] " -ForegroundColor Green -NoNewline; Write-Host "TonoLink " -ForegroundColor White -NoNewline; Write-Host "(Masaustune Indir)" -ForegroundColor DarkGray
    Write-Host "  [2] " -ForegroundColor Green -NoNewline; Write-Host "NPYS     " -ForegroundColor DarkGray -NoNewline; Write-Host "(Yakinda Eklenecek)" -ForegroundColor DarkGray
    Write-Host "  [3] " -ForegroundColor Green -NoNewline; Write-Host "PayTak   " -ForegroundColor DarkGray -NoNewline; Write-Host "(Yakinda Eklenecek)" -ForegroundColor DarkGray
    Write-Host "  [4] " -ForegroundColor Yellow -NoNewline; Write-Host "Gelistirici Araclari " -ForegroundColor White -NoNewline; Write-Host "(Chrome, VS Code, Node.js)" -ForegroundColor DarkGray
    Write-Host "  [K] " -ForegroundColor Magenta -NoNewline; Write-Host "Asistan Kisayolu Olustur " -ForegroundColor White -NoNewline; Write-Host "(Masustune ekle)`n" -ForegroundColor DarkGray
    Write-Host "  [Q] " -ForegroundColor Red -NoNewline; Write-Host "Cikis`n" -ForegroundColor White
    
    $secim = Read-Host "  > Seciminiz (1-4, K veya Q)"
    Write-Host "`n ==========================================" -ForegroundColor DarkGray

    switch ($secim) {
        '1' {
            Write-Host " [>] TonoLink.exe Google Drive'dan indiriliyor, lutfen bekleyin..." -ForegroundColor Yellow
            
            $masaustu = [Environment]::GetFolderPath("Desktop")
            $hedef = "$masaustu\TonoLink.exe"
            
            try {
                $id = "1jo9eSMdnBn0yXRIe7UvzP2O5nEllNNVt"
                
                # Google Drive virus bypass taktigi
                $html = Invoke-WebRequest -Uri "https://drive.google.com/uc?export=download&id=$id" -SessionVariable gSession -UseBasicParsing -ErrorAction Stop
                
                if ($html.Content -match 'confirm=([a-zA-Z0-9_-]+)') {$onayKodu = $Matches[1]$gercekLink = "https://drive.google.com/uc?export=download&confirm=$onayKodu&id=$id"
                    Invoke-WebRequest -Uri $gercekLink -WebSession $gSession -OutFile$hedef -UseBasicParsing -ErrorAction Stop
                } else {
                    Invoke-WebRequest -Uri "https://drive.google.com/uc?export=download&id=$id" -OutFile $hedef -UseBasicParsing -ErrorAction Stop
                }
                
                Write-Host " [+] Islem Basarili! TonoLink masaustune kaydedildi." -ForegroundColor Green
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
            Write-Host " [>] Gelistirici ortami hazirlaniyor..." -ForegroundColor Magenta
            winget install --id Google.Chrome -e --silent --accept-package-agreements --accept-source-agreements
            winget install --id Microsoft.VisualStudioCode -e --silent --accept-package-agreements
            winget install --id OpenJS.NodeJS -e --silent --accept-package-agreements
            Write-Host " [+] Tüm gelistirici araçlari kuruldu!" -ForegroundColor Green
            Read-Host "`n Menuye donmek icin Enter tusuna basin..."
        }
        
        'K' {
            Write-Host " [>] Masaustune kisayol olusturuluyor..." -ForegroundColor Yellow
            $masaustu = [Environment]::GetFolderPath("Desktop")
            $batDosyasi = "$masaustu\KurulumAsistani.bat"
            
            # Kisayol kodunu bat dosyasi olarak kaydet
            "@echo off`npowershell -ExecutionPolicy Bypass -Command `"irm buraktonoz.com/kur.ps1 | iex`"" | Out-File -FilePath $batDosyasi -Encoding UTF8
            
            Write-Host " [+] Islem Basarili! 'KurulumAsistani.bat' masaustunuze eklendi." -ForegroundColor Green
            Write-Host "     Artik sadece bu dosyaya cift tiklayarak asistanı acabilirsiniz." -ForegroundColor White
            
            Write-Host "`n Menuye donmek icin Enter tusuna basin..." -ForegroundColor DarkGray
            $null = Read-Host
        }
        
        'Q' { Write-Host " Sistemden cikiliyor. Iyi calismalar!" -ForegroundColor DarkGray; $devam =$false; Start-Sleep -Seconds 1 }
        Default { Write-Host " [!] Hatali secim yaptiniz." -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }
}
