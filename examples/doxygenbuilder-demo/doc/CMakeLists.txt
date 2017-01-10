
find_package(DoxygenBuilder)

add_doxygen(
  doc
  PROJECT_NAME
    "doxygenbuilder-demo"
  INPUT
    "${CMAKE_SOURCE_DIR}/src/"
    "${CMAKE_CURRENT_SOURCE_DIR}/pages"
  EXAMPLE_PATH
    "${CMAKE_SOURCE_DIR}/examples/"
  STRIP_FROM_PATH
    "${CMAKE_SOURCE_DIR}/src/"
  STRIP_FROM_INC_PATH
    "${CMAKE_SOURCE_DIR}/src/"
  EXCLUDE_PATTERNS
    */internal/*
  EXCLUDE_SYMBOLS
    *::internal*
    *::Priv
  INSTALL
    "${CMAKE_INSTALL_DATAROOTDIR}/doc/doxygenbuilder-demo"
  XML
  ALL
)

