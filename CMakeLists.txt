cmake_minimum_required(VERSION 2.8)
project(AS)
find_package(FLEX REQUIRED)
find_package(BISON REQUIRED)
find_package(Doxygen)

add_definitions(-std=gnu99 -pedantic -Wall -Werror -Wextra -Wshadow -Wpointer-arith -Wcast-qual -Wstrict-prototypes -Wmissing-prototypes -Wno-sign-compare)
set(CMAKE_INSTALL_PREFIX ${PROJECT_SOURCE_DIR})
include_directories(${PROJECT_SOURCE_DIR}/include/ ${PROJECT_BINARY_DIR}/src/)
enable_testing()
if(${DOXYGEN_FOUND})
  configure_file(${PROJECT_SOURCE_DIR}/Doxyfile ${PROJECT_BINARY_DIR}/Doxyfile.cmake @ONLY)
  add_custom_target(
    doc
    COMMAND ${DOXYGEN_EXECUTABLE} ${PROJECT_BINARY_DIR}/Doxyfile.cmake
    COMMENT "Generating documentation using Doxygen ${DOXYGEN_VERSION} ...")
endif(${DOXYGEN_FOUND})
add_subdirectory(src)
