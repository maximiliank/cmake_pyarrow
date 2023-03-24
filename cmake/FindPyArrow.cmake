find_package(Python COMPONENTS Interpreter Development)

message(STATUS "Using python ${Python_EXECUTABLE}")
execute_process(COMMAND "${Python_EXECUTABLE}" "-c" "import pyarrow as pa; print(pa.get_include());"
        RESULT_VARIABLE _PYARROW_SEARCH_SUCCESS
        OUTPUT_VARIABLE PYARROW_INCLUDE_DIR
        ERROR_VARIABLE _PYARROW_ERROR_VALUE
        OUTPUT_STRIP_TRAILING_WHITESPACE)

if(_PYARROW_SEARCH_SUCCESS AND NOT _PYARROW_SEARCH_SUCCESS EQUAL 0)
    message(STATUS "FAILED: ${_PYARROW_SEARCH_SUCCESS}\n${_PYARROW_ERROR_VALUE}")
endif()

set(ARROW_INCLUDE_DIR ${PYARROW_INCLUDE_DIR})
execute_process(COMMAND "${Python_EXECUTABLE}" "-c" "import pyarrow as pa; print(pa.get_library_dirs());"
        RESULT_VARIABLE _PYARROW_SEARCH_SUCCESS
        OUTPUT_VARIABLE _PYARROW_VALUES_OUTPUT
        ERROR_VARIABLE _PYARROW_ERROR_VALUE
        OUTPUT_STRIP_TRAILING_WHITESPACE)

if(_PYARROW_SEARCH_SUCCESS AND NOT _PYARROW_SEARCH_SUCCESS EQUAL 0)
    message(STATUS "FAILED: ${_PYARROW_SEARCH_SUCCESS}\n${_PYARROW_ERROR_VALUE}")
endif()

# convert to the path needed
string(REGEX REPLACE "," ";" _PYARROW_VALUES ${_PYARROW_VALUES_OUTPUT})
string(REGEX REPLACE "'" "" _PYARROW_VALUES ${_PYARROW_VALUES})
string(REGEX REPLACE "\\]" "" _PYARROW_VALUES ${_PYARROW_VALUES})
string(REGEX REPLACE "\\[" "" _PYARROW_VALUES ${_PYARROW_VALUES})
list(GET _PYARROW_VALUES 0 ARROW_SEARCH_LIB_PATH)

message(STATUS "include: ${PYARROW_INCLUDE_DIR} lib: ${ARROW_SEARCH_LIB_PATH}")

set(_Arrow_KNOWN_VERSIONS ${Arrow_ADDITIONAL_VERSIONS}
        "1100" "1000" "900" "800")
set(_arrow_TEST_VERSIONS arrow)
set(_pyarrow_TEST_VERSIONS arrow_python)
foreach(version ${_Arrow_KNOWN_VERSIONS})
    list(APPEND _arrow_TEST_VERSIONS "libarrow.so.${version}")
    list(APPEND _pyarrow_TEST_VERSIONS "libarrow_python.so.${version}")
endforeach()

find_library(ARROW_LIB NAMES ${_arrow_TEST_VERSIONS}
        PATHS
        ${ARROW_SEARCH_LIB_PATH}
        NO_DEFAULT_PATH)
message(STATUS "Found ${ARROW_LIB} in ${ARROW_SEARCH_LIB_PATH}")

find_library(ARROW_PYTHON_LIB NAMES ${_pyarrow_TEST_VERSIONS}
        PATHS
        ${ARROW_SEARCH_LIB_PATH}
        NO_DEFAULT_PATH)
message(STATUS "Found ${ARROW_PYTHON_LIB} in ${ARROW_SEARCH_LIB_PATH}")

find_package_handle_standard_args(PyArrow REQUIRED_VARS PYARROW_INCLUDE_DIR ARROW_LIB ARROW_PYTHON_LIB)

get_filename_component(ARROW_SONAME ${ARROW_LIB} NAME)
get_filename_component(PYARROW_SONAME ${ARROW_PYTHON_LIB} NAME)

add_library(arrow::arrow SHARED IMPORTED)
set_target_properties(arrow::arrow PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${ARROW_INCLUDE_DIR}"
        #INTERFACE_LINK_LIBRARIES "dl"
        IMPORTED_LOCATION "${ARROW_LIB}"
        IMPORTED_SONAME "${ARROW_SONAME}"
        )

add_library(pyarrow::pyarrow SHARED IMPORTED)
set_target_properties(pyarrow::pyarrow PROPERTIES
        IMPORTED_LOCATION "${ARROW_PYTHON_LIB}"
        IMPORTED_SONAME ${PYARROW_SONAME})

add_library(MyLib::pyarrow INTERFACE IMPORTED)
set_property(TARGET MyLib::pyarrow PROPERTY
        INTERFACE_LINK_LIBRARIES arrow::arrow pyarrow::pyarrow Python::Module)
set_property(TARGET MyLib::pyarrow APPEND PROPERTY INTERFACE_COMPILE_DEFINITIONS _GLIBCXX_USE_CXX11_ABI=0)
