# Changelog

Notable changes to the FreeOrionSDK project will be documented in this file.

## v11 - TBA

- Update boost version to 1.68
- Update python-cmake-buildsystem from c3b8d532242efed85fb3cd77b0e39e424b6db475
  to 501869c2b124552dae669d5fd6b7e7101a7cc30c.
- Pin Docker image to a stable and more recent base image
  (docker.io/ubuntu:bionic-20190307).

## v10 - 2018-05-26

- Build freetype2 dependency with explicit dependency on zlib and libpng and
  without explicit dependency on bzip2 and HarfBuzz. This enables zlib
  compressed font and fonts with bitmap emoticons. This disables bzip2
  compressed fonts formats and complex script language glyphs (e.g. persian).
- Raise Mac OS X build environment to Xcode 8.3, keeping Mac OS X 10.9 as
  deployment target.


## v9 - 2018-05-23

- Replace FreeOrionSDK Apple Disk Image release with a bzip2 compressed
  tarball and remove bootstrap script. The FreeOrion build system now
  implements the automatic download and unpacking of the SDK so the
  additional dmg image wrapping only adds needless complexity.
- Add FreeOrionSDK release for Visual Studio 2017 support, using the v141_xp
  toolset.
- Update zlib version to 1.2.11
- Update libpng version to 1.6.34
- Update boost version to 1.66
- Disabled Boost library:
  - fiber
- Use simpler boost shared libary naming scheme on Windows
- Update GLEW version to 2.1.0
- Update SDL2 version to 2.0.8
- Update libopenal-soft version to 1.18.2
- Update freetype2 version to 2.9
- Build freetype2 as shared library on Windows
- Remove freetype2 shared library suffix on Windows
- Use upstream conventions for freetype2 install header path
- Use upstream conventions for freetype2 ft2build.h install path.
- Build freetype2 as shared library.
- Update Python version to 2.7.14
- Add ccache to Ubuntu Dockerfile to utilize build cache on TravisCI.
- Pin Docker image to a stable and more recent base image
  (docker.io/ubuntu:xenial-20180417).
- Don't install package documentation into Docker image
- Move suppression of recommends installed packages into config file for Docker
  image.
- Don't install static libraries into Docker image
- Set Debian frontend to noninteractive to avoid warnings during apt-get usage.


## v8 - 2017-11-05

- Add patch to Boost dependency to fix boost #10591, which affects both running
  FreeOrion for older MacOSX platforms and building FreeOrion with CMake.
- Change OSX deployment target to 10.9
- Change OSX architecture to x86_64
- Build boost dependency as shared libraries on MacOSX.  Fixes freeorion/freeorion#1575.


## v7 - 2017-03-28

- Enable `select` extension of python dependency.  This allows FreeOrion build
  scripts to spawn subprocesses on UNIX-like systems.


## v6 - 2017-03-26

- Update python-cmake-buildsystem from 8af559448be1576bb0bb1ffd7afbfbb649b2d9dc
  to 9da2738063b6b5e16ea3578a95f7b93c6d44c9d2.
- Update libpng version to 1.6.29
- Fix bug in python-cmake-buildsystem, which prevented the execution of some
  scripts on MacOSX.
- Fix bug in python-cmake-buildsystem, which prevented the correct linking
  against the SDK python framework on MacOSX.


## v5 - 2017-03-15

- Use `j` instead of `y` when unpacking the SDK in MacOSX bootstrap.
- Install zlib headers in the default location for the Windows SDK.
- Install libpng headers in the default location for the Windows SDK.
- Install Boost into root directory of the Windows SDK.


## v4 - 2017-02-17

- Don't build python against any potentially installed instance of OpenSSL
  to avoid missing dependencies on distribution.
- Update libpng version to 1.6.27
- Fix Visual Studio target platform SDK selection for boost to allow toolsets
  without `_xp` suffix.
- Enable abbreviated pathed in boost build to avoid `failed to write output file`
  with Windows build.
- Add Dockerfile to create TravisCI build environment for Linux.
- Add patches from Boost.GIL upstream to avoid compiler errors with MacOSX
  clang.


## v3 - 2016-12-12

- Change SDK version scheme to simple sequence number
- Update output of bootstrap scripts to list the minimum required IDE
  for each platform (Visual Studio 2015 - Windows ; Xcode 6.4 - MacOSX).


## [0.4.6-2] - 2016-11-30

- Use dotglob to copy hidden files in MacOSX SDK
- Fix install name for SDL dependency library on MacOSX
- Fix install name for python dependency library on MacOSX


## [0.4.6-1] - 2016-11-09

Initial changelog for the first automatic created FreeOrionSDK.  It documents
the differences between the manual maintained old SDK and the new one.

- [ANY] Updated Boost from 1.58(WIN)/1.56(OSX) to 1.59.
- [ANY] Disabled Boost libraries:
  - context
  - coroutine
  - coroutine2
  - graph_parallel
  - mpi
  - wave
  - zlib
- [ANY] Linking boost against zlib, not boost_zlib.
- [ANY] Updated GLEW from 1.12.0 to 1.13.0.
- [ANY] Updated libpng from 1.6.17(WIN)/1.5.12(OSX) to 1.6.25.
- [ANY] Updated Python from 2.7.9(WIN)/2.7.8(OSX) to 2.7.12.
- [ANY] Disabled Python modules:
  - audioop
  - bsddb
  - csv
  - curses
  - dbm
  - elementtree
  - gdbm
  - grp
  - hotshot
  - json
  - linuxaudiodev
  - mmap
  - multibytecodecs and related implementation modules
  - multiprocessing
  - nis
  - parser
  - pwd
  - pyexpat
  - select
  - socket
  - spwd
  - sqlite
  - ssl
  - syslog
  - termios
  - testcapi
  - tkinter
  - unicodedata
  - wininst
- [ANY] Updated SDL from 2.0.3 to 2.0.4.
- [ANY] Dropped unused FreeALUT dependency.
- [ANY] Dropped unused FreeImage dependency.
- [ANY] Changed SDK artifact file names to contain matching FreeOrion version,
  compiler, toolset and target platform.
- [ANY] Moved shared libaries from `temp` into `bin` directory.  Updated
  `bootstrap.bat` and `bootstrap.command` accordingly.
- [WIN] Updated OpenAL Soft dependency from 1.15.0 to 1.17.2.
- [WIN] Remove invalid platform configuration files in python dependency stdlib.
- [OSX] Built Boost with C++11 support and against `libc++.dylib`.
- [OSX] Updated libogg dependency from 1.1.2 to 1.3.2.
- [OSX] Updated FreeType2 from 2.3.11 to 2.5.5.
- [OSX] Remove Radicale WebDAV installation from python site-packages.
- [OSX] Renamed vorbis.framework to Vorbis.framework.
- [OSX] Updated libvorbis from 1.1.1 to 1.3.5.
