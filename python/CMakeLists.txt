set(TARGET_NAME pymylib)

file(GLOB_RECURSE sources src/cpp/*.cpp src/cpp/*.h src/cpp/*.hpp)
file(GLOB_RECURSE pyfiles src/pymylib/*.py)

add_library(${TARGET_NAME} MODULE ${sources})
target_link_libraries(${TARGET_NAME} PRIVATE MyLib pybind11::module MyLib::pyarrow)
set_target_properties(${TARGET_NAME} PROPERTIES
        PREFIX "${PYTHON_MODULE_PREFIX}"
        SUFFIX "${PYTHON_MODULE_EXTENSION}"
        )

add_subdirectory(package)
