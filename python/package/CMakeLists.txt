file(GLOB_RECURSE pyfiles ../src/pymylib/*.py)

set(PYLIB_TARGET_NAME pymylib)
add_custom_target(copyPackageFiles)
add_custom_command(TARGET copyPackageFiles POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "$<TARGET_FILE:${PYLIB_TARGET_NAME}>"
        ${CMAKE_CURRENT_BINARY_DIR}/${PYLIB_TARGET_NAME}/lib/$<TARGET_FILE_NAME:${PYLIB_TARGET_NAME}>
        COMMENT "Copying $<TARGET_FILE:${TARGET_NAME}> to package/${TARGET_NAME}/lib folder"
        )

foreach (filename ${pyfiles})
    add_custom_command(TARGET copyPackageFiles POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E
            copy_if_different ${filename} "${CMAKE_CURRENT_BINARY_DIR}/${PYLIB_TARGET_NAME}"
            COMMENT "Copying ${filename} to package folder"
            )
endforeach (filename)

add_custom_command(TARGET copyPackageFiles POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E
        copy_if_different ${CMAKE_CURRENT_SOURCE_DIR}/setup.py "${CMAKE_CURRENT_BINARY_DIR}"
        COMMAND ${CMAKE_COMMAND} -E
        copy_if_different ${CMAKE_CURRENT_SOURCE_DIR}/getwheelname.py "${CMAKE_CURRENT_BINARY_DIR}"
        COMMENT "Copying setup.py and getwheelname.py"
        )

add_dependencies(copyPackageFiles ${PYLIB_TARGET_NAME})

add_custom_target(PyPackageBuild
        COMMAND "${PYTHON_EXECUTABLE}" -m pip wheel .
        WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
        COMMENT "Building python wheel package"
        )
add_dependencies(PyPackageBuild copyPackageFiles)

execute_process(COMMAND "${PYTHON_EXECUTABLE}" getwheelname.py OUTPUT_VARIABLE PY_WHEELFILE
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
message(STATUS "Detected Python wheel filename ${PY_WHEELFILE}")

add_custom_target(PyPackageInstall
        COMMAND "${PYTHON_EXECUTABLE}" -m pip install --upgrade --force-reinstall --no-deps "${PY_WHEELFILE}"
        WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
        COMMENT "Installing wheel file"
        )
add_dependencies(PyPackageInstall PyPackageBuild)
