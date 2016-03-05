Welcome to FreeOrion development!

There are two routes to get started on Windows: The MSVC project files, and CMake

Both:
=====

For any FreeOrion development, you will need Git installed.  There are command-line and GUI clients available.  The main Git website is:

http://git-scm.com

Here you can find a list of available GUI clients:

http://git-scm.com/downloads/guis

This SDK contains dependencies that are required to build FreeOrion, but does not contain any FreeOrion code.  To set up the SDK, run the bootstrap.bat batch file contained in the root directory of the SDK (this is the same directory that also conatins this README).

IMPORTANT: Before you run bootstrap.bat, you need to install the Git command line client.  Be sure that the main git executable is included in your patch, otherwise bootstrap.bat will fail.

Executing bootstrap.bat will download the source code (more precisely, it will clone the git repository and checkout the initial working copy) and initialize the SDK properly so you can build FreeOrion yourself. The batch file will delete itself after completion.


MSVC Project Files:
===================

Open the .sln solution file in the msvc2013 directory and build solution.  All the dependencies should be in preconfigured locations within the SDK directories.


CMake:
======

Download an install CMake from http://www.cmake.org/

Running the CMake GUI will allow you to specify the locations of various dependencies, all of which should be available in the FreeOrion SDK directories.  When all dependencies are specified, CMake will generate an MSVS solution file which can be opened and used to build FreeOrion.


Dependencies Included:
======================

The FreeOrion MSVC 2013 contains precompiled software dependencies so you don't have to compile them yourself, and in particular don't have to worry about making them all inter-compatible. The following software versions are included:

Dependency Versions Included:

Boost 1.58          - http://www.boost.org/users/history/version_1_58_0.html
freealut 1.1.0      - http://slackbuilds.org/repository/12.2/libraries/freealut/
FreeImage 3.17.0    - http://freeimage.sourceforge.net/download.html
FreeType 2.5.5      - http://www.freetype.org/download.html
GLEW 1.12.0         - http://glew.sourceforge.net/
libogg 1.3.2        - https://xiph.org/downloads/
libvorbis 1.3.5     - https://xiph.org/downloads/
OpenAL-Soft 1.15.1  - http://sourceforge.net/projects/openal-soft/files/openal-soft/
libpng 1.6.17       - http://www.libpng.org/pub/png/libpng.html
zlib 1.2.8          - http://www.zlib.net/
Python 2.7.9        - https://www.python.org/downloads/release/python-279/
SDL2 2.0.3          - https://www.libsdl.org/download-2.0.php
