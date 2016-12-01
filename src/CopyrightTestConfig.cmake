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

function(ADD_COPYRIGHT_TEST)
    set(one_value_args SOURCE_DIR IGNORE_DIR IGNORE_PATTERN TEST_NAME)
    cmake_parse_arguments(ADD_COPYRIGHT_TEST "" "${one_value_args}" "" ${ARGN})

    if("${ADD_COPYRIGHT_TEST_TEST_NAME}" STREQUAL "")
        set(ADD_COPYRIGHT_TEST_TEST_NAME "copyright")
    endif()

    if(NOT "${ADD_COPYRIGHT_TEST_IGNORE_DIR}" STREQUAL "")
        set(ignore_dir_opt -d ${ADD_COPYRIGHT_TEST_IGNORE_DIR})
    endif()

    if(NOT "${ADD_COPYRIGHT_TEST_IGNORE_PATTERN}" STREQUAL "")
        set(ignore_pat_opt -i ${ADD_COPYRIGHT_TEST_IGNORE_PATTERN})
    endif()

    add_test(${ADD_COPYRIGHT_TEST_TEST_NAME}
        /usr/share/cmake/CopyrightTest/check_copyright.sh
            ${ignore_dir_opt} ${ignore_pat_opt} ${ADD_COPYRIGHT_TEST_SOURCE_DIR} ${ADD_COPYRIGHT_TEST_TEST_NAME}
    )
endfunction()
