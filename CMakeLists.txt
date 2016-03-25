project(cmake-extras)
cmake_minimum_required(VERSION 2.8.9)

install(
  DIRECTORY "src/"
  DESTINATION "${CMAKE_ROOT}/Modules/"
)
