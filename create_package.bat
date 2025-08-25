@echo off
echo ========================================
echo   CREADOR DE PAQUETE DE DISTRIBUCIÓN
echo ========================================
echo.

:: Crear carpeta de distribución
set PACKAGE_NAME=StreamlitApp_Portable
if exist "%PACKAGE_NAME%" rmdir /s /q "%PACKAGE_NAME%"
mkdir "%PACKAGE_NAME%"

echo [INFO] Copiando archivos de la aplicación...

:: Copiar archivos principales
copy "app.py" "%PACKAGE_NAME%\" >nul
xcopy "assets" "%PACKAGE_NAME%\assets\" /E /I /H /Y >nul 2>&1
xcopy "utils" "%PACKAGE_NAME%\utils\" /E /I /H /Y >nul 2>&1

:: Crear el instalador INSTALL.bat en el paquete
(
echo @echo off
echo setlocal EnableDelayedExpansion
echo.
echo echo ========================================
echo echo   INSTALADOR STREAMLIT APP PORTABLE
echo echo ========================================
echo echo.
echo echo [INFO] Este script instalará Python y todas las dependencias
echo echo [INFO] Requiere conexión a internet
echo echo.
echo pause
echo.
echo :: Variables de configuración
echo set PYTHON_VERSION=3.11.9
echo set PYTHON_URL=https://www.python.org/ftp/python/%%PYTHON_VERSION%%/python-%%PYTHON_VERSION%%-embed-amd64.zip
echo set PYTHON_DIR=%%~dp0python
echo set PYTHON_EXE=%%PYTHON_DIR%%\python.exe
echo set GET_PIP_URL=https://bootstrap.pypa.io/get-pip.py
echo.
echo :: Verificar si Python portable ya existe
echo if exist "%%PYTHON_EXE%%" ^(
echo     echo [INFO] Python portable ya está instalado
echo     goto :install_dependencies
echo ^)
echo.
echo echo [INFO] Descargando Python %%PYTHON_VERSION%% portable...
echo.
echo :: Crear directorio para Python
echo if not exist "%%PYTHON_DIR%%" mkdir "%%PYTHON_DIR%%"
echo.
echo :: Descargar Python portable
echo echo [INFO] Descargando Python... ^(esto puede tardar unos minutos^)
echo powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%%PYTHON_URL%%' -OutFile 'python.zip'"
echo.
echo if not exist "python.zip" ^(
echo     echo [ERROR] No se pudo descargar Python
echo     echo Verifica tu conexión a internet
echo     pause
echo     exit /b 1
echo ^)
echo.
echo :: Extraer Python
echo echo [INFO] Extrayendo Python...
echo powershell -Command "Expand-Archive -Path 'python.zip' -DestinationPath '%%PYTHON_DIR%%' -Force"
echo del python.zip
echo.
echo :: Configurar Python portable
echo echo [INFO] Configurando Python...
echo echo import sys ^> "%%PYTHON_DIR%%\sitecustomize.py"
echo echo sys.path.insert^(0, ''^) ^>^> "%%PYTHON_DIR%%\sitecustomize.py"
echo echo import site ^>^> "%%PYTHON_DIR%%\python311._pth"
echo echo site-packages ^>^> "%%PYTHON_DIR%%\python311._pth"
echo.
echo :: Instalar pip
echo echo [INFO] Instalando pip...
echo powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%%GET_PIP_URL%%' -OutFile 'get-pip.py'"
echo "%%PYTHON_EXE%%" get-pip.py --no-warn-script-location
echo del get-pip.py
echo.
echo :install_dependencies
echo echo [INFO] Instalando dependencias de la aplicación...
echo echo [INFO] Esto puede tardar varios minutos...
echo.
echo :: Lista de dependencias
echo set DEPS=streamlit^>=1.28.0 pandas^>=1.5.0 plotly^>=5.15.0 openpyxl^>=3.0.0 xlsxwriter^>=3.0.0 xlrd^>=2.0.0 numpy^>=1.24.0 pyarrow^>=10.0.0
echo.
echo for %%%%d in ^(%%DEPS%%^) do ^(
echo     echo [INFO] Instalando %%%%d...
echo     "%%PYTHON_EXE%%" -m pip install "%%%%d" --no-warn-script-location --quiet
echo     if !errorlevel! neq 0 ^(
echo         echo [ERROR] Error instalando %%%%d
echo         pause
echo         exit /b 1
echo     ^)
echo ^)
echo.
echo echo [OK] Todas las dependencias instaladas correctamente
echo.
echo :: Crear script de ejecución
echo echo [INFO] Creando script de ejecución...
echo ^(
echo echo @echo off
echo echo echo ========================================
echo echo echo       STREAMLIT APP
echo echo echo ========================================
echo echo echo.
echo echo echo [INFO] Iniciando aplicación...
echo echo echo [INFO] La aplicación se abrirá en tu navegador
echo echo echo [INFO] URL: http://localhost:8501
echo echo echo [INFO] Para cerrar: presiona Ctrl+C
echo echo echo.
echo echo "%%PYTHON_EXE%%" -m streamlit run app.py --server.port=8501 --server.address=localhost --server.headless=false
echo echo echo.
echo echo echo [INFO] Aplicación cerrada
echo echo pause
echo ^) ^> run_app.bat
echo.
echo echo [OK] Script 'run_app.bat' creado
echo.
echo echo ========================================
echo echo      ¡INSTALACIÓN COMPLETADA!
echo echo ========================================
echo echo.
echo echo Para ejecutar la aplicación:
echo echo.
echo echo   1. Doble click en 'run_app.bat'
echo echo   2. La aplicación se abrirá en tu navegador
echo echo   3. URL: http://localhost:8501
echo echo.
echo echo ¡La instalación ha terminado exitosamente!
echo echo.
echo pause
) > "%PACKAGE_NAME%\INSTALL.bat"

:: Crear README para el usuario
(
echo ========================================
echo       STREAMLIT APP PORTABLE
echo ========================================
echo.
echo INSTRUCCIONES DE INSTALACIÓN:
echo.
echo 1. PRIMERA VEZ - INSTALACIÓN:
echo    - Ejecuta 'INSTALL.bat'
echo    - Requiere conexión a internet
echo    - El proceso tarda 5-10 minutos
echo.
echo 2. USO DIARIO:
echo    - Ejecuta 'run_app.bat'
echo    - Se abre en: http://localhost:8501
echo.
echo REQUISITOS:
echo - Windows 10/11
echo - Conexión a internet ^(solo primera vez^)
echo - ~500MB espacio libre
echo.
echo SOLUCIÓN DE PROBLEMAS:
echo - Si falla la descarga: verificar internet
echo - Si no abre el navegador: ir a http://localhost:8501
echo - Para cerrar: Ctrl+C en la ventana negra
echo.
echo ARCHIVOS:
echo - INSTALL.bat    = Instalar ^(solo primera vez^)
echo - run_app.bat    = Ejecutar aplicación
echo - app.py         = Aplicación principal
echo - assets/        = Recursos de la aplicación
echo - utils/         = Utilidades
) > "%PACKAGE_NAME%\README.txt"

echo [OK] Paquete creado exitosamente en: %PACKAGE_NAME%\
echo.
echo [INFO] Contenido del paquete:
echo ========================================
dir "%PACKAGE_NAME%" /B
echo ========================================
echo.
echo [INFO] Para distribuir:
echo   1. Comprimir la carpeta '%PACKAGE_NAME%' en ZIP
echo   2. Enviar el archivo ZIP al usuario
echo   3. Usuario descomprime y ejecuta INSTALL.bat
echo.
echo ¿Quieres comprimir automáticamente en ZIP? (S/N)
set /p COMPRESS=
if /i "%COMPRESS%"=="S" (
    echo [INFO] Comprimiendo en ZIP...
    powershell -Command "Compress-Archive -Path '%PACKAGE_NAME%' -DestinationPath '%PACKAGE_NAME%.zip' -Force"
    echo [OK] Archivo creado: %PACKAGE_NAME%.zip
    echo [INFO] ¡Listo para distribuir!
)
echo.
pause
