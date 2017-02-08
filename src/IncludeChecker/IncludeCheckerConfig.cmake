# .rst:
# IncludeChecker
# --------------
#

#=============================================================================
# Copyright 2017 Canonical Ltd
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

find_program(INCLUDE_CHECKER_EXECUTABLE
    "include_checker.py"
    PATHS ${CMAKE_CURRENT_LIST_DIR}
)

if(INCLUDE_CHECKER_EXECUTABLE)
    execute_process(
        COMMAND ${INCLUDE_CHECKER_EXECUTABLE} --version
        OUTPUT_VARIABLE include_checker_version
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE)
    if (include_checker_version MATCHES "^include_checker.py +[0-9\\.]+")
        string(
            REGEX REPLACE "^include_checker.py ([0-9\\.]+[^ \n]*).*" "\\1"
            INCLUDE_CHECKER_VERSION_STRING "${include_checker_version}"
        )
    endif()
    unset(include_checker_version)
endif()

find_program(INCLUDE_CHECKER_CLANG_EXECUTABLE
    "clang"
)

find_package_handle_standard_args(
    IncludeChecker
    REQUIRED_VARS
      INCLUDE_CHECKER_EXECUTABLE
      INCLUDE_CHECKER_CLANG_EXECUTABLE
    VERSION_VAR
      INCLUDE_CHECKER_VERSION_STRING
    HANDLE_COMPONENTS
)

function(add_include_check NAME)
    set(_multiValueArgs DIRECTORIES FORBIDDEN ALLOWED IGNORE FILE_EXTENSIONS COMPILER_OPTIONS)
    cmake_parse_arguments(_ARG "" "" "${_multiValueArgs}" ${ARGN})

    foreach(_directory ${_ARG_DIRECTORIES})
        list(APPEND _include_checker_args "-d" "${_directory}")
    endforeach()
    foreach(_forbidden ${_ARG_FORBIDDEN})
        list(APPEND _include_checker_args "-f" "${_forbidden}")
    endforeach()
    foreach(_allowed ${_ARG_ALLOWED})
        list(APPEND _include_checker_args "-a" "${_allowed}")
    endforeach()
    foreach(_ignore ${_ARG_IGNORE})
        list(APPEND _include_checker_args "-i" "${_ignore}")
    endforeach()
    foreach(_file_extension ${_ARG_FILE_EXTENSIONS})
        list(APPEND _include_checker_args "-e" "${_file_extension}")
    endforeach()

    list(APPEND _include_checker_args "--")

    get_property(_include_directories
        DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
        PROPERTY INCLUDE_DIRECTORIES
    )
    foreach(_include_directory ${_include_directories})
        list(APPEND _include_checker_args "-I" "${_include_directory}")
    endforeach()
    list(APPEND _include_checker_args ${_ARG_COMPILER_OPTIONS})

    add_test(
        NAME
            "${NAME}"
        COMMAND
            "${INCLUDE_CHECKER_EXECUTABLE}"
            ${_include_checker_args}
    )
endfunction()


