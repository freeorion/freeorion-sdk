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

set_directory_properties(
    PROPERTIES
    ADDITIONAL_MAKE_CLEAN_FILES
    ${SDK_INSTALL_DIR}
)
