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

set(ZLIB_VERSION 1.2.11)
set(ZLIB_URL http://downloads.sourceforge.net/project/libpng/zlib/${ZLIB_VERSION}/zlib-${ZLIB_VERSION}.tar.gz)
set(ZLIB_MD5 1c9f62f0778697a09d36121ead88e08e)

set(LIBPNG_VERSION 1.6.37)
set(LIBPNG_URL https://downloads.sourceforge.net/project/libpng/libpng16/${LIBPNG_VERSION}/libpng-${LIBPNG_VERSION}.tar.gz)
set(LIBPNG_MD5 6c7519f6c75939efa0ed3053197abd54)

set(PYTHON_CMAKE_HASH c8ebbcde77433daf17c6e91f8bc7041c380bc61c)
set(PYTHON_CMAKE_URL https://github.com/freeorion/python-cmake-buildsystem/archive/${PYTHON_CMAKE_HASH}.zip)
set(PYTHON_CMAKE_MD5 ef568d9a803ef4fdc7dcd0453742f3ed)

set(PYTHON3_VERSION 3.9.21)
set(PYTHON3_URL https://www.python.org/ftp/python/${PYTHON3_VERSION}/Python-${PYTHON3_VERSION}.tgz)
set(PYTHON3_MD5 e61b3568082b57d55fd74cfc7ca020b4)

set(FREETYPE_VERSION 2.9)
set(FREETYPE_URL http://downloads.sourceforge.net/project/freetype/freetype2/${FREETYPE_VERSION}/freetype-${FREETYPE_VERSION}.tar.gz)
set(FREETYPE_MD5 d23a1b246e78890458c6672cb45eacd0)

set(SDL_VERSION 2.26.0)
set(SDL_URL https://www.libsdl.org/release/SDL2-${SDL_VERSION}.tar.gz)
set(SDL_MD5 35bc58cfe41b8fb6c8e6646be26fa47e)

set(LIBOGG_VERSION 1.3.2)
set(LIBOGG_URL http://downloads.xiph.org/releases/ogg/libogg-${LIBOGG_VERSION}.tar.gz)
set(LIBOGG_MD5 b72e1a1dbadff3248e4ed62a4177e937)

set(LIBVORBIS_VERSION 1.3.5)
set(LIBVORBIS_URL http://downloads.xiph.org/releases/vorbis/libvorbis-${LIBVORBIS_VERSION}.tar.gz)
set(LIBVORBIS_MD5 7220e089f3be3412a2317d6fde9e3944)

set(OPENAL_SOFT_VERSION 1.18.2)
set(OPENAL_SOFT_URL https://github.com/kcat/openal-soft/archive/openal-soft-${OPENAL_SOFT_VERSION}.tar.gz)
set(OPENAL_SOFT_MD5 fa2cb3df766ab5976c86efbcc1d24d68)

set(GLEW_VERSION 2.2.0)
set(GLEW_URL http://downloads.sourceforge.net/project/glew/glew/${GLEW_VERSION}/glew-${GLEW_VERSION}.tgz)
set(GLEW_MD5 3579164bccaef09e36c0af7f4fd5c7c7)

set(BOOST_VERSION 1.87.0)
string(REPLACE "." "_" BOOST_VERSION_ ${BOOST_VERSION})
set(BOOST_URL https://downloads.sourceforge.net/project/boost/boost/${BOOST_VERSION}/boost_${BOOST_VERSION_}.tar.gz)
set(BOOST_MD5 f435e8ae57edb203a1165cdb99cfb2a3)
