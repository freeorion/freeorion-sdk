cmake_minimum_required(VERSION 2.8)

project(FreeOrionSDK)

include(ExternalProject)

# Root directory of the SDK release.  This directory should contain
# everything a user needs to build FreeOrion from source.
set(SDK_INSTALL_DIR ${CMAKE_BINARY_DIR}/INSTALL)

# Common download directory for all dependency source releases.  Storing
# those in a separate directory from the standard *-prefix directories
# prevents re-downloading them when cleaning up the SDK build.
set(SDK_DOWNLOAD_DIR downloads)

ExternalProject_Add(zlib
    URL http://sourceforge.net/projects/libpng/files/zlib/1.2.8/zlib-1.2.8.tar.gz/download
    URL_MD5 44d667c142d7cda120332623eab69f40
    DOWNLOAD_DIR ${SDK_DOWNLOAD_DIR}
    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
        -DSKIP_INSTALL_FILES=ON
    INSTALL_DIR ${SDK_INSTALL_DIR}
)

ExternalProject_Add(libpng
    DEPENDS zlib
    URL http://sourceforge.net/projects/libpng/files/libpng16/1.6.17/libpng-1.6.17.tar.gz/download
    URL_MD5 134282f1752dcf4cd81a37b8ff421cef
    DOWNLOAD_DIR ${SDK_DOWNLOAD_DIR}
    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
        -DPNG_STATIC=OFF
        -DPNG_TESTS=OFF
        -DSKIP_INSTALL_EXECUTABLES=ON
        -DSKIP_INSTALL_FILES=ON
        -DSKIP_INSTALL_EXPORT=ON
        -DZLIB_ROOT=<INSTALL_DIR>
    INSTALL_DIR ${SDK_INSTALL_DIR}
)

ExternalProject_Add(freetype2
    URL http://sourceforge.net/projects/freetype/files/freetype2/2.5.5/freetype-2.5.5.tar.gz/download
    URL_MD5 7448edfbd40c7aa5088684b0a3edb2b8
    DOWNLOAD_DIR ${SDK_DOWNLOAD_DIR}
    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
    INSTALL_DIR ${SDK_INSTALL_DIR}
)

ExternalProject_Add(sdl
    URL https://www.libsdl.org/release/SDL2-2.0.3.tar.gz
    URL_MD5 fe6c61d2e9df9ef570e7e80c6e822537
    DOWNLOAD_DIR ${SDK_DOWNLOAD_DIR}
    CMAKE_ARGS
        -DSDL_STATIC=OFF
        -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
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

set_directory_properties(
    PROPERTIES
    ADDITIONAL_MAKE_CLEAN_FILES
    ${SDK_INSTALL_DIR}
)
