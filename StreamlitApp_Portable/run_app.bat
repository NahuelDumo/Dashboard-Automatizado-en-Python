@echo off
chcp 65001 >nul

echo ========================================
echo       STREAMLIT APP LAUNCHER
echo ========================================
echo.

if not exist "python\python.exe" (
    echo [ERROR] Python no está instalado.
    echo.
    echo Por favor ejecuta install.bat primero para instalar
    echo Python y todas las dependencias necesarias.
    echo.
    pause
    exit /b 1
)

if not exist "app.py" (
    echo [ERROR] No se encontró el archivo app.py
    echo.
    echo Asegúrate de estar en el directorio correcto
    echo y que el archivo app.py esté presente.
    echo.
    pause  
    exit /b 1
)

echo [INFO] Iniciando aplicación Streamlit...
echo [INFO] La aplicación se abrirá en: http://localhost:8501
echo [INFO] Presiona Ctrl+C en esta ventana para detener la aplicación
echo.
echo ¡Espera unos segundos mientras se carga la aplicación
echo.
echo.
"python\python.exe" -m streamlit run app.py --server.port=8501 --server.headless=true

echo.
echo Aplicación finalizada.
pause
