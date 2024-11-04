cmake_minimum_required(VERSION 3.11)
project(TemplateLibrary_examples CXX)

if(NOT TARGET TemplateLibrary)
    find_package(TemplateLibrary REQUIRED)
endif()

 
add_executable(example
example.cpp
)
TARGET_LINK_LIBRARIES( example
    TemplateLibrary
) 