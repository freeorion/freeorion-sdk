@echo off
echo ----------------------------------------------------
echo          FreeOrion Windows SDK bootstrapper
echo ----------------------------------------------------
echo For help on compiling FreeOrion, look at at BUILD.md in
echo the FreeOrion repository root directory.
echo Note: You need to have MSVC 2019 or 2022 installed to use
echo the SDK to build FreeOrion.
echo ----------------------------------------------------
echo Cloning the FreeOrion repository from GitHub...
cd "%~d0%~p0"
git clone https://github.com/freeorion/freeorion.git FreeOrion
move bin\* FreeOrion\ > NUL
rmdir bin
echo Done.
echo ----------------------------------------------------
echo To update your clone of the repo later use your git client
echo The MSVC 2019 solution is located at:
echo %~d0%~p0FreeOrion\msvc2019\FreeOrion.sln
echo now. Have fun while developing! :D
pause
del bootstrap.bat
