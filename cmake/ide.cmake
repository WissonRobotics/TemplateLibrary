# ---------------------------------------------------------------------------------------
# IDE support for headers
# ---------------------------------------------------------------------------------------
set(TemplateLibrary_HEADERS_DIR "${CMAKE_CURRENT_LIST_DIR}/../include")


file(GLOB TemplateLibrary_TOP_HEADERS "${TemplateLibrary_HEADERS_DIR}/TemplateLibrary/*.h")
file(GLOB TemplateLibrary_LOGURU_HEADERS "${TemplateLibrary_HEADERS_DIR}/TemplateLibrary/*.hpp")
 
set(TemplateLibrary_ALL_HEADERS ${TemplateLibrary_TOP_HEADERS} ${TemplateLibrary_LOGURU_HEADERS})

source_group("Header Files\\TemplateLibrary" FILES ${TemplateLibrary_ALL_HEADERS}) 
