# find_package(<PACKAGE> <VERSION>) as a consumer sees it: the target exists, and every include
# directory it names does too (a consumer of a target linking it fails to generate otherwise).
cmake_minimum_required(VERSION 3.25)
project(find_dependency LANGUAGES CXX)

find_package(${PACKAGE} ${VERSION} REQUIRED CONFIG)
if(NOT TARGET ${TARGET})
  message(FATAL_ERROR "find_package(${PACKAGE}) gave no ${TARGET}")
endif()
get_target_property(_incs ${TARGET} INTERFACE_INCLUDE_DIRECTORIES)
foreach(_inc IN LISTS _incs)
  if(NOT IS_DIRECTORY "${_inc}")
    message(FATAL_ERROR "${TARGET} names ${_inc}, which does not exist")
  endif()
endforeach()
message(STATUS "${PACKAGE} ${${PACKAGE}_VERSION}: ${TARGET} -> ${_incs}")
