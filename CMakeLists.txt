set(REQUIRED_CMAKE_VERSION 2.8.11)

if(WIN32)
    set(REQUIRED_CMAKE_VERSION 3.4)
endif()

cmake_minimum_required(VERSION ${REQUIRED_CMAKE_VERSION})

option(BUILD_SHARED_LIBS "Build external projects as shared libraries." ON)
option(CMAKE_VERBOSE_MAKEFILE "Build with verbose Makefile output." OFF)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "RelWithDebInfo" CACHE STRING "Set the default build configuration for this build" FORCE)
endif()

project(FreeOrionSDK)

include(ExternalProject)

# Root directory of the SDK release.  This directory should contain
# everything a user needs to build FreeOrion from source.
set(SDK_INSTALL_DIR ${CMAKE_BINARY_DIR}/INSTALL)

if(APPLE)
    set(BUILD_SHARED_LIBS OFF)
    set(SDK_INSTALL_DIR "${SDK_INSTALL_DIR}/dep")
endif()

# Common download directory for all dependency source releases.  Storing
# those in a separate directory from the standard *-prefix directories
# prevents re-downloading them when cleaning up the SDK build.
set(SDK_DOWNLOAD_DIR ${CMAKE_BINARY_DIR}/downloads)

# Common directory for all executables to build the SDK.
set(SDK_BINARY_DIR ${CMAKE_BINARY_DIR}/bin)

if(WIN32)
    # Windows doesn't provide a basic patch tool, so we download one from the GNUWIN32 project
    ExternalProject_Add(patch
        URL http://downloads.sourceforge.net/project/gnuwin32/patch/2.5.9-7/patch-2.5.9-7-bin.zip
        URL_MD5 b9c8b31d62f4b2e4f1887bbb63e8a905
        DOWNLOAD_DIR ${SDK_DOWNLOAD_DIR}
        # Windows Vista+ introduces UAC, which believes that patch.exe does require administrative
        # privileges.  By installing the manifest we assure that this isn't the case.
        PATCH_COMMAND ${CMAKE_COMMAND} -E copy
            ${CMAKE_SOURCE_DIR}/exe.manifest
            <SOURCE_DIR>/bin/patch.exe.manifest
        # To let UAC pick up the manifest the executable needs to be more recent than the manifest
        COMMAND ${CMAKE_COMMAND} -E touch <SOURCE_DIR>/bin/patch.exe
        CONFIGURE_COMMAND ""
        BUILD_COMMAND ""
        INSTALL_COMMAND ${CMAKE_COMMAND} -E copy
            <SOURCE_DIR>/bin/patch.exe.manifest
            ${SDK_BINARY_DIR}/patch.exe.manifest
        COMMAND ${CMAKE_COMMAND} -E copy
            <SOURCE_DIR>/bin/patch.exe
            ${SDK_BINARY_DIR}/patch.exe
    )
    set(PATCH_EXECUTABLE ${SDK_BINARY_DIR}/patch.exe)
else()
    add_custom_target(patch)
    find_program(PATCH_EXECUTABLE patch)
    if(NOT PATCH_EXECUTABLE)
        message(FATAL_ERROR "Unable to locate `patch` executable.")
    endif()
endif()

if(WIN32)
    # CMake doesn't allow to pack directories as zip files without adding a prefix to the zip
    # file entries, so we download the zip tool from the GNUWIN32 project
    ExternalProject_Add(zip-deps
        URL http://downloads.sourceforge.net/project/gnuwin32/zip/3.0/zip-3.0-dep.zip
        URL_MD5 8bd9a45e1259238c1f6bb277fe6386c0
        CONFIGURE_COMMAND ""
        BUILD_COMMAND ""
        INSTALL_COMMAND ${CMAKE_COMMAND} -E copy
            <SOURCE_DIR>/bin/bzip2.dll
            ${SDK_BINARY_DIR}/bzip2.dll
    )

    ExternalProject_Add(zip
        DEPENDS zip-deps
        URL http://downloads.sourceforge.net/project/gnuwin32/zip/3.0/zip-3.0-bin.zip
        URL_MD5 5b268fe06ce5f89bc5762805a7a9d7aa
        # Windows Vista+ introduces UAC, which believes that patch.exe does require administrative
        # privileges.  By installing the manifest we assure that this isn't the case.
        PATCH_COMMAND ${CMAKE_COMMAND} -E copy
            ${CMAKE_SOURCE_DIR}/exe.manifest
            <SOURCE_DIR>/bin/zip.exe.manifest
        # To let UAC pick up the manifest the executable needs to be more recent than the manifest
        COMMAND ${CMAKE_COMMAND} -E touch <SOURCE_DIR>/bin/zip.exe
        CONFIGURE_COMMAND ""
        BUILD_COMMAND ""
        INSTALL_COMMAND ${CMAKE_COMMAND} -E copy
            <SOURCE_DIR>/bin/zip.exe.manifest
            ${SDK_BINARY_DIR}/zip.exe.manifest
        COMMAND ${CMAKE_COMMAND} -E copy
            <SOURCE_DIR>/bin/zip.exe
            ${SDK_BINARY_DIR}/zip.exe
    )
    set(ZIP_EXECUTABLE ${SDK_BINARY_DIR}/zip.exe)
else()
    add_custom_target(zip)
    find_program(ZIP_EXECUTABLE zip)
    if(NOT ZIP_EXECUTABLE)
        message(FATAL_ERROR "Unable to locate `zip` executable.")
    endif()
endif()

if(WIN32)
    add_custom_target(tar)
else()
    add_custom_target(tar)
    find_program(TAR_EXECUTABLE tar)
    if(NOT TAR_EXECUTABLE)
        message(FATAL_ERROR "Unable to locate `tar` executable.")
    endif()
endif()

set(ZLIB_VERSION 1.2.8)

if(WIN32)
    # Move the installed include dir for the WIN32 SDK
    set(ZLIB_INCLUDE_DIR ${SDK_INSTALL_DIR}/include/zlib)
else()
    set(ZLIB_INCLUDE_DIR ${SDK_INSTALL_DIR}/include)
endif()

ExternalProject_Add(zlib
    DEPENDS patch
    URL http://downloads.sourceforge.net/project/libpng/zlib/${ZLIB_VERSION}/zlib-${ZLIB_VERSION}.tar.gz
    URL_MD5 44d667c142d7cda120332623eab69f40
    DOWNLOAD_DIR ${SDK_DOWNLOAD_DIR}
    PATCH_COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/zlib/0001-Install-pdb-file-for-Debug-and-RelWithDebInfo.patch
    COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/zlib/0002-Replace-zlibstatic-target-with-CMake-BUILD_SHARED_LI.patch
    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE}
        -DSKIP_INSTALL_FILES=ON
        -DINSTALL_INC_DIR=${ZLIB_INCLUDE_DIR}
    INSTALL_DIR ${SDK_INSTALL_DIR}
)

if(BUILD_SHARED_LIBS)
    set(PNG_SHARED ON)
    set(PNG_STATIC OFF)
else()
    set(PNG_SHARED OFF)
    set(PNG_STATIC ON)
endif()

ExternalProject_Add(libpng
    DEPENDS patch zlib
    URL https://downloads.sourceforge.net/project/libpng/libpng16/1.6.25/libpng-1.6.25.tar.gz
    URL_MD5 87cbd0f69e4bff0215de3994a149df77
    DOWNLOAD_DIR ${SDK_DOWNLOAD_DIR}
    PATCH_COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/libpng/0001-Install-pdb-file-for-Debug-and-RelWithDebInfo-config.patch
    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE}
        -DPNG_SHARED=${PNG_SHARED}
        -DPNG_STATIC=${PNG_STATIC}
        -DPNG_TESTS=OFF
        -DSKIP_INSTALL_EXECUTABLES=ON
        -DSKIP_INSTALL_PROGRAMS=ON
        -DSKIP_INSTALL_FILES=ON
        -DSKIP_INSTALL_EXPORT=ON
        -DZLIB_ROOT=<INSTALL_DIR>
        -DZLIB_INCLUDE_DIR=${ZLIB_INCLUDE_DIR}
    INSTALL_DIR ${SDK_INSTALL_DIR}
)

if(WIN32)
    # This circumvents a wrongly installed include dir in the WIN32 SDK
    ExternalProject_Add_Step(libpng
        moveHeader
        DEPENDEES install
        WORKING_DIRECTORY <INSTALL_DIR>
        COMMAND ${CMAKE_COMMAND} -E remove_directory
            <INSTALL_DIR>/include/png
        COMMAND ${CMAKE_COMMAND} -E rename
            <INSTALL_DIR>/include/libpng16
            <INSTALL_DIR>/include/png
        COMMAND ${CMAKE_COMMAND} -E remove
            <INSTALL_DIR>/include/png.h
            <INSTALL_DIR>/include/pngconf.h
            <INSTALL_DIR>/include/pnglibconf.h
        COMMENT "Move FreeType headers to broken WIN32 SDK location"
    )
endif()

set(PYTHON_VERSION 2.7.12)

ExternalProject_Add(python-cmake
    DEPENDS patch
    URL https://github.com/python-cmake-buildsystem/python-cmake-buildsystem/archive/8af559448be1576bb0bb1ffd7afbfbb649b2d9dc.zip
    DOWNLOAD_DIR ${SDK_DOWNLOAD_DIR}
    PATCH_COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/python-cmake/0001-Install-libpython-pdb-file-when-building-shared-libr.patch
    COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/python-cmake/0002-Don-t-export-python-cmake-targets.patch
    COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/python-cmake/0003-Change-pathes-to-match-current-SDK-layout.patch
    COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/python-cmake/0004-Disable-MSVC-specific-compiler-warnings.patch
    COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/python-cmake/0005-Include-backported-Visual-Studio-2015-patch-into-bui.patch
    COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/python-cmake/0006-Add-Mac-OSX-framework-support.patch
    COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/python-cmake/0007-Install-binaries-libraries-headers-files-and-auxilli.patch
    COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/python-cmake/0008-Change-PYTHONPATH-and-PYTHONHOME-for-framework-build.patch
    COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/python-cmake/0009-Install-platform-library-files-on-MacOSX.patch
    COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/python-cmake/0010-Install-configure-Makefile-and-pyconfig.h-for-syscon.patch
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
)

ExternalProject_Get_Property(python-cmake SOURCE_DIR)
set(PYTHON_CMAKE_SOURCE_DIR ${SOURCE_DIR})
unset(SOURCE_DIR)


if(WIN32)
    set(PYTHON_CONFIGURE_FLAGS "")
    set(PYTHON_CONFIGURE_INSTALL_DIR ${SDK_INSTALL_DIR})
else()
    set(PYTHON_CONFIGURE_FLAGS "-DBUILD_FRAMEWORK=ON")
    set(PYTHON_CONFIGURE_INSTALL_DIR ${SDK_INSTALL_DIR}/Frameworks)
endif()

ExternalProject_Add(python
    DEPENDS zip python-cmake zlib
    URL https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz
    URL_MD5 88d61f82e3616a4be952828b3694109d
    DOWNLOAD_DIR ${SDK_DOWNLOAD_DIR}
    PATCH_COMMAND
        ${CMAKE_COMMAND} -E copy ${PYTHON_CMAKE_SOURCE_DIR}/CMakeLists.txt <SOURCE_DIR>
    COMMAND
        ${CMAKE_COMMAND} -E copy ${PYTHON_CMAKE_SOURCE_DIR}/CTestConfig.cmake <SOURCE_DIR>
    COMMAND
        ${CMAKE_COMMAND} -E make_directory <SOURCE_DIR>/cmake
    COMMAND
        ${CMAKE_COMMAND} -E copy_directory ${PYTHON_CMAKE_SOURCE_DIR}/cmake/ <SOURCE_DIR>/cmake/
    COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/python/0001-Add-defines-for-missing-globals-in-VS-2015.patch
    COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/python/0002-Handle-file-descriptor-verification-for-VS-2015.patch
    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
        -DBUILD_LIBPYTHON_SHARED=${BUILD_SHARED_LIBS}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE}
        -DPYTHON_VERSION=${PYTHON_VERSION}
        ${PYTHON_CONFIGURE_FLAGS}
        -DDOWNLOAD_SOURCES=OFF
        -DBUILD_TESTING=OFF
        -DBUILD_WININST=OFF
        -DENABLE_AUDIOOP=OFF
        -DENABLE_BSDDB=OFF
        #DENABLE_BZ2=OFF
        #DENABLE_CODECS_CN=OFF
        #DENABLE_CODECS_HK=OFF
        #DENABLE_CODECS_ISO2022=OFF
        #DENABLE_CODECS_JP=OFF
        #DENABLE_CODECS_KR=OFF
        #DENABLE_CODECS=OFF
        #DENABLE_CODECS_TW=OFF
        #DENABLE_CRYPT=OFF
        -DENABLE_CSV=OFF
        -DENABLE_CTYPES_TEST=OFF
        #DENABLE_CURSES=OFF
        #DENABLE_CURSES_PANEL=OFF
        #DENABLE_DBM=OFF
        -DENABLE_ELEMENTTREE=OFF
        #DENABLE_FCNTL=OFF
        -DENABLE_GDBM=OFF
        -DENABLE_GRP=OFF
        #DENABLE_HASHLIB=OFF
        #DENABLE_HEAPQ=OFF
        #DENABLE_HOTSHOT=OFF
        #DENABLE_JSON=OFF
        -DENABLE_LINUXAUDIODEV=OFF
        #DENABLE_MMAP=OFF
        #DENABLE_MULTIBYTECODEC=OFF
        -DENABLE_MULTIPROCESSING=OFF
        -DENABLE_NIS=OFF
        #DENABLE_NT=OFF
        -DENABLE_OSSAUDIODEV=OFF
        #DENABLE_PARSER=OFF
        #DENABLE_POSIX=OFF
        -DENABLE_PWD=OFF
        -DENABLE_PYEXPAT=OFF
        #DENABLE_READLINE=OFF
        -DENABLE_SELECT=OFF
        -DENABLE_SOCKET=OFF
        -DENABLE_SPWD=OFF
        -DENABLE_SQLITE3=OFF
        -DENABLE_SSL=OFF
        #DENABLE_STRUCT=OFF
        -DENABLE_SYSLOG=OFF
        -DENABLE_TERMIOS=OFF
        -DENABLE_TESTCAPI=OFF
        -DENABLE_TKINTER=OFF
        -DENABLE_UNICODEDATA=OFF
        #DENABLE_ZLIB=OFF
    INSTALL_DIR ${PYTHON_CONFIGURE_INSTALL_DIR}
)

if(WIN32)
    # FreeOrion packages the python standard library in a zip file for
    # distribution.
    ExternalProject_Add_Step(python
        zipPythonSTDlib
        DEPENDEES install
        WORKING_DIRECTORY
            <INSTALL_DIR>/lib/python27
        COMMAND ${CMAKE_COMMAND} -E remove_directory
            <INSTALL_DIR>/lib/python27/lib-dynload
        COMMAND ${ZIP_EXECUTABLE} -r -9 -q
            <INSTALL_DIR>/bin/python27.zip
            .
        COMMENT "Zip python standard library"
    )

    ExternalProject_Add_Step(python
        removePythonSTDlib
        DEPENDEES zipPythonSTDlib
        COMMAND ${CMAKE_COMMAND} -E remove_directory
            <INSTALL_DIR>/lib/python27
        COMMENT "Remove python standard library from install"
    )
endif()

ExternalProject_Add(freetype2
    DEPENDS patch
    URL http://downloads.sourceforge.net/project/freetype/freetype2/2.5.5/freetype-2.5.5.tar.gz
    URL_MD5 7448edfbd40c7aa5088684b0a3edb2b8
    DOWNLOAD_DIR ${SDK_DOWNLOAD_DIR}
    PATCH_COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/freetype2/0001-cmake-Add-version-and-c-runtime-type-to-output-name.patch
    COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/freetype2/0002-Remove-2-suffix-from-freetype-header-install-path.patch
    COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/freetype2/0003-Disable-MSVC-deprecation-warnings-in-CMake.patch
    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
        # FreeType doesn't provide any exported symbols, so build
        # it as static library.
        -DBUILD_SHARED_LIBS=OFF
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE}
    INSTALL_DIR ${SDK_INSTALL_DIR}
)

if(WIN32)
    set(SDL2_CONFIGURE_FLAGS "")
    set(SDL2_CONFIGURE_INSTALL_DIR ${SDK_INSTALL_DIR})
else()
    set(SDL2_CONFIGURE_FLAGS
        -DBUILD_FRAMEWORK=ON
    )
    set(SDL2_CONFIGURE_INSTALL_DIR ${SDK_INSTALL_DIR}/Frameworks)
endif()

ExternalProject_Add(sdl2
    DEPENDS patch
    URL https://www.libsdl.org/release/SDL2-2.0.4.tar.gz
    URL_MD5 44fc4a023349933e7f5d7a582f7b886e
    DOWNLOAD_DIR ${SDK_DOWNLOAD_DIR}
    PATCH_COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/sdl2/0001-CMake-Install-pdb-file-for-Debug-and-RelWithDebInfo-.patch
    COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/sdl2/0002-Never-build-and-install-SDL2main-library.patch
    COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/sdl2/0003-Remove-Wl-no-undefined-linker-flag.patch
    COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/sdl2/0004-CMake-Use-PUBLIC_HEADER-property-to-install-headers.patch
    COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/sdl2/0005-CMake-Add-MacOSX-Framework-support.patch
    COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/sdl2/0006-CMake-Set-framework-install-directory.patch
    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE}
        -DSDL_STATIC=OFF
        -DDIRECTX=OFF
        -DRENDER_D3D=OFF
        ${SDL2_CONFIGURE_FLAGS}
    INSTALL_DIR ${SDL2_CONFIGURE_INSTALL_DIR}
)

if(WIN32)
    set(LIBOGG_CONFIGURE_FLAGS "")
    set(LIBOGG_CONFIGURE_INSTALL_DIR ${SDK_INSTALL_DIR})
else()
    set(LIBOGG_CONFIGURE_FLAGS "-DBUILD_FRAMEWORK=ON")
    set(LIBOGG_CONFIGURE_INSTALL_DIR ${SDK_INSTALL_DIR}/Frameworks)
endif()

ExternalProject_Add(libogg
    DEPENDS patch
    URL http://downloads.xiph.org/releases/ogg/libogg-1.3.2.tar.gz
    URL_MD5 b72e1a1dbadff3248e4ed62a4177e937
    DOWNLOAD_DIR ${SDK_DOWNLOAD_DIR}
    PATCH_COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/libogg/0001-Upstream-changes-since-v1.3.2.patch
    COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/libogg/0002-CMake-Don-t-install-pkg-config-files-on-Windows.patch
    COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/libogg/0003-CMake-Add-lib-prefix-to-output-files-on-Windows.patch
    COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/libogg/0004-CMake-Install-pdb-file-for-Debug-and-RelWithDebInfo.patch
    COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/libogg/0005-Don-t-install-pkg-config-files-when-building-a-MacOS.patch
    COMMAND ${CMAKE_COMMAND} -E rename
        <SOURCE_DIR>/configure.in
        <SOURCE_DIR>/configure.ac
    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE}
        ${LIBOGG_CONFIGURE_FLAGS}
    INSTALL_DIR ${LIBOGG_CONFIGURE_INSTALL_DIR}
)

if(WIN32)
    set(LIBVORBIS_CONFIGURE_FLAGS "")
    set(LIBVORBIS_CONFIGURE_INSTALL_DIR ${SDK_INSTALL_DIR})
else()
    set(LIBVORBIS_CONFIGURE_FLAGS
        -DBUILD_FRAMEWORK=ON
        -DCMAKE_FRAMEWORK_PATH=${SDK_INSTALL_DIR}/Frameworks
    )
    set(LIBVORBIS_CONFIGURE_INSTALL_DIR ${SDK_INSTALL_DIR}/Frameworks)
endif()

ExternalProject_Add(libvorbis
    DEPENDS patch libogg
    URL http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.5.tar.gz
    URL_MD5 7220e089f3be3412a2317d6fde9e3944
    DOWNLOAD_DIR ${SDK_DOWNLOAD_DIR}
    PATCH_COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/libvorbis/0001-Upstream-changes-since-v1.3.5.patch
    COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/libvorbis/0002-CMake-Add-vorbisenc.c-to-vorbis-target-for-MSVC-buil.patch
    COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/libvorbis/0003-CMake-Don-t-install-pkg-config-files-on-Windows.patch
    COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/libvorbis/0004-CMake-Add-lib-prefix-to-output-files-on-Windows.patch
    COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/libvorbis/0005-CMake-Install-pdb-file-for-Debug-and-RelWithDebInfo.patch
    COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/libvorbis/0006-CMake-Add-libogg-as-additional-name-to-ogg-library-s.patch
    COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/libvorbis/0007-CMake-Remove-vorbisenc-target.patch
    COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/libvorbis/0008-Disable-MSVC-specific-compiler-warnings.patch
    COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/libvorbis/0009-CMake-Use-install-command-for-both-framework-and-non.patch
    COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/libvorbis/0010-Don-t-install-pkg-config-files-when-creating-a-MacOS.patch
    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE}
        ${LIBVORBIS_CONFIGURE_FLAGS}
    INSTALL_DIR ${LIBVORBIS_CONFIGURE_INSTALL_DIR}
)

if(NOT APPLE)
    ExternalProject_Add(openal-soft
        DEPENDS patch
        URL http://kcat.strangesoft.net/openal-releases/openal-soft-1.17.2.tar.bz2
        URL_MD5 1764e0d8fec499589b47ebc724e0913d
        DOWNLOAD_DIR ${SDK_DOWNLOAD_DIR}
        PATCH_COMMAND
            ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/openal-soft/0001-Don-t-install-pkg-config-files-on-Windows.patch
        COMMAND
            ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/openal-soft/0002-Install-pdb-file-for-Debug-and-RelWithDebInfo-config.patch
        CMAKE_ARGS
            -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
            -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
            -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
            -DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE}
            -DALSOFT_UTILS=OFF
            -DALSOFT_NO_CONFIG_UTIL=ON
            -DALSOFT_EXAMPLES=OFF
            -DALSOFT_CONFIG=OFF
            -DALSOFT_TESTS=OFF
            -DALSOFT_HRTF_DEFS=OFF
            -DALSOFT_REQUIRE_MMDEVAPI=${WIN32}
            -DALSOFT_REQUIRE_COREAUDIO=${APPLE}
            -DALSOFT_CPUEXT_NEON=OFF
            -DALSOFT_MIDI_FLUIDSYNTH=OFF
            -DALSOFT_BACKEND_ALSA=OFF
            -DALSOFT_BACKEND_OSS=OFF
            -DALSOFT_BACKEND_SOLARIS=OFF
            -DALSOFT_BACKEND_SNDIO=OFF
            -DALSOFT_BACKEND_QSA=OFF
            -DALSOFT_BACKEND_WINMM=OFF
            -DALSOFT_BACKEND_DSOUND=OFF
            -DALSOFT_BACKEND_PORTAUDIO=OFF
            -DALSOFT_BACKEND_PULSEAUDIO=OFF
            -DALSOFT_BACKEND_OPENSL=OFF
            -DALSOFT_BACKEND_WAVE=OFF
        INSTALL_DIR ${SDK_INSTALL_DIR}
    )
else()
    # The MacOSX SDK doesn't contain OpenAL-soft, so add an empty target
    add_custom_target(openal-soft)
endif()

ExternalProject_Add(glew
    DEPENDS patch
    URL http://downloads.sourceforge.net/project/glew/glew/1.13.0/glew-1.13.0.tgz
    URL_MD5 7cbada3166d2aadfc4169c4283701066
    DOWNLOAD_DIR ${SDK_DOWNLOAD_DIR}
    PATCH_COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/glew/0001-CMake-Don-t-install-pkg-config-files-on-Windows.patch
    COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/glew/0002-Remove-glewmx-related-targets.patch
    COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/glew/0003-CMake-Install-pdb-file-for-Debug-and-RelWithDebInfo.patch
    COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/glew/0004-Don-t-install-glew-CMake-export-targets.patch
    CONFIGURE_COMMAND ${CMAKE_COMMAND}
        -G "${CMAKE_GENERATOR}"
        -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE}
        -DBUILD_UTILS=OFF
        <SOURCE_DIR>/build/cmake/
    INSTALL_DIR ${SDK_INSTALL_DIR}
)

if(NOT WIN32)
    set(BOOST_CONFIGURE_COMMAND <SOURCE_DIR>/bootstrap.sh)
    set(BOOST_CONFIGURE_FLAGS "")
    set(BOOST_CONFIGURE_INSTALL_DIR ${SDK_INSTALL_DIR})
else()
    set(BOOST_CONFIGURE_COMMAND <SOURCE_DIR>/bootstrap.bat)
    set(BOOST_CONFIGURE_FLAGS "debug-store=database")
    set(BOOST_CONFIGURE_INSTALL_DIR ${SDK_INSTALL_DIR}/Boost)
endif()
string(SUBSTRING "${PYTHON_VERSION}" 0 3 PYTHON_VERSION)

if(BUILD_SHARED_LIBS)
    set(BOOST_LINK "shared")
else()
    set(BOOST_LINK "static")
endif()

if(CMAKE_BUILD_TYPE MATCHES "^Rel(ease|WithDebInfo)$")
    set(BOOST_VARIANT "release")
else()
    set(BOOST_VARIANT "debug")
endif()

configure_file(
    boost-config.jam.in
    boost-config.jam
)

ExternalProject_Add(boost
    DEPENDS patch zlib python
    URL http://downloads.sourceforge.net/project/boost/boost/1.59.0/boost_1_59_0.tar.gz
    URL_MD5 51528a0e3b33d9e10aaa311d9eb451e3
    DOWNLOAD_DIR ${SDK_DOWNLOAD_DIR}
    BUILD_IN_SOURCE 1
    PATCH_COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/boost-0-install_pdb_files_for_debug_and_relwithdebinfo.patch
    COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/boost-1-remove_version_suffix_from_include_directory.patch
    CONFIGURE_COMMAND ${BOOST_CONFIGURE_COMMAND}
    BUILD_COMMAND <SOURCE_DIR>/b2 install
        -d
        --user-config=${CMAKE_BINARY_DIR}/boost-config.jam
        --without-graph_parallel
        --without-mpi
        --without-wave
        --prefix=<INSTALL_DIR>
        threading=multi
        link=${BOOST_LINK}
        variant=${BOOST_VARIANT}
        debug-symbols=on
        ${BOOST_CONFIGURE_FLAGS}
        pch=off
        -s NO_BZIP2=1
    INSTALL_COMMAND ""
    INSTALL_DIR ${BOOST_CONFIGURE_INSTALL_DIR}
)

if(WIN32)
    ExternalProject_Add_Step(boost
        copyDLL
        DEPENDEES install
        COMMAND ${CMAKE_COMMAND} -P ${CMAKE_SOURCE_DIR}/cmake/CopyFiles.cmake --
            <INSTALL_DIR>/lib/*.dll
            ${SDK_INSTALL_DIR}/bin/
        COMMAND ${CMAKE_COMMAND} -P ${CMAKE_SOURCE_DIR}/cmake/DeleteFiles.cmake --
            <INSTALL_DIR>/lib/*.dll
        COMMENT "Copy boost dll files into SDK bin directory"
    )
endif()

ExternalProject_Add_Step(boost
    removeExtraPDB
    DEPENDEES install
    COMMAND ${CMAKE_COMMAND} -E remove
        <INSTALL_DIR>/lib/accepts_shared_option.pdb
        <INSTALL_DIR>/lib/has_atomic_flag_lockfree.pdb
    COMMENT "Remove extra PDB files"
)

if(WIN32)
    configure_file(
        ${CMAKE_SOURCE_DIR}/bootstrap.bat
        ${SDK_INSTALL_DIR}/bootstrap.bat
        COPYONLY
    )

    configure_file(
        ${CMAKE_SOURCE_DIR}/README-WIN32.txt
        ${SDK_INSTALL_DIR}/README.txt
        COPYONLY
    )
elseif(APPLE)
    # SDK_INSTALL_DIR points to the `dep` subdirectory
    configure_file(
        ${CMAKE_SOURCE_DIR}/bootstrap.command
        ${SDK_INSTALL_DIR}/../bootstrap.command
        COPYONLY
    )
else()
    message(FATAL "Target system not yet supported")
endif()

string(TIMESTAMP DIST_TS "%Y-%m-%d" UTC)

set(DIST_TOOLSET ${CMAKE_CXX_COMPILER_ID})
if(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
    string(REPLACE "." ";" _VERSION ${CMAKE_CXX_COMPILER_VERSION})
    list(GET ${_VERSION} 0 1 _VERSION})
    string(REPLACE ";" "." _VERSION "${_VERSION}")
    set(DIST_TOOLSET ${DIST_TOOLSET}-${_VERSION})
endif()

if(WIN32)
    set(DIST_PACK_COMMAND ${ZIP_EXECUTABLE} -r -9)
    set(DIST_PACK_EXT zip)
else()
    set(DIST_PACK_COMMAND ${TAR_EXECUTABLE} cjvf)
    set(DIST_PACK_EXT tar.bz2)
endif()

add_custom_target(pack ALL
    DEPENDS
        zip tar zlib libpng python-cmake python freetype2 sdl2
        libogg libvorbis openal-soft glew boost
    WORKING_DIRECTORY
        ${SDK_INSTALL_DIR}
    COMMAND
        ${DIST_PACK_COMMAND}
        ${CMAKE_BINARY_DIR}/${PROJECT_NAME}_${DIST_TOOLSET}_${DIST_TS}.${DIST_PACK_EXT}
        .
)

set_directory_properties(
    PROPERTIES
    ADDITIONAL_MAKE_CLEAN_FILES
    "${SDK_INSTALL_DIR};${SDK_BINARY_DIR}"
)
