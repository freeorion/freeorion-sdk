cmake_minimum_required(VERSION 2.8 FATAL_ERROR)

set(_ARG_NUM 0)
math(EXPR _LAST_IDX "${CMAKE_ARGC}-1")
set(_FOUND_SEPARATOR FALSE)
set(SOURCE "")
set(DESTINATION "")

while(_ARG_NUM LESS CMAKE_ARGC)
    if(CMAKE_ARGV${_ARG_NUM} STREQUAL "--")
        set(_FOUND_SEPARATOR TRUE)
        math(EXPR _ARG_NUM "${_ARG_NUM}+1")
    endif()

    if(_FOUND_SEPARATOR AND DEFINED CMAKE_ARGV${_ARG_NUM})
        if(NOT _ARG_NUM EQUAL _LAST_IDX)
            file(GLOB _FILE_LIST "${CMAKE_ARGV${_ARG_NUM}}")
            list(APPEND SOURCE ${_FILE_LIST})
        else()
            set(DESTINATION "${CMAKE_ARGV${_ARG_NUM}}")
        endif()
    endif()

    math(EXPR _ARG_NUM "${_ARG_NUM}+1")
endwhile()

if(NOT SOURCE)
    message(FATAL_ERROR "No source(s) given.")
endif()

if(NOT DESTINATION)
    message(FATAL_ERROR "No destination given")
endif()

file(COPY ${SOURCE} DESTINATION "${DESTINATION}")
