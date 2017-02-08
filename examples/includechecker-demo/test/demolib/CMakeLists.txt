
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

add_include_check(
    demolib-include-check
    DIRECTORIES
        "${CMAKE_SOURCE_DIR}/include"
    FORBIDDEN
        "glib.h"
    ALLOWED
        "bad/bad-header.h:glib.h"
    IGNORE
        "internal"
    FILE_EXTENSIONS
        ".h"
        ".hxx"
    COMPILER_OPTIONS
        "-std=gnu++14"
)

