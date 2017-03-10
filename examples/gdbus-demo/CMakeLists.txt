cmake_minimum_required(VERSION 3.1)
project(gdbus-demo)

set (CMAKE_CXX_STANDARD 14)
if(CMAKE_COMPILER_IS_GNUCC)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -Wpedantic")
endif()
enable_testing()

include(GNUInstallDirs)
find_package(GDbus)
find_package(PkgConfig REQUIRED)

pkg_check_modules(
  GLIB REQUIRED
  gio-unix-2.0
  glib-2.0
)
include_directories(${GLIB_INCLUDE_DIRS})
include_directories(${CMAKE_CURRENT_BINARY_DIR})

set(SOURCES
  main.cpp
)

add_gdbus_codegen(
  SOURCES
  dbus-standard
  org.freedesktop
  org.freedesktop.DBus.xml
  )

add_gdbus_codegen(
  SOURCES
  dbus-namespaced
  org.freedesktop
  org.freedesktop.DBus.xml
  NAMESPACE "DBus"
  )

add_executable(
  test-gdbus

  ${SOURCES}
  )
target_link_libraries(
  test-gdbus

  ${GLIB_LDFLAGS}
  )

add_test(test-gdbus test-gdbus)
