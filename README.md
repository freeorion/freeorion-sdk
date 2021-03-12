# FreeOrion SDK

[![Windows build status badge]](https://ci.appveyor.com/project/freeorion/freeorion-sdk)
[![MacOSX build status badge]](https://travis-ci.org/freeorion/freeorion-sdk)

Build script used to build the FreeOrion SDK for the Windows and Mac OSX
operating systems.  For Linux there exists a Dockerfile, which creates a Docker
container capable of building FreeOrion.  All artifacts (Windows SDK, ḾacOSX SDK
and Linux Docker container) are used for continuous integration within the
project.


## Prerequisites

To build the FreeOrion SDK an instance of a properly configured development
environment for the C and C++ programming language is required.  Depending
on the operating system this usually means that at least one of the
following development environments are installed (but isn't necessary
limited to):

 * Visual Studio
 * Windows Platform SDK
 * XCode

Beside an installation of [CMake] *version 3.4 or later* must be available and
the cmake executables pathes must have been added to the `PATH` environment
variable.

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

This command creates a native build system for the SDK.

To select a specific IDE or a version thereof, use the `-G` (generator) parameter.
Valid values for this parameter are `-G "Visual Studio 15 2017"`, `-G "Xcode"` or similar.
Note: `-G "Visual Studio 16 2019"` is not supported due to errors when linking FreeOrion to GLEW.

To select a specific MSVC archticture, use the `-A` (architecture) parameter.
Valid values for this parameter are `-A Win32`.
Note: `-A x64` is not tested or supported.

To select a specific MSVC toolset version, use the `-T` (toolset) parameter.
Valid values for this parameter are `-T v141`.
Note: `-T v142` requires Visual Studio 2019, so is not supported for building the SDK, but Visual Studio 2019 and toolset v142 can be used when building FreeOrion itself and linking to an SDK built with `-T v141`.

After that, the SDK can be build with:

`cmake --build . --config RelWithDebInfo`

The `--config RelWithDebInfo` parameter is required.

The build takes about 25 to 40 minutes and the results are stored inside the `build/INSTALL`
directory.

A prepackaged version called `FreeOrionSDK_{MSVC,CLANG}_<timestamp>.zip` can be found in the `build` directory.

If you have any questions or problems please feel free to create an [Issue].


## Homepage

http://freeorion.org

[CMake]: https://cmake.org/
[Git]: https://git-scm.com/
[Issue]: https://github.com/freeorion/freeorion-sdk/issues
[Windows build status badge]: https://ci.appveyor.com/api/projects/status/github/freeorion/freeorion-sdk?branch=master&svg=true
[MacOSX build status badge]: https://travis-ci.org/freeorion/freeorion-sdk.svg?branch=master
