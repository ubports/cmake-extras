cmake_minimum_required(VERSION 3.0.2)
project(cmake-extras)

include(GNUInstallDirs)

# Modules using the newer find_package() "config" extension mechanism.
install(
  DIRECTORY "src/"
  DESTINATION "${CMAKE_INSTALL_DATADIR}/cmake/"
  USE_SOURCE_PERMISSIONS
)

# Modules installed directly to CMAKE_ROOT
# TODO: migrate these to the above tree, since installing to
#       CMAKE_ROOT is frowned upon.
install(
  DIRECTORY "modules/"
  DESTINATION "${CMAKE_ROOT}/Modules/"
  USE_SOURCE_PERMISSIONS
)
