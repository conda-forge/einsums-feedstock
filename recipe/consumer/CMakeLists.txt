cmake_minimum_required(VERSION 3.25)
project(einsums_consumer LANGUAGES CXX)

# What a downstream project writes: find the installed package and link its target.
find_package(Einsums 2.0 CONFIG REQUIRED)

add_executable(consumer main.cpp)
target_link_libraries(consumer PRIVATE Einsums::Einsums)
