# Copyright (C) 2016 Canonical Ltd
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
#
# Authored by: Michi Henning <michi.henning@canonical.com>

#
# Test to check that files contain an acceptable copyright header.
#
# Example:
#
# find_package(CopyrightTest)
# 
# add_copyright_test(
#     SOURCE_DIR ${CMAKE_SOURCE_DIR}
#     IGNORE_PATTERN "\\/\\.bzr\\/|\\.sci$|debian|HACKING|README|\\.txt$|\\.in$|\\.pm$"
#     IGNORE_DIR ${CMAKE_BINARY_DIR}
# )
# 
# This adds a test called "copyright" that scans files in the source directory. Any files in the build
# directory are ignored. In addition, complaints about missing copyright headers in files that
# match IGNORE_PATTERN are ignored as well.
# 
# Parameters:
# 
# - SOURCE_DIR (mandatory)
#   The source directory to recursively scan for files to check.
# 
# - INCLUDE_PATTERN
#   Changes the default set of common source files scanned by licensecheck to files matching the
#   specified pattern. (This parameter is passed to the -c option of licensecheck.)
#
# - IGNORE_PATTERN (optional)
#   Ignore complaints about files with names matching the pattern. (This parameter is passed to
#   the -i option of licensecheck.)
# 
# - IGNORE_DIR (optional)
#   Ignore complaints about files in this subtree. This parameter is used to post-filter
#   the list of missing copyright messages from licensecheck: any reports about files without
#   a copyright header in this subtree are ignored.
# 
# - TEST_NAME (optional)
#   Sets the name of the test to be added. The default is "copyright".
#
#   Note that patterns match against the full path name of files. To make sure that you do not
#   accidentally match a path component in the middle of a path, anchor the pattern appropriately.
#   Any regex meta-characters that you want to match literally must be escaped with a double backslash.
# 
# The generated test uses licensecheck to probe for copyright headers. The output from the command
# is kept in a file <TEST_NAME>.log. Complaints about files that were not ignored are stored in
# <TEST_NAME>_filtered.log. (The defaults are copyright.log and copyright_filtered.log.)
# 
# The name of the test target is <TEST_NAME>_test (copyright_test by default), so you can run
# the test explicitly with
# 
#     $ make copyright_test
# 
# To apply different suppressions for different sub-trees, you can add multiple tests with different names.
# For example:
# 
# find_package(CopyrightTest)
# 
# add_copyright_test(
#     SOURCE_DIR some_dir
#     IGNORE_PATTERN "\\.in$"
#     IGNORE_DIR some_build_dir
#     TEST_NAME test_1
# )
# 
# add_copyright_test(
#     SOURCE_DIR other_dir
#     INCLUDE_PATTERN \\.cpp$|\\.h$
#     IGNORE_DIR other_build_dir
#     TEST_NAME test_2
# )
#

find_program(LICENSECHECK licensecheck)
if(${LICENSECHECK} STREQUAL "LICENSECHECK-NOTFOUND")
    message(SEND_ERROR "Cannot find licensecheck program, which is needed by CopyrightTest."
                       " Run \"sudo apt-get install licensecheck\" (zesty and later)"
                       " or \"sudo apt-get install devscripts\" (yakkety and earlier) to install it.")
    set(CopyrightTest_FOUND false)
endif()

set(ADD_COPYRIGHT_TEST_TEST_SCRIPT "${CMAKE_CURRENT_LIST_DIR}/check_copyright.sh")

function(ADD_COPYRIGHT_TEST)
    set(one_value_args SOURCE_DIR INCLUDE_PATTERN IGNORE_PATTERN IGNORE_DIR TEST_NAME)
    cmake_parse_arguments(ADD_COPYRIGHT_TEST "" "${one_value_args}" "" ${ARGN})

    if("${ADD_COPYRIGHT_TEST_TEST_NAME}" STREQUAL "")
        set(ADD_COPYRIGHT_TEST_TEST_NAME "copyright")
    endif()

    if(NOT ${ADD_COPYRIGHT_TEST_INCLUDE_PATTERN} STREQUAL "")
        set(opts ${opts} -c ${ADD_COPYRIGHT_TEST_INCLUDE_PATTERN})
    endif()

    if(NOT ${ADD_COPYRIGHT_TEST_IGNORE_PATTERN} STREQUAL "")
        set(opts ${opts} -i ${ADD_COPYRIGHT_TEST_IGNORE_PATTERN})
    endif()

    if(NOT ${ADD_COPYRIGHT_TEST_IGNORE_DIR} STREQUAL "")
        set(opts ${opts} -d ${ADD_COPYRIGHT_TEST_IGNORE_DIR})
    endif()

    add_custom_command(
        OUTPUT run_always_${ADD_COPYRIGHT_TEST_TEST_NAME}
               ${ADD_COPYRIGHT_TEST_TEST_NAME}.log
               ${ADD_COPYRIGHT_TEST_TEST_NAME}_filtered.log
        COMMAND ${ADD_COPYRIGHT_TEST_TEST_SCRIPT} ${opts}
                    ${ADD_COPYRIGHT_TEST_SOURCE_DIR} ${ADD_COPYRIGHT_TEST_TEST_NAME}
        VERBATIM
    )
    set_source_files_properties(run_always_${ADD_COPYRIGHT_TEST_TEST_NAME} PROPERTIES SYMBOLIC true)

    add_custom_target(${ADD_COPYRIGHT_TEST_TEST_NAME}_test DEPENDS run_always_${ADD_COPYRIGHT_TEST_TEST_NAME})

    add_test(${ADD_COPYRIGHT_TEST_TEST_NAME} ${CMAKE_MAKE_PROGRAM} ${ADD_COPYRIGHT_TEST_TEST_NAME}_test)
endfunction()
