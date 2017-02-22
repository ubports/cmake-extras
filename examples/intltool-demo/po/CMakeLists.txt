intltool_update_potfile(
    ALL
    KEYWORDS "_" "_:1,2" "N_" "N_:1,2"
    POTFILES_TEMPLATE "POTFILES.in.in"
    GETTEXT_PACKAGE ${GETTEXT_PACKAGE}
    COPYRIGHT_HOLDER "Foocorp Ltd."
    FILE_GLOBS "${CMAKE_SOURCE_DIR}/*.gschema.xml.in" "${CMAKE_SOURCE_DIR}/*.ini.in" "${CMAKE_SOURCE_DIR}/*.cpp" "${CMAKE_SOURCE_DIR}/*.h" "${CMAKE_SOURCE_DIR}/*.c"
    FILTER ".*test.*"
)

intltool_install_translations(
    ALL
    GETTEXT_PACKAGE ${GETTEXT_PACKAGE}
)

