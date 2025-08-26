@echo off
setlocal EnableDelayedExpansion

echo ========================================
echo   INSTALADOR STREAMLIT APP PORTABLE
echo ========================================
echo.
echo [INFO] Este script instalará Python y todas las dependencias
echo [INFO] Requiere conexión a internet
echo.
pause

:: Variables de configuración
set PYTHON_VERSION=3.11.9
set PYTHON_URL=https://www.python.org/ftp/python/%PYTHON_VERSION%/python-%PYTHON_VERSION%-embed-amd64.zip
set PYTHON_DIR=%~dp0python
set PYTHON_EXE=%PYTHON_DIR%\python.exe
set GET_PIP_URL=https://bootstrap.pypa.io/get-pip.py

:: Verificar si Python portable ya existe
if exist "%PYTHON_EXE%" (
    echo [INFO] Python portable ya está instalado
    goto :install_dependencies
)

echo [INFO] Descargando Python %PYTHON_VERSION% portable...

:: Crear directorio para Python
if not exist "%PYTHON_DIR%" mkdir "%PYTHON_DIR%"

:: Descargar Python portable
echo [INFO] Descargando Python... (esto puede tardar unos minutos)
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%PYTHON_URL%' -OutFile 'python.zip'"

if not exist "python.zip" (
    echo [ERROR] No se pudo descargar Python
    echo Verifica tu conexión a internet
    pause
    exit /b 1
)

:: Extraer Python
echo [INFO] Extrayendo Python...
powershell -Command "Expand-Archive -Path 'python.zip' -DestinationPath '%PYTHON_DIR%' -Force"
del python.zip

:: Configurar Python portable
echo [INFO] Configurando Python...
echo import sys > "%PYTHON_DIR%\sitecustomize.py"
echo sys.path.insert(0, '') >> "%PYTHON_DIR%\sitecustomize.py"
echo import site >> "%PYTHON_DIR%\python311._pth"
echo site-packages >> "%PYTHON_DIR%\python311._pth"

:: Instalar pip
echo [INFO] Instalando pip...
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%GET_PIP_URL%' -OutFile 'get-pip.py'"
"%PYTHON_EXE%" get-pip.py --no-warn-script-location
del get-pip.py

:install_dependencies
echo [INFO] Instalando dependencias de la aplicación...
echo [INFO] Esto puede tardar varios minutos...

:: Lista de dependencias
set DEPS=streamlit>=1.28.0 pandas>=1.5.0 plotly>=5.15.0 openpyxl>=3.0.0 xlsxwriter>=3.0.0 xlrd>=2.0.0 numpy>=1.24.0 pyarrow>=10.0.0 

for %%d in (%DEPS%) do (
    echo [INFO] Instalando %%d...
    "%PYTHON_EXE%" -m pip install "%%d" --no-warn-script-location --quiet
    if !errorlevel! neq 0 (
        echo [ERROR] Error instalando %%d
        pause
        exit /b 1
    )
)

echo [OK] Todas las dependencias instaladas correctamente

:: Crear script de ejecución
