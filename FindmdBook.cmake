# Distributed under the OSI-approved BSD 3-Clause License.
# See accompanying file LICENSE.txt for details.

#[================================================================================[.rst:
FindmdBook
----------

Try to find mdBook executable.

Imported Targets
^^^^^^^^^^^^^^^^

This module defines the following Imported Targets (only created when CMAKE_ROLE is ``PROJECT``):

``mdBook::mdBook``
  The ``mdbook`` executable.

Result Variables
^^^^^^^^^^^^^^^^

``mdBook_FOUND``
  System has mdBook. True if mdBook has been found.

``mdBook_EXECUTABLE``
  The full path to the ``mdbook`` executable.

``mdBook_VERSION``
  The version of mdBook found.

``mdBook_VERSION_MAJOR``
  The major version of mdBook found.

``mdBook_VERSION_MINOR``
  The minor version of mdBook found.

``mdBook_VERSION_PATCH``
  The patch version of mdBook found.

Hints
^^^^^

``mdBook_ROOT_DIR``, ``ENV{mdBook_ROOT_DIR}``
  Define the root directory of a mdBook installation.

#]================================================================================]

set(_mdBook_PATH_SUFFIXES bin)

set(_mdBook_SEARCH_HINTS
    ${mdBook_ROOT_DIR}
    ENV mdBook_ROOT_DIR
    ENV CARGO_HOME)

set(_mdBook_SEARCH_PATHS "")

set(_mdBook_FAILURE_REASON "")

find_program(mdBook_EXECUTABLE
    NAMES mdbook
    PATH_SUFFIXES ${_mdBook_PATH_SUFFIXES}
    HINTS ${_mdBook_SEARCH_HINTS}
    PATHS ${_mdBook_SEARCH_PATHS}
    DOC "The full path to the mdbook executable.")

if (mdBook_EXECUTABLE)
    execute_process(
        COMMAND "${mdBook_EXECUTABLE}" --version
        RESULT_VARIABLE _mdBook_VERSION_RESULT
        OUTPUT_VARIABLE _mdBook_VERSION_OUTPUT OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE  _mdBook_VERSION_ERROR  ERROR_STRIP_TRAILING_WHITESPACE)

    if (_mdBook_VERSION_RESULT EQUAL 0)
        string(REGEX MATCH "([0-9]+)\\.([0-9]+)\\.([0-9]+)" mdBook_VERSION ${_mdBook_VERSION_OUTPUT})
        set(mdBook_VERSION_MAJOR "${CMAKE_MATCH_1}")
        set(mdBook_VERSION_MINOR "${CMAKE_MATCH_2}")
        set(mdBook_VERSION_PATCH "${CMAKE_MATCH_3}")
    else()
        string(APPEND _mdBook_FAILURE_REASON
        "The command\n"
        "    \"${mdBook_EXECUTABLE}\" --version\n"
        "failed with fatal errors.\n"
        "    result:\n${_mdBook_VERSION_RESULT}\n"
        "    stdout:\n${_mdBook_VERSION_OUTPUT}\n"
        "    stderr:\n${_mdBook_VERSION_ERROR}")
    endif()
endif()

# Handle REQUIRED and QUIET arguments
# this will also set mdBook_FOUND to true if mdBook_EXECUTABLE exists
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(mdBook
    REQUIRED_VARS
        mdBook_EXECUTABLE
        mdBook_VERSION
    VERSION_VAR
        mdBook_VERSION
    FOUND_VAR
        mdBook_FOUND
    FAIL_MESSAGE
        "${_mdBook_FAILURE_REASON}")

if (mdBook_FOUND)
    get_property(_mdBook_CMAKE_ROLE GLOBAL PROPERTY CMAKE_ROLE)
    if (_mdBook_CMAKE_ROLE STREQUAL "PROJECT")
        if (NOT TARGET mdBook::mdBook)
            add_executable(mdBook::mdBook IMPORTED)
            set_target_properties(mdBook::mdBook PROPERTIES
                IMPORTED_LOCATION "${mdBook_EXECUTABLE}")
        endif()
    endif()
    unset(_mdBook_CMAKE_ROLE)
endif()

unset(_mdBook_PATH_SUFFIXES)
unset(_mdBook_SEARCH_HINTS)
unset(_mdBook_SEARCH_PATHS)
unset(_mdBook_FAILURE_REASON)
