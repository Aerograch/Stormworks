@echo off
chcp 1251
REM ===== ПУТЬ К ВАШЕМУ РЕПОЗИТОРИЮ =====
cd /d "E:\Stormworks"

REM ===== ПРОВЕРКА GIT =====
git --version >nul 2>&1
if errorlevel 1 (
    echo Git не найден. Убедитесь, что Git установлен и добавлен в PATH.
    pause
    exit /b
)

REM ===== ДОБАВЛЕНИЕ ФАЙЛОВ =====
git add .

REM ===== КОММИТ =====
set msg=Auto update %date% %time%
git commit -m "%msg%"

REM ===== ОТПРАВКА В GITHUB =====
git push

REM ===== ЗАВЕРШЕНИЕ =====
echo Репозиторий успешно обновлён.
pause
