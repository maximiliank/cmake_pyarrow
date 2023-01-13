find_package(Python COMPONENTS Interpreter Development)
message(STATUS "Using python ${Python_EXECUTABLE}")
execute_process(COMMAND "${Python_EXECUTABLE}" ${CMAKE_SOURCE_DIR}/python/find_pyarrow.py
        RESULT_VARIABLE STATUS
        OUTPUT_VARIABLE PYARROW_PATHS
        ERROR_VARIABLE ERROR
        ECHO_OUTPUT_VARIABLE
        ECHO_ERROR_VARIABLE
        )
if(STATUS AND NOT STATUS EQUAL 0)
    message(STATUS "FAILED: ${STATUS}\n${ERROR}")
endif()

foreach(NameAndValue ${PYARROW_PATHS})
    string(STRIP ${NameAndValue} NameAndValue)
    string(REGEX MATCH "^[^=]+" Name ${NameAndValue})
    string(REPLACE "${Name}=" "" Value ${NameAndValue})
    set(${Name} "${Value}")
    message(STATUS "Using ${Name} = ${Value}")
endforeach()
message(STATUS "${ARROW_INCLUDE_DIR} ${ARROW_LIB_PATH}")

set(_Arrow_KNOWN_VERSIONS ${Arrow_ADDITIONAL_VERSIONS}
        "1000" "900" "800")
set(_arrow_TEST_VERSIONS arrow)
set(_pyarrow_TEST_VERSIONS arrow_python)
foreach(version ${_Arrow_KNOWN_VERSIONS})
    list(APPEND _arrow_TEST_VERSIONS "libarrow.so.${version}")
    list(APPEND _pyarrow_TEST_VERSIONS "libarrow_python.so.${version}")
endforeach()

find_library(ARROW_LIB NAMES ${_arrow_TEST_VERSIONS}
        PATHS
        ${ARROW_LIB_PATH}
        NO_DEFAULT_PATH)
message(STATUS "Found ${ARROW_LIB} in ${ARROW_LIB_PATH}")

find_library(ARROW_PYTHON_LIB NAMES ${_pyarrow_TEST_VERSIONS}
        PATHS
        ${ARROW_LIB_PATH}
        NO_DEFAULT_PATH)
message(STATUS "Found ${ARROW_PYTHON_LIB} in ${ARROW_LIB_PATH}")

find_package_handle_standard_args(PyArrow REQUIRED_VARS ARROW_INCLUDE_DIR ARROW_LIB ARROW_PYTHON_LIB)

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
