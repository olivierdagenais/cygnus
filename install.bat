@ECHO OFF
REM -- Automates Cygwin installation
REM -- See README.md file for history and details
 
SETLOCAL EnableDelayedExpansion
 
REM -- Change to the directory of the executing batch file
CD /D %~dp0

REM -- Configure our paths
SET SITE=https://mirror.csclub.uwaterloo.ca/cygwin/
SET ROOTDIR=C:\cygwin
SET LOCALDIR=%ROOTDIR%\dist

IF NOT EXIST "%ROOTDIR%" (
	MKDIR "%ROOTDIR%"
)

SET SETUP_PATH=%ROOTDIR%\setup-x86_64.exe
IF NOT EXIST "%SETUP_PATH%" (
	ECHO *** Downloading Cygwin installer...
	bitsadmin /transfer cygwinDownloadJob /download /priority foreground https://cygwin.com/setup-x86_64.exe "%SETUP_PATH%"
	ECHO *** Cygwin installer downloaded.
)
 
SET PACKAGES=cygwin
IF EXIST "%~dp0packages.txt" (
	ECHO *** Loading packages from %~dp0packages.txt...
	FOR /F "eol=#" %%i in (%~dp0packages.txt) do (
		SET PACKAGES=!PACKAGES!,%%i
	)
	ECHO *** Packages from %~dp0packages.txt loaded.
)
REM -- These are necessary for apt-cyg install, do not change. Any duplicates will be ignored.
SET PACKAGES=%PACKAGES%,wget,tar,gawk,bzip2

REM -- More info on command line options at: https://cygwin.com/faq/faq.html#faq.setup.cli
ECHO *** Installing Cygwin and packages...
"%SETUP_PATH%" --quiet-mode --no-desktop --download --local-install --site %SITE% --local-package-dir "%LOCALDIR%" --root "%ROOTDIR%" --packages %PACKAGES%

ECHO.
ECHO.
ECHO *** Cygwin and packages installed.
ECHO *** Packages: %PACKAGES%
ECHO.

REM TODO: Fetch and decode PROFILES_DIR.
REM `"%ROOTDIR%/bin/regtool" get "/HKLM/Software/Microsoft/Windows NT/CurrentVersion/ProfileList/ProfilesDirectory"`
REM ...might give us something like "%SystemDrive%\Users" which would have to be expanded
SET PROFILES_DIR=C:\Users

IF NOT EXIST "%ROOTDIR%\home.old" (
	ECHO *** Creating junction /home -^> %PROFILES_DIR%...
	MOVE "%ROOTDIR%\home" "%ROOTDIR%\home.old"
	MKLINK /J "%ROOTDIR%\home" "%PROFILES_DIR%"
	ECHO *** Junction /home -^> %PROFILES_DIR% created.
)

ECHO *** Installing apt-cyg...
"%ROOTDIR%/bin/wget" https://raw.githubusercontent.com/transcode-open/apt-cyg/master/apt-cyg --output-document=/bin/apt-cyg
"%ROOTDIR%/bin/chmod" +x /bin/apt-cyg
ECHO *** apt-cyg installed.

ENDLOCAL
EXIT /B 0
