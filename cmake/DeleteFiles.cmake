cmake_minimum_required(VERSION 2.8 FATAL_ERROR)

set(_ARG_NUM 0)
set(_FOUND_SEPARATOR FALSE)
set(FILES "")

while(_ARG_NUM LESS CMAKE_ARGC)
    if(CMAKE_ARGV${_ARG_NUM} STREQUAL "--")
        set(_FOUND_SEPARATOR TRUE)
        math(EXPR _ARG_NUM "${_ARG_NUM}+1")
    endif()

    if(_FOUND_SEPARATOR AND DEFINED CMAKE_ARGV${_ARG_NUM})
        file(GLOB _FILE_LIST "${CMAKE_ARGV${_ARG_NUM}}")
        list(APPEND FILES ${_FILE_LIST})
    endif()

    math(EXPR _ARG_NUM "${_ARG_NUM}+1")
endwhile()

if(NOT FILES)
    message(FATAL_ERROR "No files given")
endif()

file(REMOVE_RECURSE ${FILES})
