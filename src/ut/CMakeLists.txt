macro(ADD_UT CATEGORY NAME SOURCES LIBRARIES TESTS)
  set(TARGET ${CATEGORY}_${NAME})
  string(REGEX REPLACE "[ \n]+" ";" SOURCES_LIST ${SOURCES})
  list(GET SOURCES_LIST 0 SOURCES_IGNORE)
  if(${SOURCES_IGNORE} STREQUAL "IGNORE")
    set(SOURCES_LIST "")
  endif(${SOURCES_IGNORE} STREQUAL "IGNORE")
  string(REGEX REPLACE "[ \n]+" ";" LIBRARIES_LIST ${LIBRARIES})
  list(GET LIBRARIES_LIST 0 LIBRARIES_IGNORE)
  set_source_files_properties(${SOURCES_LIST} PROPERTIES GENERATED TRUE)
  add_executable(${TARGET} ${CATEGORY}/${NAME}.c ${CATEGORY}.c ${SOURCES_LIST})
  if(NOT ${LIBRARIES_IGNORE} STREQUAL "IGNORE")
    target_link_libraries(${TARGET} ${LIBRARIES_LIST})
  endif(NOT ${LIBRARIES_IGNORE} STREQUAL "IGNORE")
  string(TOUPPER ${CATEGORY} UT_DEFINE)
  set(UT_DEFINE UT_${UT_DEFINE})
  target_compile_definitions(${TARGET} PRIVATE ${UT_DEFINE})
  string(REGEX REPLACE "[ \n]*\\|[ \n]*" ";" TESTS_LIST ${TESTS})
  list(GET TESTS_LIST 0 TEST_DEFAULT)
  if(${TEST_DEFAULT} STREQUAL "DEFAULT")
    add_test(NAME ${TARGET} COMMAND ${TARGET})
  else(${TEST_DEFAULT} STREQUAL "DEFAULT")
    foreach(TEST IN ITEMS ${TESTS_LIST})
      string(REGEX REPLACE "^([^ ]+)[ \n]*\\[(.*)\\][ \n]*$" "\\1;\\2" TEST_INTERNAL ${TEST})
      list(GET TEST_INTERNAL 0 TEST_SUBNAME)
      list(GET TEST_INTERNAL 1 TEST_ARGUMENTS)
      string(REGEX REPLACE "[ \n]+" ";" TEST_ARGUMENTS ${TEST_ARGUMENTS})
      add_test(NAME ${TARGET}_${TEST_SUBNAME} COMMAND ${TARGET} ${TEST_ARGUMENTS})
    endforeach()
  endif(${TEST_DEFAULT} STREQUAL "DEFAULT")
  install(PROGRAMS ${CMAKE_CURRENT_BINARY_DIR}/${TARGET} DESTINATION ${PROJECT_BINARY_DIR}/bin/ut/${CATEGORY} RENAME ${NAME})
endmacro()

add_ut(lexer label "${PROJECT_BINARY_DIR}/src/lexer.c" "${FLEX_LIBRARIES}" DEFAULT)
add_ut(lexer string "${PROJECT_BINARY_DIR}/src/lexer.c" "${FLEX_LIBRARIES}" DEFAULT)
add_ut(lexer import "${PROJECT_BINARY_DIR}/src/lexer.c" "${FLEX_LIBRARIES}" DEFAULT)
add_ut(lexer number "${PROJECT_BINARY_DIR}/src/lexer.c" "${FLEX_LIBRARIES}" DEFAULT)

add_ut(parser grammar 
  "${PROJECT_SOURCE_DIR}/src/ast.c
   ${PROJECT_BINARY_DIR}/src/parser.c
   ${PROJECT_BINARY_DIR}/src/lexer.c
   ${PROJECT_SOURCE_DIR}/src/word.c
   ${PROJECT_SOURCE_DIR}/src/path.c
   ${PROJECT_SOURCE_DIR}/src/pattern.c
   ${PROJECT_SOURCE_DIR}/src/import.c
   ${PROJECT_SOURCE_DIR}/src/machine.c
   ${PROJECT_SOURCE_DIR}/src/pattern_matching.c"
  "${FLEX_LIBRARIES}"
  "none              [${CMAKE_CURRENT_SOURCE_DIR}/parser/none.tohtml]                      |
   spaces            [${CMAKE_CURRENT_SOURCE_DIR}/parser/spaces.tohtml]                    |
   set               [${CMAKE_CURRENT_SOURCE_DIR}/parser/set.tohtml]                       |
   let               [${CMAKE_CURRENT_SOURCE_DIR}/parser/let.tohtml]                       |
   attributes_none   [${CMAKE_CURRENT_SOURCE_DIR}/parser/attributes_none.tohtml]           |
   attributes        [${CMAKE_CURRENT_SOURCE_DIR}/parser/attributes.tohtml]                |
   quote_in_string   [${CMAKE_CURRENT_SOURCE_DIR}/parser/quote_in_string.tohtml]           |
   double_string     [${CMAKE_CURRENT_SOURCE_DIR}/parser/double_string.tohtml]             |
   project_licit_1   [${CMAKE_CURRENT_SOURCE_DIR}/parser/project_licit_1.tohtml]           |
   project_licit_2   [${CMAKE_CURRENT_SOURCE_DIR}/parser/project_licit_2.tohtml]           |
   project_licit_3   [${CMAKE_CURRENT_SOURCE_DIR}/parser/project_licit_3.tohtml]           |
   project_illicit_1 [${CMAKE_CURRENT_SOURCE_DIR}/parser/project_illicit_1.tohtml ILLICIT] |
   project_illicit_2 [${CMAKE_CURRENT_SOURCE_DIR}/parser/project_illicit_2.tohtml ILLICIT] |
   project_illicit_3 [${CMAKE_CURRENT_SOURCE_DIR}/parser/project_illicit_3.tohtml ILLICIT] ")
