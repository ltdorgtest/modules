# Distributed under the OSI-approved BSD 3-Clause License.
# See accompanying file LICENSE-BSD for details.

#[================================================================================[.rst:
FindCMake
---------

Try to find CMake executable.

Imported Targets
^^^^^^^^^^^^^^^^

This module defines the following Imported Targets (only created when CMAKE_ROLE is ``PROJECT``):

``CMake::CMake``
  The ``cmake`` executable.

Result Variables
^^^^^^^^^^^^^^^^

``CMake_FOUND``
  System has CMake. True if CMake has been found.

``CMake_EXECUTABLE``
  The full path to the ``cmake`` executable.

``CMake_VERSION``
  The version of CMake found.

``CMake_VERSION_MAJOR``
  The major version of CMake found.

``CMake_VERSION_MINOR``
  The minor version of CMake found.

``CMake_VERSION_PATCH``
  The patch version of CMake found.

Hints
^^^^^

``CMake_ROOT_DIR``, ``ENV{CMake_ROOT_DIR}``
  Define the root directory of a CMake installation.

#]================================================================================]

set(_CMake_PATH_SUFFIXES bin)

set(_CMake_SEARCH_HINTS
    ${CMake_ROOT_DIR}
    ENV CMake_ROOT_DIR)

set(_CMake_SEARCH_PATHS "")

set(_CMake_FAILURE_REASON "")

find_program(CMake_EXECUTABLE
    NAMES cmake
    PATH_SUFFIXES ${_CMake_PATH_SUFFIXES}
    HINTS ${_CMake_SEARCH_HINTS}
    PATHS ${_CMake_SEARCH_PATHS}
    DOC "The full path to the cmake executable.")

if (CMake_EXECUTABLE)
    execute_process(
        COMMAND "${CMake_EXECUTABLE}" --version
        RESULT_VARIABLE _CMake_VERSION_RESULT
        OUTPUT_VARIABLE _CMake_VERSION_OUTPUT OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE  _CMake_VERSION_ERROR  ERROR_STRIP_TRAILING_WHITESPACE)

    if (_CMake_VERSION_RESULT EQUAL 0)
        string(REGEX MATCH "([0-9]+)\\.([0-9]+)\\.([0-9]+)" CMake_VERSION ${_CMake_VERSION_OUTPUT})
        set(CMake_VERSION_MAJOR "${CMAKE_MATCH_1}")
        set(CMake_VERSION_MINOR "${CMAKE_MATCH_2}")
        set(CMake_VERSION_PATCH "${CMAKE_MATCH_3}")
    else()
        string(APPEND _CMake_FAILURE_REASON
        "The command\n"
        "    \"${CMake_EXECUTABLE}\" --version\n"
        "failed with fatal errors.\n"
        "    result:\n${_CMake_VERSION_RESULT}\n"
        "    stdout:\n${_CMake_VERSION_OUTPUT}\n"
        "    stderr:\n${_CMake_VERSION_ERROR}")
    endif()
endif()

# Handle REQUIRED and QUIET arguments
# this will also set CMake_FOUND to true if CMake_EXECUTABLE exists
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(CMake
    REQUIRED_VARS
        CMake_EXECUTABLE
        CMake_VERSION
    VERSION_VAR
        CMake_VERSION
    FOUND_VAR
        CMake_FOUND
    FAIL_MESSAGE
        "${_CMake_FAILURE_REASON}"
    HANDLE_VERSION_RANGE)

if (CMake_FOUND)
    get_property(_CMake_CMAKE_ROLE GLOBAL PROPERTY CMAKE_ROLE)
    if (_CMake_CMAKE_ROLE STREQUAL "PROJECT")
        if (NOT TARGET CMake::CMake)
            add_executable(CMake::CMake IMPORTED)
            set_target_properties(CMake::CMake PROPERTIES
                IMPORTED_LOCATION "${CMake_EXECUTABLE}")
        endif()
    endif()
    unset(_CMake_CMAKE_ROLE)
endif()

unset(_CMake_PATH_SUFFIXES)
unset(_CMake_SEARCH_HINTS)
unset(_CMake_SEARCH_PATHS)
unset(_CMake_FAILURE_REASON)
