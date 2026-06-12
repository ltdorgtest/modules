# Distributed under the OSI-approved BSD 3-Clause License.
# See accompanying file LICENSE-BSD for details.

#[================================================================================[.rst:
FindNodeJS
----------

Find the NodeJS executables.

.. code-block:: cmake

  find_package(NodeJS [<version>] [COMPONENTS <components>...] [...])

Components
^^^^^^^^^^

Supported components include:

``Node``
  Find the ``node`` executable. This component is always automatically implied, even if not requested.

``Npm``
  Find the ``npm`` executable.

``Npx``
  Find the ``npx`` executable..

Imported Targets
^^^^^^^^^^^^^^^^

This module provides the following Imported Targets (only created when CMAKE_ROLE is ``PROJECT``):

``NodeJS::Node``
  Target encapsulating the ``node`` executable usage requirements, available if the ``Node`` component was found.

``NodeJS::Npm``
  Target encapsulating the ``npm`` executable usage requirements, available if the ``Npm`` component was found.

``NodeJS::Npx``
  Target encapsulating the ``npx`` executable usage requirements, available if the ``Npx`` component was found.

Result Variables
^^^^^^^^^^^^^^^^

``NodeJS_FOUND``
  Boolean indicating whether the NodeJS with all requested required components was found.

``NodeJS_NODE_EXECUTABLE``
  The full path to the ``node`` executable.

``NodeJS_NODE_VERSION``
  The version of the ``node`` executable found.

``NodeJS_NODE_VERSION_MAJOR``
  The major version of the ``node`` executable found.

``NodeJS_NODE_VERSION_MINOR``
  The minor version of the ``node`` executable found.

``NodeJS_NODE_VERSION_PATCH``
  The patch version of the ``node`` executable found.

``NodeJS_NPM_EXECUTABLE``
  The full path to the ``npm`` executable.

``NodeJS_NPM_VERSION``
  The version of the ``npm`` executable found.

``NodeJS_NPM_VERSION_MAJOR``
  The major version of the ``npm`` executable found.

``NodeJS_NPM_VERSION_MINOR``
  The minor version of the ``npm`` executable found.

``NodeJS_NPM_VERSION_PATCH``
  The patch version of the ``npm`` executable found.

``NodeJS_NPX_EXECUTABLE``
  The full path to the ``npx`` executable.

``NodeJS_NPX_VERSION``
  The version of the ``npx`` executable found.

``NodeJS_NPX_VERSION_MAJOR``
  The major version of the ``npx`` executable found.

``NodeJS_NPX_VERSION_MINOR``
  The minor version of the ``npx`` executable found.

``NodeJS_NPX_VERSION_PATCH``
  The patch version of the ``npx`` executable found.

Hints
^^^^^

``NodeJS_ROOT_DIR``, ``ENV{NodeJS_ROOT_DIR}``
  The root directory of a NodeJS installation where the executable is located.
  This can be used to specify a custom NodeJS installation path.

#]================================================================================]

set(_NodeJS_KNOWN_COMPONENTS
    Node
    Npm
    Npx)

# Make sure 'Node' is one of the components to find.
if (NOT NodeJS_FIND_COMPONENTS)
    set(NodeJS_FIND_COMPONENTS Node)
elseif (NOT Node IN_LIST NodeJS_FIND_COMPONENTS)
    list(INSERT NodeJS_FIND_COMPONENTS 0 Node)
endif()

set(_NodeJS_SEARCH_HINTS
    ${NodeJS_ROOT_DIR}
    ENV NodeJS_ROOT_DIR)

set(_NodeJS_SEARCH_PATHS "")

set(_NodeJS_FAILURE_REASON "")

foreach(_COMP ${NodeJS_FIND_COMPONENTS})
    if (NOT ${_COMP} IN_LIST _NodeJS_KNOWN_COMPONENTS)
        message(WARNING "${_COMP} is not a valid NodeJS component.")
        set(NodeJS_${_COMP}_FOUND FALSE)
        continue()
    endif()

    string(TOLOWER ${_COMP} _COMP_LOWER)
    string(TOUPPER ${_COMP} _COMP_UPPER)
    set(_TOOL "${_COMP_LOWER}")
    find_program(NodeJS_${_COMP_UPPER}_EXECUTABLE
        NAMES ${_TOOL}
        PATH_SUFFIXES bin
        HINTS ${_NodeJS_SEARCH_HINTS}
        PATHS ${_NodeJS_SEARCH_PATHS}
        DOC "The full path to the ``${_TOOL}`` executable.")
    if (NodeJS_${_COMP_UPPER}_EXECUTABLE)
        set(NodeJS_${_COMP}_FOUND TRUE)
    else()
        set(NodeJS_${_COMP}_FOUND FALSE)
    endif()

    if (NodeJS_${_COMP_UPPER}_EXECUTABLE)
        execute_process(
            COMMAND "${NodeJS_${_COMP_UPPER}_EXECUTABLE}" --version
            RESULT_VARIABLE _${_COMP_UPPER}_VERSION_RESULT
            OUTPUT_VARIABLE _${_COMP_UPPER}_VERSION_OUTPUT OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_VARIABLE  _${_COMP_UPPER}_VERSION_ERROR  ERROR_STRIP_TRAILING_WHITESPACE)

        if (_${_COMP_UPPER}_VERSION_RESULT EQUAL 0)
            string(REGEX MATCH "([0-9]+)\\.([0-9]+)\\.([0-9]+)" NodeJS_${_COMP_UPPER}_VERSION ${_${_COMP_UPPER}_VERSION_OUTPUT})
            set(NodeJS_${_COMP_UPPER}_VERSION_MAJOR "${CMAKE_MATCH_1}")
            set(NodeJS_${_COMP_UPPER}_VERSION_MINOR "${CMAKE_MATCH_2}")
            set(NodeJS_${_COMP_UPPER}_VERSION_PATCH "${CMAKE_MATCH_3}")
        else()
            string(APPEND _NodeJS_FAILURE_REASON
            "The command\n"
            "    \"${NodeJS_${_COMP_UPPER}_EXECUTABLE}\" --version\n"
            "failed with fatal errors.\n"
            "    result:\n${_${_COMP_UPPER}_VERSION_RESULT}\n"
            "    stdout:\n${_${_COMP_UPPER}_VERSION_OUTPUT}\n"
            "    stderr:\n${_${_COMP_UPPER}_VERSION_ERROR}")
        endif()
    endif()
endforeach()
unset(_COMP)

# Handle REQUIRED and QUIET arguments
# this will also set NodeJS_FOUND to true if NodeJS_NODE_EXECUTABLE exists
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(NodeJS
    REQUIRED_VARS
        NodeJS_NODE_EXECUTABLE
    VERSION_VAR
        NodeJS_NODE_VERSION
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
        # add_executable is not scriptable.
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
