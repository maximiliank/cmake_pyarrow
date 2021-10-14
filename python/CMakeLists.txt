set(TARGET_NAME pymylib)

find_package(pybind11 REQUIRED)

set(ArrowPython_DIR /opt/arrow_6_0_0/lib/cmake/arrow)
find_package(ArrowPython CONFIG REQUIRED)

file(GLOB_RECURSE sources src/cpp/*.cpp src/cpp/*.h src/cpp/*.hpp)
file(GLOB_RECURSE pyfiles src/pymylib/*.py)

add_library(${TARGET_NAME} MODULE ${sources})
target_link_libraries(${TARGET_NAME} PRIVATE pybind11::module MyLib arrow_python_shared)

set_target_properties(${TARGET_NAME} PROPERTIES
        PREFIX "${PYTHON_MODULE_PREFIX}"
        SUFFIX "${PYTHON_MODULE_EXTENSION}"
        )

add_subdirectory(package)
