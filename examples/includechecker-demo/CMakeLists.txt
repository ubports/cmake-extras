cmake_minimum_required(VERSION 3.1)
project(includechecker-demo LANGUAGES C CXX)

include(GNUInstallDirs)
find_package(PkgConfig REQUIRED)

pkg_check_modules(
  GLIB REQUIRED
  glib-2.0
  gobject-2.0
)
include_directories(${GLIB_INCLUDE_DIRS})

set (CMAKE_CXX_STANDARD 14)
if(CMAKE_COMPILER_IS_GNUCC)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -Wpedantic")
endif()

enable_testing()
add_subdirectory(test)

