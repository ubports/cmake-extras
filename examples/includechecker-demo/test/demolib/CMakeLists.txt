
find_package(IncludeChecker REQUIRED)

include_directories("${CMAKE_SOURCE_DIR}/include")

function(add_demolib_test NAME PREFIX)
  add_executable(
    "${NAME}"
    "${PREFIX}${NAME}.cpp"
  )

  target_link_libraries(
    "${NAME}"
    ${GLIB_LDFLAGS}
  )

  add_test(
    "${NAME}"
    "${NAME}"
  )
endfunction()

add_demolib_test("good-header-test" "")
add_demolib_test("bad-header-test" "bad/")

set(INCLUDE_CHECK_FORBIDDEN "glib.h" CACHE STRING "")
set(INCLUDE_CHECK_ALLOWED "bad/bad-header.h:glib.h" CACHE STRING "")
set(INCLUDE_CHECK_IGNORE "internal" CACHE STRING "")

add_include_check(
    demolib-include-check
    DIRECTORIES
        "${CMAKE_SOURCE_DIR}/include"
    FORBIDDEN
        ${INCLUDE_CHECK_FORBIDDEN}
    ALLOWED
        ${INCLUDE_CHECK_ALLOWED}
    IGNORE
        ${INCLUDE_CHECK_IGNORE}
    FILE_EXTENSIONS
        ".h"
        ".hxx"
    COMPILER_OPTIONS
        "-std=gnu++14"
)

