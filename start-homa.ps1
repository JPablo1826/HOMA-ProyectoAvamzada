#Requires -Version 5.1

<#
.SYNOPSIS
    Inicia HOMA (Backend + Frontend) en Windows para desarrollo local
.DESCRIPTION
    Inicia automaticamente el backend Spring Boot y el frontend Angular
    en ventanas de PowerShell separadas. Verifica requisitos y que 
    MariaDB este corriendo en localhost:3306.
.EXAMPLE
    .\start-homa.ps1
.NOTES
    Requisitos: Java 17+, Node.js 18+, MariaDB corriendo en localhost:3306
#>

[CmdletBinding()]
param()

# ============ CONFIGURACION ============
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$backendPath = Join-Path $projectRoot "Homa"
$frontendPath = Join-Path $projectRoot "frontend"
$backendWaitTime = 45
$frontendWaitTime = 5
$closeDelay = 10

# ============ FUNCIONES ============

function Test-Java {
    try {
        $output = java -version 2>&1
        $versionLine = $output | Select-String "version" | Select-Object -First 1
        if ($versionLine -match '"(\d+)\.') {
            $majorVersion = [int]$Matches[1]
            if ($majorVersion -ge 17) {
                return $true
            } else {
                Write-Host "ERROR: Se requiere Java 17 o superior. Version detectada: $majorVersion"
                return $false
            }
        }
        return $false
    } catch {
        Write-Host "ERROR: Java no esta instalado o no esta en el PATH del sistema"
        return $false
    }
}

function Test-NodeJs {
    try {
        $version = node --version 2>$null
        if ($version -match 'v(\d+)') {
            $majorVersion = [int]$Matches[1]
            if ($majorVersion -ge 18) {
                return $true
            } else {
                Write-Host "ADVERTENCIA: Node.js 18+ recomendado. Version actual: $version"
                return $true
            }
        }
        return $false
    } catch {
        Write-Host "ERROR: Node.js no esta instalado o no esta en el PATH del sistema"
        return $false
    }
}

function Test-MariaDB {
    try {
        $connection = Test-NetConnection -ComputerName localhost -Port 3306 -WarningAction SilentlyContinue
        if ($connection.TcpTestSucceeded) {
            return $true
        } else {
            Write-Host "ERROR: MariaDB no esta respondiendo en localhost:3306"
            Write-Host "Por favor asegurate de que MariaDB este corriendo antes de ejecutar este script"
            Write-Host "Puedes usar XAMPP, el servicio de MariaDB, o Docker"
            return $false
        }
    } catch {
        Write-Host "ERROR: No se pudo verificar la conexion a MariaDB"
        return $false
    }
}

function Clear-Port {
    param([int]$Port)
    
    try {
        $connection = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
        if ($connection) {
            $processId = $connection.OwningProcess
            $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
            if ($process) {
                Write-Host "Puerto $Port ocupado por proceso: $($process.ProcessName) (PID: $processId). Deteniendo..."
                Stop-Process -Id $processId -Force
                Start-Sleep -Seconds 2
                Write-Host "Puerto $Port liberado"
            }
        }
    } catch {
        # Puerto libre, no hacer nada
    }
}

function Start-BackendService {
    Write-Host "Iniciando servicio backend en nueva ventana..."
    
    $arguments = @(
        "-NoExit"
        "-Command"
        "cd '$backendPath'; Write-Host 'Iniciando Backend Spring Boot...'; .\gradlew.bat bootRun --args='--spring.profiles.active=local'"
    )
    
    $process = Start-Process powershell -ArgumentList $arguments -PassThru
    return $process
}

function Start-FrontendService {
    Write-Host "Iniciando servicio frontend en nueva ventana..."
    
    # Verificar si existe node_modules
    $nodeModulesPath = Join-Path $frontendPath "node_modules"
    if (-not (Test-Path $nodeModulesPath)) {
        Write-Host "Instalando dependencias de Node.js (primera ejecucion)..."
        $installArguments = @(
            "-NoExit"
            "-Command"
            "cd '$frontendPath'; npm install; npm start"
        )
        $process = Start-Process powershell -ArgumentList $installArguments -PassThru
    } else {
        $arguments = @(
            "-NoExit"
            "-Command"
            "cd '$frontendPath'; npm start"
        )
        $process = Start-Process powershell -ArgumentList $arguments -PassThru
    }
    
    return $process
}

# ============ EJECUCION PRINCIPAL ============

Write-Host "========================================"
Write-Host "   INICIANDO HOMA EN WINDOWS"
Write-Host "========================================"
Write-Host ""

# 1. Verificar Java
Write-Host "Verificando Java..."
if (-not (Test-Java)) {
    Write-Host ""
    Write-Host "Presiona cualquier tecla para salir..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# 2. Verificar Node.js
Write-Host "Verificando Node.js..."
if (-not (Test-NodeJs)) {
    Write-Host ""
    Write-Host "Presiona cualquier tecla para salir..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# 3. Verificar MariaDB
Write-Host "Verificando MariaDB en localhost:3306..."
if (-not (Test-MariaDB)) {
    Write-Host ""
    Write-Host "Presiona cualquier tecla para salir..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# 4. Verificar y liberar puertos
Write-Host "Verificando puertos 8080 y 4200..."
Clear-Port -Port 8080
Clear-Port -Port 4200
Write-Host "Puertos verificados"

# 5. Iniciar Backend
Write-Host ""
Write-Host "Iniciando Backend..."
$backendProcess = Start-BackendService
Write-Host "Backend iniciando en proceso: $($backendProcess.Id)"
Write-Host "Esperando $backendWaitTime segundos para que el backend este listo..."
Start-Sleep -Seconds $backendWaitTime

# 6. Iniciar Frontend
Write-Host ""
Write-Host "Iniciando Frontend..."
$frontendProcess = Start-FrontendService
Write-Host "Frontend iniciando en proceso: $($frontendProcess.Id)"
Write-Host "Esperando $frontendWaitTime segundos..."
Start-Sleep -Seconds $frontendWaitTime

# 7. Mostrar informacion final
Write-Host ""
Write-Host "========================================"
Write-Host "   HOMA ESTA CORRIENDO"
Write-Host "========================================"
Write-Host ""
Write-Host "Accesos:"
Write-Host "   Frontend: http://localhost:4200"
Write-Host "   Backend:  http://localhost:8080"
Write-Host "   API Docs: http://localhost:8080/swagger-ui.html"
Write-Host ""
Write-Host "Usuarios de prueba:"
Write-Host "   Admin:       admin@homa.com / admin123"
Write-Host "   Huesped:     huesped1@homa.com / huesped123"
Write-Host "   Anfitrion:   anfitrion1@homa.com / anfitrion123"
Write-Host ""
Write-Host "Para detener:"
Write-Host "   Cierra las ventanas de PowerShell del Backend y Frontend"
Write-Host "   O presiona Ctrl+C en cada ventana"
Write-Host ""
Write-Host "========================================"
Write-Host ""

# 8. Cierre automatico
Write-Host "Este mensaje se cerrara automaticamente en $closeDelay segundos..."
Start-Sleep -Seconds $closeDelay
