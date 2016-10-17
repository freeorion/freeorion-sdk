# FreeOrion SDK

[![Windows build status badge]](https://ci.appveyor.com/project/freeorion/freeorion-sdk)
[![MacOSX build status badge]](https://travis-ci.org/freeorion/freeorion-sdk)

Build script used to build the FreeOrion SDK for the Windows and Mac OSX
operating systems.


## Prerequisites

To build the FreeOrion SDK an instance of a properly configured development
environment for the C and C++ programming language is required.  Depending
on the operating system this usually means that at least one of the
following development environments are installed (but isn't necessary
limited to):

 * Visual Studio
 * Windows Platform SDK
 * XCode

Beside an installation of [CMake] *version 2.8.11 or later, version 3.4 or later
on Windows* must be available and the cmake executables pathes must have been
added to the `PATH` environment variable.

Also an installation of [Git] *version 1.9 or later* must be available and
the git executable pathes must have been added to the `PATH` environment
variable.


## Usage

To prepare building the SDK clone this repository by calling:

`git clone https://github.com/freeorion/freeorion-sdk.git freeorion-sdk`

and change into the checked out repository by calling:

`cd freeorion-sdk`

To actually build the SDK a dedicated build directory is required, so create
one:

`mkdir build`

and change into it:

`cd build`

Now configure the build to check if the tools and build environments are
properly set up:

`cmake ..`

This command creates a native build system for the SDK. After that the SDK
can be build with:

`cmake --build . --config RelWithDebInfo`

The `--config RelWithDebInfo` parameter is required.  The build takes around
25 minutes and after that the results are stored inside the `build/INSTALL`
directory and a prepackaged version called

`FreeOrionSDK_{MSVC,CLANG}_<timestamp>.zip`

can be found in the `build` directory.

If you have any questions or problems please feel free to create an [issue].


## Homepage

http://freeorion.org

[CMake]: https://cmake.org/
[Git]: https://git-scm.com/
[issue]: https://github.com/freeorion/freeorion-sdk/issues
[Windows build status badge]: https://ci.appveyor.com/api/projects/status/github/freeorion/freeorion-sdk?branch=master&svg=true
[MacOSX build status badge]: https://travis-ci.org/freeorion/freeorion-sdk.svg?branch=master
