#!/bin/bash
echo '----------------------------------------------------'
echo '         FreeOrion Mac OSX SDK bootstrapper         '
echo '----------------------------------------------------'
echo 'For help on compiling FreeOrion have a look at the Wiki:'
echo 'http://freeorion.org/index.php/Compile_In_Mac_OS_X'
echo 'Note: You need to have Xcode 5 or later installed to use the SDK'
echo '------------------------------------------------'
echo 'Cloning the FreeOrion repository from GitHub...'
cd "$(dirname "$0")"
git clone https://github.com/freeorion/freeorion.git temp
mv temp/* ./
mv temp/.git* ./
rmdir temp
echo 'Done.'
echo '------------------------------------------------'
echo 'Unzipping dependencies...'
tar -xyf dep.tar.bz2 -C Xcode
echo 'Done.'
echo 'Removing archive...'
rm dep.tar.bz2
echo '------------------------------------------------'
echo 'To update your clone of the repo later use your git client'
echo 'The Xcode project is located at:'
echo "$(dirname "$0")/Xcode/FreeOrion.xcodeproj"
echo 'now. Have fun while developing! :D'
rm bootstrap.command
