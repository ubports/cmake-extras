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

add_copyright_test(
    SOURCE_DIR ${CMAKE_SOURCE_DIR}
    IGNORE_DIR ${CMAKE_BINARY_DIR}
    INCLUDE_PATTERN \\.cpp$
    TEST_NAME must_fail_2
)

add_copyright_test(
    SOURCE_DIR ${CMAKE_SOURCE_DIR}
    IGNORE_DIR ${CMAKE_BINARY_DIR}
    INCLUDE_PATTERN \\.cpp|\\.h$
    IGNORE_PATTERN no_copyright\\.h$
    TEST_NAME must_fail_3
)

add_copyright_test(
    SOURCE_DIR ${CMAKE_SOURCE_DIR}
    IGNORE_PATTERN *\\.h|*\\.cpp$
    TEST_NAME must_fail_4
)

add_copyright_test(
    SOURCE_DIR ${CMAKE_SOURCE_DIR}
    IGNORE_DIR ${CMAKE_BINARY_DIR}
    IGNORE_PATTERN no_copyright
    TEST_NAME must_succeed_1
)

add_copyright_test(
    SOURCE_DIR ${CMAKE_SOURCE_DIR}
    IGNORE_DIR ${CMAKE_BINARY_DIR}
    INCLUDE_PATTERN \\.cpp$
    IGNORE_PATTERN no_copyright\\.cpp$
    TEST_NAME must_succeed_2
)

add_copyright_test(
    SOURCE_DIR ${CMAKE_SOURCE_DIR}
    IGNORE_DIR ${CMAKE_BINARY_DIR}
    INCLUDE_PATTERN \\.cpp|\\.h$
    IGNORE_PATTERN no_copyright\\.h$|no_copyright\\.cpp$
    TEST_NAME must_succeed_3
)
