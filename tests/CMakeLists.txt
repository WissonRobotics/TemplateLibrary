cmake_minimum_required(VERSION 3.11)
project(TemplateLibrary_utests CXX)

if(NOT TARGET TemplateLibrary)
    # Stand-alone build
    find_package(TemplateLibrary REQUIRED)
endif()

include(../cmake/utils.cmake)

find_package(PkgConfig)
 

find_package(Catch2 REQUIRED)
if(Catch2_FOUND)
    message(STATUS "Packaged version of Catch will be used.")
else()
    message(STATUS "Bundled version of Catch will be downloaded and used.")
    include(FetchContent)
    FetchContent_Declare(Catch2
            GIT_REPOSITORY https://github.com/catchorg/Catch2.git
            GIT_TAG 53d0d913a422d356b23dd927547febdf69ee9081 # v3.5.0
    )
    FetchContent_MakeAvailable(Catch2)
endif()

set(TemplateLibrary_UTESTS_SOURCES
    test.cpp 
)


enable_testing()

function(TemplateLibrary_prepare_test test_target TemplateLibrary_lib)
    add_executable(${test_target} ${TemplateLibrary_UTESTS_SOURCES})
    TemplateLibrary_enable_warnings(${test_target})
    target_link_libraries(${test_target} PRIVATE ${TemplateLibrary_lib})
    target_link_libraries(${test_target} PRIVATE Catch2::Catch2WithMain)
    if(TemplateLibrary_SANITIZE_ADDRESS)
        TemplateLibrary_enable_sanitizer(${test_target})
    endif()
    add_test(NAME ${test_target} COMMAND ${test_target})
    set_tests_properties(${test_target} PROPERTIES RUN_SERIAL ON)
endfunction()

# The compiled library tests
if(TemplateLibrary_BUILD_TESTS OR TemplateLibrary_BUILD_ALL)
    TemplateLibrary_prepare_test(TemplateLibrary-utests TemplateLibrary::TemplateLibrary)
endif()
 