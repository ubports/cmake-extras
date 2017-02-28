# Copyright (C) 2017 Canonical Ltd
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License version 3 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

#.rst:
# GDbus
# -----
#
# A `gdbus-codegen` module for CMake.
#
# Finds ths ``gdbus-codegen`` executable and adds the
# :command:`add_gdbus_codegen` command.
#
# In order to find the ``gdbus-codegen`` executable, it uses the
# :variable:`GDBUS_CODEGEN_EXECUTABLE` variable.

### Find the executable
find_program(GDBUS_CODEGEN_EXECUTABLE gdbus-codegen)

### Handle standard args
include(FindPackageHandleStandardArgs)

find_package_handle_standard_args(
    GDbus
    REQUIRED_VARS
      GDBUS_CODEGEN_EXECUTABLE
    HANDLE_COMPONENTS
)

#.rst:
#.. command:: add_gdbus_codegen
#
#  Generates C code and header file from XML service description, and
#  sets the :variable:<VARIABLE_PREFIX>_SOURCES variable with the newly
#  generated source files. This variable should be added to the list of
#  sources for your :command:add_executable or :command:add_library target.
#
#    add_gdbus_codegen(<VARIABLE_PREFIX> <NAME> <PREFIX> <SERVICE_XML> [NAMESPACE])
#
#  For example:
#
#  .. code-block:: cmake
#
#   add_gdbus_codegen(DBUS_PROXY
#     dbus-proxy
#     org.freedesktop
#     org.freedesktop.DBus.xml
#     )
#
function(ADD_GDBUS_CODEGEN VARIABLE_PREFIX NAME PREFIX SERVICE_XML)
  set(_options ALL)
  set(_oneValueArgs NAMESPACE)

  cmake_parse_arguments(_ARG "${_options}" "${_oneValueArgs}" "" ${ARGN})

  get_filename_component(_ABS_SERVICE_XML ${SERVICE_XML} ABSOLUTE)

  set(_NAMESPACE "")
  if(_ARG_NAMESPACE)
    set(_NAMESPACE "--c-namespace=${_ARG_NAMESPACE}")
  endif()

  set(_OUTPUT_PREFIX "${CMAKE_CURRENT_BINARY_DIR}/${NAME}")
  set(_OUTPUT_FILES "${_OUTPUT_PREFIX}.c" "${_OUTPUT_PREFIX}.h")
  set("${VARIABLE_PREFIX}_SOURCES" "${_OUTPUT_FILES}" PARENT_SCOPE)
  add_custom_command(
    OUTPUT ${_OUTPUT_FILES}
    COMMAND "${GDBUS_CODEGEN_EXECUTABLE}"
        --interface-prefix ${PREFIX}
        --generate-c-code="${NAME}"
        ${_NAMESPACE}
        ${_ABS_SERVICE_XML}
    BYPRODUCTS ${_OUTPUT_FILES}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS ${_ABS_SERVICE_XML}
    )
endfunction()
