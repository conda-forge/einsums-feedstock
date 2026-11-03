# Einsums 2.0.0a2 checklist

Working notes for the 2.0.0a2 recipe.
Delete this file before opening the pull request against conda-forge `dev`.

## Done on this branch

These need Einsums 2.0.0a2 sources, so this branch does not build 2.0.0a1.

- [x] CMake 3.27 everywhere, the floor Einsums 2.0.0a2 sets (a6e81f5).
- [x] zlib dropped from both outputs (20b14aa).
- [x] cpptrace back in pyeinsums' `ignore_run_exports_from` (6f4b30a).
- [x] libcblas dropped; both build scripts pass `BLA_VENDOR=Generic` instead of naming the libraries (310fd6e).
- [x] Patches 0001 to 0004 deleted; each reverse-applies to Einsums origin/main, so all four fixes are in what 2.0.0a2 is tagged from.

## When Einsums v2.0.0a2 is tagged

- [ ] Set `version` to 2.0.0a2 and replace the Einsums tarball's `sha256`.
- [ ] Keep `build_number` at 0 for the new version.
- [ ] Check that Einsums still pins Stripes v1.0.0 and Waggle v1.0.1 (`cmake/Einsums_SetupStripes.cmake`, `cmake/Einsums_SetupWaggle.cmake`); bump `stripes_version` and `waggle_version` if not.
- [ ] Rerender with conda-smithy.
- [ ] Build locally with two Python variants (`--variants "{python: [...]}"`), since per-Python outputs share one work directory.

## Checks on the built packages

- [ ] `nm -u libEinsums-abi1` lists no `cblas_` symbol.
- [ ] libEinsums links `libblas` and `liblapack`, not `libopenblas` directly, so the install-time BLAS switch still reaches it.
- [ ] The installed `EinsumsConfig.cmake` runs `FindTargetLAPACK` and the build recorded `Generic`, not `All`.
- [ ] The einsums output's consumer test links with no `ld: warning: directory not found for option -F/opt/conda-sdks/...`, and on macOS resolves the environment's `libblas`, not Accelerate.
- [ ] `channel_targets` is still `conda-forge einsums_dev`.

## Open decisions

- [ ] Bindings-only pyeinsums: `build-py.sh` configures and builds all of Einsums again, five times per job on Linux (about 60 minutes).
  It needs an Einsums mode that builds only `_core` against the installed einsums.
  Decide whether that lands for 2.0.0a2 or waits.
- [ ] Windows stays paused.
