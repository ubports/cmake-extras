
# INI file with translations embedded

intltool_merge_translations(
  "${CMAKE_CURRENT_SOURCE_DIR}/foo.ini.in"
  "${CMAKE_CURRENT_BINARY_DIR}/foo.ini"
  ALL
  UTF8
)

install(
  FILES "${CMAKE_CURRENT_BINARY_DIR}/foo.ini"
  DESTINATION ${CMAKE_INSTALL_DATADIR}/fooapp
)

# FooApp executable

add_definitions(
  -DGETTEXT_PACKAGE="${GETTEXT_PACKAGE}"
  -DLOCALE_DIR="${LOCALE_DIR}"
  -DCONFIG_FILE="${CMAKE_INSTALL_FULL_DATADIR}/fooapp/foo.ini"
  -DLANGUAGE="en_AU.UTF-8"
)

add_executable(
  fooapp
  main.cpp
)

target_link_libraries(
  fooapp
  ${GLIB_LDFLAGS}
)

install(
  TARGETS fooapp
  RUNTIME DESTINATION usr/bin
)
