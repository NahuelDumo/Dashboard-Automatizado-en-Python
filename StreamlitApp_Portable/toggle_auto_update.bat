@echo off
chcp 65001 >nul

echo ========================================
echo    CONFIGURACIÓN AUTO UPDATE
echo ========================================
echo.
echo.
set AUTO_UPDATE_FILE=%~dp0auto_update.txt
set STATUS=false

if exist "%AUTO_UPDATE_FILE%" (
    set /p STATUS=<"%AUTO_UPDATE_FILE%"
)

if /i ""=="true" (
    echo [INFO] Estado actual: HABILITADO
    echo.
    set /p CONFIRM="¿Deseas DESHABILITAR auto update? ^(S/N^): "
    if /i ""=="S" (
        echo false > "%AUTO_UPDATE_FILE%"
        echo.
        echo [OK] Auto update DESHABILITADO
    )
) else (
    echo [INFO] Estado actual: DESHABILITADO  
    echo.
    set /p CONFIRM="¿Deseas HABILITAR auto update? ^(S/N^): "
    if /i ""=="S" (
        echo true > "%AUTO_UPDATE_FILE%"
        echo.
        echo [OK] Auto update HABILITADO
    )
)

pause
