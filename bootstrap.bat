@echo off
echo ----------------------------------------------------
echo          FreeOrion Windows SDK bootstrapper
echo ----------------------------------------------------
echo For help on compiling FreeOrion have a look at the Wiki:
echo http://freeorion.org/index.php/Compile_In_Windows
echo Note: You need to have MSVC 2017 or 2019 installed to use
echo the SDK
echo ----------------------------------------------------
echo Cloning the FreeOrion repository from GitHub...
cd "%~d0%~p0"
git clone https://github.com/freeorion/freeorion.git FreeOrion
move bin\* FreeOrion\ > NUL
rmdir bin
echo Done.
echo ----------------------------------------------------
echo To update your clone of the repo later use your git client
echo The MSVC 2017 solution is located at:
echo %~d0%~p0FreeOrion\msvc2017\FreeOrion.sln
echo now. Have fun while developing! :D
pause
del bootstrap.bat
