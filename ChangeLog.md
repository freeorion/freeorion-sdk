# Changelog

Notable changes to the FreeOrionSDK project will be documented in this file.


## [next] - TBA

Initial changelog for the first automatic created FreeOrionSDK.  It documents
the differences between the manual maintained old SDK and the new one.

- [ANY] Updated Boost from 1.58(WIN)/1.56(OSX) to 1.59.
- [ANY] Updated GLEW from 1.12.0 to 1.13.0.
- [ANY] Updated libpng from 1.6.17(WIN)/1.5.12(OSX) to 1.6.25.
- [ANY] Updated Python from 2.7.9(WIN)/2.7.8(OSX) to 2.7.12.
- [ANY] Updated SDL from 2.0.3 to 2.0.4.
- [ANY] Dropped unused FreeALUT dependency.
- [ANY] Dropped unused FreeImage dependency.
- [WIN] Changed SDK artifact file name from
  `FreeOrion_VS<VisualStudio version>_SDK_<short month name>_<4-digit year>.zip`
  to `FreeOrionSDK_<toolchain name>-<toolset version>_<ISO 8601 date>.zip`.
- [OSX] Changed SDK artifact file name from
  `FreeOrion_SDK_MacOSX_<OSX version>_<OSX arch>_<ISO 8601 date>.bz2`
  to `FreeOrionSDK_<toolchain name>_<ISO 8601 date>.bz2`.
- [WIN] Moved shared libaries from `temp` into `bin` directory.  Updated
  `bootstrap.bat` accordingly.
- [WIN] Updated OpenAL Soft dependency from 1.15.0 to 1.17.2.
- [WIN] Remove invalid platform configuration files in python dependency stdlib.
- [OSX] Updated libogg dependency from 1.1.2 to 1.3.2.
- [OSX] Updated FreeType2 from 2.3.11 to 2.5.5.
- [OSX] Remove Radicale WebDAV installation(???) from python site-packages.
- [OSX] Renamed vorbis.framework to Vorbis.framework.
- [OSX] Updated libvorbis from 1.1.1 to 1.3.5.
