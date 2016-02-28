cmake_minimum_required(VERSION 3.0)
project(AS)
find_package(FLEX REQUIRED)
find_package(BISON REQUIRED)

add_definitions(-std=gnu99 -g -pedantic -Wall -Wextra -Wshadow -Wpointer-arith -Wcast-qual -Wstrict-prototypes -Wmissing-prototypes)

if(WIN32)
# TODO
endif(WIN32)

set(CMAKE_INSTALL_PREFIX ${PROJECT_SOURCE_DIR})
include_directories(${PROJECT_SOURCE_DIR}/include ${PROJECT_BINARY_DIR}/src)
enable_testing()
configure_file(${PROJECT_SOURCE_DIR}/Doxyfile ${PROJECT_BINARY_DIR}/Doxyfile.cmake @ONLY)
add_custom_target(doc COMMAND doxygen ${PROJECT_BINARY_DIR}/Doxyfile.cmake)
add_subdirectory(src)