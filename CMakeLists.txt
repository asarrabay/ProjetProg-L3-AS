cmake_minimum_required(VERSION 2.8)
project(AS)
find_package(FLEX REQUIRED)
find_package(BISON REQUIRED)

add_definitions(-std=gnu99 -pedantic -Wall -Wextra -Wshadow -Wpointer-arith -Wcast-qual -Wstrict-prototypes -Wmissing-prototypes)

if(WIN32)
# TODO
endif(WIN32)

set(CMAKE_INSTALL_PREFIX ${PROJECT_SOURCE_DIR})
include_directories(${PROJECT_SOURCE_DIR}/include ${PROJECT_BINARY_DIR}/src)
enable_testing()
configure_file(${PROJECT_SOURCE_DIR}/Doxyfile ${PROJECT_BINARY_DIR}/Doxyfile.cmake @ONLY)
add_custom_target(doc COMMAND doxygen ${PROJECT_BINARY_DIR}/Doxyfile.cmake)
add_custom_target(flex COMMAND flex ${PROJECT_SOURCE_DIR}/src/lexer.l && mv ${PROJECT_BINARY_DIR}/lex.yy.c ${PROJECT_BINARY_DIR}/src/lexer.l.c)
add_subdirectory(src)