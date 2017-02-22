# GSettingsConfig.cmake, CMake macros written for Marlin, feel free to re-use them.
find_package(PkgConfig REQUIRED)

# We need this for generating unique target identifiers
find_package(Gettext REQUIRED)

# Find the binary for compiling schemas
execute_process(
  COMMAND ${PKG_CONFIG_EXECUTABLE} gio-2.0 --variable glib_compile_schemas
  OUTPUT_VARIABLE _GLIB_COMPILE_SCHEMAS
  OUTPUT_STRIP_TRAILING_WHITESPACE
)


# Have an option to not install the schema into where GLib is
option (GSETTINGS_LOCALINSTALL "Install GSettings schemas locally instead of to the GLib prefix" OFF)
if (GSETTINGS_LOCALINSTALL)
    message(STATUS "GSettings schemas will be installed locally.")
    set (GSETTINGS_DIR "${CMAKE_INSTALL_PREFIX}/share/glib-2.0/schemas/")
else (GSETTINGS_LOCALINSTALL)
    execute_process (
      COMMAND ${PKG_CONFIG_EXECUTABLE} glib-2.0 --variable prefix
      OUTPUT_VARIABLE _glib_prefix
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    set (GSETTINGS_DIR "${_glib_prefix}/share/glib-2.0/schemas/")
endif (GSETTINGS_LOCALINSTALL)
message (STATUS "GSettings schemas will be installed into ${GSETTINGS_DIR}")

# Have an option to compile the schemas once installed
option (GSETTINGS_COMPILE "Compile GSettings schemas after installation" OFF)
if(GSETTINGS_COMPILE)
    message(STATUS "Installed GSettings schemas will be compiled.")
endif()

function(add_schema SCHEMA_NAME)
  # Make sure a target exists
  if(NOT TARGET ${SCHEMA_NAME})
    add_custom_target(
      ${SCHEMA_NAME}
      COMMAND true
      )
  endif()

  # Always copy the schema file to BINARY_DIR as schema compilation
  # should be done on binary dir, when needed for tests.
  if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${SCHEMA_NAME})
    set(SCHEMA_FILE "${CMAKE_CURRENT_SOURCE_DIR}/${SCHEMA_NAME}")
    file(COPY "${SCHEMA_FILE}" DESTINATION "${CMAKE_CURRENT_BINARY_DIR}")
  else()
    set(SCHEMA_FILE "${CMAKE_CURRENT_BINARY_DIR}/${SCHEMA_NAME}")
  endif()

  set_property(
    DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    APPEND PROPERTY _SCHEMA_FILES "${SCHEMA_NAME}"
    )
  add_test(
    NAME "validate-${SCHEMA_NAME}"
    COMMAND ${_GLIB_COMPILE_SCHEMAS} --dry-run --schema-file=${SCHEMA_FILE}
    )

  # Install the schemas
  install (FILES ${SCHEMA_FILE} DESTINATION ${GSETTINGS_DIR} OPTIONAL)

  # Add a rule to compile the schemas if so enabled
  # FIXME: This should ideally only be called once, after all the files
  # have been installed, but we must do so every time currently, due
  # to a bug in cmake lacking ability to order last (LP: #1665006)
  if(GSETTINGS_COMPILE)
    install (CODE "
      find_package(GSettings REQUIRED)
      compile_schemas(${GSETTINGS_DIR})
      "
      )
  endif()
endfunction()

function(compile_schemas SCHEMA_DIR)
  if (${SCHEMA_DIR} MATCHES "^${CMAKE_SOURCE_DIR}.*$")
    set(OUTPUT_FILE "${SCHEMA_DIR}/gschemas.compiled")
    get_property(
      _SCHEMA_FILES
      DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      PROPERTY _SCHEMA_FILES
      )
    add_custom_command(
      OUTPUT ${OUTPUT_FILE}
      COMMAND "${_GLIB_COMPILE_SCHEMAS}" "${SCHEMA_DIR}"
      BYPRODUCTS ${OUTPUT_FILE}
      DEPENDS ${_SCHEMA_FILES}
      )
    _GETTEXT_GET_UNIQUE_TARGET_NAME("gschemas.compiled" _UNIQUE_TARGET_NAME)
    add_custom_target(
      ${_UNIQUE_TARGET_NAME}
      ALL
      DEPENDS ${OUTPUT_FILE}
      )
  else()
    message(STATUS "Compiling GSettings schemas in: ${SCHEMA_DIR}")
    execute_process(
      COMMAND "${_GLIB_COMPILE_SCHEMAS}" "${SCHEMA_DIR}"
      ERROR_VARIABLE _schema_compile_error
      OUTPUT_STRIP_TRAILING_WHITESPACE
      )
      if(_schema_compile_error)
        message(SEND_ERROR "Schemas compile failed: ${_schema_compile_error}")
      endif(_schema_compile_error)
    endif()
endfunction()
