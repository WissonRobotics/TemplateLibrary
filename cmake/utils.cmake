# Get TemplateLibrary version from include/TemplateLibrary/version.h and put it in TemplateLibrary_VERSION
function(TemplateLibrary_extract_version)
    file(READ "${CMAKE_CURRENT_LIST_DIR}/include/TemplateLibrary/version.h" file_contents)
    string(REGEX MATCH "TemplateLibrary_VER_MAJOR ([0-9]+)" _ "${file_contents}")
    if(NOT CMAKE_MATCH_COUNT EQUAL 1)
        message(FATAL_ERROR "Could not extract major version number from TemplateLibrary/version.h")
    endif()
    set(ver_major ${CMAKE_MATCH_1})

    string(REGEX MATCH "TemplateLibrary_VER_MINOR ([0-9]+)" _ "${file_contents}")
    if(NOT CMAKE_MATCH_COUNT EQUAL 1)
        message(FATAL_ERROR "Could not extract minor version number from TemplateLibrary/version.h")
    endif()

    set(ver_minor ${CMAKE_MATCH_1})
    string(REGEX MATCH "TemplateLibrary_VER_PATCH ([0-9]+)" _ "${file_contents}")
    if(NOT CMAKE_MATCH_COUNT EQUAL 1)
        message(FATAL_ERROR "Could not extract patch version number from TemplateLibrary/version.h")
    endif()
    set(ver_patch ${CMAKE_MATCH_1})

    set(TemplateLibrary_VERSION_MAJOR ${ver_major} PARENT_SCOPE)
    set(TemplateLibrary_VERSION_MINOR ${ver_minor} PARENT_SCOPE)
    set(TemplateLibrary_VERSION_PATCH ${ver_patch} PARENT_SCOPE)
    set(TemplateLibrary_VERSION "${ver_major}.${ver_minor}.${ver_patch}" PARENT_SCOPE)
endfunction()

# Turn on warnings on the given target
function(TemplateLibrary_enable_warnings target_name)
    if(TemplateLibrary_BUILD_WARNINGS)
        if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
            list(APPEND MSVC_OPTIONS "/W3")
            if(MSVC_VERSION GREATER 1900) # Allow non fatal security warnings for msvc 2015
                list(APPEND MSVC_OPTIONS "/WX")
            endif()
        endif()

        target_compile_options(
            ${target_name}
            PRIVATE $<$<OR:$<CXX_COMPILER_ID:Clang>,$<CXX_COMPILER_ID:AppleClang>,$<CXX_COMPILER_ID:GNU>>:
                    -Wall
                    -Wextra
                    -Wconversion
                    -pedantic
                    -Werror
                    -Wfatal-errors>
                    $<$<CXX_COMPILER_ID:MSVC>:${MSVC_OPTIONS}>)
    endif()
endfunction()

# Enable address sanitizer (gcc/clang only)
function(TemplateLibrary_enable_sanitizer target_name)
    if(NOT CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
        message(FATAL_ERROR "Sanitizer supported only for gcc/clang")
    endif()
    message(STATUS "Address sanitizer enabled")
    target_compile_options(${target_name} PRIVATE -fsanitize=address,undefined)
    target_compile_options(${target_name} PRIVATE -fno-sanitize=signed-integer-overflow)
    target_compile_options(${target_name} PRIVATE -fno-sanitize-recover=all)
    target_compile_options(${target_name} PRIVATE -fno-omit-frame-pointer)
    target_link_libraries(${target_name} PRIVATE -fsanitize=address,undefined -fuse-ld=gold)
endfunction()
