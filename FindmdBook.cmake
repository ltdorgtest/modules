# Distributed under the OSI-approved BSD 3-Clause License.
# See accompanying file LICENSE-BSD for details.

#[================================================================================[.rst:
FindmdBook
----------

Try to find mdBook executable, along with some optional supporting tools.

Components
^^^^^^^^^^

Supported components include:

``Admonish``
  Find the ``mdbook-admonish`` executable.

``Mermaid``
  Find the ``mdbook-mermaid`` executable.

``Toc``
  Find the ``mdbook-toc`` executable.

Imported Targets
^^^^^^^^^^^^^^^^

This module defines the following Imported Targets (only created when CMAKE_ROLE is ``PROJECT``):

``mdBook::mdBook``
  The full path to the ``mdbook`` executable.

``mdBook::Admonish``
  The full path to the ``mdbook-admonish`` executable.

``mdBook::Mermaid``
  The full path to the ``mdbook-mermaid`` executable.

``mdBook::Toc``
  The full path to the ``mdbook-toc`` executable.

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

``mdBook_Admonish_FOUND``
  System has ``mdbook-admonish``. True if ``mdbook-admonish`` has been found.

``mdBook_ADMONISH_EXECUTABLE``
  The full path to the ``mdbook-admonish`` executable.

``mdBook_Admonish_VERSION``
  The version of ``mdbook-admonish`` found.

``mdBook_Admonish_VERSION_MAJOR``
  The major version of ``mdbook-admonish`` found.

``mdBook_Admonish_VERSION_MINOR``
  The minor version of ``mdbook-admonish`` found.

``mdBook_Admonish_VERSION_PATCH``
  The patch version of ``mdbook-admonish`` found.

``mdBook_Mermaid_FOUND``
  System has ``mdbook-mermaid``. True if ``mdbook-mermaid`` has been found.

``mdBook_MERMAID_EXECUTABLE``
  The full path to the ``mdbook-mermaid`` executable.

``mdBook_Mermaid_VERSION``
  The version of ``mdbook-mermaid`` found.

``mdBook_Mermaid_VERSION_MAJOR``
  The major version of ``mdbook-mermaid`` found.

``mdBook_Mermaid_VERSION_MINOR``
  The minor version of ``mdbook-mermaid`` found.

``mdBook_Mermaid_VERSION_PATCH``
  The patch version of ``mdbook-mermaid`` found.

``mdBook_Toc_FOUND``
  System has ``mdbook-toc``. True if ``mdbook-toc`` has been found.

``mdBook_TOC_EXECUTABLE``
  The full path to the ``mdbook-toc`` executable.

``mdBook_Toc_VERSION``
  The version of ``mdbook-toc`` found.

``mdBook_Toc_VERSION_MAJOR``
  The major version of ``mdbook-toc`` found.

``mdBook_Toc_VERSION_MINOR``
  The minor version of ``mdbook-toc`` found.

``mdBook_Toc_VERSION_PATCH``
  The patch version of ``mdbook-toc`` found.

Hints
^^^^^

``mdBook_ROOT_DIR``, ``ENV{mdBook_ROOT_DIR}``
  Define the root directory of a mdBook installation.

#]================================================================================]

set(_mdBook_PATH_SUFFIXES bin)

set(_mdBook_KNOWN_COMPONENTS
    Admonish
    Mermaid
    Toc)

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

foreach(_COMP ${_mdBook_KNOWN_COMPONENTS})
    string(TOLOWER ${_COMP} _COMP_LOWER)
    string(TOUPPER ${_COMP} _COMP_UPPER)
    set(_TOOL "mdbook-${_COMP_LOWER}")
    find_program(mdBook_${_COMP_UPPER}_EXECUTABLE
        NAMES ${_TOOL}
        NAMES_PER_DIR
        PATH_SUFFIXES ${_mdBook_PATH_SUFFIXES}
        HINTS ${_mdBook_SEARCH_HINTS}
        PATHS ${_mdBook_SEARCH_PATHS}
        DOC "The full path to the '${_TOOL}' executable.")

    if (mdBook_${_COMP_UPPER}_EXECUTABLE)
        execute_process(
            COMMAND "${mdBook_${_COMP_UPPER}_EXECUTABLE}" --version
            RESULT_VARIABLE _mdBook_${_COMP}_VERSION_RESULT
            OUTPUT_VARIABLE _mdBook_${_COMP}_VERSION_OUTPUT OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_VARIABLE  _mdBook_${_COMP}_VERSION_ERROR  ERROR_STRIP_TRAILING_WHITESPACE)

        if (_mdBook_${_COMP}_VERSION_RESULT EQUAL 0)
            string(REGEX MATCH "([0-9]+)\\.([0-9]+)\\.([0-9]+)" mdBook_${_COMP}_VERSION ${_mdBook_${_COMP}_VERSION_OUTPUT})
            set(mdBook_${_COMP}_VERSION_MAJOR "${CMAKE_MATCH_1}")
            set(mdBook_${_COMP}_VERSION_MINOR "${CMAKE_MATCH_2}")
            set(mdBook_${_COMP}_VERSION_PATCH "${CMAKE_MATCH_3}")
        else()
            string(APPEND _mdBook_FAILURE_REASON
            "The command\n"
            "    \"${mdBook_${_COMP_UPPER}_EXECUTABLE}\" --version\n"
            "failed with fatal errors.\n"
            "    result:\n${_mdBook_${_COMP}_VERSION_RESULT}\n"
            "    stdout:\n${_mdBook_${_COMP}_VERSION_OUTPUT}\n"
            "    stderr:\n${_mdBook_${_COMP}_VERSION_ERROR}")
        endif()
    endif()

    if (mdBook_${_COMP_UPPER}_EXECUTABLE)
        set(mdBook_${_COMP}_FOUND TRUE)
    else()
        set(mdBook_${_COMP}_FOUND FALSE)
    endif()
endforeach()
unset(_COMP)

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
        "${_mdBook_FAILURE_REASON}"
    HANDLE_VERSION_RANGE
    HANDLE_COMPONENTS)

if (mdBook_FOUND)
    get_property(_mdBook_CMAKE_ROLE GLOBAL PROPERTY CMAKE_ROLE)
    if (_mdBook_CMAKE_ROLE STREQUAL "PROJECT")
        #
        # add_executable is not scriptable.
        #
        if (NOT TARGET mdBook::mdBook)
            add_executable(mdBook::mdBook IMPORTED)
            set_target_properties(mdBook::mdBook PROPERTIES
                IMPORTED_LOCATION "${mdBook_EXECUTABLE}")
        endif()
        foreach(_COMP ${mdBook_FIND_COMPONENTS})
            string(TOUPPER ${_COMP} _COMP_UPPER)
            if (NOT TARGET mdBook::${_COMP}
                AND mdBook_${_COMP}_FOUND)
                add_executable(mdBook::${_COMP} IMPORTED)
                set_target_properties(mdBook::${_COMP} PROPERTIES
                    IMPORTED_LOCATION
                        "${mdBook_${_COMP_UPPER}_EXECUTABLE}")
            endif()
        endforeach()
    endif()
    unset(_mdBook_CMAKE_ROLE)
endif()

unset(_mdBook_PATH_SUFFIXES)
unset(_mdBook_SEARCH_HINTS)
unset(_mdBook_SEARCH_PATHS)
unset(_mdBook_FAILURE_REASON)
