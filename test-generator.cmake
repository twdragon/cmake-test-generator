message(STATUS "Processing tests for ${PROJECT_NAME}")

enable_testing()

option(COMPILE_TESTS
    "Set this option to turn on compilation of the test suite"
    ON)

set(TEST_GENERATOR_ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/cmake-test-generator")
if(NOT DEFINED TEST_DIR)
    set(TEST_DIR "${CMAKE_CURRENT_SOURCE_DIR}/tests")
endif(NOT DEFINED TEST_DIR)

if(NOT DEFINED TEST_TEMPLATE_NAME)
    set(TEST_TEMPLATE_NAME "${TEST_GENERATOR_ROOT_DIR}/config/test.cpp.in")
endif(NOT DEFINED TEST_TEMPLATE_NAME)

if(NOT DEFINED TEST_LIBRARY)
    set(TEST_LIBRARY "${PROJECT_NAME}")
endif(NOT DEFINED TEST_LIBRARY)

foreach(I_TEST IN LISTS TESTS_AVAILABLE)
	if(EXISTS ${TEST_DIR}/${I_TEST}-test.cpp)
		message(STATUS "Preparing test '${I_TEST}'")
	else(EXISTS ${TEST_DIR}/${I_TEST}-test.cpp)
		message(STATUS "Added unexisting test, re-creating test as stub: '${I_TEST}'")
        if(NOT EXISTS "${TEST_TEMPLATE_NAME}")
		    message(ERROR "Cannot find test template ${TEST_GENERATOR_ROOT_DIR}/config/test.cpp.in. Please reclone repository or provide correct test template!")
        endif(NOT EXISTS "${TEST_TEMPLATE_NAME}")
        configure_file(${TEST_TEMPLATE_NAME}
			${TEST_DIR}/${I_TEST}-test.cpp
			@ONLY)
	endif(EXISTS ${TEST_DIR}/${I_TEST}-test.cpp)
	if(COMPILE_TESTS)
		add_executable(${I_TEST}-test
			${TEST_DIR}/${I_TEST}-test.cpp)
        if(DEFINED ${I_TEST}_LIBRARIES)
            target_link_libraries(${I_TEST}-test ${TEST_LIBRARY} ${${I_TEST}_LIBRARIES})
        else(DEFINED ${I_TEST}_LIBRARIES)
            target_link_libraries(${I_TEST}-test ${TEST_LIBRARY})
        endif(DEFINED ${I_TEST}_LIBRARIES)
		if(DEFINED ${I_TEST}_INCLUDE_DIRS)
		    target_include_directories(${I_TEST}-test PRIVATE ${${I_TEST}_INCLUDE_DIRS})
		endif(DEFINED ${I_TEST}_INCLUDE_DIRS)
        add_test(NAME test-${I_TEST} COMMAND "${I_TEST}-test" "${${I_TEST}_FLAGS}" WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")
        message(STATUS "Test ${I_TEST} will be run as '${I_TEST}-test ${${I_TEST}_RUN_FLAGS}'")
	endif(COMPILE_TESTS)
endforeach()

