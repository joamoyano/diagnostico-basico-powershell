# === Configuración de log ===
$fecha = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$logDir = "$PSScriptRoot\logs"
$logFile = "$logDir\diagnostico_$fecha.txt"

# Crear carpeta de logs
if (!(Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir | Out-Null
}

# Función compatible y sin emojis ni acentos
function Escribir-Log {
    param([string]$linea)

    Write-Output $linea
    $utf8 = New-Object System.Text.UTF8Encoding($true)
    [System.IO.File]::AppendAllText($logFile, "$linea`r`n", $utf8)
}

# Encabezado
Escribir-Log "Diagnostico basico - $fecha"
Escribir-Log "------------------------------------------"

# Servicios a revisar
$servicios = @("ZabbixAgent", "Spooler", "wuauserv")
Escribir-Log "`nEstado de servicios:"
foreach ($s in $servicios) {
    try {
        $estado = Get-Service -Name $s -ErrorAction Stop
        Escribir-Log "$($estado.DisplayName): $($estado.Status)"
    } catch {
        Escribir-Log "${s}: No encontrado o sin permisos."
    }
}

# Uso de disco
Escribir-Log "`nUso del disco:"
$unidadC = Get-PSDrive C
$totalGB = "{0:N2}" -f (($unidadC.Used + $unidadC.Free) / 1GB)
$usadoGB = "{0:N2}" -f ($unidadC.Used / 1GB)
$libreGB = "{0:N2}" -f ($unidadC.Free / 1GB)
Escribir-Log "C:\ Total: $totalGB GB | Usado: $usadoGB GB | Libre: $libreGB GB"

# Conectividad
Escribir-Log "`nConectividad:"
$hosts = @("8.8.8.8", "www.google.com")
foreach ($h in $hosts) {
    if (Test-Connection -ComputerName $h -Count 2 -Quiet) {
        Escribir-Log "{h}: OK"
    } else {
        Escribir-Log "{h}: SIN RESPUESTA"
    }
}

# Uptime
Escribir-Log "`nUptime del sistema:"
$uptime = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
Escribir-Log "Uptime: $($uptime.Days) dias, $($uptime.Hours) hs, $($uptime.Minutes) min"

# Final
Escribir-Log "`nLog guardado en: $logFile"
