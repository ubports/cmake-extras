find_package(GSettings REQUIRED)

# INI file with translations embedded

intltool_merge_translations(
  "foo.ini.in"
  "foo.ini"
  ALL
  UTF8
)

install(
  FILES "${CMAKE_CURRENT_BINARY_DIR}/foo.ini"
  DESTINATION ${CMAKE_INSTALL_DATADIR}/fooapp
)

# Translation merge tests for non-desktop file without translations
intltool_merge_translations(
  "translated.gschema.xml.in"
  "translated.gschema.xml"
  ALL
  UTF8
  STYLE "xml"
  NO_TRANSLATIONS
)

add_schema("translated.gschema.xml")

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
