include(CMakeParseArguments)

enable_testing()

option(COMPILE_TESTS
    "Set this option to turn on compilation of the test suite"
    ON)

message(STATUS "Processing tests for ${PROJECT_NAME}")

function(CreateTests) # TEST_LIST TEST_DIR TEST_TEMPLATE_NAME TEST_LIBRARY
    set(SINGLE_VALUES TEST_DIR TEST_TEMPLATE_NAME TEST_LIBRARY)
    cmake_parse_arguments(
        CREATE_TESTS
        ""
        "${SINGLE_VALUES}"
        "TEST_LIST"
        ${ARGN}
        )
    if(NOT DEFINED TEST_GENERATOR_ROOT_DIR)
        if(IS_DIRECTORY "${PROJECT_SOURCE_DIR}/cmake-test-generator")
            set(TEST_GENERATOR_ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/cmake-test-generator")
        else(IS_DIRECTORY ${PROJECT_SOURCE_DIR}/cmake-test-generator)
            set(TEST_GENERATOR_ROOT_DIR "")
        endif()
    endif()
    if(NOT DEFINED CREATE_TESTS_TEST_DIR)
        set(CREATE_TESTS_TEST_DIR "${CMAKE_CURRENT_SOURCE_DIR}/tests")
    endif(NOT DEFINED CREATE_TESTS_TEST_DIR)
    if(NOT DEFINED CREATE_TESTS_TEST_TEMPLATE_NAME)
        set(CREATE_TESTS_TEST_TEMPLATE_NAME "${TEST_GENERATOR_ROOT_DIR}/config/test.cpp.in")
    endif(NOT DEFINED CREATE_TESTS_TEST_TEMPLATE_NAME)
    if(NOT DEFINED CREATE_TESTS_TEST_LIBRARY)
        set(CREATE_TESTS_TEST_LIBRARY "${PROJECT_NAME}")
    endif(NOT DEFINED CREATE_TESTS_TEST_LIBRARY)

    foreach(I_TEST IN LISTS CREATE_TESTS_TEST_LIST)
        if(EXISTS ${CREATE_TESTS_TEST_DIR}/${I_TEST}-test.cpp)
            message(STATUS "Preparing test '${I_TEST}'")
        else(EXISTS ${CREATE_TESTS_TEST_DIR}/${I_TEST}-test.cpp)
            message(STATUS "Added unexisting test, re-creating test as stub: '${I_TEST}'")
            if(NOT EXISTS "${CREATE_TESTS_TEST_TEMPLATE_NAME}")
                message(ERROR "Cannot find test template ${TEST_GENERATOR_ROOT_DIR}/config/test.cpp.in. Please reclone repository or provide correct test template!")
            endif(NOT EXISTS "${CREATE_TESTS_TEST_TEMPLATE_NAME}")
            configure_file(${CREATE_TESTS_TEST_TEMPLATE_NAME}
                ${CREATE_TESTS_TEST_DIR}/${I_TEST}-test.cpp
                @ONLY)
        endif(EXISTS ${CREATE_TESTS_TEST_DIR}/${I_TEST}-test.cpp)
        if(COMPILE_TESTS)
            add_executable(${I_TEST}-test
                ${CREATE_TESTS_TEST_DIR}/${I_TEST}-test.cpp)
            if(DEFINED CREATE_TESTS_TEST_LIBRARY)
                if(DEFINED ${I_TEST}_LIBRARIES)
                    target_link_libraries(${I_TEST}-test ${CREATE_TESTS_TEST_LIBRARY} ${${I_TEST}_LIBRARIES})
                else(DEFINED ${I_TEST}_LIBRARIES)
                    target_link_libraries(${I_TEST}-test ${CREATE_TESTS_TEST_LIBRARY})
                endif(DEFINED ${I_TEST}_LIBRARIES)
            else(DEFINED CREATE_TESTS_TEST_LIBRARY)
                if(DEFINED ${I_TEST}_LIBRARIES)
                    target_link_libraries(${I_TEST}-test ${${I_TEST}_LIBRARIES})
                endif(DEFINED ${I_TEST}_LIBRARIES)
            endif(DEFINED CREATE_TESTS_TEST_LIBRARY)
            if(DEFINED ${I_TEST}_INCLUDE_DIRS)
                target_include_directories(${I_TEST}-test PRIVATE ${${I_TEST}_INCLUDE_DIRS})
            endif(DEFINED ${I_TEST}_INCLUDE_DIRS)
            add_test(NAME test-${I_TEST} COMMAND "${I_TEST}-test" "${${I_TEST}_FLAGS}" WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")
            message(STATUS "Test ${I_TEST} will be run in ${CMAKE_CURRENT_BINARY_DIR} as '${I_TEST}-test ${${I_TEST}_RUN_FLAGS}'")
        endif(COMPILE_TESTS)
    endforeach()
endfunction(CreateTests)

