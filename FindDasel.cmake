# Distributed under the OSI-approved BSD 3-Clause License.
# See accompanying file LICENSE.txt for details.

#[================================================================================[.rst:
FindDasel
---------

Find the Dasel executable.

Imported Targets
^^^^^^^^^^^^^^^^

This module defines the following Imported Targets (only created when CMAKE_ROLE is ``PROJECT``):

``Dasel::Dasel``
  Target encapsulating the ``dasel`` executable usage requirements.

Result Variables
^^^^^^^^^^^^^^^^

``Dasel_FOUND``
  Boolean indicating whether the ``dasel`` executable.

``Dasel_EXECUTABLE``
  The full path to the ``dasel`` executable.

``Dasel_VERSION``
  The version of the ``dasel`` executable found.

``Dasel_VERSION_MAJOR``
  The major version of the ``dasel`` executable found.

``Dasel_VERSION_MINOR``
  The minor version of the ``dasel`` executable found.

``Dasel_VERSION_PATCH``
  The patch version of the ``dasel`` executable found.

Hints
^^^^^

``Dasel_ROOT_DIR``, ``ENV{Dasel_ROOT_DIR}``
  The root directory of a Dasel installation where the executable is located.
  This can be used to specify a custom Dasel installation path.

#]================================================================================]

set(_Dasel_PATH_SUFFIXES bin)

set(_Dasel_SEARCH_HINTS
    ${Dasel_ROOT_DIR}
    ENV Dasel_ROOT_DIR)

set(_Dasel_SEARCH_PATHS "")

set(_Dasel_FAILURE_REASON "")

find_program(Dasel_EXECUTABLE
    NAMES dasel
    PATH_SUFFIXES ${_Dasel_PATH_SUFFIXES}
    HINTS ${_Dasel_SEARCH_HINTS}
    PATHS ${_Dasel_SEARCH_PATHS}
    DOC "The full path to the dasel executable.")

if (Dasel_EXECUTABLE)
    execute_process(
        COMMAND "${Dasel_EXECUTABLE}" --version
        RESULT_VARIABLE _Dasel_VERSION_RESULT
        OUTPUT_VARIABLE _Dasel_VERSION_OUTPUT OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE  _Dasel_VERSION_ERROR  ERROR_STRIP_TRAILING_WHITESPACE)

    if (_Dasel_VERSION_RESULT EQUAL 0)
        string(REGEX MATCH "([0-9]+)\\.([0-9]+)\\.([0-9]+)" Dasel_VERSION ${_Dasel_VERSION_OUTPUT})
        set(Dasel_VERSION_MAJOR "${CMAKE_MATCH_1}")
        set(Dasel_VERSION_MINOR "${CMAKE_MATCH_2}")
        set(Dasel_VERSION_PATCH "${CMAKE_MATCH_3}")
    else()
        string(APPEND _Dasel_FAILURE_REASON
        "The command\n"
        "    \"${Dasel_EXECUTABLE}\" --version\n"
        "failed with fatal errors.\n"
        "    result:\n${_Dasel_VERSION_RESULT}\n"
        "    stdout:\n${_Dasel_VERSION_OUTPUT}\n"
        "    stderr:\n${_Dasel_VERSION_ERROR}")
    endif()
endif()

# Handle REQUIRED and QUIET arguments
# this will also set Dasel_FOUND to true if Dasel_EXECUTABLE exists
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Dasel
    REQUIRED_VARS
        Dasel_EXECUTABLE
        Dasel_VERSION
    VERSION_VAR
        Dasel_VERSION
    FOUND_VAR
        Dasel_FOUND
    FAIL_MESSAGE
        "${_Dasel_FAILURE_REASON}"
    HANDLE_VERSION_RANGE)

if (Dasel_FOUND)
    get_property(_Dasel_CMAKE_ROLE GLOBAL PROPERTY CMAKE_ROLE)
    if (_Dasel_CMAKE_ROLE STREQUAL "PROJECT")
        if (NOT TARGET Dasel::Dasel)
            add_executable(Dasel::Dasel IMPORTED)
            set_target_properties(Dasel::Dasel PROPERTIES
                IMPORTED_LOCATION "${Dasel_EXECUTABLE}")
        endif()
    endif()
    unset(_Dasel_CMAKE_ROLE)
endif()

unset(_Dasel_PATH_SUFFIXES)
unset(_Dasel_SEARCH_HINTS)
unset(_Dasel_SEARCH_PATHS)
unset(_Dasel_FAILURE_REASON)
