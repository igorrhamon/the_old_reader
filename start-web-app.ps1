# Start The Old Reader Web App with Proxy
# PowerShell Script

function Write-ColorOutput($ForegroundColor) {
    # Save the current color
    $previousForegroundColor = $host.UI.RawUI.ForegroundColor

    # Set the new color
    $host.UI.RawUI.ForegroundColor = $ForegroundColor

    # Write the output
    if ($args) {
        Write-Output $args
    }
    else {
        $input | Write-Output
    }

    # Restore the original color
    $host.UI.RawUI.ForegroundColor = $previousForegroundColor
}

function Check-PortInUse {
    param(
        [int]$port
    )
    
    $connections = netstat -ano | Select-String -Pattern "TCP.*:$port.*LISTENING"
    
    if ($connections.Count -gt 0) {
        Write-ColorOutput Yellow "AVISO: A porta $port já está em uso."
        
        foreach ($conn in $connections) {
            $line = $conn.ToString()
            if ($line -match "LISTENING\s+(\d+)") {
                $pid = $matches[1]
                $process = Get-Process -Id $pid -ErrorAction SilentlyContinue
                
                if ($process) {
                    Write-ColorOutput Yellow "Processo usando a porta: $($process.Name) (PID: $pid)"
                    
                    $choice = Read-Host "Deseja encerrar este processo? (S/N)"
                    if ($choice -eq "S" -or $choice -eq "s") {
                        Stop-Process -Id $pid -Force
                        Write-ColorOutput Green "Processo encerrado."
                        return $false
                    } else {
                        Write-ColorOutput Red "Operação cancelada. Escolha outra porta ou encerre o processo manualmente."
                        return $true
                    }
                } else {
                    Write-ColorOutput Red "Não foi possível identificar o processo (PID: $pid)"
                    return $true
                }
            }
        }
    } else {
        Write-ColorOutput Green "A porta $port está disponível."
        return $false
    }
}

function Check-Dependencies {
    $requiredModules = @("express", "cors", "node-fetch")
    $missing = @()
    
    Write-ColorOutput Cyan "Verificando dependências..."
    
    foreach ($module in $requiredModules) {
        $moduleInstalled = npm list $module --depth=0 2>$null
        if ($LASTEXITCODE -ne 0) {
            $missing += $module
        }
    }
    
    if ($missing.Count -gt 0) {
        Write-ColorOutput Yellow "Faltam as seguintes dependências: $($missing -join ', ')"
        $install = Read-Host "Deseja instalar as dependências faltantes? (S/N)"
        
        if ($install -eq "S" -or $install -eq "s") {
            foreach ($module in $missing) {
                Write-ColorOutput Cyan "Instalando $module..."
                npm install $module
            }
            Write-ColorOutput Green "Todas as dependências foram instaladas."
        } else {
            Write-ColorOutput Red "As dependências não foram instaladas. O proxy pode não funcionar corretamente."
            return $false
        }
    } else {
        Write-ColorOutput Green "Todas as dependências estão instaladas."
    }
    
    return $true
}

function Check-FlutterInstallation {
    try {
        $flutterVersion = flutter --version
        Write-ColorOutput Green "Flutter instalado: $($flutterVersion[0])"
        return $true
    } catch {
        Write-ColorOutput Red "Flutter não encontrado. Certifique-se de que o Flutter está instalado e no PATH."
        Write-ColorOutput Yellow "Download: https://flutter.dev/docs/get-started/install"
        return $false
    }
}

# Main script
Clear-Host
Write-ColorOutput Blue "=========================================================="
Write-ColorOutput Blue "      INICIANDO THE OLD READER APP (WEB + PROXY)"
Write-ColorOutput Blue "=========================================================="
Write-Host ""

# Check ports
$port3000InUse = Check-PortInUse -port 3000
if ($port3000InUse) {
    Write-ColorOutput Red "Não foi possível liberar a porta 3000 para o proxy."
    exit
}

$port8000InUse = Check-PortInUse -port 8000
if ($port8000InUse) {
    Write-ColorOutput Red "Não foi possível liberar a porta 8000 para o Flutter Web."
    exit
}

# Check dependencies
$dependenciesOk = Check-Dependencies
if (-not $dependenciesOk) {
    $continue = Read-Host "Continuar mesmo assim? (S/N)"
    if ($continue -ne "S" -and $continue -ne "s") {
        exit
    }
}

# Check Flutter
$flutterOk = Check-FlutterInstallation
if (-not $flutterOk) {
    exit
}

# Start proxy
Write-ColorOutput Cyan "Iniciando o proxy em segundo plano..."
$proxyJob = Start-Job -ScriptBlock { 
    Set-Location -Path $using:PSScriptRoot
    node proxy.js 
}

Write-ColorOutput Yellow "Aguardando o proxy iniciar (3 segundos)..."
Start-Sleep -Seconds 3

# Start Flutter web
Write-ColorOutput Blue "=========================================================="
Write-ColorOutput Blue "      INICIANDO FLUTTER WEB NO MODO WEB-SERVER"
Write-ColorOutput Blue "=========================================================="
Write-Host ""
Write-ColorOutput Cyan "O aplicativo web estará disponível em:"
Write-ColorOutput Yellow "  http://127.0.0.1:8000"
Write-Host ""
Write-ColorOutput Yellow "Você pode acessar este endereço no seu navegador."
Write-Host ""
Write-ColorOutput Yellow "Pressione Ctrl+C para encerrar o servidor."
Write-Host ""

try {
    Set-Location -Path $PSScriptRoot
    flutter run -d web-server --web-port 8000 --web-hostname 127.0.0.1
} finally {
    # Clean up
    Write-ColorOutput Cyan "Encerrando o proxy..."
    Stop-Job $proxyJob
    Remove-Job $proxyJob
    Write-ColorOutput Green "Aplicação encerrada."
}
