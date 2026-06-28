# Check if port 3000 is already in use
function Check-PortInUse {
    param(
        [int]$port = 3000
    )
    
    $connections = netstat -ano | Select-String -Pattern "TCP.*:$port.*LISTENING"
    
    if ($connections.Count -gt 0) {
        Write-Host "AVISO: A porta $port já está em uso." -ForegroundColor Yellow
        
        foreach ($conn in $connections) {
            $line = $conn.ToString()
            if ($line -match "LISTENING\s+(\d+)") {
                $pid = $matches[1]
                $process = Get-Process -Id $pid -ErrorAction SilentlyContinue
                
                if ($process) {
                    Write-Host "Processo usando a porta: $($process.Name) (PID: $pid)" -ForegroundColor Yellow
                    
                    $choice = Read-Host "Deseja encerrar este processo? (S/N)"
                    if ($choice -eq "S" -or $choice -eq "s") {
                        Stop-Process -Id $pid -Force
                        Write-Host "Processo encerrado." -ForegroundColor Green
                        return $false
                    } else {
                        Write-Host "Operação cancelada. Escolha outra porta ou encerre o processo manualmente." -ForegroundColor Red
                        return $true
                    }
                } else {
                    Write-Host "Não foi possível identificar o processo (PID: $pid)" -ForegroundColor Red
                    return $true
                }
            }
        }
    } else {
        Write-Host "A porta $port está disponível." -ForegroundColor Green
        return $false
    }
}

# Check for required dependencies
function Check-Dependencies {
    $requiredModules = @("express", "cors", "node-fetch")
    $missing = @()
    
    Write-Host "Verificando dependências..." -ForegroundColor Cyan
    
    foreach ($module in $requiredModules) {
        $moduleInstalled = npm list $module --depth=0 2>$null
        if ($LASTEXITCODE -ne 0) {
            $missing += $module
        }
    }
    
    if ($missing.Count -gt 0) {
        Write-Host "Faltam as seguintes dependências: $($missing -join ', ')" -ForegroundColor Yellow
        $install = Read-Host "Deseja instalar as dependências faltantes? (S/N)"
        
        if ($install -eq "S" -or $install -eq "s") {
            foreach ($module in $missing) {
                Write-Host "Instalando $module..." -ForegroundColor Cyan
                npm install $module
            }
            Write-Host "Todas as dependências foram instaladas." -ForegroundColor Green
        } else {
            Write-Host "As dependências não foram instaladas. O proxy pode não funcionar corretamente." -ForegroundColor Red
            return $false
        }
    } else {
        Write-Host "Todas as dependências estão instaladas." -ForegroundColor Green
    }
    
    return $true
}

# Main script
Write-Host "==========================================" -ForegroundColor Blue
Write-Host "  VERIFICAÇÃO DO PROXY PARA THE OLD READER" -ForegroundColor Blue
Write-Host "==========================================" -ForegroundColor Blue

$portInUse = Check-PortInUse
if ($portInUse) {
    exit
}

$dependenciesOk = Check-Dependencies
if (-not $dependenciesOk) {
    $continue = Read-Host "Continuar mesmo assim? (S/N)"
    if ($continue -ne "S" -and $continue -ne "s") {
        exit
    }
}

Write-Host "==========================================" -ForegroundColor Blue
Write-Host "  INICIANDO O PROXY PARA THE OLD READER" -ForegroundColor Blue
Write-Host "==========================================" -ForegroundColor Blue
Write-Host "Executando: node proxy\proxy.js" -ForegroundColor Cyan
Write-Host "Pressione CTRL+C para encerrar o servidor" -ForegroundColor Yellow
Write-Host ""

node proxy\proxy.js
