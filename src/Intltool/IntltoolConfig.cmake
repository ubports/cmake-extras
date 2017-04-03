# Copyright (C) 2014 Canonical Ltd
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

# This package provides macros that wrap the intltool programs.
# 
# An example of common usage is:
#
# For a .desktop file:
#
# intltool_merge_translations(
#   "foo.desktop.in"
#   "foo.destkop"
#   ALL
#   UTF8
# )
#
# For a .gschema.xml file:
#
# intltool_merge_translations(
#   "foo.gschema.xml.in"
#   "foo.gschema.xml"
#   ALL
#   UTF8
#   STYLE "xml"
#   NO_TRANSLATIONS
# )
#
# Inside po/CMakeLists.txt:
#
# intltool_update_potfile(
#     ALL
#     KEYWORDS "_" "_:1,2" "N_" "N_:1,2"
#     POTFILES_TEMPLATE "POTFILES.in.in"
#     GETTEXT_PACKAGE ${GETTEXT_PACKAGE}
# )
#
# NOTE: It is recommended to include N_ in the keywords list, as
# xgettext uses this keyword when extracting translations from
# ini files.
#
# or
#
# intltool_update_potfile(
#     ALL
#     UBUNTU_SDK_DEFAULTS
#     POTFILES_TEMPLATE "POTFILES.in.in"
#     GETTEXT_PACKAGE ${GETTEXT_PACKAGE}
# )
#
# then
#
# intltool_install_translations(
#     ALL
#     GETTEXT_PACKAGE ${GETTEXT_PACKAGE}
# )
#
# NOTE: Either you must include a po/POTFILES.in file or use the
# POTFILES_TEMPLATE argument and pass a file such as:
# [type: gettext/ini] data/foo.ini.in
# @GENERATED_POTFILES@
#
# NOTE: It is recommended to add both 'po/Makefile.in.in' and
# 'po/POTFILES.in' to your source control system's exclusions
# file.

find_package(Gettext REQUIRED)

find_program(INTLTOOL_UPDATE_EXECUTABLE intltool-update)

if(INTLTOOL_UPDATE_EXECUTABLE)
    execute_process(
        COMMAND ${INTLTOOL_UPDATE_EXECUTABLE} --version
        OUTPUT_VARIABLE intltool_update_version
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE)
    if (intltool_update_version MATCHES "^intltool-update \\(.*\\) [0-9]")
        string(
            REGEX REPLACE "^intltool-update \\([^\\)]*\\) ([0-9\\.]+[^ \n]*).*" "\\1"
            INTLTOOL_UPDATE_VERSION_STRING "${intltool_update_version}"
        )
    endif()
    unset(intltool_update_version)
endif()

find_program(INTLTOOL_MERGE_EXECUTABLE intltool-merge)

if(INTLTOOL_MERGE_EXECUTABLE)
    execute_process(
        COMMAND ${INTLTOOL_MERGE_EXECUTABLE} --version
        OUTPUT_VARIABLE intltool_merge_version
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE)
    if (intltool_update_version MATCHES "^intltool-merge \\(.*\\) [0-9]")
        string(
            REGEX REPLACE "^intltool-merge \\([^\\)]*\\) ([0-9\\.]+[^ \n]*).*" "\\1"
            INTLTOOL_MERGE_VERSION_STRING "${intltool_merge_version}"
        )
    endif()
    unset(intltool_merge_version)
endif()

include(FindPackageHandleStandardArgs)

find_package_handle_standard_args(
    Intltool
    REQUIRED_VARS
      INTLTOOL_UPDATE_EXECUTABLE
      INTLTOOL_MERGE_EXECUTABLE
    VERSION_VAR
      INTLTOOL_UPDATE_VERSION_STRING
    HANDLE_COMPONENTS
)

function(_INTLTOOL_JOIN_LIST LISTNAME GLUE OUTPUT)
    set(_tmp "")
    set(_first true)
    foreach(VAL ${${LISTNAME}})
        if(_first)
            set(_tmp "${VAL}")
            set(_first false)
        else()
            set(_tmp "${_tmp}${GLUE}${VAL}")
        endif()
    endforeach()
    set(${OUTPUT} "${_tmp}" PARENT_SCOPE)
endfunction()

macro(_WRITE_INTLTOOL_MAKEFILE_IN ARG_PO_DIRECTORY ARG_KEYWORDS
                                  ARG_COPYRIGHT_HOLDER ARG_LANGUAGE)
    set(_KEYWORDS "XGETTEXT_KEYWORDS=")
    if(NOT "${ARG_LANGUAGE}" STREQUAL "")
        set(_KEYWORDS "${_KEYWORDS}--language ${ARG_LANGUAGE} ")
    else()
        set(_KEYWORDS "${_KEYWORDS}--c++")
    endif()

    if(NOT "${ARG_COPYRIGHT_HOLDER}" STREQUAL "")
        set(_KEYWORDS "${_KEYWORDS} --copyright-holder='${ARG_COPYRIGHT_HOLDER}'")
    endif()
    foreach(_KEYWORD ${${ARG_KEYWORDS}})
        set(_KEYWORDS "${_KEYWORDS} --keyword=${_KEYWORD}")
    endforeach()
    file(WRITE "${ARG_PO_DIRECTORY}/Makefile.in.in" "${_KEYWORDS}\n")
endmacro()

function(_INTLTOOL_EXCLUDE_PATH LISTNAME FILTER OUTPUT)
     string(LENGTH ${FILTER} _FILTER_LENGTH)
     foreach(_PATH ${${LISTNAME}})
        set(_ABS_PATH "${CMAKE_SOURCE_DIR}/${_PATH}")
        string(LENGTH "${_ABS_PATH}" _ABS_PATH_LENGTH)
        if(${_FILTER_LENGTH} GREATER ${_ABS_PATH_LENGTH})
            # If the path is too short to match the filter
            list(APPEND _TMP ${_PATH})
        else()
            # If the path is at least as long as the filter
            string(SUBSTRING ${_ABS_PATH} 0 ${_FILTER_LENGTH} _PATH_HEAD)
            if(NOT ${_PATH_HEAD} STREQUAL ${FILTER})
                list(APPEND _TMP ${_PATH})
            endif()
        endif()
    endforeach()
    set(${OUTPUT} "${_TMP}" PARENT_SCOPE)
endfunction()

function(_INTLTOOL_LIST_FILTER INPUT OUTPUT)
    set(_multiValueArgs EXPRESSIONS)
    cmake_parse_arguments(_ARG "" "" "${_multiValueArgs}" ${ARGN})

    if(_ARG_EXPRESSIONS)
        set(_TMP "")
        foreach(_ITEM ${${INPUT}})
            unset(_MATCHED)
            foreach(_REGEX ${_ARG_EXPRESSIONS})
                if("${_ITEM}" MATCHES "${_REGEX}")
                  set(_MATCHED ON)
                  break()
                endif()
            endforeach()
            if(NOT _MATCHED)
              list(APPEND _TMP "${_ITEM}")
            endif()
        endforeach()
        set(${OUTPUT} "${_TMP}" PARENT_SCOPE)
        unset(_TMP)
    else()
        set(${OUTPUT} "${${INPUT}}" PARENT_SCOPE)
    endif()
endfunction()


function(INTLTOOL_UPDATE_POTFILE)
    set(_options ALL UBUNTU_SDK_DEFAULTS)
    set(_oneValueArgs COPYRIGHT_HOLDER GETTEXT_PACKAGE OUTPUT_FILE PO_DIRECTORY POTFILES_TEMPLATE LANGUAGE)
    set(_multiValueArgs KEYWORDS FILE_GLOBS FILTER)

    cmake_parse_arguments(_ARG "${_options}" "${_oneValueArgs}" "${_multiValueArgs}" ${ARGN})
    
    set(_POT_FILE "${PROJECT}.pot")

    set(_GETTEXT_PACKAGE "")
    if(_ARG_GETTEXT_PACKAGE)
        set(_POT_FILE "${_ARG_GETTEXT_PACKAGE}.pot")
        set(_GETTEXT_PACKAGE --gettext-package="${_ARG_GETTEXT_PACKAGE}")
    endif()

    set(_OUTPUT_FILE "")
    if(_ARG_OUTPUT_FILE)
        set(_POT_FILE "${_ARG_OUTPUT_FILE}")
        set(_OUTPUT_FILE --output-file="${_ARG_OUTPUT_FILE}")
    endif()

    set(_PO_DIRECTORY "${CMAKE_SOURCE_DIR}/po")
    if(_ARG_PO_DIRECTORY)
        set(_PO_DIRECTORY "${_ARG_PO_DIRECTORY}")
    endif()

    if(_ARG_KEYWORDS)
        _write_intltool_makefile_in(${_PO_DIRECTORY} _ARG_KEYWORDS "${_ARG_COPYRIGHT_HOLDER}" "${_ARG_LANGUAGE}")
    elseif(_ARG_UBUNTU_SDK_DEFAULTS)
        set(_UBUNTU_SDK_DEFAULT_KEYWORDS "tr" "tr:1,2" "dtr:2" "dtr:2,3" "N_")
        _write_intltool_makefile_in(${_PO_DIRECTORY} _UBUNTU_SDK_DEFAULT_KEYWORDS "${_ARG_COPYRIGHT_HOLDER}" "${_ARG_LANGUAGE}")
    endif()
    
    set(_FILE_GLOBS
        ${CMAKE_SOURCE_DIR}/*.cpp
        ${CMAKE_SOURCE_DIR}/*.cc
        ${CMAKE_SOURCE_DIR}/*.cxx
        ${CMAKE_SOURCE_DIR}/*.vala
        ${CMAKE_SOURCE_DIR}/*.c
        ${CMAKE_SOURCE_DIR}/*.h
    )

    if(_ARG_UBUNTU_SDK_DEFAULTS)
        list(APPEND _FILE_GLOBS ${CMAKE_SOURCE_DIR}/*.qml)
        list(APPEND _FILE_GLOBS ${CMAKE_SOURCE_DIR}/*.js)
    endif()
 
    if(_ARG_FILE_GLOBS)
        list(APPEND _FILE_GLOBS ${_ARG_FILE_GLOBS})
    endif()

    file(
        GLOB_RECURSE _SOURCE_FILES
        RELATIVE ${CMAKE_SOURCE_DIR}
        ${_FILE_GLOBS}
    )

    # We don't want to include paths from the binary directory
    _intltool_exclude_path(_SOURCE_FILES ${CMAKE_BINARY_DIR} _FILTERED_SOURCE_FILES_TMP)

    # Remove any paths from the filter expressions
    _intltool_list_filter(_FILTERED_SOURCE_FILES_TMP _FILTERED_SOURCE_FILES EXPRESSIONS ${_ARG_FILTER})

    # Build the text to substitute into the POTFILES.in
    _intltool_join_list(_FILTERED_SOURCE_FILES "\n" GENERATED_POTFILES)

    if(_ARG_POTFILES_TEMPLATE)
        configure_file(
            ${_ARG_POTFILES_TEMPLATE}
            "${_PO_DIRECTORY}/POTFILES.in"
        )
    else()
        file(WRITE
            "${_PO_DIRECTORY}/POTFILES.in"
            "${GENERATED_POTFILES}\n"
        )
    endif()
    
    # Read in the POTFILES
    file(
        STRINGS
        "${_PO_DIRECTORY}/POTFILES.in"
         _POTFILES_LINES
    )

    # Parse the input files from it
    foreach(_LINE ${_POTFILES_LINES})
        # Handle lines with types
        string(FIND ${_LINE} "]" _POS)
        if(_POS GREATER 0)
            math(EXPR _POS "2+${_POS}")
            string(SUBSTRING ${_LINE} ${_POS} -1 _LINE)
        endif()
        list(APPEND _CODE_SOURCES "${CMAKE_SOURCE_DIR}/${_LINE}")
    endforeach()

    add_custom_command(
        OUTPUT
          "${_PO_DIRECTORY}/${_POT_FILE}"
        COMMAND
          "${INTLTOOL_UPDATE_EXECUTABLE}" --pot "${_OUTPUT_FILE}" "${_GETTEXT_PACKAGE}"
        DEPENDS
          "${_PO_DIRECTORY}/POTFILES.in"
          "${_PO_DIRECTORY}/Makefile.in.in"
          ${_CODE_SOURCES}
        WORKING_DIRECTORY
          ${_PO_DIRECTORY}
    )
    
    if(_ARG_ALL)
        add_custom_target(
          "${_POT_FILE}"
          ALL
          DEPENDS
            "${_PO_DIRECTORY}/${_POT_FILE}"
        )
    else()
        add_custom_target(
          "${_POT_FILE}"
          DEPENDS
            "${_PO_DIRECTORY}/${_POT_FILE}"
        )
    endif()
endfunction()

function(INTLTOOL_INSTALL_TRANSLATIONS)
    set(_options ALL)
    set(_oneValueArgs GETTEXT_PACKAGE)

    cmake_parse_arguments(_ARG "${_options}" "${_oneValueArgs}" "" ${ARGN})

    set(_GETTEXT_PACKAGE "${PROJECT}")

    if(_ARG_GETTEXT_PACKAGE)
      set(_GETTEXT_PACKAGE "${_ARG_GETTEXT_PACKAGE}")
    endif()

    file(
        GLOB _PO_FILES
        RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *.po
    )

    foreach(_PO_FILE ${_PO_FILES})
        string(REPLACE ".po" "" _LANG ${_PO_FILE})
        if(_ARG_ALL)
          gettext_process_po_files(
            ${_LANG}
            ALL
            PO_FILES ${_PO_FILE}
          )
        else()
          gettext_process_po_files(
            ${_LANG}
            PO_FILES ${_PO_FILE}
          )
        endif()
        # Must define install ourselves as process_po_files doesn't know
        # the gettext package, so installs en as en/LC_MESSAGES/en.mo
        install(
          FILES ${CMAKE_CURRENT_BINARY_DIR}/${_LANG}.gmo
          DESTINATION ${CMAKE_INSTALL_LOCALEDIR}/${_LANG}/LC_MESSAGES/
          RENAME ${_GETTEXT_PACKAGE}.mo
        )
    endforeach()
endfunction()

function(INTLTOOL_MERGE_TRANSLATIONS FILENAME OUTPUT_FILE)
    # PASS_THROUGH option in intltool-merge is deprecated, so too is it here.
    # We must keep it around as an option though, to avoid breaking things.
    set(_options ALL UTF8 PASS_THROUGH NO_TRANSLATIONS)
    set(_oneValueArgs PO_DIRECTORY STYLE)

    cmake_parse_arguments(_ARG "${_options}" "${_oneValueArgs}" "" ${ARGN})

    set(_PO_DIRECTORY "${CMAKE_SOURCE_DIR}/po")
    if(_ARG_PO_DIRECTORY)
        set(_PO_DIRECTORY "${_ARG_PO_DIRECTORY}")
    endif()

    set(_UTF8 "")
    if(_ARG_UTF8)
        set(_UTF8 "--utf8")
    endif()

    # Deprecated
    if(_ARG_PASS_THROUGH)
      message(DEPRECATION "PASS_THROUGH option is deprecated. Do not use it.")
    endif()

    # When --no-translations is used with XML should not get used,
    # so we default to using it for the arg, to use otherwise.
    set(_NO_TRANSLATIONS "${_PO_DIRECTORY}")
    if(_ARG_NO_TRANSLATIONS)
        set(_NO_TRANSLATIONS "--no-translations")
    endif()

    set(_STYLE "--desktop-style")
    if(_ARG_STYLE)
      set(_STYLE "--${_ARG_STYLE}-style")
    endif()

    file(
        GLOB_RECURSE _PO_FILES
        ${_PO_DIRECTORY}/*.po
    )

    get_filename_component(_INPUT_NAME ${FILENAME} NAME)
    get_filename_component(_OUTPUT_NAME ${OUTPUT_FILE} NAME)
    set(_ABS_OUTPUT_FILE ${CMAKE_CURRENT_BINARY_DIR}/${_OUTPUT_NAME})

    if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${_INPUT_NAME})
      set(_INPUT_FILE ${CMAKE_CURRENT_SOURCE_DIR}/${_INPUT_NAME})
    else()
      set(_INPUT_FILE ${CMAKE_CURRENT_BINARY_DIR}/${_INPUT_NAME})
    endif()

    add_custom_command(
        OUTPUT
          ${_ABS_OUTPUT_FILE}
        COMMAND
          ${INTLTOOL_MERGE_EXECUTABLE} ${_STYLE} --quiet ${_UTF8} ${_NO_TRANSLATIONS} ${_INPUT_FILE} ${_OUTPUT_NAME}
        DEPENDS
          ${_INPUT_FILE}
          ${_PO_FILES}
    )


    if(_ARG_ALL)
        add_custom_target(
          ${_OUTPUT_NAME}
          ALL
          DEPENDS
            ${_ABS_OUTPUT_FILE}
        )
    else()
        add_custom_target(
          ${_OUTPUT_NAME}
          DEPENDS
            ${_ABS_OUTPUT_FILE}
        )
    endif()
endfunction()
