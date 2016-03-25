# .rst:
# FormatCode
# ----------
#
# Helpers to reformat code or test that source follows the style guide.
# Supports astyle and clang-format.
#
# The following public functions are provided by this module:
#
# ::
#
#   add_formatcode_target
#     - Reformat the source code when 'make formatcode' is run
#   add_formatcode_test
#     - Add ctest to confirm the source code follows the style guide
#
# The following variables may be set before calling these functions
# to modify the way the formatcode is run:
#
# ::
#
#   FORMATCODE_SOURCES = list of sources to reformat or test. (Required)
#   FORMATCODE_STYLE = project name house style to look for shared style files,
#                      eg /usr/share/cmake/Modules/formatcode/$project.astyle.
#   FORMATCODE_ASTYLE_CONFIG = file of astyle options to use
#   FORMATCODE_CLANG_FORMAT_CONFIG = file of clang-format options to use
#
# Example use:
#
# ::
#
#   In CMakeLists.txt:
#
#     set(FORMATCODE_STYLE unity-api)
#     file(GLOB_RECURSE FORMATCODE_SOURCES src/*.cpp src/*.cxx src/*.cc src/*.h)
#     include(FormatCode)
#     add_formatcode_target()
#
#   In tests/CMakeLists.txt:
#
#     add_formatcode_test()
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

set(FORMATCODE_CMAKE_MODULE_DIR ${CMAKE_CURRENT_LIST_DIR}/formatcode)

# Look for which .astyle or .clang-format style files to use.
# 1. Try the project/house style in FORMATCODE_STYLE first
# 2. Look for FORMATCODE_ASTYLE_CONFIG or FORMATCODE_CLANG_FORMAT_CONFIG
# 3. Lastly, look in ${CMAKE_SOURCE_DIR} for astyle-config or .clang-format

message(STATUS "checking for astyle or clang-format style files")

if(FORMATCODE_STYLE)
    set(style_search_path
        ${FORMATCODE_CMAKE_MODULE_DIR}
        ${CMAKE_SOURCE_DIR}
        ${CMAKE_SOURCE_DIR}/data
    )
    set(filename ${FORMATCODE_STYLE}.astyle)
    find_file(FORMATCODE_ASTYLE_CONFIG ${filename} PATHS ${style_search_path})
    set(filename ${FORMATCODE_STYLE}.clang-format)
    find_file(FORMATCODE_CLANG_FORMAT_CONFIG ${filename} PATHS ${style_search_path})
endif()

if(NOT FORMATCODE_ASTYLE_CONFIG)
    set(fallback ${CMAKE_SOURCE_DIR}/astyle-config)
    if(EXISTS ${fallback})
        set(FORMATCODE_ASTYLE_CONFIG ${fallback})
    endif()
endif()

if(NOT FORMATCODE_CLANG_FORMAT_CONFIG)
    set(fallback ${CMAKE_SOURCE_DIR}/.clang-format)
    if(EXISTS ${fallback})
        set(FORMATCODE_CLANG_FORMAT_CONFIG ${fallback})
    endif()
endif()

if(FORMATCODE_ASTYLE_CONFIG)
    message(STATUS "  found ${FORMATCODE_ASTYLE_CONFIG}")
endif()

if(FORMATCODE_CLANG_FORMAT_CONFIG)
    message(STATUS "  found ${FORMATCODE_CLANG_FORMAT_CONFIG}")
endif()



# add a 'make formatcode' target to reformat the source files
function(add_formatcode_target)
    if(NOT FORMATCODE_SOURCES)
        message(FATAL_ERROR "add_formatcode_target() called without FORMATCODE_SOURCES set")
    endif()
    set(TMPFILE ${CMAKE_BINARY_DIR}/formatcode_format.cmake)
    configure_file(${FORMATCODE_CMAKE_MODULE_DIR}/formatcode_format.cmake.in ${TMPFILE} @ONLY)
    add_custom_target(formatcode COMMAND ${CMAKE_COMMAND} -P ${TMPFILE} DEPENDS ${FORMATCODE_SOURCES})
endfunction()

# add a 'formatcode' test to confirm the source files follow the style guide
function(add_formatcode_test)
    if(NOT FORMATCODE_SOURCES)
        message(FATAL_ERROR "add_formatcode_test() called without FORMATCODE_SOURCES set")
    endif()
    set(TMPFILE ${CMAKE_BINARY_DIR}/formatcode_test.cmake)
    configure_file(${FORMATCODE_CMAKE_MODULE_DIR}/formatcode_test.cmake.in ${TMPFILE} @ONLY)
    add_test(NAME formatcode COMMAND ${CMAKE_COMMAND} -P ${TMPFILE})
endfunction()
