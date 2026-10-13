[console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Menü sürekli açık kalsın diye bir döngü (while) başlatıyoruz
$devam =$true

while ($devam) {
    Clear-Host
    Write-Host "=========================================================" -ForegroundColor Cyan
    Write-Host "       BURAK TONOZ - MERKEZİ KURULUM ASİSTANI            " -ForegroundColor Yellow
    Write-Host "=========================================================" -ForegroundColor Cyan
    Write-Host " Lütfen indirmek/kurmak istediğiniz aracı seçin:`n" -ForegroundColor White
    
    # Menü Seçenekleri
    Write-Host "  [1] " -ForegroundColor Green -NoNewline; Write-Host "TonoLink (Masaüstüne İndir)"
    Write-Host "  [2] " -ForegroundColor DarkGray -NoNewline; Write-Host "NPYS Kurulumu (Yakında...)" -ForegroundColor DarkGray
    Write-Host "  [3] " -ForegroundColor DarkGray -NoNewline; Write-Host "PayTak Kurulumu (Yakında...)" -ForegroundColor DarkGray
    Write-Host "  [4] " -ForegroundColor Yellow -NoNewline; Write-Host "Geliştirici Araçları (VS Code vs.)"
    Write-Host "  [Q] " -ForegroundColor Red -NoNewline; Write-Host "Çıkış`n"
    
    $secim = Read-Host "Seçiminiz (1/2/3/4/Q)"
    Write-Host "`n=========================================================" -ForegroundColor Cyan

    switch ($secim) {
        '1' {
            Write-Host "[>] TonoLink.exe Drive'dan masaüstüne indiriliyor..." -ForegroundColor Yellow
            
            $masaustu = [Environment]::GetFolderPath("Desktop")
            $hedef = "$masaustu\TonoLink.exe"
            # Senin Drive doğrudan indirme linkin
            $driveLink = "https://drive.google.com/uc?export=download&id=1jo9eSMdnBn0yXRIe7UvzP2O5nEllNNVt"
            
            try {
                Invoke-WebRequest -Uri $driveLink -OutFile $hedef -UseBasicParsing
                Write-Host "[+] İşlem Başarılı! TonoLink masaüstünüze eklendi." -ForegroundColor Green
            } catch {
                Write-Host "[-] İndirme başarısız oldu. İnternet veya Drive erişimini kontrol edin." -ForegroundColor Red
            }
            
            Write-Host "`nMenüye dönmek için bir tuşa basın..." -ForegroundColor White
            $null =$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
        }
        
        '2' {
            Write-Host "[!] Bu modül henüz eklenmedi. Daha sonra kendi Drive linkini buraya gireceksin." -ForegroundColor DarkGray
            Start-Sleep -Seconds 2
        }
        
        '3' {
            Write-Host "[!] Bu modül henüz eklenmedi." -ForegroundColor DarkGray
            Start-Sleep -Seconds 2
        }

        '4' {
            Write-Host "[!] Winget modülü buraya eklenecek." -ForegroundColor DarkGray
            Start-Sleep -Seconds 2
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
