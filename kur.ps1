[console]::OutputEncoding = [System.Text.Encoding]::UTF8

$devam = $true

while ($devam) {
    Clear-Host
    Write-Host "=========================================================" -ForegroundColor Cyan
    Write-Host "       BURAK TONOZ - MERKEZİ KURULUM ASİSTANI            " -ForegroundColor Yellow
    Write-Host "=========================================================" -ForegroundColor Cyan
    Write-Host " Lütfen indirmek veya kurmak istediğiniz aracı seçin:`n" -ForegroundColor White
    
    # Menü Seçenekleri
    Write-Host "  [1] " -ForegroundColor Green -NoNewline; Write-Host "TonoLink (Masaüstüne İndir)"
    Write-Host "  [2] " -ForegroundColor DarkGray -NoNewline; Write-Host "NPYS Kurulumu (Yakında...)"
    Write-Host "  [3] " -ForegroundColor DarkGray -NoNewline; Write-Host "PayTak Kurulumu (Yakında...)"
    Write-Host "  [4] " -ForegroundColor Yellow -NoNewline; Write-Host "Geliştirici Araçları (Chrome, VS Code, Node.js)"
    Write-Host "  [Q] " -ForegroundColor Red -NoNewline; Write-Host "Çıkış`n"
    
    $secim = Read-Host "Seçiminiz (1/2/3/4/Q)"
    Write-Host "`n=========================================================" -ForegroundColor Cyan

    switch ($secim) {
        '1' {
            Write-Host "[>] TonoLink.exe Drive'dan masaüstüne indiriliyor..." -ForegroundColor Yellow
            
            $masaustu = [Environment]::GetFolderPath("Desktop")
            $hedef = "$masaustu\TonoLink.exe"
            $driveLink = "https://drive.google.com/uc?export=download&id=1jo9eSMdnBn0yXRIe7UvzP2O5nEllNNVt"
            
            try {
                Invoke-WebRequest -Uri $driveLink -OutFile$hedef -UseBasicParsing
                Write-Host "[+] İşlem Başarılı! TonoLink masaüstünüze eklendi." -ForegroundColor Green
            } catch {
                Write-Host "[-] İndirme başarısız oldu. İnternet bağlantınızı kontrol edin." -ForegroundColor Red
            }
            
            Write-Host "`nMenüye dönmek için Enter'a basın..." -ForegroundColor White
            Read-Host
        }
        
        '2' {
            Write-Host "[!] NPYS modülü henüz eklenmedi. Daha sonra Drive linkini buraya gireceksin." -ForegroundColor DarkGray
            Start-Sleep -Seconds 2
        }
        
        '3' {
            Write-Host "[!] PayTak modülü henüz eklenmedi." -ForegroundColor DarkGray
            Start-Sleep -Seconds 2
        }

        '4' {
            Write-Host "[>] Geliştirici ortamı hazırlanıyor, lütfen bekleyin..." -ForegroundColor Magenta
            
            Write-Host "  [*] Google Chrome kuruluyor..." -ForegroundColor Yellow
            winget install --id Google.Chrome -e --silent --accept-package-agreements --accept-source-agreements
            
            Write-Host "  [*] Visual Studio Code kuruluyor..." -ForegroundColor Yellow
            winget install --id Microsoft.VisualStudioCode -e --silent --accept-package-agreements
            
            Write-Host "  [*] Node.js kuruluyor..." -ForegroundColor Yellow
            winget install --id OpenJS.NodeJS -e --silent --accept-package-agreements
            
            Write-Host "[+] Tüm geliştirici araçları başarıyla kuruldu!" -ForegroundColor Green
            
            Write-Host "`nMenüye dönmek için Enter'a basın..." -ForegroundColor White
            Read-Host
        }
        
        'Q' {
            Write-Host "Sistemden çıkılıyor. İyi çalışmalar!" -ForegroundColor DarkGray
            $devam =$false
            Start-Sleep -Seconds 1
        }
        
        Default {
            Write-Host "[!] Hatalı seçim yaptınız, lütfen listedeki tuşları kullanın." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
}
