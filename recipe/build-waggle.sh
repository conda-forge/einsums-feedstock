#!/bin/bash
set -euxo pipefail

# The Python package and waggle._core go to site-packages, given relative to the prefix.
SP_REL="${SP_DIR#${PREFIX}/}"

# Every Python variant builds in the same work directory; the previous one's cache would point
# CMake at a Python whose host environment is gone.
rm -rf build-waggle

# Waggle's own suite stays off: it needs a runner set up to let a process read its counters,
# record signposts and advertise over mDNS, which a conda-forge builder is not.
cmake ${CMAKE_ARGS} \
  -S ${SRC_DIR}/waggle-src \
  -B build-waggle \
  -G Ninja \
  -D CMAKE_BUILD_TYPE=Release \
  -D CMAKE_INSTALL_LIBDIR=lib \
  -D Python_EXECUTABLE=${PYTHON} \
  -D WAGGLE_BUILD_PYTHON=ON \
  -D WAGGLE_PYTHON_INSTALL_DIR=${SP_REL} \
  -D WAGGLE_BUILD_TESTS=OFF \
  -D WAGGLE_BUILD_DOCS=OFF

cmake --build build-waggle -j${CPU_COUNT}
cmake --install build-waggle
