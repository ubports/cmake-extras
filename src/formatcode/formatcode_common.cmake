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

# formatting funcs

function(formatcode_format_file fc_command filename)
    execute_process(COMMAND ${fc_command} ${filename})
endfunction()

function(formatcode_format_files fc_command filenames)
    foreach(filename IN LISTS filenames)
        formatcode_format_file("${fc_command}" "${filename}")
    endforeach(filename)
endfunction()

# testing funcs

set(FORMATCODE_TEST_DIR ${CMAKE_BINARY_DIR}/formatted)

function(formatcode_test_file success fc_command filename)

    # copy the file into a relative path underneath $build/formatted/
    # so that, if the test fails, we can leave the formatted copy behind
    # as a breadcrumb without clutting any other directories
    file(RELATIVE_PATH rel ${CMAKE_SOURCE_DIR} ${filename})
    set(tmpfile ${FORMATCODE_TEST_DIR}/${rel})
    get_filename_component(base ${tmpfile} NAME)
    file(MAKE_DIRECTORY base)
    file(REMOVE ${tmpfile})
    file(READ ${filename} input)
    file(WRITE ${tmpfile} "${input}")

    # format the file
    formatcode_format_file("${fc_command}" ${tmpfile})

    # if the format changed, then $filename didn't match the style guide
    string(MD5 md5in "${input}")
    file(MD5 ${tmpfile} md5out)
    if(md5in STREQUAL md5out)
        file(REMOVE ${tmpfile})
        set(${success} TRUE PARENT_SCOPE)
    else()
        message(STATUS "leaving formatted copy in ${tmpfile}")
        set(${success} FALSE PARENT_SCOPE)
    endif()

endfunction()

function(formatcode_test_files fc_command filenames)
    set(error_count 0)
    foreach(filename IN LISTS filenames)
        formatcode_test_file(success "${fc_command}" "${filename}")
        if(NOT success)
            MATH(EXPR error_count "${error_count}+1")
        endif()
    endforeach(filename)
    if(error_count)
        message(FATAL_ERROR "formatcode test failed in ${error_count} files")
    else()
        # if nothing failed, clean up the test directory
        file(REMOVE_RECURSE ${FORMATCODE_TEST_DIR})
    endif()
endfunction()

