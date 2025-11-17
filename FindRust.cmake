# Distributed under the OSI-approved BSD 3-Clause License.
# See accompanying file LICENSE-BSD for details.

#[================================================================================[.rst:
FindRust
----------

Find the Rust Compiler, along with some optional supporting tools.

.. code-block:: cmake

  find_package(Rust [<version>] [COMPONENTS <components>...] [...])

Components
^^^^^^^^^^

Supported components include:

``Rustc``
  Find the ``rustc`` executable. This component is always automatically implied, even if not requested.

``Cargo``
  Find the ``cargo`` executable.

``Rustdoc``
  Find the ``rustdoc`` executable.

Imported Targets
^^^^^^^^^^^^^^^^

This module provides the following Imported Targets (only created when CMAKE_ROLE is ``PROJECT``):

``Rust::Rustc``
  Target encapsulating the ``rustc`` executable usage requirements, available if the ``Rustc`` component was found.

``Rust::Cargo``
  Target encapsulating the ``cargo`` executable usage requirements, available if the ``Cargo`` component was found.

``Rust::Rustdoc``
  Target encapsulating the ``rustdoc`` executable usage requirements, available if the ``Rustdoc`` component was found.

Result Variables
^^^^^^^^^^^^^^^^

``Rust_FOUND``
  Boolean indicating whether the Rust with all requested required components was found.

``Rust_VERSION``
  The version of the Rust found.

``Rust_VERSION_MAJOR``
  The major version of the Rust found.

``Rust_VERSION_MINOR``
  The minor version of the Rust found.

``Rust_VERSION_PATCH``
  The patch version of the Rust found.

``Rust_RUSTC_EXECUTABLE``
  The full path to the ``rustc`` executable.

``Rust_CARGO_EXECUTABLE``
  The full path to the ``cargo`` executable.

``Rust_RUSTDOC_EXECUTABLE``
  The full path to the ``rustdoc`` executable.

Hints
^^^^^

``Rust_ROOT_DIR``, ``ENV{Rust_ROOT_DIR}``
  The root directory of a Rust installation where the executable is located.
  This can be used to specify a custom Rust installation path.

``ENV{CARGO_HOME}``
  The Cargo home directory where installed binaries are typically located.
  Rust and its plugins are usually installed via Cargo and placed in ``$CARGO_HOME/bin``.

#]================================================================================]

set(_Rust_PATH_SUFFIXES bin)

set(_Rust_KNOWN_COMPONENTS
    Rustc
    Cargo
    Rustdoc)

# Make sure 'Rustc' is one of the components to find.
if (NOT Rust_FIND_COMPONENTS)
    set(Rust_FIND_COMPONENTS Rustc)
elseif (NOT Rustc IN_LIST Rust_FIND_COMPONENTS)
    list(INSERT Rust_FIND_COMPONENTS 0 Rustc)
endif()

set(_Rust_SEARCH_HINTS
    ${Rust_ROOT_DIR}
    ENV Rust_ROOT_DIR
    ENV CARGO_HOME)

set(_Rust_SEARCH_PATHS "")

set(_Rust_FAILURE_REASON "")

foreach(_COMP ${Rust_FIND_COMPONENTS})
    if (NOT ${_COMP} IN_LIST _Rust_KNOWN_COMPONENTS)
        message(WARNING "${_COMP} is not a valid Rust component.")
        set(Rust_${_COMP}_FOUND FALSE)
        continue()
    endif()

    string(TOLOWER ${_COMP} _COMP_LOWER)
    string(TOUPPER ${_COMP} _COMP_UPPER)
    set(_TOOL "${_COMP_LOWER}")
    find_program(Rust_${_COMP_UPPER}_EXECUTABLE
        NAMES ${_TOOL}
        NAMES_PER_DIR
        PATH_SUFFIXES ${_Rust_PATH_SUFFIXES}
        HINTS ${_Rust_SEARCH_HINTS}
        PATHS ${_Rust_SEARCH_PATHS}
        DOC "The full path to the ``${_TOOL}`` executable.")

    if (Rust_${_COMP_UPPER}_EXECUTABLE)
        set(Rust_${_COMP}_FOUND TRUE)
    else()
        set(Rust_${_COMP}_FOUND FALSE)
    endif()
endforeach()
unset(_COMP)

if (Rust_RUSTC_EXECUTABLE)
    execute_process(
        COMMAND "${Rust_RUSTC_EXECUTABLE}" --version
        RESULT_VARIABLE _Rust_VERSION_RESULT
        OUTPUT_VARIABLE _Rust_VERSION_OUTPUT OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE  _Rust_VERSION_ERROR  ERROR_STRIP_TRAILING_WHITESPACE)

    if (_Rust_VERSION_RESULT EQUAL 0)
        string(REGEX MATCH "([0-9]+)\\.([0-9]+)\\.([0-9]+)" Rust_VERSION ${_Rust_VERSION_OUTPUT})
        set(Rust_VERSION_MAJOR "${CMAKE_MATCH_1}")
        set(Rust_VERSION_MINOR "${CMAKE_MATCH_2}")
        set(Rust_VERSION_PATCH "${CMAKE_MATCH_3}")
    else()
        string(APPEND _Rust_FAILURE_REASON
        "The command\n"
        "    \"${Rust_RUSTC_EXECUTABLE}\" --version\n"
        "failed with fatal errors.\n"
        "    result:\n${_Rust_VERSION_RESULT}\n"
        "    stdout:\n${_Rust_VERSION_OUTPUT}\n"
        "    stderr:\n${_Rust_VERSION_ERROR}")
    endif()
endif()

# Handle REQUIRED and QUIET arguments
# this will also set Rust_FOUND to true if Rust_EXECUTABLE exists
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Rust
    REQUIRED_VARS
        Rust_RUSTC_EXECUTABLE
        Rust_VERSION
    VERSION_VAR
        Rust_VERSION
    FOUND_VAR
        Rust_FOUND
    FAIL_MESSAGE
        "${_Rust_FAILURE_REASON}"
    HANDLE_VERSION_RANGE
    HANDLE_COMPONENTS)

if (Rust_FOUND)
    get_property(_Rust_CMAKE_ROLE GLOBAL PROPERTY CMAKE_ROLE)
    if (_Rust_CMAKE_ROLE STREQUAL "PROJECT")
        #
        # add_executable is not scriptable.
        #
        foreach(_COMP ${Rust_FIND_COMPONENTS})
            if (NOT ${_COMP} IN_LIST _Rust_KNOWN_COMPONENTS)
                continue()
            endif()
            string(TOUPPER ${_COMP} _COMP_UPPER)
            if (NOT TARGET Rust::${_COMP} AND Rust_${_COMP}_FOUND)
                add_executable(Rust::${_COMP} IMPORTED)
                set_target_properties(Rust::${_COMP} PROPERTIES
                    IMPORTED_LOCATION
                        "${Rust_${_COMP_UPPER}_EXECUTABLE}")
            endif()
        endforeach()
    endif()
    unset(_Rust_CMAKE_ROLE)
endif()

unset(_Rust_PATH_SUFFIXES)
unset(_Rust_SEARCH_HINTS)
unset(_Rust_SEARCH_PATHS)
unset(_Rust_FAILURE_REASON)
