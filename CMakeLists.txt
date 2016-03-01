cmake_minimum_required(VERSION 2.8)

option(BUILD_SHARED_LIBS "Build external projects as shared libraries." ON)
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "RelWithDebInfo" CACHE STRING "Set the default build configuration for this build" FORCE)
endif()

project(FreeOrionSDK)

include(ExternalProject)

# Root directory of the SDK release.  This directory should contain
# everything a user needs to build FreeOrion from source.
set(SDK_INSTALL_DIR ${CMAKE_BINARY_DIR}/INSTALL)

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

ExternalProject_Add(zlib
    DEPENDS patch
    URL http://sourceforge.net/projects/libpng/files/zlib/1.2.8/zlib-1.2.8.tar.gz/download
    URL_MD5 44d667c142d7cda120332623eab69f40
    DOWNLOAD_DIR ${SDK_DOWNLOAD_DIR}
    PATCH_COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/zlib.patch
    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DSKIP_INSTALL_FILES=ON
    INSTALL_DIR ${SDK_INSTALL_DIR}
)

if(WIN32)
    # This circumvents a wrongly installed include dir in the WIN32 SDK
    ExternalProject_Add_Step(zlib
        moveHeader
        DEPENDEES install
        WORKING_DIRECTORY <INSTALL_DIR>
        COMMAND ${CMAKE_COMMAND} -E remove_directory
            <INSTALL_DIR>/include/zlib
        COMMAND ${CMAKE_COMMAND} -E make_directory
            <INSTALL_DIR>/include/zlib
        COMMAND ${CMAKE_COMMAND} -E rename
            <INSTALL_DIR>/include/zlib.h
            <INSTALL_DIR>/include/zlib/zlib.h
        COMMAND ${CMAKE_COMMAND} -E rename
            <INSTALL_DIR>/include/zconf.h
            <INSTALL_DIR>/include/zlib/zconf.h
        COMMENT "Move zlib headers to broken WIN32 SDK location"
    )
    set(ZLIB_INCLUDE_DIR ${SDK_INSTALL_DIR}/include/zlib)
else()
    set(ZLIB_INCLUDE_DIR ${SDK_INSTALL_DIR}/include)
endif()

ExternalProject_Add(libpng
    DEPENDS zlib
    URL https://sourceforge.net/projects/libpng/files/libpng16/older-releases/1.6.17/libpng-1.6.17.tar.gz/download
    URL_MD5 134282f1752dcf4cd81a37b8ff421cef
    DOWNLOAD_DIR ${SDK_DOWNLOAD_DIR}
    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DPNG_STATIC=OFF
        -DPNG_TESTS=OFF
        -DSKIP_INSTALL_EXECUTABLES=ON
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

set(PYTHON_VERSION 2.7.9)

ExternalProject_Add(python-cmake
    DEPENDS patch
    URL https://github.com/python-cmake-buildsystem/python-cmake-buildsystem/archive/master.zip
    DOWNLOAD_DIR ${SDK_DOWNLOAD_DIR}
    PATCH_COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/python-cmake.patch
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
)

ExternalProject_Get_Property(python-cmake SOURCE_DIR)
set(PYTHON_CMAKE_SOURCE_DIR ${SOURCE_DIR})
unset(SOURCE_DIR)

if(BUILD_SHARED_LIBS)
    set(PYTHON_BUILD_STATIC OFF)
else()
    set(PYTHON_BUILD_STATIC ON)
endif()

ExternalProject_Add(python
    DEPENDS zip python-cmake zlib
    URL https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz
    URL_MD5 5eebcaa0030dc4061156d3429657fb83
    DOWNLOAD_DIR ${SDK_DOWNLOAD_DIR}
    PATCH_COMMAND ${CMAKE_COMMAND} -E copy ${PYTHON_CMAKE_SOURCE_DIR}/CMakeLists.txt <SOURCE_DIR>
    COMMAND ${CMAKE_COMMAND} -E copy ${PYTHON_CMAKE_SOURCE_DIR}/CTestConfig.cmake <SOURCE_DIR>
    COMMAND ${CMAKE_COMMAND} -E make_directory <SOURCE_DIR>/cmake
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${PYTHON_CMAKE_SOURCE_DIR}/cmake/ <SOURCE_DIR>/cmake/
    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
        -DBUILD_SHARED=${BUILD_SHARED_LIBS}
        -DBUILD_STATIC=${PYTHON_BUILD_STATIC}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DPY_VERSION=${PYTHON_VERSION}
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
        -DENABLE_CTYPES=OFF
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
        #DENABLE_SSL=OFF
        #DENABLE_STRUCT=OFF
        #DENABLE_SYSLOG=OFF
        #DENABLE_TERMIOS=OFF
        -DENABLE_TESTCAPI=OFF
        #DENABLE_TKINTER=OFF
        -DENABLE_UNICODEDATA=OFF
        #DENABLE_ZLIB=OFF
    INSTALL_DIR ${SDK_INSTALL_DIR}
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
        COMMAND ${ZIP_EXECUTABLE} -r -9
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
    URL http://sourceforge.net/projects/freetype/files/freetype2/2.5.5/freetype-2.5.5.tar.gz/download
    URL_MD5 7448edfbd40c7aa5088684b0a3edb2b8
    DOWNLOAD_DIR ${SDK_DOWNLOAD_DIR}
    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    INSTALL_DIR ${SDK_INSTALL_DIR}
)

if(WIN32)
    # This circumvents a wrongly installed include dir in the WIN32 SDK
    ExternalProject_Add_Step(freetype2
        moveHeader
        DEPENDEES install
        WORKING_DIRECTORY <INSTALL_DIR>
        COMMAND ${CMAKE_COMMAND} -E rename
            <INSTALL_DIR>/include/freetype2
            <INSTALL_DIR>/include/freetype
        COMMENT "Move FreeType headers to broken WIN32 SDK location"
    )
endif(WIN32)

ExternalProject_Add(sdl
    URL https://www.libsdl.org/release/SDL2-2.0.3.tar.gz
    URL_MD5 fe6c61d2e9df9ef570e7e80c6e822537
    DOWNLOAD_DIR ${SDK_DOWNLOAD_DIR}
    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DSDL_STATIC=OFF
        -DDIRECTX=OFF
        -DRENDER_D3D=OFF
    INSTALL_DIR ${SDK_INSTALL_DIR}
)

# This circumvents a missing option to prevent installing the executables
# pkgconfig files
ExternalProject_Add_Step(sdl
    removeExtraFiles
    DEPENDEES install
    WORKING_DIRECTORY <INSTALL_DIR>
    COMMAND ${CMAKE_COMMAND} -E remove
        <INSTALL_DIR>/bin/sdl2-config
        <INSTALL_DIR>/share/aclocal/sdl2.m4
        <INSTALL_DIR>/lib/pkgconfig/sdl2.pc
    COMMENT "Remove sdl additional files"
)

ExternalProject_Add(libogg
    URL http://downloads.xiph.org/releases/ogg/libogg-1.3.2.tar.gz
    URL_MD5 b72e1a1dbadff3248e4ed62a4177e937
    DOWNLOAD_DIR ${SDK_DOWNLOAD_DIR}
    CONFIGURE_COMMAND <SOURCE_DIR>/configure
        --prefix=<INSTALL_DIR>
        --disable-oggtest
    INSTALL_DIR ${SDK_INSTALL_DIR}
)

# This circumvents a missing option in the upstream configure.ac file
ExternalProject_Add_Step(libogg
    deleteDocumentation
    DEPENDEES install
    WORKING_DIRECTORY <INSTALL_DIR>
    COMMAND ${CMAKE_COMMAND} -E remove_directory <INSTALL_DIR>/share/doc/libogg
    COMMENT "Remove documentation for libogg from SDK"
)

# This circumvents a missing option to prevent installing the executables
# pkgconfig files
ExternalProject_Add_Step(libogg
    removeExtraFiles
    DEPENDEES install
    WORKING_DIRECTORY <INSTALL_DIR>
    COMMAND ${CMAKE_COMMAND} -E remove
        <INSTALL_DIR>/lib/pkgconfig/ogg.pc
        <INSTALL_DIR>/share/aclocal/ogg.m4
    COMMENT "Remove libogg additional files"
)

ExternalProject_Add(libvorbis
    DEPENDS libogg
    URL http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.5.tar.gz
    URL_MD5 7220e089f3be3412a2317d6fde9e3944
    DOWNLOAD_DIR ${SDK_DOWNLOAD_DIR}
    CONFIGURE_COMMAND <SOURCE_DIR>/configure
        --prefix=<INSTALL_DIR>
        --disable-docs
        --disable-examples
        --disable-oggtest
    INSTALL_DIR ${SDK_INSTALL_DIR}
)

# This circumvents a bug in the upstream configure.ac file
ExternalProject_Add_Step(libvorbis
    deleteDocumentation
    DEPENDEES install
    WORKING_DIRECTORY <INSTALL_DIR>
    COMMAND ${CMAKE_COMMAND} -E remove_directory <INSTALL_DIR>/share/doc/libvorbis-1.3.5
    COMMENT "Remove documentation for libvorbis from SDK"
)

# This circumvents a missing option to prevent installing the executables
# pkgconfig files
ExternalProject_Add_Step(libvorbis
    removeExtraFiles
    DEPENDEES install
    WORKING_DIRECTORY <INSTALL_DIR>
    COMMAND ${CMAKE_COMMAND} -E remove
        <INSTALL_DIR>/lib/pkgconfig/vorbis.pc
        <INSTALL_DIR>/lib/pkgconfig/vorbisenc.pc
        <INSTALL_DIR>/lib/pkgconfig/vorbisfile.pc
        <INSTALL_DIR>/share/aclocal/vorbis.m4
    COMMENT "Remove libvorbis additional files"
)

ExternalProject_Add(openal-soft
    DEPENDS patch
    URL http://kcat.strangesoft.net/openal-releases/openal-soft-1.16.0.tar.bz2
    URL_MD5 14db4b0d12f07252070b4fe5eb5911f6
    DOWNLOAD_DIR ${SDK_DOWNLOAD_DIR}
    PATCH_COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/openal-soft.patch
    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DALSOFT_UTILS=OFF
        -DALSOFT_NO_CONFIG_UTIL=ON
        -DALSOFT_EXAMPLES=OFF
        -DALSOFT_CONFIG=OFF
        -DALSOFT_HRTF_DEFS=OFF
        -DALSOFT_PKGCONFIG=OFF
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

ExternalProject_Add(glew
    URL http://sourceforge.net/projects/glew/files/glew/1.12.0/glew-1.12.0.tgz/download
    URL_MD5 01246c7ecd135d99be031aa63f86dca1
    DOWNLOAD_DIR ${SDK_DOWNLOAD_DIR}
    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    INSTALL_DIR ${SDK_INSTALL_DIR}
)

# This circumvents a bug in the upstream CMakeLists.txt file
ExternalProject_Add_Step(glew
    installHEADER
    DEPENDEES install
    WORKING_DIRECTORY <INSTALL_DIR>
    COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/include <INSTALL_DIR>/include
    COMMENT "Copy glew header files to SDK"
)

# This circumvents a missing option to prevent installing the executables
# pkgconfig files
ExternalProject_Add_Step(glew
    removeExtraFiles
    DEPENDEES install
    WORKING_DIRECTORY <INSTALL_DIR>
    COMMAND ${CMAKE_COMMAND} -E remove
        <INSTALL_DIR>/bin/glewinfo
        <INSTALL_DIR>/bin/visualinfo
        <INSTALL_DIR>/lib/pkgconfig/glew.pc
        <INSTALL_DIR>/lib/pkgconfig/glewmx.pc
    COMMENT "Remove glew additional files"
)

if(NOT WIN32)
    set(BOOST_CONFIGURE_COMMAND <SOURCE_DIR>/bootstrap.sh)
else()
    set(BOOST_CONFIGURE_COMMAND <SOURCE_DIR>/bootstrap.bat)
endif()

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
    DEPENDS zlib python
    URL http://sourceforge.net/projects/boost/files/boost/1.58.0/boost_1_58_0.tar.gz/download
    URL_MD5 5a5d5614d9a07672e1ab2a250b5defc5
    DOWNLOAD_DIR ${SDK_DOWNLOAD_DIR}
    BUILD_IN_SOURCE 1
    CONFIGURE_COMMAND ${BOOST_CONFIGURE_COMMAND}
    BUILD_COMMAND <SOURCE_DIR>/b2 install
        --user-config=${CMAKE_BINARY_DIR}/boost-config.jam
        --without-coroutine
        --without-mpi
        --without-program_options
        --without-wave
        --prefix=<INSTALL_DIR>
        threading=multi
        link=${BOOST_LINK}
        variant=${BOOST_VARIANT}
        -s NO_BZIP2=1
        -s NO_ZLIB=0
        -s ZLIB_SOURCE=${SDK_INSTALL_DIR}
        -d0 # Please, shut up
    INSTALL_COMMAND ""
    INSTALL_DIR ${SDK_INSTALL_DIR}/Boost
)

set_directory_properties(
    PROPERTIES
    ADDITIONAL_MAKE_CLEAN_FILES
    "${SDK_INSTALL_DIR};${SDK_BINARY_DIR}"
)
