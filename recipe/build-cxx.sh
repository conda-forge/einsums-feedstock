if [ "$(uname)" == "Darwin" ]; then
    # avoid "error: use of undeclared identifier 'aligned_alloc'; did you mean 'omp_aligned_alloc'?"
    ARCH_ARGS="-DEINSUMS_H5CPP_USE_OMP_ALIGNED_ALLOC=ON"
    # avoid "error: 'bad_variant_access' is unavailable: introduced in macOS 10.13"
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

    # c-f-provided CMAKE_ARGS handles CMAKE_OSX_DEPLOYMENT_TARGET, CMAKE_OSX_SYSROOT
fi
if [ "$(uname)" == "Linux" ]; then
    ARCH_ARGS=""

fi

if [[ "$target_platform" == "osx-arm64" ]]; then
    echo "Skipping tests on macOS ARM"
    ARCH_ARGS="${ARCH_ARGS} -D EINSUMS_WITH_TESTS=OFF"
else
    ARCH_ARGS="${ARCH_ARGS} -D EINSUMS_WITH_TESTS=ON -D CMAKE_REQUIRE_FIND_PACKAGE_Catch2=ON"
fi

# Einsums target platform specific options
plat_args=()

${BUILD_PREFIX}/bin/cmake ${CMAKE_ARGS} ${ARCH_ARGS} \
  -S ${SRC_DIR} \
  -B build \
  -G Ninja \
  -D CMAKE_INSTALL_PREFIX=${PREFIX} \
  -D CMAKE_BUILD_TYPE=Release \
  -D CMAKE_C_COMPILER=${CC} \
  -D CMAKE_C_FLAGS="${CFLAGS}" \
  -D CMAKE_CXX_COMPILER=${CXX} \
  -D CMAKE_CXX_FLAGS="${CXXFLAGS}" \
  -D CMAKE_INSTALL_LIBDIR=lib \
  -D EINSUMS_WITH_DOCUMENTATION=OFF \
  -D EINSUMS_BUILD_PYTHON=OFF \
  -D EINSUMS_WITH_EXAMPLES=OFF \
  "${plat_args[@]}" \
  -D FETCHCONTENT_QUIET=OFF \
  -D CMAKE_REQUIRE_FIND_PACKAGE_fmt=ON \
  -D CMAKE_PREFIX_PATH="${PREFIX}"

cmake --build build --target install -j${CPU_COUNT}

cd build
if [[ "$target_platform" != "osx-arm64" && ( "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || -n "${CROSSCOMPILING_EMULATOR}" ) ]]; then
    ctest --rerun-failed --output-on-failure -j${CPU_COUNT}
fi