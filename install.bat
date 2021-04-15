@ECHO OFF
REM -- Automates Cygwin installation
REM -- See README.md file for history and details
 
SETLOCAL
 
REM -- Change to the directory of the executing batch file
CD /D %~dp0

REM -- Configure our paths
SET SITE=https://mirror.csclub.uwaterloo.ca/cygwin/
SET ROOTDIR=C:\cygwin
SET LOCALDIR=%ROOTDIR%\dist

IF NOT EXIST "%ROOTDIR%" (
	MKDIR "%ROOTDIR%"
)

REM -- Download the Cygwin installer
SET SETUP_PATH=%ROOTDIR%\setup-x86_64.exe
IF NOT EXIST "%SETUP_PATH%" (
	ECHO %SETUP_PATH% NOT found! Downloading installer...
	bitsadmin /transfer cygwinDownloadJob /download /priority high https://cygwin.com/setup-x86_64.exe "%SETUP_PATH%"
) ELSE (
	ECHO %SETUP_PATH% found! Skipping installer download...
)
 
REM -- These are the packages we will install (in addition to the default packages)
SET PACKAGES=mintty,wget,ctags,diffutils,git,git-completion
REM -- These are necessary for apt-cyg install, do not change. Any duplicates will be ignored.
SET PACKAGES=%PACKAGES%,wget,tar,gawk,bzip2
 
REM -- More info on command line options at: https://cygwin.com/faq/faq.html#faq.setup.cli
REM -- Do it!
ECHO *** INSTALLING DEFAULT PACKAGES
"%SETUP_PATH%" --quiet-mode --no-desktop --download --local-install --no-verify --site %SITE% --local-package-dir "%LOCALDIR%" --root "%ROOTDIR%" --packages %PACKAGES%

REM -- Show what we did
ECHO.
ECHO.
ECHO cygwin installation updated
ECHO  - %PACKAGES%
ECHO.

ECHO apt-cyg installing.
"%ROOTDIR%/bin/wget" https://raw.githubusercontent.com/transcode-open/apt-cyg/master/apt-cyg --output-document=/bin/apt-cyg
"%ROOTDIR%/bin/chmod" +x /bin/apt-cyg
ECHO apt-cyg installed

ENDLOCAL
EXIT /B 0
