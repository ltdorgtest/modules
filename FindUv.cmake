# Distributed under the OSI-approved BSD 3-Clause License.
# See accompanying file LICENSE-BSD for details.

#[================================================================================[.rst:
FindUv
---------

Try to find Uv executable.

Imported Targets
^^^^^^^^^^^^^^^^

This module defines the following Imported Targets (only created when CMAKE_ROLE is ``PROJECT``):

``Uv::Uv``
  The ``uv`` executable.

Result Variables
^^^^^^^^^^^^^^^^

``Uv_FOUND``
  System has Uv. True if Uv has been found.

``Uv_EXECUTABLE``
  The full path to the ``uv`` executable.

``Uv_VERSION``
  The version of Uv found.

``Uv_VERSION_MAJOR``
  The major version of Uv found.

``Uv_VERSION_MINOR``
  The minor version of Uv found.

``Uv_VERSION_PATCH``
  The patch version of Uv found.

Hints
^^^^^

``Uv_ROOT_DIR``, ``ENV{Uv_ROOT_DIR}``
  Define the root directory of a Uv installation.

#]================================================================================]

set(_Uv_PATH_SUFFIXES bin)

set(_Uv_SEARCH_HINTS
    ${Uv_ROOT_DIR}
    ENV Uv_ROOT_DIR
    ENV CARGO_HOME)

set(_Uv_SEARCH_PATHS "")

set(_Uv_FAILURE_REASON "")

find_program(Uv_EXECUTABLE
    NAMES uv
    PATH_SUFFIXES ${_Uv_PATH_SUFFIXES}
    HINTS ${_Uv_SEARCH_HINTS}
    PATHS ${_Uv_SEARCH_PATHS}
    DOC "The full path to the uv executable.")

if (Uv_EXECUTABLE)
    execute_process(
        COMMAND "${Uv_EXECUTABLE}" --version
        RESULT_VARIABLE _Uv_VERSION_RESULT
        OUTPUT_VARIABLE _Uv_VERSION_OUTPUT OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE  _Uv_VERSION_ERROR  ERROR_STRIP_TRAILING_WHITESPACE)

    if (_Uv_VERSION_RESULT EQUAL 0)
        string(REGEX MATCH "([0-9]+)\\.([0-9]+)\\.([0-9]+)" Uv_VERSION ${_Uv_VERSION_OUTPUT})
        set(Uv_VERSION_MAJOR "${CMAKE_MATCH_1}")
        set(Uv_VERSION_MINOR "${CMAKE_MATCH_2}")
        set(Uv_VERSION_PATCH "${CMAKE_MATCH_3}")
    else()
        string(APPEND _Uv_FAILURE_REASON
        "The command\n"
        "    \"${Uv_EXECUTABLE}\" --version\n"
        "failed with fatal errors.\n"
        "    result:\n${_Uv_VERSION_RESULT}\n"
        "    stdout:\n${_Uv_VERSION_OUTPUT}\n"
        "    stderr:\n${_Uv_VERSION_ERROR}")
    endif()
endif()

# Handle REQUIRED and QUIET arguments
# this will also set Uv_FOUND to true if Uv_EXECUTABLE exists
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Uv
    REQUIRED_VARS
        Uv_EXECUTABLE
        Uv_VERSION
    VERSION_VAR
        Uv_VERSION
    FOUND_VAR
        Uv_FOUND
    FAIL_MESSAGE
        "${_Uv_FAILURE_REASON}"
    HANDLE_VERSION_RANGE)

if (Uv_FOUND)
    get_property(_Uv_CMAKE_ROLE GLOBAL PROPERTY CMAKE_ROLE)
    if (_Uv_CMAKE_ROLE STREQUAL "PROJECT")
        if (NOT TARGET Uv::Uv)
            add_executable(Uv::Uv IMPORTED)
            set_target_properties(Uv::Uv PROPERTIES
                IMPORTED_LOCATION "${Uv_EXECUTABLE}")
        endif()
    endif()
    unset(_Uv_CMAKE_ROLE)
endif()

unset(_Uv_PATH_SUFFIXES)
unset(_Uv_SEARCH_HINTS)
unset(_Uv_SEARCH_PATHS)
unset(_Uv_FAILURE_REASON)
