# Distributed under the OSI-approved BSD 3-Clause License.
# See accompanying file LICENSE-BSD for details.

#[================================================================================[.rst:
FindmdBook
----------

Try to find `mdBook <https://github.com/rust-lang/mdBook>`_, along with some optional supporting tools:

* `mdbook-admonish <https://github.com/tommilligan/mdbook-admonish>`_
* `mdbook-mermaid <https://github.com/badboy/mdbook-mermaid>`_

Components
^^^^^^^^^^

Supported components include:

``mdBook``
  Find the ``mdbook`` executable. This component is always automatically implied, even if not requested.

``Admonish``
  Find the ``mdbook-admonish`` executable.

``Mermaid``
  Find the ``mdbook-mermaid`` executable.

Imported Targets
^^^^^^^^^^^^^^^^

This module provides the following Imported Targets (only created when CMAKE_ROLE is ``PROJECT``):

``mdBook::mdBook``
  Target encapsulating the ``mdbook`` executable usage requirements, available if the ``mdBook`` component was found.

``mdBook::Admonish``
  Target encapsulating the ``admonish`` executable usage requirements, available if the ``Admonish`` component was found.

``mdBook::Mermaid``
  Target encapsulating the ``mdbook-mermaid`` executable usage requirements, available if the ``Mermaid`` component was found.

Result Variables
^^^^^^^^^^^^^^^^

``mdBook_FOUND``
  Boolean indicating whether the ``mdbook`` executable and all requested required components were found.

``mdBook_EXECUTABLE``
  The full path to the ``mdbook`` executable.

``mdBook_mdBook_FOUND``
  Boolean indicating whether the ``mdbook`` executable.

``mdBook_VERSION``
  The version of the ``mdbook`` executable found.

``mdBook_VERSION_MAJOR``
  The major version of the ``mdbook`` executable found.

``mdBook_VERSION_MINOR``
  The minor version of the ``mdbook`` executable found.

``mdBook_VERSION_PATCH``
  The patch version of the ``mdbook`` executable found.

``mdBook_ADMONISH_EXECUTABLE``
  The full path to the ``mdbook-admonish`` executable.

``mdBook_Admonish_FOUND``
  Boolean indicating whether the ``mdbook-admonish`` executable.

``mdBook_Admonish_VERSION``
  The version of the ``mdbook-admonish`` executable found.

``mdBook_Admonish_VERSION_MAJOR``
  The major version of the ``mdbook-admonish`` executable found.

``mdBook_Admonish_VERSION_MINOR``
  The minor version of the ``mdbook-admonish`` executable found.

``mdBook_Admonish_VERSION_PATCH``
  The patch version of the ``mdbook-admonish`` executable found.

``mdBook_MERMAID_EXECUTABLE``
  The full path to the ``mdbook-mermaid`` executable.

``mdBook_Mermaid_FOUND``
  Boolean indicating whether the ``mdbook-mermaid`` executable.

``mdBook_Mermaid_VERSION``
  The version of the ``mdbook-mermaid`` executable found.

``mdBook_Mermaid_VERSION_MAJOR``
  The major version of the ``mdbook-mermaid`` executable found.

``mdBook_Mermaid_VERSION_MINOR``
  The minor version of the ``mdbook-mermaid`` executable found.

``mdBook_Mermaid_VERSION_PATCH``
  The patch version of the ``mdbook-mermaid`` executable found.

Hints
^^^^^

``mdBook_ROOT_DIR``, ``ENV{mdBook_ROOT_DIR}``
  The root directory of a mdBook installation where the executable is located.
  This can be used to specify a custom mdBook installation path.

``ENV{CARGO_HOME}``
  The Cargo home directory where installed binaries are typically located.
  mdBook and its plugins are usually installed via Cargo and placed in ``$CARGO_HOME/bin``.

#]================================================================================]

set(_mdBook_PATH_SUFFIXES bin)

set(_mdBook_KNOWN_COMPONENTS
    mdBook
    Admonish
    Mermaid)

# Make sure 'mdBook' is one of the components to find.
if (NOT mdBook_FIND_COMPONENTS)
    set(mdBook_FIND_COMPONENTS mdBook)
elseif (NOT mdBook IN_LIST mdBook_FIND_COMPONENTS)
    list(INSERT mdBook_FIND_COMPONENTS 0 mdBook)
endif()

set(_mdBook_SEARCH_HINTS
    ${mdBook_ROOT_DIR}
    ENV mdBook_ROOT_DIR
    ENV CARGO_HOME)

set(_mdBook_SEARCH_PATHS "")

set(_mdBook_FAILURE_REASON "")

foreach(_COMP ${mdBook_FIND_COMPONENTS})
    if (NOT ${_COMP} IN_LIST _mdBook_KNOWN_COMPONENTS)
        message(WARNING "${_COMP} is not a valid mdBook component.")
        set(mdBook_${_COMP}_FOUND FALSE)
        continue()
    endif()

    if (_COMP STREQUAL "mdBook")
        find_program(mdBook_EXECUTABLE
            NAMES mdbook
            PATH_SUFFIXES ${_mdBook_PATH_SUFFIXES}
            HINTS ${_mdBook_SEARCH_HINTS}
            PATHS ${_mdBook_SEARCH_PATHS}
            DOC "The full path to the ``mdbook`` executable.")

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

            set(mdBook_${_COMP}_FOUND TRUE)
        else()
            set(mdBook_${_COMP}_FOUND FALSE)
        endif()
    else()
        string(TOLOWER ${_COMP} _COMP_LOWER)
        string(TOUPPER ${_COMP} _COMP_UPPER)
        set(_TOOL "mdbook-${_COMP_LOWER}")
        find_program(mdBook_${_COMP_UPPER}_EXECUTABLE
            NAMES ${_TOOL}
            NAMES_PER_DIR
            PATH_SUFFIXES ${_mdBook_PATH_SUFFIXES}
            HINTS ${_mdBook_SEARCH_HINTS}
            PATHS ${_mdBook_SEARCH_PATHS}
            DOC "The full path to the ``${_TOOL}`` executable.")

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

            set(mdBook_${_COMP}_FOUND TRUE)
        else()
            set(mdBook_${_COMP}_FOUND FALSE)
        endif()
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
        foreach(_COMP ${mdBook_FIND_COMPONENTS})
            if (NOT ${_COMP} IN_LIST _mdBook_KNOWN_COMPONENTS)
                continue()
            endif()
            if (_COMP STREQUAL "mdBook")
                if (NOT TARGET mdBook::${_COMP} AND mdBook_FOUND)
                    add_executable(mdBook::${_COMP} IMPORTED)
                    set_target_properties(mdBook::${_COMP} PROPERTIES
                        IMPORTED_LOCATION
                            "${mdBook_EXECUTABLE}")
                endif()
            else()
                string(TOUPPER ${_COMP} _COMP_UPPER)
                if (NOT TARGET mdBook::${_COMP} AND mdBook_${_COMP}_FOUND)
                    add_executable(mdBook::${_COMP} IMPORTED)
                    set_target_properties(mdBook::${_COMP} PROPERTIES
                        IMPORTED_LOCATION
                            "${mdBook_${_COMP_UPPER}_EXECUTABLE}")
                endif()
            endif()
        endforeach()
    endif()
    unset(_mdBook_CMAKE_ROLE)
endif()

unset(_mdBook_PATH_SUFFIXES)
unset(_mdBook_SEARCH_HINTS)
unset(_mdBook_SEARCH_PATHS)
unset(_mdBook_FAILURE_REASON)
