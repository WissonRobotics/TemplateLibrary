cmake_minimum_required(VERSION 3.16.0)

######################  utils *******************
include(cmake/utils.cmake)
include(cmake/ide.cmake)

#######################  get version from version.h*******************
TemplateLibrary_extract_version()

 
############################ Project Info *******************
project (TemplateLibrary VERSION ${TemplateLibrary_VERSION} LANGUAGES CXX)
message(STATUS "Build TemplateLibrary: ${TemplateLibrary_VERSION}")

############################ build type default as Release *******************
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Choose Release or Debug" FORCE)
endif()

############################ choose compiler *******************
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

############################ check system platform*******************
if(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "aarch64")
    message("Platform is Arm aarch64")
    set(ARM64   1)
    set(UNIX 1)
    set(WINDOWS 0)
elseif(${CMAKE_HOST_UNIX})
    message("Platform is Linux x86_64")
    set(ARM64   0)
    set(UNIX 1)
    set(WINDOWS 0)
elseif(${CMAKE_HOST_WIN32})
    message("Platform is Windows")
    set(ARM64   0)
    set(UNIX 0)
    set(WINDOWS 1)
    add_definitions(-D_WIN32_WINNT=0x0601)
endif()
 
if(${WINDOWS})
include(InstallRequiredSystemLibraries)
endif()
include(GNUInstallDirs)

 
 
################## build options #############################
if(NOT DEFINED TemplateLibrary_MASTER_PROJECT)
    if(CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
        set(TemplateLibrary_MASTER_PROJECT ON)
    else()
        set(TemplateLibrary_MASTER_PROJECT OFF)
    endif()
endif()
message(TemplateLibrary_MASTER_PROJECT = ${TemplateLibrary_MASTER_PROJECT})
 
# example options
option(TemplateLibrary_BUILD_EXAMPLE "Build example" ${TemplateLibrary_MASTER_PROJECT})

# testing options
option(TemplateLibrary_BUILD_TESTS "Build tests" ${TemplateLibrary_MASTER_PROJECT})

# install options
option(TemplateLibrary_INSTALL "Generate the install target" ${TemplateLibrary_MASTER_PROJECT})

# sanitizer options
option(TemplateLibrary_SANITIZE_ADDRESS "Enable address sanitizer in tests" OFF)



##################  build static library #############################
find_package(SlimSerialRTDE REQUIRED)

find_package(Boost REQUIRED COMPONENTS system)
 
find_package(Threads REQUIRED)

find_package(spdlog REQUIRED)
 
set(TemplateLibrary_SRCS  
src/TemplateLibrary.cpp
)
add_library(TemplateLibrary STATIC ${TemplateLibrary_SRCS} ${TemplateLibrary_ALL_HEADERS})

add_library(TemplateLibrary::TemplateLibrary ALIAS TemplateLibrary)

set(TemplateLibrary_INCLUDES_LEVEL "")
if(TemplateLibrary_SYSTEM_INCLUDES)
    set(TemplateLibrary_INCLUDES_LEVEL "SYSTEM")
endif()

target_include_directories(TemplateLibrary ${TemplateLibrary_INCLUDES_LEVEL} PUBLIC 
"$<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/include>"
"$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>")

target_link_libraries(TemplateLibrary PUBLIC 
Boost::system
Threads::Threads
spdlog::spdlog
SlimSerialRTDE::SlimSerialRTDE
)

# if(${UNIX})
# add_compile_options(-fPIC)
# target_link_libraries(TemplateLibrary PUBLIC
#  pthread dl
#  -fPIC
# )
# endif()

set_target_properties(TemplateLibrary PROPERTIES VERSION ${TemplateLibrary_VERSION} SOVERSION ${TemplateLibrary_VERSION_MAJOR}.${TemplateLibrary_VERSION_MINOR})


##################  build example #############################
if(TemplateLibrary_BUILD_EXAMPLE)
    message(STATUS "Generating example(s)")
    add_subdirectory(example)
endif()


##################  build tests #############################
if(TemplateLibrary_BUILD_TESTS )
    message(STATUS "Generating tests")
    enable_testing()
    add_subdirectory(tests)
endif()
 

##################  install #############################
if(TemplateLibrary_INSTALL)
    message(STATUS "Generating install")
    set(project_config_in "${CMAKE_CURRENT_LIST_DIR}/cmake/TemplateLibraryConfig.cmake.in")
    set(project_config_out "${CMAKE_CURRENT_BINARY_DIR}/TemplateLibraryConfig.cmake")
    set(config_targets_file "TemplateLibraryConfigTargets.cmake")
    set(version_config_file "${CMAKE_CURRENT_BINARY_DIR}/TemplateLibraryConfigVersion.cmake")
    set(export_dest_dir "${CMAKE_INSTALL_LIBDIR}/cmake/TemplateLibrary")
    set(pkgconfig_install_dir "${CMAKE_INSTALL_LIBDIR}/pkgconfig")
    set(pkg_config "${CMAKE_BINARY_DIR}/${PROJECT_NAME}.pc")

    # ---------------------------------------------------------------------------------------
    # Include files
    # ---------------------------------------------------------------------------------------
    install(DIRECTORY include/ DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")
    install(
        TARGETS TemplateLibrary
        EXPORT TemplateLibrary
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})

    # ---------------------------------------------------------------------------------------
    # Install pkg-config file
    # ---------------------------------------------------------------------------------------
    if(IS_ABSOLUTE "${CMAKE_INSTALL_INCLUDEDIR}")
        set(PKG_CONFIG_INCLUDEDIR "${CMAKE_INSTALL_INCLUDEDIR}")
    else()
        set(PKG_CONFIG_INCLUDEDIR "\${prefix}/${CMAKE_INSTALL_INCLUDEDIR}")
    endif()
    if(IS_ABSOLUTE "${CMAKE_INSTALL_LIBDIR}")
        set(PKG_CONFIG_LIBDIR "${CMAKE_INSTALL_LIBDIR}")
    else()
        set(PKG_CONFIG_LIBDIR "\${exec_prefix}/${CMAKE_INSTALL_LIBDIR}")
    endif()
    get_target_property(PKG_CONFIG_DEFINES TemplateLibrary INTERFACE_COMPILE_DEFINITIONS)
    string(REPLACE ";" " -D" PKG_CONFIG_DEFINES "${PKG_CONFIG_DEFINES}")
    string(CONCAT PKG_CONFIG_DEFINES "-D" "${PKG_CONFIG_DEFINES}")
    configure_file("cmake/${PROJECT_NAME}.pc.in" "${pkg_config}" @ONLY)
    install(FILES "${pkg_config}" DESTINATION "${pkgconfig_install_dir}")

    # ---------------------------------------------------------------------------------------
    # Install CMake config files
    # ---------------------------------------------------------------------------------------
    export(TARGETS TemplateLibrary  NAMESPACE TemplateLibrary::
           FILE "${CMAKE_CURRENT_BINARY_DIR}/${config_targets_file}")
    install(EXPORT TemplateLibrary DESTINATION ${export_dest_dir} NAMESPACE TemplateLibrary:: FILE ${config_targets_file})

    include(CMakePackageConfigHelpers)
    configure_package_config_file("${project_config_in}" "${project_config_out}" INSTALL_DESTINATION ${export_dest_dir})

    write_basic_package_version_file("${version_config_file}" COMPATIBILITY SameMajorVersion)
    install(FILES "${project_config_out}" "${version_config_file}" DESTINATION "${export_dest_dir}")

    # ---------------------------------------------------------------------------------------
    # Support creation of installable packages
    # ---------------------------------------------------------------------------------------
    include(cmake/TemplateLibraryCPack.cmake)
endif()



##################  uninstall #############################
# make uninstall
add_custom_target("uninstall" COMMENT "Uninstall installed files")
add_custom_command(
    TARGET "uninstall"
    POST_BUILD
    COMMENT "Uninstall files with install_manifest.txt"
    COMMAND xargs rm -vf < install_manifest.txt || echo Nothing in
            install_manifest.txt to be uninstalled!
    COMMAND xargs rm -rf  /usr/local/include/TemplateLibrary
    COMMAND xargs rm -rf  /usr/local/lib/cmake/TemplateLibrary
)




 