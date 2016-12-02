cmake_minimum_required(VERSION 3.0.2)
project(findgmock-demo LANGUAGES C CXX)

# find_package(GMock) will find the Google Mock source, and add it to
# this project's build.  It will create the targets gtest, gtest_main,
# gmock, and gmock_main.
find_package(GMock)

add_executable(test-suite test-suite.cpp)
target_link_libraries(test-suite gtest_main)
