@echo off
REM ============================================================================
REM ONE-CLICK GITHUB PUSH SCRIPT FOR VINIPOLY DRM (WINDOWS CMD / POWERSHELL)
REM ============================================================================
echo ==================================================================
echo   VINIPOLY DRM - GITHUB REPOSITORY PUBLISHER (WINDOWS)
echo ==================================================================

set REPO_URL=%~1
if "%REPO_URL%"=="" (
    set /p REPO_URL="Nhap link kho GitHub cua ban (VD: https://github.com/username/vinipoly-drm.git): "
)

if "%REPO_URL%"=="" (
    echo [Loi] Ban chua nhap URL kho GitHub.
    pause
    exit /b 1
)

if not exist ".git" (
    git init
    git branch -M main
)

git add .
git commit -m "feat: release ViniPoly DRM Enterprise PHP Protection Suite & Bilingual Docs (v1.1.3)" 2>nul

git remote remove origin 2>nul
git remote add origin "%REPO_URL%"
git branch -M main

echo Dang day len GitHub: %REPO_URL% ...
git push -u origin main

echo ==================================================================
echo   HOAN TAT! Kho GitHub ViniPoly DRM da duoc day thanh cong.
echo ==================================================================
pause
