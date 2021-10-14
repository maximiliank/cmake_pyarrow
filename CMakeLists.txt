cmake_minimum_required(VERSION 3.18)
project(cmake_pyarrow)

set(CMAKE_CXX_STANDARD 20)


set(Arrow_DIR /opt/arrow_6_0_0/lib/cmake/arrow)
find_package(Arrow CONFIG REQUIRED)

add_subdirectory(Source/MyLib)
add_subdirectory(python)
