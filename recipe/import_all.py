"""Import every module of the einsums package.

The full test suite runs on one Python only. Every module of the pure-Python package is imported
on the others too, so a syntax or import error that only one Python version hits still fails the
build. A module that needs an optional third-party package that is not installed is reported and
passed over; a missing einsums module is an error.
"""

import importlib
import pkgutil
import sys

import einsums

failed = []
optional = []
count = 0
for info in pkgutil.walk_packages(einsums.__path__, "einsums."):
    # Importing a __main__ runs the command it implements.
    if info.name.rsplit(".", 1)[-1] == "__main__":
        continue
    count += 1
    try:
        importlib.import_module(info.name)
    except ModuleNotFoundError as e:
        if e.name and e.name.split(".")[0] != "einsums":
            optional.append(f"{info.name} (needs {e.name})")
        else:
            failed.append(f"{info.name}: {e!r}")
    except Exception as e:
        failed.append(f"{info.name}: {e!r}")

print(f"imported {count - len(failed) - len(optional)} of {count} einsums modules")
for name in optional:
    print(f"  skipped, optional dependency missing: {name}")
for line in failed:
    print(f"  FAILED: {line}")
sys.exit(1 if failed else 0)
