cmake_minimum_required(VERSION 3.1)
project(intltool-demo)

include(GNUInstallDirs)
find_package(GSettings)

add_schema ("static.gschema.xml")

configure_file ("generated.gschema.xml.in" "generated.gschema.xml")
add_schema ("generated.gschema.xml")
