# Distributed under the OSI-approved BSD 3-Clause License.
# See accompanying file LICENSE-BSD for details.

#[================================================================================[.rst:
FindGit
-------

Try to find Git client.

Imported Targets
^^^^^^^^^^^^^^^^

This module defines the following Imported Targets (only created when CMAKE_ROLE is ``PROJECT``):

``Git::Git``
  The full path to the ``git`` executable.

Result Variables
^^^^^^^^^^^^^^^^

``Git_FOUND``
  System has the Git. True if Git has been found.

``Git_EXECUTABLE``
  The full path to the ``git`` executable.

``Git_VERSION``
  The version of the Git found.

``Git_VERSION_MAJOR``
  The major version of the Git found.

``Git_VERSION_MINOR``
  The minor version of the Git found.

``Git_VERSION_PATCH``
  The patch version of the Git found.

Hints
^^^^^

``Git_ROOT_DIR``, ``ENV{Git_ROOT_DIR}``
  Define the root directory of a Git installation.

#]================================================================================]

set(_Git_SEARCH_HINTS
    ${Git_ROOT_DIR}
    ENV Git_ROOT_DIR)

set(_Git_SEARCH_PATHS)

set(_Git_FAILURE_REASON "")

find_program(Git_EXECUTABLE
    NAMES git
    HINTS ${_Git_SEARCH_HINTS}
    PATHS ${_Git_SEARCH_PATHS}
    DOC "The full path to the 'git' executable.")

if (Git_EXECUTABLE)
    execute_process(
        COMMAND ${Git_EXECUTABLE} --version
        RESULT_VARIABLE _Git_VERSION_RESULT
        OUTPUT_VARIABLE _Git_VERSION_OUTPUT OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE  _Git_VERSION_ERROR  ERROR_STRIP_TRAILING_WHITESPACE)

    if (_Git_VERSION_RESULT EQUAL 0)
        string(REGEX MATCH "([0-9]+)\\.([0-9]+)\\.([0-9]+)([-\\.][a-zA-Z0-9]+)*" Git_VERSION ${_Git_VERSION_OUTPUT})
        set(Git_VERSION_MAJOR "${CMAKE_MATCH_1}")
        set(Git_VERSION_MINOR "${CMAKE_MATCH_2}")
        set(Git_VERSION_PATCH "${CMAKE_MATCH_3}")
    else()
        string(APPEND _Git_FAILURE_REASON
        "The command\n"
        "    \"${Git_EXECUTABLE}\" --version\n"
        "failed with fatal errors.\n"
        "    result:\n${_Git_VERSION_RESULT}\n"
        "    stdout:\n${_Git_VERSION_OUTPUT}\n"
        "    stderr:\n${_Git_VERSION_ERROR}")
    endif()
endif()

# Handle REQUIRED and QUIET arguments
# this will also set Git_FOUND to true if Git_EXECUTABLE exists
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Git
    REQUIRED_VARS
        Git_EXECUTABLE
        Git_VERSION
    VERSION_VAR
        Git_VERSION
    FOUND_VAR
        Git_FOUND
    FAIL_MESSAGE
        "${_Git_FAILURE_REASON}"
    HANDLE_VERSION_RANGE)

if (Git_FOUND)
    get_property(_Git_CMAKE_ROLE GLOBAL PROPERTY CMAKE_ROLE)
    if (_Git_CMAKE_ROLE STREQUAL "PROJECT")
        if (NOT TARGET Git::Git)
            add_executable(Git::Git IMPORTED)
            set_target_properties(Git::Git PROPERTIES
                IMPORTED_LOCATION
                    "${Git_EXECUTABLE}")
        endif()
    endif()
    unset(_Git_CMAKE_ROLE)
endif()

unset(_Git_SEARCH_HINTS)
unset(_Git_SEARCH_PATHS)
unset(_Git_FAILURE_REASON)
