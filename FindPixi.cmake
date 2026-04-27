# Distributed under the OSI-approved BSD 3-Clause License.
# See accompanying file LICENSE-BSD for details.

#[================================================================================[.rst:
FindPixi
--------

Find the Pixi executable.

Imported Targets
^^^^^^^^^^^^^^^^

This module defines the following Imported Targets (only created when CMAKE_ROLE is ``PROJECT``):

``Pixi::Pixi``
  Target encapsulating the ``pixi`` executable usage requirements.

Result Variables
^^^^^^^^^^^^^^^^

``Pixi_FOUND``
  Boolean indicating whether the ``pixi`` executable.

``Pixi_EXECUTABLE``
  The full path to the ``pixi`` executable.

``Pixi_VERSION``
  The version of the ``pixi`` executable found.

``Pixi_VERSION_MAJOR``
  The major version of the ``pixi`` executable found.

``Pixi_VERSION_MINOR``
  The minor version of the ``pixi`` executable found.

``Pixi_VERSION_PATCH``
  The patch version of the ``pixi`` executable found.

Hints
^^^^^

``Pixi_ROOT_DIR``, ``ENV{Pixi_ROOT_DIR}``
  The root directory of a Pixi installation where the executable is located.
  This can be used to specify a custom Pixi installation path.

#]================================================================================]

if (CMAKE_HOST_WIN32)
    set(_Pixi_PATH_SUFFIXES Scripts)
else()
    set(_Pixi_PATH_SUFFIXES bin)
endif()

set(_Pixi_SEARCH_HINTS
    ${Pixi_ROOT_DIR}
    ENV Pixi_ROOT_DIR)

set(_Pixi_SEARCH_PATHS "")

set(_Pixi_FAILURE_REASON "")

find_program(Pixi_EXECUTABLE
    NAMES pixi
    PATH_SUFFIXES ${_Pixi_PATH_SUFFIXES}
    HINTS ${_Pixi_SEARCH_HINTS}
    PATHS ${_Pixi_SEARCH_PATHS}
    DOC "The full path to the ``pixi`` executable.")

if (Pixi_EXECUTABLE)
    execute_process(
        COMMAND ${Pixi_EXECUTABLE} --version
        RESULT_VARIABLE _Pixi_VERSION_RESULT
        OUTPUT_VARIABLE _Pixi_VERSION_OUTPUT OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE  _Pixi_VERSION_ERROR  ERROR_STRIP_TRAILING_WHITESPACE)

    if (_Pixi_VERSION_RESULT EQUAL 0)
        string(REGEX MATCH "([0-9]+)\\.([0-9]+)\\.([0-9]+)" Pixi_VERSION ${_Pixi_VERSION_OUTPUT})
        set(Pixi_VERSION_MAJOR "${CMAKE_MATCH_1}")
        set(Pixi_VERSION_MINOR "${CMAKE_MATCH_2}")
        set(Pixi_VERSION_PATCH "${CMAKE_MATCH_3}")
    else()
        string(APPEND _Pixi_FAILURE_REASON
        "The command\n"
        "    \"${Pixi_EXECUTABLE}\" --version\n"
        "failed with fatal errors.\n"
        "    result:\n${_Pixi_VERSION_RESULT}\n"
        "    stdout:\n${_Pixi_VERSION_OUTPUT}\n"
        "    stderr:\n${_Pixi_VERSION_ERROR}")
    endif()
endif()

# Handle REQUIRED and QUIET arguments
# this will also set Pixi_FOUND to true if Pixi_EXECUTABLE exists
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Pixi
    REQUIRED_VARS
        Pixi_EXECUTABLE
        Pixi_VERSION
    VERSION_VAR
        Pixi_VERSION
    FOUND_VAR
        Pixi_FOUND
    FAIL_MESSAGE
        "${_Pixi_FAILURE_REASON}"
    HANDLE_VERSION_RANGE)

if (Pixi_FOUND)
    get_property(_Pixi_CMAKE_ROLE GLOBAL PROPERTY CMAKE_ROLE)
    if (_Pixi_CMAKE_ROLE STREQUAL "PROJECT")
        if (NOT TARGET Pixi::Pixi)
            add_executable(Pixi::Pixi IMPORTED)
            set_target_properties(Pixi::Pixi PROPERTIES
                IMPORTED_LOCATION
                    "${Pixi_EXECUTABLE}")
        endif()
    endif()
    unset(_Pixi_CMAKE_ROLE)
endif()

unset(_Pixi_PATH_SUFFIXES)
unset(_Pixi_SEARCH_HINTS)
unset(_Pixi_SEARCH_PATHS)
unset(_Pixi_FAILURE_REASON)
