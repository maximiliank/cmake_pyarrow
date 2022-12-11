cmake_minimum_required(VERSION 3.18)
project(cmake_pyarrow)

set(CMAKE_CXX_STANDARD 20)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/")

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(PyArrow REQUIRED)
find_package(pybind11 REQUIRED)

add_subdirectory(Source/MyLib)
add_subdirectory(python)
