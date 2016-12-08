# .rst:
# FormatCode
# ----------
#
# Helpers to reformat source or test that it follows a style guide.
# Supports astyle and clang-format.
#
# The ``ADD_FORMATCODE_TARGET'' function adds a rule
# to reformat the specified sources into the desired style::
#
#    add_formatcode_target(
#        sources
#        [STYLE_NAME <name>]
#        [ASTYLE_CONFIG <path>]
#        [CFORMAT_CONFIG <path>]
#    )
#
# If the ``STYLE_NAME`` argument is used, formatcode first looks for shared
# style files installed in the FormatCode module's formatcode/ directory.
#
# Otherwise it looks in ${CMAKE_SOURCE_DIR} and ${CMAKE_SOURCE_DIR}/data/
# for the ``ASTYLE_CONFIG`` and ``CFORMAT_CONFIG`` files.
#
# The ``ADD_FORMATCODE_TEST'' function takes the same arguments as
# ``ADD_FORMATCODE_TARGET'' and adds a test to see if the specified
# sources follow the desired style::
#
#    add_formatcode_test(
#        sources
#        [STYLE_NAME <name>]
#        [ASTYLE_CONFIG <path>]
#        [CFORMAT_CONFIG <path>]
#    )
#
#   Example use:
#
#   In CMakeLists.txt:
#
#     file(GLOB_RECURSE MY_SOURCES src/*.cpp src/*.cxx src/*.cc src/*.h)
#     find_package(FormatCode)
#     add_formatcode_target(${MY_SOURCES} STYLE_NAME unity-api)
#
#   In tests/CMakeLists.txt:
#
#     add_formatcode_test(${MY_SOURCES} STYLE_NAME unity-api)
#

#=============================================================================
# Copyright 2016 Canonical Ltd
#
# This file may be licensed under the terms of the
# GNU Lesser General Public License Version 3 (the ``LGPL''),
# or (at your option) any later version.
#
# Software distributed under the License is distributed
# on an ``AS IS'' basis, WITHOUT WARRANTY OF ANY KIND, either
# express or implied. See the LGPL for the specific language
# governing rights and limitations.
#
# You should have received a copy of the LGPL along with this
# program. If not, go to http://www.gnu.org/licenses/lgpl.html
# or write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
#=============================================================================

include(CMakeParseArguments)

set(FC_CMAKE_MODULE_DIR ${CMAKE_CURRENT_LIST_DIR})

function(_fc_find_style_files FC_STYLE_NAME FC_ASTYLE_CONFIG FC_CFORMAT_CONFIG)

    message(STATUS "checking for astyle or clang-format")

    set(style_search_path
        ${CMAKE_SOURCE_DIR}
        ${CMAKE_SOURCE_DIR}/data
        ${FC_CMAKE_MODULE_DIR}
    )
    
    if(FC_STYLE_NAME)
        set(filename ${FC_STYLE_NAME}.astyle)
        find_file(astyle_tmp ${filename} PATHS ${style_search_path})
        set(filename ${FC_STYLE_NAME}.clang-format)
        find_file(cformat_tmp ${filename} PATHS ${style_search_path})
    endif()

    if(FC_ASTYLE_CONFIG AND NOT astyle_tmp)
        if(EXISTS ${FC_ASTYLE_CONFIG})
            set(astyle_tmp ${FC_ASTYLE_CONFIG})
        else()
            find_file(astyle_tmp
                NAMES ${FC_ASTYLE_CONFIG} astyle-config
                PATHS ${style_search_path}
            )
        endif()
    endif()

    if(FC_CFORMAT_CONFIG AND NOT cformat_tmp)
        if(EXISTS ${FC_CFORMAT_CONFIG})
            set(cformat_tmp ${FC_CFORMAT_CONFIG})
        else()
            find_file(cformat_tmp
                NAMES ${FC_CFORMAT_CONFIG} cformat-config
                PATHS ${style_search_path}
            )
        endif()
    endif()

    # set retvals

    if(astyle_tmp)
        message(STATUS "  found ${astyle_tmp}")
        set(FC_ASTYLE_CONFIG ${astyle_tmp} PARENT_SCOPE)
    else()
        unset(FC_ASTYLE_CONFIG PARENT_SCOPE)
    endif()

    if(cformat_tmp)
        message(STATUS "  found ${cformat_tmp}")
        set(FC_CFORMAT_CONFIG ${cformat_tmp} PARENT_SCOPE)
    else()
        unset(FC_CFORMAT_CONFIG PARENT_SCOPE)
    endif()

endfunction()

function(_fc_find_apps FC_ASTYLE_CONFIG FC_CFORMAT_CONFIG)

    if(EXISTS ${FC_ASTYLE_CONFIG})
        # find astyle...
        find_program(ASTYLE NAMES astyle)
        if(NOT ASTYLE)
            message(WARNING "found astyle config file, but not astyle")
        endif()
    endif()

    if(EXISTS ${FC_CFORMAT_CONFIG})
        # find clang-format executable...
        find_program(CFORMAT NAMES clang-format clang-format-3.8 clang-format-3.7 clang-format-3.6 clang-format-3.5)
        if(NOT CFORMAT)
            message(WARNING "found clang-format style file, but not clang-format")
        endif()
    endif()

    # set retvals

    if(ASTYLE)
        message(STATUS "  found ${ASTYLE}")
        set(FC_ASTYLE ${ASTYLE} PARENT_SCOPE)
    else()
        unset(FC_ASTYLE PARENT_SCOPE)
    endif()

    if(CFORMAT)
        message(STATUS "  found ${CFORMAT}")
        set(FC_CFORMAT ${CFORMAT} PARENT_SCOPE)
    else()
        unset(FC_CFORMAT PARENT_SCOPE)
    endif()

endfunction()

# cmake doesn't have a mktemp func, so roll a simple one
function(_fc_mktemp in out)
    set(_counter 1)
    while(EXISTS ${in}.${_counter})
        math(EXPR _counter "${_counter} + 1")
    endwhile()
    set(${out} "${in}.${_counter}" PARENT_SCOPE)
endfunction()

# clang-format has a goofy wart, it doesn't let you pass in an arbitrary
# style file. But, you CAN pass style options on the command line with
# --style="{foo: bar, mum: baz}" ... so let's read the style file in
# and bang it into a --style string
function(_fc_get_cformat_style cformat_style_string filename)
    file(READ ${filename} contents)
    STRING(REGEX REPLACE ";" "\\\\;" contents "${contents}")
    STRING(REGEX REPLACE "\n" ";" contents "${contents}")
    set(style)
    foreach(LINE IN LISTS contents)
        string(STRIP "${LINE}" LINE)
        if (LINE MATCHES ".*:.*")
            set(style "${style}${LINE}, ")
        endif()
    endforeach(LINE)
    STRING(LENGTH "${style}" len)
    if(${len} GREATER 2) # trim the trailing ", "
        MATH(EXPR len "${len}-2")
        STRING(SUBSTRING "${style}" 0 ${len} style)
    endif()
    # set retval
    set(${cformat_style_string} "{${style}}" PARENT_SCOPE)
endfunction()


# add_custom_target() and add_test() can take a cmake file argument but not a
# function name argument, so we generate cmake files to call
# formatcode_format_files() or formatcode_test_files() with the right FC_* args
function(_fc_configure_new_cmake_file filename template_name)

    # parse the args
    set(options)
    set(oneValueArgs STYLE_NAME ASTYLE_CONFIG CFORMAT_CONFIG)
    set(multiValueArgs)
    cmake_parse_arguments(FC "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    set(FC_SOURCES "${FC_UNPARSED_ARGUMENTS}")

    # use the args to find the right formatters and config files
    _fc_find_style_files("${FC_STYLE_NAME}" "${FC_ASTYLE_CONFIG}" "${FC_CFORMAT_CONFIG}")
    _fc_find_apps("${FC_ASTYLE_CONFIG}" "${FC_CFORMAT_CONFIG}")

    # build the filter
    set(FC_COMMAND ${CMAKE_BINARY_DIR}/formatcode)
    _fc_get_cformat_style(FC_CFORMAT_STYLE "${FC_CFORMAT_CONFIG}")
    configure_file(${FC_CMAKE_MODULE_DIR}/formatcode.in ${FC_COMMAND} @ONLY)

    # build the config file
    _fc_mktemp(${CMAKE_BINARY_DIR}/${template_name} TMPFILE)
    set(TMPFILE ${TMPFILE}.cmake)
    configure_file(${FC_CMAKE_MODULE_DIR}/${template_name}.cmake.in ${TMPFILE} @ONLY)

    # set the retval, the filename of the generated file
    set(${filename} ${TMPFILE} PARENT_SCOPE)
endfunction()

# add a 'make formatcode' target to reformat the source files
function(add_formatcode_target)
    _fc_configure_new_cmake_file(cmake_file "formatcode_format" ${ARGN})
    add_custom_target(formatcode COMMAND ${CMAKE_COMMAND} -P ${cmake_file} DEPENDS ${FC_SOURCES})
endfunction()

# add a 'formatcode' test to confirm the source files follow the style guide
function(add_formatcode_test)
    _fc_configure_new_cmake_file(cmake_file "formatcode_test" ${ARGN})
    add_test(NAME formatcode COMMAND ${CMAKE_COMMAND} -P ${cmake_file})
endfunction()

