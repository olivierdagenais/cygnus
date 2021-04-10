@ECHO OFF
REM -- Automates Cygwin installation
REM -- See README.md file for history and details
 
SETLOCAL
 
REM -- Change to the directory of the executing batch file
CD /D %~dp0

REM -- Download the Cygwin installer
IF NOT EXIST cygwin-setup.exe (
	ECHO cygwin-setup.exe NOT found! Downloading installer...
	bitsadmin /transfer cygwinDownloadJob /download /priority high https://cygwin.com/setup-x86_64.exe %CD%\\cygwin-setup.exe
) ELSE (
	ECHO cygwin-setup.exe found! Skipping installer download...
)
 
REM -- Configure our paths
SET SITE=https://mirror.csclub.uwaterloo.ca/cygwin/
SET LOCALDIR=%CD%
SET ROOTDIR=C:/cygwin
 
REM -- These are the packages we will install (in addition to the default packages)
SET PACKAGES=mintty,wget,ctags,diffutils,git,git-completion,git-svn,stgit,mercurial
REM -- These are necessary for apt-cyg install, do not change. Any duplicates will be ignored.
SET PACKAGES=%PACKAGES%,wget,tar,gawk,bzip2,subversion
 
REM -- More info on command line options at: https://cygwin.com/faq/faq.html#faq.setup.cli
REM -- Do it!
ECHO *** INSTALLING DEFAULT PACKAGES
cygwin-setup --quiet-mode --no-desktop --download --local-install --no-verify --site %SITE% --local-package-dir "%LOCALDIR%" --root "%ROOTDIR%"
ECHO.
ECHO.
ECHO *** INSTALLING CUSTOM PACKAGES
cygwin-setup -q -d -D -L -X -s %SITE% -l "%LOCALDIR%" -R "%ROOTDIR%" -P %PACKAGES%
 
REM -- Show what we did
ECHO.
ECHO.
ECHO cygwin installation updated
ECHO  - %PACKAGES%
ECHO.

ECHO apt-cyg installing.
set PATH=%ROOTDIR%/bin;%PATH%
%ROOTDIR%/bin/bash.exe -c 'svn --force export http://apt-cyg.googlecode.com/svn/trunk/ /bin/'
%ROOTDIR%/bin/bash.exe -c 'chmod +x /bin/apt-cyg'
ECHO apt-cyg installed if it says somin like "A    /bin" and "A   /bin/apt-cyg" and "Exported revision 18" or some other number.

ENDLOCAL
 
PAUSE
EXIT /B 0
