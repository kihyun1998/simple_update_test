@echo off
setlocal enabledelayedexpansion

REM Flutter 프로젝트 경로 설정
set "PROJECT_PATH=C:\simple_update_test"

REM hash-maker 경로 설정
set "HASH_MAKER_PATH=C:\Users\User\go\src\hash-maker\hash-maker.exe"

REM 추가할 파일 경로 설정
set "UPDATER_PATH=C:\Users\User\go\src\fync-updater\updater.exe"

REM 사용자 지정 ZIP 파일 이름 (인자로 받음)
set "CUSTOM_ZIP_NAME=%*"

REM Ensure the full argument is captured and spaces are handled properly
set "CUSTOM_ZIP_NAME=!CUSTOM_ZIP_NAME:"=!"

echo Current directory: %CD%
echo Project path: %PROJECT_PATH%
echo Hash-maker path: %HASH_MAKER_PATH%
echo Additional file path: %UPDATER_PATH%

REM 프로젝트 디렉토리로 이동
echo Changing directory to %PROJECT_PATH%
cd /d "%PROJECT_PATH%"
if %ERRORLEVEL% neq 0 (
    echo Failed to change directory. Error code: %ERRORLEVEL%
    exit /b %ERRORLEVEL%
)
echo Current directory after change: %CD%

REM Flutter 빌드 명령어 실행
echo Building Flutter Windows app...
call flutter build windows --release
if %ERRORLEVEL% neq 0 (
    echo Flutter build failed. Error code: %ERRORLEVEL%
    exit /b %ERRORLEVEL%
)
echo Flutter build completed successfully.

REM 빌드 결과물 디렉토리 설정
set "BUILD_DIR=%PROJECT_PATH%\build\windows\x64\runner\Release\."
echo Build directory: %BUILD_DIR%
if not exist "%BUILD_DIR%" (
    echo Build directory does not exist: %BUILD_DIR%
    exit /b 1
)
dir "%BUILD_DIR%"

REM 업데이트 exe 파일 복사
echo Copying updater file to build directory...
copy "%UPDATER_PATH%" "%BUILD_DIR%"
if %ERRORLEVEL% neq 0 (
    echo Failed to copy updater file. Error code: %ERRORLEVEL%
    exit /b %ERRORLEVEL%
)
echo Updater file copied successfully.

REM ZIP 파일 이름 설정
if not "!CUSTOM_ZIP_NAME!"=="" (
    set "FILENAME=!CUSTOM_ZIP_NAME!.zip"
) else (
    for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
    set "FILENAME=flutter_windows_build_%datetime:~0,8%_%datetime:~8,6%.zip"
)
echo Output filename: "!FILENAME!"


REM hash-maker를 사용하여 빌드 결과물의 해시 생성
echo Generating hash for build output...
"%HASH_MAKER_PATH%" -startPath "%BUILD_DIR%"
if %ERRORLEVEL% neq 0 (
    echo Failed to generate hash. Error code: %ERRORLEVEL%
    exit /b %ERRORLEVEL%
)
echo Hash generation completed successfully.

REM hash-maker로 zip파일 생성
echo Compressing build output to "!FILENAME!" using hash-maker...
"%HASH_MAKER_PATH%" -zipfolder "%BUILD_DIR%" -zipname "!FILENAME!" -zipoutput "%PROJECT_PATH%"

if %ERRORLEVEL% neq 0 (
    echo Failed to generate hash and create ZIP. Error code: %ERRORLEVEL%
    exit /b %ERRORLEVEL%
)
echo ZIP file created successfully: "!FILENAME!"

REM hash-maker를 사용하여 ZIP 파일의 해시 생성
echo Generating hash for ZIP file...
"%HASH_MAKER_PATH%" -zip -zipPath "!FILENAME!"
if %ERRORLEVEL% neq 0 (
    echo Failed to generate hash for ZIP. Error code: %ERRORLEVEL%
    exit /b %ERRORLEVEL%
)
echo Hash generation for ZIP completed successfully.
exit /b 0
