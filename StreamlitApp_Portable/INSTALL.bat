@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

echo.
echo ========================================
echo   INSTALADOR STREAMLIT APP PORTABLE
echo ========================================
echo.
echo [INFO] Este proceso instalará Python portable y todas las dependencias
echo Asegúrate de tener conexión a internet
echo.
echo Presiona cualquier tecla para continuar...
pause >nul
echo.

set PYTHON_VERSION=3.11.9
set PYTHON_URL=https://www.python.org/ftp/python/%PYTHON_VERSION%/python-%PYTHON_VERSION%-embed-amd64.zip
set PYTHON_DIR=%~dp0python
set PYTHON_EXE=%PYTHON_DIR%\python.exe
set GET_PIP_URL=https://bootstrap.pypa.io/get-pip.py

echo [INFO] Verificando instalación de Python...
if exist "%PYTHON_EXE%" (
    echo [INFO] Python portable ya está instalado
    goto :install_deps
)

echo [INFO] Creando directorio para Python...
if not exist "%PYTHON_DIR%" mkdir "%PYTHON_DIR%"

echo [INFO] Descargando Python %PYTHON_VERSION%...
powershell -Command "try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%PYTHON_URL%' -OutFile 'python.zip' -UseBasicParsing; Write-Host 'Descarga completada' } catch { Write-Host 'Error en descarga: '$_.Exception.Message; exit 1 }"
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Falló la descarga de Python
    pause
    exit /b 1
)

echo [INFO] Extrayendo Python...
powershell -Command "try { Expand-Archive -Path 'python.zip' -DestinationPath '%PYTHON_DIR%' -Force; Remove-Item 'python.zip' -Force; Write-Host 'Extracción completada' } catch { Write-Host 'Error extrayendo: '$_.Exception.Message; exit 1 }"

echo [INFO] Configurando Python portable...
echo import site >> "%PYTHON_DIR%\python311._pth"
echo site-packages >> "%PYTHON_DIR%\python311._pth"

echo [INFO] Descargando e instalando pip...
powershell -Command "try { Invoke-WebRequest -Uri '%GET_PIP_URL%' -OutFile 'get-pip.py' -UseBasicParsing; Write-Host 'pip descargado' } catch { Write-Host 'Error descargando pip: '$_.Exception.Message; exit 1 }"
"%PYTHON_EXE%" get-pip.py --quiet --no-warn-script-location
del get-pip.py

:install_deps
echo [INFO] Instalando dependencias de Streamlit...
echo   → streamlit
"%PYTHON_EXE%" -m pip install streamlit>=1.28.0 --quiet --disable-pip-version-check --no-warn-script-location
echo   → pandas
"%PYTHON_EXE%" -m pip install pandas>=1.5.0 --quiet --disable-pip-version-check --no-warn-script-location
echo   → plotly
"%PYTHON_EXE%" -m pip install plotly>=5.15.0 --quiet --disable-pip-version-check --no-warn-script-location
echo   → openpyxl
"%PYTHON_EXE%" -m pip install openpyxl>=3.0.0 --quiet --disable-pip-version-check --no-warn-script-location
echo   → xlsxwriter
"%PYTHON_EXE%" -m pip install xlsxwriter>=3.0.0 --quiet --disable-pip-version-check --no-warn-script-location
echo   → xlrd
"%PYTHON_EXE%" -m pip install xlrd>=2.0.0 --quiet --disable-pip-version-check --no-warn-script-location
echo   → numpy
"%PYTHON_EXE%" -m pip install numpy>=1.24.0 --quiet --disable-pip-version-check --no-warn-script-location
echo   → pyarrow
"%PYTHON_EXE%" -m pip install pyarrow>=10.0.0 --quiet --disable-pip-version-check --no-warn-script-location
echo   → requests
"%PYTHON_EXE%" -m pip install requests>=2.28.0 --quiet --disable-pip-version-check --no-warn-script-location
echo   → kaleido (para exportar gráficos)
"%PYTHON_EXE%" -m pip install kaleido --quiet --disable-pip-version-check --no-warn-script-location

echo [OK] ¡Instalación completada exitosamente
echo.
echo Para ejecutar la aplicación, usa: run_app.bat
echo La aplicación se abrirá en: http://localhost:8501
echo.
pause
