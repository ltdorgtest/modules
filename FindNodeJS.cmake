# Distributed under the OSI-approved BSD 3-Clause License.
# See accompanying file LICENSE-BSD for details.

#[================================================================================[.rst:
FindNodeJS
-----------

Find the NodeJS.

Imported Targets
^^^^^^^^^^^^^^^^

This module defines the following Imported Targets (only created when CMAKE_ROLE is ``PROJECT``):

``NodeJS::Node``
  The NodeJS ``node`` executable, if found.

``NodeJS::Npm``
  The NodeJS ``npm`` executable, if found.

``NodeJS::Npx``
  The NodeJS ``npx`` executable, if found.

Result Variables
^^^^^^^^^^^^^^^^

This module will set the following variables in your project:

``NodeJS_FOUND``
  System has the NodeJS. TRUE if NodeJS has been found.

``NodeJS_NODE_EXECUTABLE``
  The full path to the NodeJS ``node`` executable.

``NodeJS_NPM_EXECUTABLE``
  The full path to the NodeJS ``npm`` executable.

``NodeJS_NPX_EXECUTABLE``
  The full path to the NodeJS ``npx`` executable.

``NodeJS_VERSION``
  The version of NodeJS ``node`` found.

``NodeJS_VERSION_MAJOR``
  The major version of the NodeJS ``node`` found.

``NodeJS_VERSION_MINOR``
  The minor version of the NodeJS ``node`` found.

``NodeJS_NPM_VERSION``
  The version of NodeJS ``npm`` found.

``NodeJS_NPM_VERSION_MAJOR``
  The major version of the NodeJS ``npm`` found.

``NodeJS_NPM_VERSION_MINOR``
  The minor version of the NodeJS ``npm`` found.

``NodeJS_NPX_VERSION``
  The version of NodeJS ``npx`` found.

``NodeJS_NPX_VERSION_MAJOR``
  The major version of the NodeJS ``npx`` found.

``NodeJS_NPX_VERSION_MINOR``
  The minor version of the NodeJS ``npx`` found.

Hints
^^^^^

``NodeJS_ROOT_DIR``, ``ENV{NodeJS_ROOT_DIR}``
  Define the root directory of a NodeJS installation.

#]================================================================================]

set(_NodeJS_KNOWN_COMPONENTS
    Node
    Npm
    Npx)

if (NOT NodeJS_FIND_COMPONENTS)
    set(NodeJS_FIND_COMPONENTS ${_NodeJS_KNOWN_COMPONENTS})
    foreach(_COMP ${NodeJS_FIND_COMPONENTS})
        set(NodeJS_FIND_REQUIRED_${_COMP} TRUE)
    endforeach()
    unset(_COMP)
endif()

set(_NodeJS_SEARCH_HINTS
    ${NodeJS_ROOT_DIR}
    ENV NodeJS_ROOT_DIR)

set(_NodeJS_SEARCH_PATHS "")

set(_NodeJS_FAILURE_REASON "")

foreach(_COMP ${_NodeJS_KNOWN_COMPONENTS})
    string(TOLOWER ${_COMP} _COMP_LOWER)
    string(TOUPPER ${_COMP} _COMP_UPPER)
    set(_TOOL "${_COMP_LOWER}")
    find_program(NodeJS_${_COMP_UPPER}_EXECUTABLE
        NAMES ${_TOOL}
        HINTS ${_NodeJS_SEARCH_HINTS}
        PATHS ${_NodeJS_SEARCH_PATHS}
        DOC "The full path to the '${_TOOL}' executable.")
    if (NodeJS_${_COMP_UPPER}_EXECUTABLE)
        set(NodeJS_${_COMP}_FOUND TRUE)
    else()
        set(NodeJS_${_COMP}_FOUND FALSE)
    endif()
endforeach()
unset(_COMP)

if (NodeJS_NODE_EXECUTABLE)
    execute_process(
        COMMAND ${NodeJS_NODE_EXECUTABLE} --version
        RESULT_VARIABLE _NODE_VERSION_RESULT
        OUTPUT_VARIABLE _NODE_VERSION_OUTPUT  OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE  _NODE_VERSION_ERROR   ERROR_STRIP_TRAILING_WHITESPACE)

    if (_NODE_VERSION_RESULT EQUAL 0)
        string(REGEX MATCH "([0-9]+)\\.([0-9]+)\\.([0-9]+)" NodeJS_VERSION ${_NODE_VERSION_OUTPUT})
        set(NodeJS_VERSION_MAJOR "${CMAKE_MATCH_1}")
        set(NodeJS_VERSION_MINOR "${CMAKE_MATCH_2}")
        set(NodeJS_VERSION_PATCH "${CMAKE_MATCH_3}")
    else()
        string(APPEND _NodeJS_FAILURE_REASON
        "The command\n"
        "    \"${NodeJS_NODE_EXECUTABLE}\" --version\n"
        "failed with fatal errors.\n"
        "    result:\n${_NODE_VERSION_RESULT}\n"
        "    stdout:\n${_NODE_VERSION_OUTPUT}\n"
        "    stderr:\n${_NODE_VERSION_ERROR}")
    endif()
endif()

if (NodeJS_NPM_EXECUTABLE)
    execute_process(
        COMMAND ${NodeJS_NPM_EXECUTABLE} --version
        RESULT_VARIABLE _NPM_VERSION_RESULT
        OUTPUT_VARIABLE _NPM_VERSION_OUTPUT OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE  _NPM_VERSION_ERROR  ERROR_STRIP_TRAILING_WHITESPACE)

    if (_NPM_VERSION_RESULT EQUAL 0)
        string(REGEX MATCH "([0-9]+)\\.([0-9]+)\\.([0-9]+)" NodeJS_NPM_VERSION ${_NPM_VERSION_OUTPUT})
        set(NodeJS_NPM_VERSION_MAJOR "${CMAKE_MATCH_1}")
        set(NodeJS_NPM_VERSION_MINOR "${CMAKE_MATCH_2}")
        set(NodeJS_NPM_VERSION_PATCH "${CMAKE_MATCH_3}")
    else()
        string(APPEND _NodeJS_FAILURE_REASON
        "The command\n"
        "    \"${NodeJS_NPM_EXECUTABLE}\" --version\n"
        "failed with fatal errors.\n"
        "    result:\n${_NPM_VERSION_RESULT}\n"
        "    stdout:\n${_NPM_VERSION_OUTPUT}\n"
        "    stderr:\n${_NPM_VERSION_ERROR}")
    endif()
endif()

if (NodeJS_NPX_EXECUTABLE)
    execute_process(
        COMMAND ${NodeJS_NPX_EXECUTABLE} --version
        RESULT_VARIABLE _NPX_VERSION_RESULT
        OUTPUT_VARIABLE _NPX_VERSION_OUTPUT OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE  _NPX_VERSION_ERROR  ERROR_STRIP_TRAILING_WHITESPACE)

    if (_NPX_VERSION_RESULT EQUAL 0)
        string(REGEX MATCH "([0-9]+)\\.([0-9]+)\\.([0-9]+)" NodeJS_NPX_VERSION ${_NPX_VERSION_OUTPUT})
        set(NodeJS_NPX_VERSION_MAJOR "${CMAKE_MATCH_1}")
        set(NodeJS_NPX_VERSION_MINOR "${CMAKE_MATCH_2}")
        set(NodeJS_NPX_VERSION_PATCH "${CMAKE_MATCH_3}")
    else()
        string(APPEND _NodeJS_FAILURE_REASON
        "The command\n"
        "    \"${NodeJS_NPX_EXECUTABLE}\" --version\n"
        "failed with fatal errors.\n"
        "    result:\n${_NPX_VERSION_RESULT}\n"
        "    stdout:\n${_NPX_VERSION_OUTPUT}\n"
        "    stderr:\n${_NPX_VERSION_ERROR}")
    endif()
endif()

# Handle REQUIRED and QUIET arguments
# this will also set SPHINX_FOUND to true if NodeJS_NODE_EXECUTABLE exists
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(NodeJS
    REQUIRED_VARS
        NodeJS_NODE_EXECUTABLE
        NodeJS_VERSION
    VERSION_VAR
        NodeJS_VERSION
    FOUND_VAR
        NodeJS_FOUND
    REASON_FAILURE_MESSAGE
        "${_NodeJS_FAILURE_REASON}"
    HANDLE_VERSION_RANGE
    HANDLE_COMPONENTS)

if (NodeJS_FOUND)
    get_property(_NodeJS_CMAKE_ROLE GLOBAL PROPERTY CMAKE_ROLE)
    if (_NodeJS_CMAKE_ROLE STREQUAL "PROJECT")
        #
        # add_executable is not scriptable
        #
        foreach(_COMP ${NodeJS_FIND_COMPONENTS})
            string(TOUPPER ${_COMP} _COMP_UPPER)
            if (NOT TARGET NodeJS::${_COMP}
                AND NodeJS_${_COMP}_FOUND)
                add_executable(NodeJS::${_COMP} IMPORTED)
                set_target_properties(NodeJS::${_COMP} PROPERTIES
                    IMPORTED_LOCATION
                        "${NodeJS_${_COMP_UPPER}_EXECUTABLE}")
            endif()
        endforeach()
    endif()
    unset(_NodeJS_CMAKE_ROLE)
endif()

unset(_NodeJS_KNOWN_COMPONENTS)
unset(_NodeJS_SEARCH_HINTS)
unset(_NodeJS_SEARCH_PATHS)
unset(_NodeJS_FAILURE_REASON)
