cmake %CMAKE_ARGS% ^
  -G "Ninja" ^
  -S %SRC_DIR% ^
  -B build ^
  -D CMAKE_BUILD_TYPE=Release ^
  -D CMAKE_INSTALL_PREFIX="%PREFIX%" ^
  -D CMAKE_C_COMPILER=clang-cl ^
  -D CMAKE_C_FLAGS="%CFLAGS%" ^
  -D CMAKE_CXX_COMPILER=clang-cl ^
  -D CMAKE_CXX_FLAGS="%CXXFLAGS%" ^
  -D CMAKE_INSTALL_LIBDIR="Library\\lib" ^
  -D CMAKE_INSTALL_INCLUDEDIR="Library\\include" ^
  -D CMAKE_INSTALL_BINDIR="Scripts" ^
  -D CMAKE_INSTALL_DATADIR="Library\\share" ^
  -D EINSUMS_STATIC_BUILD=OFF ^
  -D EINSUMS_USE_HPTT=ON ^
  -D FETCHCONTENT_QUIET=OFF ^
  -D CMAKE_REQUIRE_FIND_PACKAGE_Catch2=ON ^
  -D CMAKE_REQUIRE_FIND_PACKAGE_fmt=ON ^
  -D CMAKE_REQUIRE_FIND_PACKAGE_range-v3=ON ^
  -D CMAKE_VERBOSE_MAKEFILE=OFF ^
  -D CMAKE_PREFIX_PATH="%LIBRARY_PREFIX%"
if errorlevel 1 exit 1

cmake --build build ^
      --config Release ^
      --target install ^
      -- -j %CPU_COUNT%
if errorlevel 1 exit 1
