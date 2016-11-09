# Changelog

Notable changes to the FreeOrionSDK project will be documented in this file.


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
