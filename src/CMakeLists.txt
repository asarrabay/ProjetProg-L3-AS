flex_target(LEXER ${CMAKE_CURRENT_SOURCE_DIR}/lexer.l ${CMAKE_CURRENT_BINARY_DIR}/lexer.c)
add_custom_target(
  lexer
  DEPENDS ${FLEX_LEXER_OUTPUTS})
if(${CMAKE_BUILD_TYPE} STREQUAL "Debug")
  bison_target(PARSER ${CMAKE_CURRENT_SOURCE_DIR}/parser.y ${CMAKE_CURRENT_BINARY_DIR}/parser.c COMPILE_FLAGS "-v")
  set_directory_properties(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES parser.output)
else(${CMAKE_BUILD_TYPE} STREQUAL "Debug")
  bison_target(PARSER ${CMAKE_CURRENT_SOURCE_DIR}/parser.y ${CMAKE_CURRENT_BINARY_DIR}/parser.c)
endif(${CMAKE_BUILD_TYPE} STREQUAL "Debug")
add_flex_bison_dependency(LEXER PARSER)
add_custom_target(
  parser
  DEPENDS ${BISON_PARSER_OUTPUTS})
#add_executable(main main.c ${BISON_PARSER_OUTPUTS} ${FLEX_LEXER_OUTPUTS})
#target_link_libraries(main ${FLEX_LIBRARIES} ${BISON_LIBRARIES})
#install(TARGETS main RUNTIME DESTINATION ${PROJECT_BINARY_DIR}/bin)
add_subdirectory(ut)