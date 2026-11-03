#!/bin/bash
set -euxo pipefail

# The same libc++ availability override and BLAS vendor as build-cxx.sh, which explains both.
if [[ "${target_platform}" == osx-* ]]; then
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi
# The codegen runs apiary's scripts out of the host prefix; their bytecode would land in apiary's
# directory and be packaged here.
export PYTHONDONTWRITEBYTECODE=1

# The bindings link the C++ library, so this configures and builds it again; only the Python
# component is installed, since the einsums output already holds the rest. Every Python variant
# builds in the same work directory, so each starts from an empty build tree, as build-waggle.sh does.
rm -rf build-py
cmake ${CMAKE_ARGS} \
  -S ${SRC_DIR} \
  -B build-py \
  -G Ninja \
  -D CMAKE_BUILD_TYPE=Release \
  -D CMAKE_INSTALL_LIBDIR=lib \
  -D Python_EXECUTABLE=${PYTHON} \
  -D EINSUMS_BUILD_PYTHON=ON \
  -D EINSUMS_INSTALL_PYMODDIR=prefix \
  -D EINSUMS_WITH_TESTS=OFF \
  -D EINSUMS_WITH_DOCUMENTATION=OFF \
  -D EINSUMS_WITH_EXAMPLES=OFF \
  -D BLA_VENDOR=Generic \
  -D FETCHCONTENT_FULLY_DISCONNECTED=ON \
  -D CMAKE_REQUIRE_FIND_PACKAGE_fmt=ON \
  -D CMAKE_REQUIRE_FIND_PACKAGE_cpptrace=ON \
  -D CMAKE_REQUIRE_FIND_PACKAGE_spdlog=ON \
  -D CMAKE_REQUIRE_FIND_PACKAGE_mimalloc=ON \
  -D CMAKE_REQUIRE_FIND_PACKAGE_Apiary=ON \
  -D CMAKE_REQUIRE_FIND_PACKAGE_Stripes=ON \
  -D CMAKE_REQUIRE_FIND_PACKAGE_Waggle=ON

cmake --build build-py -j${CPU_COUNT}
# The Python package (einsums/, its stubs and _core) and the einsums launcher.
cmake --install build-py --component EinsumsPy
