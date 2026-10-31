#!/bin/bash
set -euxo pipefail

# libc++ marks the floating-point std::to_chars and std::from_chars (Json) unavailable on every
# macOS, because it judges by the system libc++. The libc++ these packages load is conda-forge's
# libcxx, which has them.
if [[ "${target_platform}" == osx-* ]]; then
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

# conda-forge links against the netlib interface libraries, which users switch to OpenBLAS, MKL or
# Accelerate at install time. CBLAS is its own library there, and Einsums calls it for the complex
# dot products, so the libraries are named instead of detected (FindTargetLAPACK honors this).
EINSUMS_LAPACK_LIBRARIES="${PREFIX}/lib/liblapack${SHLIB_EXT};${PREFIX}/lib/libcblas${SHLIB_EXT};${PREFIX}/lib/libblas${SHLIB_EXT}"

# The suite runs wherever the build can execute what it compiles: every native build, osx-arm64
# included, and a cross build that has an emulator.
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || -n "${CROSSCOMPILING_EMULATOR:-}" ]]; then
    RUN_TESTS=1
    TEST_ARGS="-D EINSUMS_WITH_TESTS=ON -D EINSUMS_WITH_TESTS_HEADERS=OFF -D EINSUMS_WITH_TESTS_BENCHMARKS=OFF -D EINSUMS_WITH_TESTS_EXAMPLES=OFF -D CMAKE_REQUIRE_FIND_PACKAGE_Catch2=ON"
else
    RUN_TESTS=0
    TEST_ARGS="-D EINSUMS_WITH_TESTS=OFF"
fi

# Every dependency comes from the host environment: a FetchContent download here would ship a
# second copy of a package conda-forge already provides.
cmake ${CMAKE_ARGS} ${TEST_ARGS} \
  -S ${SRC_DIR} \
  -B build \
  -G Ninja \
  -D CMAKE_BUILD_TYPE=Release \
  -D CMAKE_INSTALL_LIBDIR=lib \
  -D EINSUMS_BUILD_PYTHON=OFF \
  -D EINSUMS_WITH_DOCUMENTATION=OFF \
  -D EINSUMS_WITH_EXAMPLES=OFF \
  -D LAPACK_LIBRARIES="${EINSUMS_LAPACK_LIBRARIES}" \
  -D FETCHCONTENT_FULLY_DISCONNECTED=ON \
  -D CMAKE_REQUIRE_FIND_PACKAGE_fmt=ON \
  -D CMAKE_REQUIRE_FIND_PACKAGE_cpptrace=ON \
  -D CMAKE_REQUIRE_FIND_PACKAGE_spdlog=ON \
  -D CMAKE_REQUIRE_FIND_PACKAGE_mimalloc=ON \
  -D CMAKE_REQUIRE_FIND_PACKAGE_Apiary=ON \
  -D CMAKE_REQUIRE_FIND_PACKAGE_Stripes=ON \
  -D CMAKE_REQUIRE_FIND_PACKAGE_Waggle=ON

cmake --build build -j${CPU_COUNT}
cmake --install build

if [[ "${RUN_TESTS}" == "1" ]]; then
    ctest --test-dir build --output-on-failure -j${CPU_COUNT}
fi
