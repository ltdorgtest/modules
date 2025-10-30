# Distributed under the OSI-approved BSD 3-Clause License.
# See accompanying file LICENSE-BSD for details.

#[================================================================================[.rst:
FindPoetry
---------

Try to find Poetry executable.

Imported Targets
^^^^^^^^^^^^^^^^

This module defines the following Imported Targets (only created when CMAKE_ROLE is ``PROJECT``):

``Poetry::Poetry``
  The ``poetry`` executable.

Result Variables
^^^^^^^^^^^^^^^^

``Poetry_FOUND``
  System has Poetry. True if Poetry has been found.

``Poetry_EXECUTABLE``
  The full path to the ``poetry`` executable.

``Poetry_VERSION``
  The version of Poetry found.

``Poetry_VERSION_MAJOR``
  The major version of Poetry found.

``Poetry_VERSION_MINOR``
  The minor version of Poetry found.

``Poetry_VERSION_PATCH``
  The patch version of Poetry found.

Hints
^^^^^

``Poetry_ROOT_DIR``, ``ENV{Poetry_ROOT_DIR}``
  Define the root directory of a Poetry installation.

#]================================================================================]

if (CMAKE_HOST_WIN32)
    set(_POETRY_NAME "poetry.bat;poetry.exe")
else()
    set(_POETRY_NAME "poetry")
endif()

if (CMAKE_HOST_WIN32)
    set(_Poetry_PATH_SUFFIXES Scripts)
else()
    set(_Poetry_PATH_SUFFIXES bin)
endif()

set(_Poetry_SEARCH_HINTS
    ${Poetry_ROOT_DIR}
    ENV Poetry_ROOT_DIR)

set(_Poetry_SEARCH_PATHS "")

set(_Poetry_FAILURE_REASON "")

find_program(Poetry_EXECUTABLE
    NAMES ${_POETRY_NAME}
    PATH_SUFFIXES ${_Poetry_PATH_SUFFIXES}
    HINTS ${_Poetry_SEARCH_HINTS}
    PATHS ${_Poetry_SEARCH_PATHS}
    DOC "The full path to the 'poetry' executable.")

if (Poetry_EXECUTABLE)
    execute_process(
        COMMAND ${Poetry_EXECUTABLE} --version
        RESULT_VARIABLE _Poetry_VERSION_RESULT
        OUTPUT_VARIABLE _Poetry_VERSION_OUTPUT OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE  _Poetry_VERSION_ERROR  ERROR_STRIP_TRAILING_WHITESPACE)

    if (_Poetry_VERSION_RESULT EQUAL 0)
        string(REGEX MATCH "([0-9]+)\\.([0-9]+)\\.([0-9]+)" Poetry_VERSION ${_Poetry_VERSION_OUTPUT})
        set(Poetry_VERSION_MAJOR "${CMAKE_MATCH_1}")
        set(Poetry_VERSION_MINOR "${CMAKE_MATCH_2}")
        set(Poetry_VERSION_PATCH "${CMAKE_MATCH_3}")
    else()
        string(APPEND _Poetry_FAILURE_REASON
        "The command\n"
        "    \"${Poetry_EXECUTABLE}\" --version\n"
        "failed with fatal errors.\n"
        "    result:\n${_Poetry_VERSION_RESULT}\n"
        "    stdout:\n${_Poetry_VERSION_OUTPUT}\n"
        "    stderr:\n${_Poetry_VERSION_ERROR}")
    endif()
endif()

# Handle REQUIRED and QUIET arguments
# this will also set Poetry_FOUND to true if Poetry_EXECUTABLE exists
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Poetry
    REQUIRED_VARS
        Poetry_EXECUTABLE
        Poetry_VERSION
    VERSION_VAR
        Poetry_VERSION
    FOUND_VAR
        Poetry_FOUND
    FAIL_MESSAGE
        "${_Poetry_FAILURE_REASON}"
    HANDLE_VERSION_RANGE)

if (Poetry_FOUND)
    get_property(_Poetry_CMAKE_ROLE GLOBAL PROPERTY CMAKE_ROLE)
    if (_Poetry_CMAKE_ROLE STREQUAL "PROJECT")
        if (NOT TARGET Poetry::Poetry)
            add_executable(Poetry::Poetry IMPORTED)
            set_target_properties(Poetry::Poetry PROPERTIES
                IMPORTED_LOCATION
                    "${Poetry_EXECUTABLE}")
        endif()
    endif()
    unset(_Poetry_CMAKE_ROLE)
endif()

unset(_Poetry_SEARCH_HINTS)
unset(_Poetry_SEARCH_PATHS)
unset(_Poetry_FAILURE_REASON)
