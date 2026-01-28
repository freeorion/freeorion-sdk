# This file contains CMake variable definitions for the various dependency
# versions, the source package URLs MD5 checksums of the source packages. The
# leading part of the variable corresponds with the name of the target the
# value triplet belongs to.
#
# This file is used to allow the CI systems to keep the download cache only
# dependent on the actual versions, URLs and MD5 sums.
set(PATCH_VERSION 2.5.9-7)
set(PATCH_URL http://downloads.sourceforge.net/project/gnuwin32/patch/${PATCH_VERSION}/patch-${PATCH_VERSION}-bin.zip)
set(PATCH_MD5 b9c8b31d62f4b2e4f1887bbb63e8a905)

set(ZIP_VERSION 3.0)
set(ZIP_DEPS_URL http://downloads.sourceforge.net/project/gnuwin32/zip/${ZIP_VERSION}/zip-${ZIP_VERSION}-dep.zip)
set(ZIP_DEPS_MD5 8bd9a45e1259238c1f6bb277fe6386c0)
set(ZIP_URL http://downloads.sourceforge.net/project/gnuwin32/zip/${ZIP_VERSION}/zip-${ZIP_VERSION}-bin.zip)
set(ZIP_MD5 5b268fe06ce5f89bc5762805a7a9d7aa)

set(ZLIB_VERSION 1.3.1)
set(ZLIB_URL https://zlib.net/zlib-${ZLIB_VERSION}.tar.gz)
set(ZLIB_MD5 9855b6d802d7fe5b7bd5b196a2271655)

set(LIBPNG_VERSION 1.6.53)
set(LIBPNG_URL https://download.sourceforge.net/libpng/libpng-${LIBPNG_VERSION}.tar.gz)
set(LIBPNG_MD5 26a61c77606a21583346316add2891a9)

set(PYTHON_CMAKE_HASH 52b4f065eefd3ba0a2fb4a48cfa6871ac1924249)
set(PYTHON_CMAKE_URL https://github.com/freeorion/python-cmake-buildsystem/archive/${PYTHON_CMAKE_HASH}.zip)
set(PYTHON_CMAKE_MD5 2fe9f2a445978ba28ad013e1751d9fb8)

set(PYTHON3_VERSION 3.10.16)
set(PYTHON3_URL https://www.python.org/ftp/python/${PYTHON3_VERSION}/Python-${PYTHON3_VERSION}.tgz)
set(PYTHON3_MD5 2515d8571c6fdd7fc620aa9e1cc6d202)

set(FREETYPE_VERSION 2.14.1)
set(FREETYPE_URL https://downloads.sourceforge.net/project/freetype/freetype2/${FREETYPE_VERSION}/freetype-${FREETYPE_VERSION}.tar.gz)
set(FREETYPE_MD5 d8c8b0c3a6d4c7ed4c90e1a8c7171887)

set(SDL_VERSION 2.32.10)
set(SDL_URL https://www.libsdl.org/release/SDL2-${SDL_VERSION}.tar.gz)
set(SDL_MD5 7b234751c91737168d88c83041ca5aa9)

set(LIBOGG_VERSION 1.3.6)
set(LIBOGG_URL https://ftp.osuosl.org/pub/xiph/releases/ogg/libogg-${LIBOGG_VERSION}.tar.gz)
set(LIBOGG_MD5 e2ab08345a440d32e88b2156cf499eb9)

set(LIBVORBIS_VERSION 1.3.7)
set(LIBVORBIS_URL https://ftp.osuosl.org/pub/xiph/releases/vorbis/libvorbis-${LIBVORBIS_VERSION}.tar.gz)
set(LIBVORBIS_MD5 9b8034da6edc1a17d18b9bc4542015c7)

set(OPENAL_SOFT_VERSION 1.18.2)
set(OPENAL_SOFT_URL https://github.com/kcat/openal-soft/archive/openal-soft-${OPENAL_SOFT_VERSION}.tar.gz)
set(OPENAL_SOFT_MD5 fa2cb3df766ab5976c86efbcc1d24d68)

set(GLEW_VERSION 2.3.0)
set(GLEW_URL https://downloads.sourceforge.net/project/glew/glew/${GLEW_VERSION}/glew-${GLEW_VERSION}.tgz)
set(GLEW_MD5 1b321240e1f6651175e953b46bccb3f2)

set(BOOST_VERSION 1.88.0)
string(REPLACE "." "_" BOOST_VERSION_ ${BOOST_VERSION})
set(BOOST_URL https://downloads.sourceforge.net/project/boost/boost/${BOOST_VERSION}/boost_${BOOST_VERSION_}.tar.gz)
set(BOOST_MD5 6cd58b3cc890e4fbbc036c7629129e18)
