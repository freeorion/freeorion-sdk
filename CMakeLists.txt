if(WIN32)
    set(REQUIRED_CMAKE_VERSION 3.4)
else()
    set(REQUIRED_CMAKE_VERSION 3.2)
endif()

cmake_minimum_required(VERSION ${REQUIRED_CMAKE_VERSION})

option(BUILD_SHARED_LIBS "Build external projects as shared libraries." ON)
option(CMAKE_VERBOSE_MAKEFILE "Build with verbose Makefile output." OFF)
set(DIST_VERSION 0.4.6-2 CACHE STRING "FreeOrionSDK release version.")
set(CMAKE_CXX_STANDARD 11 CACHE STRING "Set the C++ standard the dependencies should be build with.")
set(CMAKE_OSX_DEPLOYMENT_TARGET 10.7 CACHE STRING "Set the minimum OSX deployment target version")
set(CMAKE_OSX_ARCHITECTURES i386 CACHE STRING "Set the architecture the universal binaries for OSX should be built for")
set(CMAKE_INSTALL_MESSAGE NEVER CACHE STRING "Set the verbosity level for the install messages")

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "RelWithDebInfo" CACHE STRING "Set the default build configuration for this build" FORCE)
endif()

function(ExternalProject_PatchSet TARGET_NAME RESULT)
    if(NOT PATCH_EXECUTABLE)
        message(FATAL "No PATCH_EXECUTABLE set, unable to create patch sets")
    endif()
    file(GLOB _PATCHES ${CMAKE_SOURCE_DIR}/patches/${TARGET_NAME}/*.patch)
    list(SORT _PATCHES)
    set(${RESULT} "")
    foreach(_PATCH ${_PATCHES})
        if(NOT ${RESULT})
            set(${RESULT} PATCH_COMMAND)
        else()
            set(${RESULT} ${${RESULT}} COMMAND)
        endif()
        set(${RESULT} ${${RESULT}} ${PATCH_EXECUTABLE} -p1 < ${_PATCH})
    endforeach()
    set(${RESULT} ${${RESULT}} PARENT_SCOPE)
endfunction()

string(REPLACE ";" "$<SEMICOLON>" CMAKE_OSX_ARCHITECTURES_ "${CMAKE_OSX_ARCHITECTURES}")

project(FreeOrionSDK)

include(ExternalProject)

# Root directory of the SDK release.  This directory should contain
# everything a user needs to build FreeOrion from source.
set(SDK_INSTALL_DIR ${CMAKE_BINARY_DIR}/INSTALL)

# List of targets that are required to pack the SDK release.
set(DIST_PACK_TOOLS )

# List of targets that should be packaged for the SDK release.
set(DIST_PACK_TARGETS )

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

# Import dependency source versions, URLs and MD5 checksums.
include(Sources.cmake)

if(WIN32)
    # Windows doesn't provide a basic patch tool, so we download one from the GNUWIN32 project
    ExternalProject_Add(patch
        URL ${PATCH_URL}
        URL_MD5 ${PATCH_MD5}
        DOWNLOAD_DIR ${SDK_DOWNLOAD_DIR}
        # Windows Vista+ introduces UAC, which believes that patch.exe does require administrative
        # privileges.  By installing the manifest we assure that this isn't the case.
        PATCH_COMMAND ${CMAKE_COMMAND} -E copy
            ${CMAKE_SOURCE_DIR}/patches/gnu-utils/exe.manifest
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
        URL ${ZIP_DEPS_URL}
        URL_MD5 ${ZIP_DEPS_MD5}
        DOWNLOAD_DIR ${SDK_DOWNLOAD_DIR}
        CONFIGURE_COMMAND ""
        BUILD_COMMAND ""
        INSTALL_COMMAND ${CMAKE_COMMAND} -E copy
            <SOURCE_DIR>/bin/bzip2.dll
            ${SDK_BINARY_DIR}/bzip2.dll
    )

    ExternalProject_Add(zip
        DEPENDS zip-deps
        URL ${ZIP_URL}
        URL_MD5 ${ZIP_MD5}
        DOWNLOAD_DIR ${SDK_DOWNLOAD_DIR}
        # Windows Vista+ introduces UAC, which believes that patch.exe does require administrative
        # privileges.  By installing the manifest we assure that this isn't the case.
        PATCH_COMMAND ${CMAKE_COMMAND} -E copy
            ${CMAKE_SOURCE_DIR}/patches/gnu-utils/exe.manifest
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
    list(APPEND DIST_PACK_TOOLS zip)
endif()

if(APPLE)
    add_custom_target(tar)
    find_program(TAR_EXECUTABLE tar)
    if(NOT TAR_EXECUTABLE)
        message(FATAL_ERROR "Unable to locate `tar` executable.")
    endif()
    list(APPEND DIST_PACK_TOOLS tar)

    add_custom_target(hdiutil)
    find_program(HDIUTIL_EXECUTABLE hdiutil)
    if(NOT HDIUTIL_EXECUTABLE)
        message(FATAL_ERROR "Unable to locate `hdiutil` executable.")
    endif()
    list(APPEND DIST_PACK_TOOLS hdiutil)
endif()

if(WIN32)
    # Move the installed include dir for the WIN32 SDK
    set(ZLIB_INCLUDE_DIR ${SDK_INSTALL_DIR}/include/zlib)
else()
    set(ZLIB_INCLUDE_DIR ${SDK_INSTALL_DIR}/include)
endif()

ExternalProject_PatchSet(zlib ZLIB_PATCHSET)
ExternalProject_Add(zlib
    DEPENDS patch
    URL ${ZLIB_URL}
    URL_MD5 ${ZLIB_MD5}
    DOWNLOAD_DIR ${SDK_DOWNLOAD_DIR}
    ${ZLIB_PATCHSET}
    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE}
        -DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET}
        -DCMAKE_OSX_ARCHITECTURES=${CMAKE_OSX_ARCHITECTURES_}
        -DCMAKE_INSTALL_MESSAGE=${CMAKE_INSTALL_MESSAGE}
        -DSKIP_INSTALL_FILES=ON
        -DINSTALL_INC_DIR=${ZLIB_INCLUDE_DIR}
    INSTALL_DIR ${SDK_INSTALL_DIR}
)
list(APPEND DIST_PACK_TARGETS zlib)

if(BUILD_SHARED_LIBS)
    set(PNG_SHARED ON)
    set(PNG_STATIC OFF)
else()
    set(PNG_SHARED OFF)
    set(PNG_STATIC ON)
endif()

ExternalProject_PatchSet(libpng LIBPNG_PATCHSET)
ExternalProject_Add(libpng
    DEPENDS patch zlib
    URL ${LIBPNG_URL}
    URL_MD5 ${LIBPNG_MD5}
    DOWNLOAD_DIR ${SDK_DOWNLOAD_DIR}
    ${LIBPNG_PATCHSET}
    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE}
        -DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET}
        -DCMAKE_OSX_ARCHITECTURES=${CMAKE_OSX_ARCHITECTURES_}
        -DCMAKE_INSTALL_MESSAGE=${CMAKE_INSTALL_MESSAGE}
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
list(APPEND DIST_PACK_TARGETS libpng)

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

ExternalProject_PatchSet(python-cmake PYTHON_CMAKE_PATCHSET)
ExternalProject_Add(python-cmake
    DEPENDS patch
    URL ${PYTHON_CMAKE_URL}
    URL_MD5 ${PYTHON_CMAKE_MD5}
    DOWNLOAD_DIR ${SDK_DOWNLOAD_DIR}
    ${PYTHON_CMAKE_PATCHSET}
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
)

ExternalProject_Get_Property(python-cmake SOURCE_DIR)
set(PYTHON_CMAKE_SOURCE_DIR ${SOURCE_DIR})
unset(SOURCE_DIR)


if(WIN32)
    set(PYTHON_CONFIGURE_FLAGS
        -DBUILD_EXTENSIONS_AS_BUILTIN=ON
    )
    set(PYTHON_CONFIGURE_INSTALL_DIR ${SDK_INSTALL_DIR})
else()
    set(PYTHON_CONFIGURE_FLAGS "-DBUILD_FRAMEWORK=ON")
    set(PYTHON_CONFIGURE_INSTALL_DIR ${SDK_INSTALL_DIR}/Frameworks)
endif()

ExternalProject_PatchSet(python PYTHON_PATCHSET)
ExternalProject_Add(python
    DEPENDS ${DIST_PACK_TOOLS} python-cmake zlib
    URL ${PYTHON_URL}
    URL_MD5 ${PYTHON_MD5}
    DOWNLOAD_DIR ${SDK_DOWNLOAD_DIR}
    ${PYTHON_PATCHSET}
    COMMAND
        ${CMAKE_COMMAND} -E copy ${PYTHON_CMAKE_SOURCE_DIR}/CMakeLists.txt <SOURCE_DIR>
    COMMAND
        ${CMAKE_COMMAND} -E copy ${PYTHON_CMAKE_SOURCE_DIR}/CTestConfig.cmake <SOURCE_DIR>
    COMMAND
        ${CMAKE_COMMAND} -E make_directory <SOURCE_DIR>/cmake
    COMMAND
        ${CMAKE_COMMAND} -E copy_directory ${PYTHON_CMAKE_SOURCE_DIR}/cmake/ <SOURCE_DIR>/cmake/
    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE}
        -DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET}
        -DCMAKE_OSX_ARCHITECTURES=${CMAKE_OSX_ARCHITECTURES_}
        -DCMAKE_INSTALL_MESSAGE=${CMAKE_INSTALL_MESSAGE}
        -DCMAKE_PREFIX_PATH=<INSTALL_DIR>
        -DBUILD_LIBPYTHON_SHARED=${BUILD_SHARED_LIBS}
        -DPYTHON_VERSION=${PYTHON_VERSION}
        ${PYTHON_CONFIGURE_FLAGS}
        -DDOWNLOAD_SOURCES=OFF
        -DBUILD_TESTING=OFF
        -DBUILD_WININST=OFF
        -DENABLE_AUDIOOP=OFF
        -DENABLE_BSDDB=OFF
        #DENABLE_BZ2=OFF
        -DENABLE_CODECS_CN=OFF
        -DENABLE_CODECS_HK=OFF
        -DENABLE_CODECS_ISO2022=OFF
        -DENABLE_CODECS_JP=OFF
        -DENABLE_CODECS_KR=OFF
        #DENABLE_CODECS=OFF
        -DENABLE_CODECS_TW=OFF
        #DENABLE_CRYPT=OFF
        -DENABLE_CSV=OFF
        -DENABLE_CTYPES_TEST=OFF
        -DENABLE_CURSES=OFF
        -DENABLE_CURSES_PANEL=OFF
        -DENABLE_DBM=OFF
        -DENABLE_ELEMENTTREE=OFF
        -DENABLE_GDBM=OFF
        -DENABLE_GRP=OFF
        #DENABLE_HASHLIB=OFF
        -DENABLE_HOTSHOT=OFF
        -DENABLE_JSON=OFF
        -DENABLE_LINUXAUDIODEV=OFF
        -DENABLE_MMAP=OFF
        -DENABLE_MULTIBYTECODEC=OFF
        -DENABLE_MULTIPROCESSING=OFF
        -DENABLE_NIS=OFF
        -DENABLE_OSSAUDIODEV=OFF
        -DENABLE_PARSER=OFF
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
list(APPEND DIST_PACK_TARGETS python)

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
        COMMAND ${ZIP_EXECUTABLE} -r -9 -q --exclude=*.pyc
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

ExternalProject_PatchSet(freetype FREETYPE_PATCHSET)
ExternalProject_Add(freetype
    DEPENDS patch
    URL ${FREETYPE_URL}
    URL_MD5 ${FREETYPE_MD5}
    DOWNLOAD_DIR ${SDK_DOWNLOAD_DIR}
    ${FREETYPE_PATCHSET}
    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
        # FreeType doesn't provide any exported symbols, so build
        # it as static library.
        -DBUILD_SHARED_LIBS=OFF
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE}
        -DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET}
        -DCMAKE_OSX_ARCHITECTURES=${CMAKE_OSX_ARCHITECTURES_}
        -DCMAKE_INSTALL_MESSAGE=${CMAKE_INSTALL_MESSAGE}
    INSTALL_DIR ${SDK_INSTALL_DIR}
)
list(APPEND DIST_PACK_TARGETS freetype)

if(WIN32)
    set(SDL_CONFIGURE_FLAGS "")
    set(SDL_CONFIGURE_INSTALL_DIR ${SDK_INSTALL_DIR})
else()
    set(SDL_CONFIGURE_FLAGS
        -DBUILD_FRAMEWORK=ON
    )
    set(SDL_CONFIGURE_INSTALL_DIR ${SDK_INSTALL_DIR}/Frameworks)
endif()

ExternalProject_PatchSet(sdl SDL_PATCHSET)
ExternalProject_Add(sdl
    DEPENDS patch
    URL ${SDL_URL}
    URL_MD5 ${SDL_MD5}
    DOWNLOAD_DIR ${SDK_DOWNLOAD_DIR}
    ${SDL_PATCHSET}
    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE}
        -DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET}
        -DCMAKE_OSX_ARCHITECTURES=${CMAKE_OSX_ARCHITECTURES_}
        -DCMAKE_INSTALL_MESSAGE=${CMAKE_INSTALL_MESSAGE}
        -DSDL_STATIC=OFF
        -DDIRECTX=OFF
        -DRENDER_D3D=OFF
        ${SDL_CONFIGURE_FLAGS}
    INSTALL_DIR ${SDL_CONFIGURE_INSTALL_DIR}
)
list(APPEND DIST_PACK_TARGETS sdl)

if(WIN32)
    set(LIBOGG_CONFIGURE_FLAGS "")
    set(LIBOGG_CONFIGURE_INSTALL_DIR ${SDK_INSTALL_DIR})
else()
    set(LIBOGG_CONFIGURE_FLAGS "-DBUILD_FRAMEWORK=ON")
    set(LIBOGG_CONFIGURE_INSTALL_DIR ${SDK_INSTALL_DIR}/Frameworks)
endif()

ExternalProject_PatchSet(libogg LIBOGG_PATCHSET)
ExternalProject_Add(libogg
    DEPENDS patch
    URL ${LIBOGG_URL}
    URL_MD5 ${LIBOGG_MD5}
    DOWNLOAD_DIR ${SDK_DOWNLOAD_DIR}
    ${LIBOGG_PATCHSET}
    COMMAND ${CMAKE_COMMAND} -E rename
        <SOURCE_DIR>/configure.in
        <SOURCE_DIR>/configure.ac
    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE}
        -DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET}
        -DCMAKE_OSX_ARCHITECTURES=${CMAKE_OSX_ARCHITECTURES_}
        -DCMAKE_INSTALL_MESSAGE=${CMAKE_INSTALL_MESSAGE}
        ${LIBOGG_CONFIGURE_FLAGS}
    INSTALL_DIR ${LIBOGG_CONFIGURE_INSTALL_DIR}
)
list(APPEND DIST_PACK_TARGETS libogg)

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

ExternalProject_PatchSet(libvorbis LIBVORBIS_PATCHSET)
ExternalProject_Add(libvorbis
    DEPENDS patch libogg
    URL ${LIBVORBIS_URL}
    URL_MD5 ${LIBVORBIS_MD5}
    DOWNLOAD_DIR ${SDK_DOWNLOAD_DIR}
    ${LIBVORBIS_PATCHSET}
    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE}
        -DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET}
        -DCMAKE_OSX_ARCHITECTURES=${CMAKE_OSX_ARCHITECTURES_}
        -DCMAKE_INSTALL_MESSAGE=${CMAKE_INSTALL_MESSAGE}
        ${LIBVORBIS_CONFIGURE_FLAGS}
    INSTALL_DIR ${LIBVORBIS_CONFIGURE_INSTALL_DIR}
)
list(APPEND DIST_PACK_TARGETS libvorbis)

if(NOT APPLE)
    ExternalProject_PatchSet(openal-soft OPENAL_SOFT_PATCHSET)
    ExternalProject_Add(openal-soft
        DEPENDS patch
        URL ${OPENAL_SOFT_URL}
        URL_MD5 ${OPENAL_SOFT_MD5}
        DOWNLOAD_DIR ${SDK_DOWNLOAD_DIR}
        ${OPENAL_SOFT_PATCHSET}
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
    list(APPEND DIST_PACK_TARGETS openal-soft)
endif()

ExternalProject_PatchSet(glew GLEW_PATCHSET)
ExternalProject_Add(glew
    DEPENDS patch
    URL ${GLEW_URL}
    URL_MD5 ${GLEW_MD5}
    DOWNLOAD_DIR ${SDK_DOWNLOAD_DIR}
    ${GLEW_PATCHSET}
    CONFIGURE_COMMAND ${CMAKE_COMMAND}
        -G "${CMAKE_GENERATOR}"
        -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE}
        -DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET}
        -DCMAKE_OSX_ARCHITECTURES=${CMAKE_OSX_ARCHITECTURES_}
        -DCMAKE_INSTALL_MESSAGE=${CMAKE_INSTALL_MESSAGE}
        -DBUILD_UTILS=OFF
        <SOURCE_DIR>/build/cmake/
    INSTALL_DIR ${SDK_INSTALL_DIR}
)
list(APPEND DIST_PACK_TARGETS glew)

if(NOT WIN32)
    set(BOOST_CONFIGURE_COMMAND <SOURCE_DIR>/bootstrap.sh)
    set(BOOST_CONFIGURE_FLAGS
        macosx-version-min=${CMAKE_OSX_DEPLOYMENT_TARGET}
        architecture=x86
    )
    set(BOOST_ARCHITECTURES)
    foreach(_OSX_ARCH IN LISTS CMAKE_OSX_ARCHITECTURES)
        set(BOOST_ARCHITECTURES "${BOOST_ARCHITECTURES} -arch ${_OSX_ARCH}")
    endforeach()
    if(CMAKE_CXX_STANDARD GREATER 10)
        list(APPEND BOOST_CONFIGURE_FLAGS
            "cxxflags=-std=c++${CMAKE_CXX_STANDARD} -stdlib=libc++ ${BOOST_ARCHITECTURES}"
            "cflags=${BOOST_ARCHITECTURES}"
            "linkflags=-stdlib=libc++ ${BOOST_ARCHITECTURES}"
        )
    endif()
    set(BOOST_TOOLSET clang)
    set(BOOST_CONFIGURE_INSTALL_DIR ${SDK_INSTALL_DIR})
    set(BOOST_OSX_SYSROOT ${CMAKE_OSX_SYSROOT})
    # strip concrete mac osx directory to allow boost build the detection of
    # available SDKs.
    get_filename_component(BOOST_OSX_SYSROOT "${BOOST_OSX_SYSROOT}" DIRECTORY)
    get_filename_component(BOOST_OSX_SYSROOT "${BOOST_OSX_SYSROOT}" DIRECTORY)
else()
    set(BOOST_CONFIGURE_COMMAND <SOURCE_DIR>/bootstrap.bat)
    string(REGEX REPLACE "^v([1-9][0-9]*)(_(.*))?$" "\\1;\\3" _VS_PLATFORM_TOOLSET "${CMAKE_VS_PLATFORM_TOOLSET}")
    list(GET _VS_PLATFORM_TOOLSET 0 _VS_PLATFORM_TOOLSET_VERSION)
    list(GET _VS_PLATFORM_TOOLSET 1 _VS_PLATFORM_TOOLSET_TARGET)
    math(EXPR _VS_PLATFORM_TOOLSET_VERSION "${_VS_PLATFORM_TOOLSET_VERSION}/10")
    set(_VS_PLATFORM_TOOLSET_VERSION "${_VS_PLATFORM_TOOLSET_VERSION}.0")
    set(BOOST_CONFIGURE_FLAGS
        debug-store=database
    )
    if("${_VS_PLATFORM_TOOLSET_TARGET}" STREQUAL "xp")
        list(APPEND BOOST_CONFIGURE_FLAGS define=BOOST_USE_WINAPI_VERSION=BOOST_WINAPI_VERSION_WINXP)
    endif()
    set(BOOST_TOOLSET msvc-${_VS_PLATFORM_TOOLSET_VERSION})
    set(BOOST_CONFIGURE_INSTALL_DIR ${SDK_INSTALL_DIR}/Boost)
    set(BOOST_OSX_SYSROOT "")
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

if(APPLE)
    set(PYTHON_INSTALL_DIR ${SDK_INSTALL_DIR}/Frameworks/Python.framework/Versions/${PYTHON_VERSION})
else()
    set(PYTHON_INSTALL_DIR ${SDK_INSTALL_DIR})
endif()

configure_file(
    boost-config.jam.in
    boost-config.jam
)

ExternalProject_Add(boost
    DEPENDS patch zlib python
    URL ${BOOST_URL}
    URL_MD5 ${BOOST_MD5}
    DOWNLOAD_DIR ${SDK_DOWNLOAD_DIR}
    BUILD_IN_SOURCE 1
    PATCH_COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/boost-0-install_pdb_files_for_debug_and_relwithdebinfo.patch
    COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/boost-1-remove_version_suffix_from_include_directory.patch
    COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/boost-2-prevent-multiple-definitions-of-BOOST_ASIO_ERROR_CATEGORY_NOEXCEPT.patch
    COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/boost-4-Print-selected-configurations-for-darwin-compiler.patch
    COMMAND
        ${PATCH_EXECUTABLE} -p1 < ${CMAKE_SOURCE_DIR}/patches/boost-5-Remove-SDK-subdirectory-it-doesn-t-exist-in-the-new-.patch
    CONFIGURE_COMMAND ${BOOST_CONFIGURE_COMMAND}
    BUILD_COMMAND <SOURCE_DIR>/b2 install
        toolset=${BOOST_TOOLSET}
        -d
        --debug-configuration
        --user-config=${CMAKE_BINARY_DIR}/boost-config.jam
        --without-context
        --without-coroutine
        --without-coroutine2
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
        -s NO_ZLIB=0
        # Build documentation for boost::iostreams is outdated.
        # Starting with 1.55 the zlib dependency detection uses the boost.build
        # zlib tool, not using ZLIB_LIBPATH anymore.  The new parameters are
        # documented in source here:
        # https://github.com/boostorg/build/blob/boost-1.59.0/src/tools/zlib.jam#L40
        -s ZLIB_INCLUDE=${ZLIB_INCLUDE_DIR}
        -s ZLIB_LIBRARY_PATH=${SDK_INSTALL_DIR}/lib
    INSTALL_COMMAND ""
    INSTALL_DIR ${BOOST_CONFIGURE_INSTALL_DIR}
)
list(APPEND DIST_PACK_TARGETS boost)

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
    file(
        COPY
            ${CMAKE_SOURCE_DIR}/bootstrap.command
        DESTINATION
            ${SDK_INSTALL_DIR}/../
    )

    add_custom_target(pre-pack
        DEPENDS
        ${DIST_PACK_TOOLS}
        ${DIST_PACK_TARGETS}
    WORKING_DIRECTORY
        ${SDK_INSTALL_DIR}/..
    COMMAND
        ${TAR_EXECUTABLE} cjf
        dep.tar.bz2
        dep
    COMMAND
        ${CMAKE_COMMAND} -E remove_directory
        ${SDK_INSTALL_DIR}
    )
    list(APPEND DIST_PACK_TARGETS pre-pack)
else()
    message(FATAL "Target system not yet supported")
endif()

set(DIST_TOOLSET ${CMAKE_CXX_COMPILER_ID})
if(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
    string(REPLACE "_" "-" _VS_PLATFORM_TOOLSET "${CMAKE_VS_PLATFORM_TOOLSET}")
    set(DIST_TOOLSET ${DIST_TOOLSET}-${_VS_PLATFORM_TOOLSET})
endif()
if(CMAKE_CXX_COMPILER_ID MATCHES "AppleClang")
    string(REPLACE ";" "-" _OSX_ARCHITECTURES "${CMAKE_OSX_ARCHITECTURES}")
    set(DIST_TOOLSET Clang-MacOSX-${CMAKE_OSX_DEPLOYMENT_TARGET}-${_OSX_ARCHITECTURES})
endif()

if(WIN32)
    set(DIST_PACK_COMMAND ${ZIP_EXECUTABLE} -r -q -9)
    set(DIST_PACK_EXT zip)
    set(DIST_PACK_WORKING_DIR ${SDK_INSTALL_DIR})
    set(DIST_PACK_SOURCE .)
else()
    set(DIST_PACK_COMMAND ${HDIUTIL_EXECUTABLE} create -volname ${PROJECT_NAME} -format UDZO -srcfolder .)
    set(DIST_PACK_EXT dmg)
    # SDK_INSTALL_DIR points to the `dep` subdirectory
    set(DIST_PACK_WORKING_DIR ${SDK_INSTALL_DIR}/..)
    set(DIST_PACK_SOURCE)
endif()

set(DIST_ARTIFACT "${CMAKE_BINARY_DIR}/${PROJECT_NAME}_${DIST_VERSION}_${DIST_TOOLSET}.${DIST_PACK_EXT}")

add_custom_target(pack ALL
    DEPENDS
        ${DIST_PACK_TOOLS}
        ${DIST_PACK_TARGETS}
    WORKING_DIRECTORY
        ${DIST_PACK_WORKING_DIR}
    COMMAND
        ${DIST_PACK_COMMAND} ${DIST_ARTIFACT} ${DIST_PACK_SOURCE}
    COMMENT
        "Packaging build artifact \"${DIST_ARTIFACT}\""
)

set_directory_properties(
    PROPERTIES
    ADDITIONAL_MAKE_CLEAN_FILES
    "${SDK_INSTALL_DIR};${SDK_BINARY_DIR}"
)
