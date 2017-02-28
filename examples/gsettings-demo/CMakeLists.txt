cmake_minimum_required(VERSION 3.1)
project(intltool-demo)

enable_testing()

include(GNUInstallDirs)
find_package(GSettings)

set (DEFAULT_UUID_VALUE "" CACHE STRING "Default UUID to use in schema.")
set (DEFAULT_UUID "'${DEFAULT_UUID_VALUE}'")

add_schema ("static.gschema.xml")

configure_file ("generated.gschema.xml.in" "generated.gschema.xml")
add_schema ("generated.gschema.xml")

compile_schemas(${CMAKE_CURRENT_BINARY_DIR})
