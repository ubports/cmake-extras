find_package(Intltool REQUIRED)

intltool_update_potfile(
    ALL
    KEYWORDS "_" "_:1,2" "N_" "N_:1,2"
    POTFILES_TEMPLATE "POTFILES.in.in"
    GETTEXT_PACKAGE ${GETTEXT_PACKAGE}
    COPYRIGHT_HOLDER "Foocorp Ltd."
)

intltool_install_translations(
    ALL
    GETTEXT_PACKAGE ${GETTEXT_PACKAGE}
)

