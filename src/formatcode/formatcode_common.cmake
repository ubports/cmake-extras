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

# check to see what formatter(s) we're using...

if(EXISTS ${FORMATCODE_ASTYLE_CONFIG})

    # find the astyle...
    set(USE_ASTYLE TRUE)
    find_program(ASTYLE NAMES astyle)
    if(NOT ASTYLE)
        message(WARNING "found astyle config file, but not astyle")
    endif()

    # astyle 2.03 writes DOS line endings: https://sourceforge.net/p/astyle/bugs/268/
    find_program(DOS2UNIX NAMES dos2unix)
    if(NOT DOS2UNIX)
        message(WARNING "formatcode astyle needs dos2unix")
    endif()

endif()

if(EXISTS ${FORMATCODE_CLANG_FORMAT_CONFIG})

    # find the clang-format executable...
    find_program(CLANG_FORMAT NAMES clang-format clang-format-3.8 clang-format-3.7 clang-format-3.6 clang-format-3.5)
    if(NOT CLANG_FORMAT)
        message(WARNING "found clang-format style file, but not clang-format")
    endif()

    # clang-format has a goofy wart, it doesn't let you pass in an arbitrary
    # style file. But, you CAN pass style options on the command line with
    # --style="{foo: bar, mum: baz}" ... so let's read the style file in
    # and bang it into a --style string
    file(READ ${FORMATCODE_CLANG_FORMAT_CONFIG} contents)
    STRING(REGEX REPLACE ";" "\\\\;" contents "${contents}")
    STRING(REGEX REPLACE "\n" ";" contents "${contents}")
    set(CLANG_FORMAT_STYLE)
    foreach(LINE IN LISTS contents)
        string(STRIP "${LINE}" LINE)
        if (LINE MATCHES ".*:.*")
            set(CLANG_FORMAT_STYLE "${CLANG_FORMAT_STYLE}${LINE}, ")
        endif()
    endforeach(LINE)
    STRING(LENGTH "${CLANG_FORMAT_STYLE}" len)
    if(${len} GREATER 2) # trim the trailing ", "
        MATH(EXPR len "${len}-2") 
        STRING(SUBSTRING "${CLANG_FORMAT_STYLE}" 0 ${len} CLANG_FORMAT_STYLE)
    endif()
    set(CLANG_FORMAT_STYLE "{${CLANG_FORMAT_STYLE}}")

endif()

# formatting funcs

function(formatcode_format_file filename)
    if(ASTYLE)
        set(activity TRUE)
        execute_process(COMMAND ${ASTYLE} --quiet -n --options=${FORMATCODE_ASTYLE_CONFIG} ${filename})
        execute_process(COMMAND ${DOS2UNIX} --quiet ${filename})
    endif()
    if(CLANG_FORMAT)
        set(activity TRUE)
        execute_process(COMMAND ${CLANG_FORMAT} -i -style=${CLANG_FORMAT_STYLE} ${filename})
    endif()
    if(NOT activity)
        message(WARNING "no formatter specified for ${filename}")
    endif()
endfunction()

function(formatcode_format_files filenames)
    foreach(filename IN LISTS filenames)
        message(STATUS "formatcode ${filename}")
       formatcode_format_file("${filename}")
    endforeach(filename)
endfunction()

# testing funcs

set(FORMATCODE_TEST_DIR ${CMAKE_BINARY_DIR}/formatcode)

function(formatcode_test_file success filename)

    # copy the file into a relative path underneath $build/formatcode/
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
    formatcode_format_file(${tmpfile})

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

function(formatcode_test_files filenames)
    set(error_count 0)
    foreach(filename IN LISTS filenames)
        formatcode_test_file(success ${filename})
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

