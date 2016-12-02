#
# Copyright (C) 2015 Canonical Ltd.
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

cmake_minimum_required(VERSION 3.0.2)
project(copyrighttest-demo LANGUAGES C CXX)

include(CTest)
enable_testing()

find_package(CopyrightTest REQUIRED)

add_copyright_test(
    SOURCE_DIR ${CMAKE_SOURCE_DIR}
    IGNORE_DIR ${CMAKE_BINARY_DIR}
    TEST_NAME must_fail_1
)

#
# HACK: The licensecheck -c option is broken in zesty:
#       https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=842368
#       once this is fixed, we need to re-enable the tests
#       that use INCLUDE_PATTERN.
#
#add_copyright_test(
#    SOURCE_DIR ${CMAKE_SOURCE_DIR}
#    IGNORE_DIR ${CMAKE_BINARY_DIR}
#    INCLUDE_PATTERN \\.cpp$
#    TEST_NAME must_fail_2
#)
#
#add_copyright_test(
#    SOURCE_DIR ${CMAKE_SOURCE_DIR}
#    IGNORE_DIR ${CMAKE_BINARY_DIR}
#    INCLUDE_PATTERN \\.cpp$|\\.h$
#    IGNORE_PATTERN no_copyright\\.h$
#    TEST_NAME must_fail_3
#)

add_copyright_test(
    SOURCE_DIR ${CMAKE_SOURCE_DIR}
    IGNORE_PATTERN \\.h$
    TEST_NAME must_fail_4
)

add_copyright_test(
    SOURCE_DIR ${CMAKE_SOURCE_DIR}
    IGNORE_DIR ${CMAKE_BINARY_DIR}
    IGNORE_PATTERN no_copyright
    TEST_NAME must_succeed_1
)

#add_copyright_test(
#    SOURCE_DIR ${CMAKE_SOURCE_DIR}
#    IGNORE_DIR ${CMAKE_BINARY_DIR}
#    INCLUDE_PATTERN \\.cpp$
#    IGNORE_PATTERN no_copyright\\.cpp$
#    TEST_NAME must_succeed_2
#)

add_copyright_test(
    SOURCE_DIR ${CMAKE_SOURCE_DIR}
    IGNORE_DIR ${CMAKE_BINARY_DIR}
    INCLUDE_PATTERN \\.cpp$|\\.h$
    IGNORE_PATTERN no_copyright\\.h$|no_copyright\\.cpp$
    TEST_NAME must_succeed_3
)
