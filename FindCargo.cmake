# Distributed under the OSI-approved BSD 3-Clause License.
# See accompanying file LICENSE.txt for details.

#[=======================================================================[.rst:
FindCargo
---------

Try to find Cargo executable.

Imported Targets
^^^^^^^^^^^^^^^^

This module defines the following Imported Targets (only created when CMAKE_ROLE is ``PROJECT``):

``Cargo::Cargo``
  The ``cargo`` executable.

Result Variables
^^^^^^^^^^^^^^^^

``Cargo_FOUND``
  System has Cargo. True if Cargo has been found.

``Cargo_EXECUTABLE``
  The full path to the ``cargo`` executable.

``Cargo_VERSION``
  The version of Cargo found.

``Cargo_VERSION_MAJOR``
  The major version of Cargo found.

``Cargo_VERSION_MINOR``
  The minor version of Cargo found.

``Cargo_VERSION_PATCH``
  The patch version of Cargo found.

Hints
^^^^^

``Cargo_ROOT_DIR``, ``ENV{Cargo_ROOT_DIR}``
  Define the root directory of a Cargo installation.

#]=======================================================================]

set(_Cargo_PATH_SUFFIXES bin)

set(_Cargo_SEARCH_HINTS
    ${Cargo_ROOT_DIR}
    ENV Cargo_ROOT_DIR
    ENV CARGO_HOME)

set(_Cargo_SEARCH_PATHS)

find_program(Cargo_EXECUTABLE
    NAMES cargo
    PATH_SUFFIXES ${_Cargo_PATH_SUFFIXES}
    HINTS ${_Cargo_SEARCH_HINTS}
    PATHS ${_Cargo_SEARCH_PATHS}
    DOC "The full path to the cargo executable.")

if (Cargo_EXECUTABLE)
    execute_process(
        COMMAND "${Cargo_EXECUTABLE}" --version
        RESULT_VARIABLE _Cargo_VERSION_RESULT
        OUTPUT_VARIABLE _Cargo_VERSION_OUTPUT OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE  _Cargo_VERSION_ERROR  ERROR_STRIP_TRAILING_WHITESPACE)

    if (_Cargo_VERSION_RESULT EQUAL 0)
        string(REGEX MATCH "([0-9]+)\\.([0-9]+)\\.([0-9]+)" Cargo_VERSION ${_Cargo_VERSION_OUTPUT})
        set(Cargo_VERSION_MAJOR "${CMAKE_MATCH_1}")
        set(Cargo_VERSION_MINOR "${CMAKE_MATCH_2}")
        set(Cargo_VERSION_PATCH "${CMAKE_MATCH_3}")
    else()
        string(APPEND _Cargo_FAILURE_REASON
        "The command\n"
        "    \"${Cargo_EXECUTABLE}\" --version\n"
        "failed with fatal errors.\n"
        "    result:\n${_Cargo_VERSION_RESULT}\n"
        "    stdout:\n${_Cargo_VERSION_OUTPUT}\n"
        "    stderr:\n${_Cargo_VERSION_ERROR}")
    endif()
endif()

# Handle REQUIRED and QUIET arguments
# this will also set Cargo_FOUND to true if Cargo_EXECUTABLE exists
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Cargo
    REQUIRED_VARS
        Cargo_EXECUTABLE
    VERSION_VAR
        Cargo_VERSION
    FOUND_VAR
        Cargo_FOUND
    FAIL_MESSAGE
        "Failed to locate cargo executable")

if (Cargo_FOUND)
    get_property(_Cargo_CMAKE_ROLE GLOBAL PROPERTY CMAKE_ROLE)
    if (_Cargo_CMAKE_ROLE STREQUAL "PROJECT")
        if (NOT TARGET Cargo::Cargo)
            add_executable(Cargo::Cargo IMPORTED)
            set_target_properties(Cargo::Cargo PROPERTIES
                IMPORTED_LOCATION "${Cargo_EXECUTABLE}")
        endif()
    endif()
    unset(_Cargo_CMAKE_ROLE)
endif()

unset(_Cargo_SEARCH_HINTS)
unset(_Cargo_SEARCH_PATHS)
