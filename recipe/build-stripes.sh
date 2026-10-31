#!/bin/bash
set -euxo pipefail

# Stripes' own suite stays off: Einsums' tests in the einsums output exercise it, the dispatch to
# every rung the build machine has included.
cmake ${CMAKE_ARGS} \
  -S ${SRC_DIR}/stripes-src \
  -B build-stripes \
  -G Ninja \
  -D CMAKE_BUILD_TYPE=Release \
  -D CMAKE_INSTALL_LIBDIR=lib \
  -D STRIPES_WITH_TESTS=OFF \
  -D STRIPES_WITH_EXAMPLES=OFF \
  -D STRIPES_WITH_BENCHMARKS=OFF

cmake --build build-stripes -j${CPU_COUNT}
cmake --install build-stripes
