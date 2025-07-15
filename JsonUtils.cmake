# Distributed under the OSI-approved BSD 3-Clause License.
# See accompanying file LICENSE-BSD for details.

#[================================================================================[.rst
JsonUtils
---------

Initialize a references.json file
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. command:: init_references_json_file

  Initialize a `references.json` file of `branch` type in `language` mode:

  .. code-block:: cmake

    init_references_json_file(
        IN_FILEPATH       "${CMAKE_CURRENT_LIST_DIR}/references.json"
        IN_VERSION_TYPE   "branch"
        IN_VERSION        "master"
        IN_INIT_MODE      "language"
        IN_INIT_LIST      "zh_CN;zh_TW")

  Initialize a `references.json` file of `tag` type in `language` mode:

  .. code-block:: cmake

    init_references_json_file(
        IN_FILEPATH       "${CMAKE_CURRENT_LIST_DIR}/references.json"
        IN_VERSION_TYPE   "tag"
        IN_VERSION        "master"
        IN_INIT_MODE      "language"
        IN_INIT_LIST      "zh_CN;zh_TW")

  Initialize a `references.json` file of `branch` type in `repository` mode:

  .. code-block:: cmake

    init_references_json_file(
        IN_FILEPATH       "${CMAKE_CURRENT_LIST_DIR}/references.json"
        IN_VERSION_TYPE   "branch"
        IN_VERSION        "develop2"
        IN_INIT_MODE      "repository"
        IN_INIT_LIST      "conan")

  Initialize a `references.json` file of `tag` type in `repository` mode:

  .. code-block:: cmake

    init_references_json_file(
        IN_FILEPATH       "${CMAKE_CURRENT_LIST_DIR}/references.json"
        IN_VERSION_TYPE   "tag"
        IN_VERSION        "develop2"
        IN_INIT_MODE      "repository"
        IN_INIT_LIST      "conan")

Get Members of Json Object
^^^^^^^^^^^^^^^^^^^^^^^^^^

.. command:: get_members_of_json_object

  .. code-block:: cmake

    get_members_of_json_object(
        IN_JSON_OBJECT      "${JSON_CNT}"
        OUT_MEMBER_NAMES    MEMBER_NAMES
        OUT_MEMBER_VALUES   MEMBER_VALUES
        OUT_MEMBER_NUMBER   MEMBER_NUMBER)

Set Members of Json Object for language and commit
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. command:: set_members_of_reference_json_object

  .. code-block:: cmake

    set_members_of_reference_json_object(
        IN_VERSION_TYPE     "tag"
        IN_MEMBER_TAG       "\"${repo_latest_tag}\""
        OUT_JSON_OBJECT     LANGUAGE_CNT)

  .. code-block:: cmake

    set_members_of_reference_json_object(
        IN_VERSION_TYPE     "branch"
        IN_MEMBER_BRANCH    "\"${IN_VERSION}\""
        IN_MEMBER_COMMIT    "${COMMIT_CNT}"
        OUT_JSON_OBJECT     LANGUAGE_CNT)

.. command:: set_members_of_commit_json_object

  .. code-block:: cmake

    set_members_of_commit_json_object(
        IN_MEMBER_DATE      "\"2023-07-19 14:40:53 -0400\""
        IN_MEMBER_HASH      "\"0baa8af568bcb0b0caadb7cedcb21353396cae7b\""
        IN_MEMBER_TITLE     "\"Merge branch 'release-3.27'\""
        OUT_JSON_OBJECT     COMMIT_CNT)

Dot Notation Setter/Getter
^^^^^^^^^^^^^^^^^^^^^^^^^^

.. command:: set_json_value_by_dot_notation

  .. code-block:: cmake

    set_json_value_by_dot_notation(
        IN_JSON_OBJECT    "${JSON_CNT}"
        IN_DOT_NOTATION   ".po.zh_TW"
        IN_VALUE          "${poLocaleValue}"
        OUT_JSON_OBJECT   JSON_CNT)

.. command:: get_json_value_by_dot_notation

  .. code-block:: cmake

    get_json_value_by_dot_notation(
        IN_JSON_OBJECT    "${JSON_CNT}"
        IN_DOT_NOTATION   "pot"
        OUT_VALUE         potValue)

Get Reference of Latest from Repository and Current from Json
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  .. code-block:: cmake

    get_reference_of_latest_from_repo_and_current_from_json(
        IN_JSON_CNT             "${REFERENCES_JSON_CNT}"
        IN_LOCAL_PATH           "${PROJ_OUT_REPO_DIR}"
        IN_DOT_NOTATION         ".pot"
        IN_VERSION_TYPE         "${VERSION_TYPE}"
        IN_BRANCH_NAME          "${BRANCH_NAME}"
        IN_TAG_PATTERN          "${TAG_PATTERN}"
        IN_TAG_SUFFIX           "${TAG_SUFFIX}"
        OUT_LATEST_OBJECT       LATEST_POT_OBJECT
        OUT_LATEST_REFERENCE    LATEST_POT_REFERENCE
        OUT_CURRENT_OBJECT      CURRENT_POT_OBJECT
        OUT_CURRENT_REFERENCE   CURRENT_POT_REFERENCE)

  .. code-block:: cmake

    get_reference_of_latest_from_repo_and_current_from_json(
        IN_JSON_CNT             "${REFERENCES_JSON_CNT}"
        IN_LOCAL_PATH           "${PROJ_OUT_REPO_DIR}"
        IN_DOT_NOTATION         ".conan"
        IN_VERSION_TYPE         "${VERSION_TYPE}"
        IN_BRANCH_NAME          "${BRANCH_NAME}"
        IN_TAG_PATTERN          "${TAG_PATTERN}"
        IN_TAG_SUFFIX           "${TAG_SUFFIX}"
        OUT_LATEST_OBJECT       LATEST_CONAN_OBJECT
        OUT_LATEST_REFERENCE    LATEST_CONAN_REFERENCE
        OUT_CURRENT_OBJECT      CURRENT_CONAN_OBJECT
        OUT_CURRENT_REFERENCE   CURRENT_CONAN_REFERENCE)

Get Reference of POT and PO from Json
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  .. code-block:: cmake

    get_reference_of_pot_and_po_from_json(
        IN_JSON_CNT             "${REFERENCES_JSON_CNT}"
        IN_VERSION_TYPE         "${VERSION_TYPE}"
        OUT_POT_OBJECT          CURRENT_POT_OBJECT
        OUT_POT_REFERENCE       CURRENT_POT_REFERENCE
        OUT_PO_OBJECT           CURRENT_PO_OBJECT
        OUT_PO_REFERENCE        CURRENT_PO_REFERENCE)

#]================================================================================]


include_guard()


include(GitUtils)


function(init_references_json_file)
    #
    # Parse arguments.
    #
    set(OPTIONS)
    set(ONE_VALUE_ARGS      IN_FILEPATH
                            IN_VERSION_TYPE
                            IN_VERSION
                            IN_INIT_MODE)
    set(MULTI_VALUE_ARGS    IN_INIT_LIST)
    cmake_parse_arguments(IRJF
        "${OPTIONS}"
        "${ONE_VALUE_ARGS}"
        "${MULTI_VALUE_ARGS}"
        ${ARGN})
    #
    # Ensure all required arguments are provided.
    #
    set(REQUIRED_ARGS       IN_FILEPATH
                            IN_VERSION_TYPE
                            IN_VERSION
                            IN_INIT_MODE
                            IN_INIT_LIST)
    foreach(_ARG ${REQUIRED_ARGS})
        if (NOT DEFINED IRJF_${_ARG})
            message(FATAL_ERROR "Missing IRJF_${_ARG} argument.")
        endif()
    endforeach()
    unset(_ARG)
    #
    # Initialize or create the JSON file at specified ${IRJF_IN_FILEPATH}.
    #
    set(_FILEPATH "${IRJF_IN_FILEPATH}")
    if (NOT EXISTS "${_FILEPATH}")
        get_filename_component(_FILEPATH_DIR "${_FILEPATH}" DIRECTORY)
        file(MAKE_DIRECTORY "${_FILEPATH_DIR}")
        file(TOUCH "${_FILEPATH}")
    endif()
    file(READ "${_FILEPATH}" JSON_CNT)
    if (NOT JSON_CNT)
        set(JSON_CNT "{}")
    endif()
    #
    # Initialize 'version' property based on ${IRJF_IN_VERSION}.
    #
    string(JSON JSON_CNT SET "${JSON_CNT}" "version" "\"${IRJF_IN_VERSION}\"")
    #
    # Initialize 'type' property based on ${IRJF_IN_VERSION_TYPE}.
    #
    string(JSON JSON_CNT SET "${JSON_CNT}" "type" "\"${IRJF_IN_VERSION_TYPE}\"")
    #
    # Call internal initialization functions based on IN_VERSION_TYPE and IN_INIT_MODE.
    #
    if (IRJF_IN_VERSION_TYPE STREQUAL "tag")
        if (IRJF_IN_INIT_MODE STREQUAL "language")
            _init_references_json_file_for_tag_language()
        elseif (IRJF_IN_INIT_MODE STREQUAL "repository")
            _init_references_json_file_for_tag_repository()
        else()
            message(FATAL_ERROR "Invalid IRJF_IN_INIT_MODE argument. (${IRJF_IN_INIT_MODE})")
        endif()
    elseif (IRJF_IN_VERSION_TYPE STREQUAL "branch")
        if (IRJF_IN_INIT_MODE STREQUAL "language")
            _init_references_json_file_for_branch_language()
        elseif (IRJF_IN_INIT_MODE STREQUAL "repository")
            _init_references_json_file_for_branch_repository()
        else()
            message(FATAL_ERROR "Invalid IRJF_IN_INIT_MODE argument. (${IRJF_IN_INIT_MODE})")
        endif()
    else()
        message(FATAL_ERROR "Invalid IRJF_IN_VERSION_TYPE argument. (${IRJF_IN_VERSION_TYPE})")
    endif()
    #
    # Write the content of ${JSON_CNT} into ${_FILEPATH}.
    #
    file(WRITE "${_FILEPATH}" "${JSON_CNT}")
endfunction()


macro(_init_references_json_file_for_tag_language)
    #
    # For 'tag' type:
    # (1)   Initialize '.pot' property as empty if missing.
    # (1.1) Initialize '.pot.${REF_PROP_NAME}' property as empty if missing.
    # (2)   Initialize '.po' property as empty if missing.
    # (2.1) Initialize '.po.${_LANG}' objects as empty if missing.
    # (2.2) Initialize '.po.${_LANG}.${REF_PROP_NAME}' property as empty if missing.
    #
    set(LANG_LIST "${IRJF_IN_INIT_LIST}")
    set(REF_PROP_NAME_LIST tag)
    set(REF_PROP_TYPE_LIST STRING)
    #
    # (1) Initialize '.pot' property as empty if missing.
    #
    string(JSON pot_CNT ERROR_VARIABLE pot_ERR GET "${JSON_CNT}" "pot")
    if (NOT pot_ERR STREQUAL "NOTFOUND")
        set(pot_CNT "{}")
        string(JSON JSON_CNT SET "${JSON_CNT}" "pot" "${pot_CNT}")
    endif()
    list(LENGTH REF_PROP_NAME_LIST REF_PROP_NUM)
    math(EXPR REF_PROP_MAX_ID "${REF_PROP_NUM} - 1")
    foreach(REF_PROP_ID RANGE ${REF_PROP_MAX_ID})
        #
        # (1.1) Initialize 'pot.${REF_PROP_NAME}' property as empty if missing.
        #
        list(GET REF_PROP_NAME_LIST ${REF_PROP_ID} REF_PROP_NAME)
        list(GET REF_PROP_TYPE_LIST ${REF_PROP_ID} REF_PROP_TYPE)
        string(JSON ${REF_PROP_NAME}_CNT ERROR_VARIABLE ${REF_PROP_NAME}_ERR GET "${pot_CNT}" "${REF_PROP_NAME}")
        if (NOT ${REF_PROP_NAME}_ERR STREQUAL "NOTFOUND")
            if (REF_PROP_TYPE STREQUAL "STRING")
                set(${REF_PROP_NAME}_CNT "\"\"")
            endif()
            string(JSON pot_CNT SET "${pot_CNT}" "${REF_PROP_NAME}" "${${REF_PROP_NAME}_CNT}")
        endif()
    endforeach()
    unset(REF_PROP_ID)
    string(JSON JSON_CNT SET "${JSON_CNT}" "pot" "${pot_CNT}")
    #
    # (2) Initialize '.po' property as empty if missing.
    #
    string(JSON po_CNT ERROR_VARIABLE po_ERR GET "${JSON_CNT}" "po")
    if (NOT po_ERR STREQUAL "NOTFOUND")
        set(po_CNT "{}")
        string(JSON JSON_CNT SET "${JSON_CNT}" "po" "${po_CNT}")
    endif()
    foreach(_LANG ${LANG_LIST})
        #
        # (2.1) Initialize '.po.${_LANG}' objects as empty if missing.
        #
        string(JSON ${_LANG}_CNT ERROR_VARIABLE ${_LANG}_ERR GET "${po_CNT}" "${_LANG}")
        if (NOT ${_LANG}_ERR STREQUAL "NOTFOUND")
            set(${_LANG}_CNT "{}")
            string(JSON po_CNT SET "${po_CNT}" "${_LANG}" "${${_LANG}_CNT}")
        endif()
        list(LENGTH REF_PROP_NAME_LIST REF_PROP_NUM)
        math(EXPR REF_PROP_MAX_ID "${REF_PROP_NUM} - 1")
        foreach(REF_PROP_ID RANGE ${REF_PROP_MAX_ID})
            #
            # (2.2) Initialize '.po.${_LANG}.${REF_PROP_NAME}' property as empty if missing.
            #
            list(GET REF_PROP_NAME_LIST ${REF_PROP_ID} REF_PROP_NAME)
            list(GET REF_PROP_TYPE_LIST ${REF_PROP_ID} REF_PROP_TYPE)
            string(JSON ${REF_PROP_NAME}_CNT ERROR_VARIABLE ${REF_PROP_NAME}_ERR GET "${${_LANG}_CNT}" "${REF_PROP_NAME}")
            if (NOT ${REF_PROP_NAME}_ERR STREQUAL "NOTFOUND")
                if (REF_PROP_TYPE STREQUAL "STRING")
                    set(${REF_PROP_NAME}_CNT "\"\"")
                endif()
                string(JSON ${_LANG}_CNT SET "${${_LANG}_CNT}" "${REF_PROP_NAME}" "${${REF_PROP_NAME}_CNT}")
            endif()
        endforeach()
        unset(REF_PROP_ID)
        string(JSON po_CNT SET "${po_CNT}" "${_LANG}" "${${_LANG}_CNT}")
    endforeach()
    unset(_LANG)
    string(JSON JSON_CNT SET "${JSON_CNT}" "po" "${po_CNT}")
endmacro()


macro(_init_references_json_file_for_tag_repository)
    #
    # For 'tag' type:
    # (1)   Initialize '.${_REPO}' property as empty if missing.
    # (1.1) Initialize '.${_REPO}.${REF_PROP_NAME}' property as empty if missing.
    #
    set(REPO_LIST ${IRJF_IN_INIT_LIST})
    set(REF_PROP_NAME_LIST tag)
    set(REF_PROP_TYPE_LIST STRING)
    foreach(_REPO ${REPO_LIST})
        #
        # (1) Initialize '.${_REPO}' property as empty if missing.
        #
        string(JSON ${_REPO}_CNT ERROR_VARIABLE ${_REPO}_ERR GET "${JSON_CNT}" "${_REPO}")
        if (NOT ${_REPO}_ERR STREQUAL "NOTFOUND")
            set(${_REPO}_CNT "{}")
            string(JSON JSON_CNT SET "${JSON_CNT}" "${_REPO}" "${${_REPO}_CNT}")
        endif()
        list(LENGTH REF_PROP_NAME_LIST REF_PROP_NUM)
        math(EXPR REF_PROP_MAX_ID "${REF_PROP_NUM} - 1")
        foreach(REF_PROP_ID RANGE ${REF_PROP_MAX_ID})
            #
            # (1.1) Initialize '.${_REPO}.${REF_PROP_NAME}' property as empty if missing.
            #
            list(GET REF_PROP_NAME_LIST ${REF_PROP_ID} REF_PROP_NAME)
            list(GET REF_PROP_TYPE_LIST ${REF_PROP_ID} REF_PROP_TYPE)
            string(JSON ${REF_PROP_NAME}_CNT ERROR_VARIABLE ${REF_PROP_NAME}_ERR GET "${${_REPO}_CNT}" "${REF_PROP_NAME}")
            if (NOT ${REF_PROP_NAME}_ERR STREQUAL "NOTFOUND")
                if (REF_PROP_TYPE STREQUAL "STRING")
                    set(${REF_PROP_NAME}_CNT "\"\"")
                endif()
                string(JSON ${_REPO}_CNT SET "${${_REPO}_CNT}" "${REF_PROP_NAME}" "${${REF_PROP_NAME}_CNT}")
            endif()
        endforeach()
        unset(REF_PROP_ID)
        string(JSON JSON_CNT SET "${JSON_CNT}" "${_REPO}" "${${_REPO}_CNT}")
    endforeach()
    unset(_REPO)
endmacro()


macro(_init_references_json_file_for_branch_language)
    #
    # For 'branch' type:
    # (1)   Initialize '.pot' property as empty if missing.
    # (1.1) Initialize '.pot.${REF_PROP_NAME}' property as empty if missing.
    # (1.2) Initialize '.pot.commit.${COMMIT_PROP_NAME}' property as empty if missing.
    # (2)   Initialize '.po' property as empty if missing.
    # (2.1) Initialize '..po.${_LANG}' objects as empty if missing.
    # (2.2) Initialize '..po.${_LANG}.${REF_PROP_NAME}' property as empty if missing.
    # (2.3) Initialize '..po.${_LANG}.commit.${COMMIT_PROP_NAME}' property as empty if missing.
    #
    set(LANG_LIST "${IRJF_IN_INIT_LIST}")
    set(REF_PROP_NAME_LIST branch commit)
    set(REF_PROP_TYPE_LIST STRING OBJECT)
    set(COMMIT_PROP_NAME_LIST date hash title)
    set(COMMIT_PROP_TYPE_LIST STRING STRING STRING)
    #
    # (1) Initialize '.pot' property as empty if missing.
    #
    string(JSON pot_CNT ERROR_VARIABLE pot_ERR GET "${JSON_CNT}" "pot")
    if (NOT pot_ERR STREQUAL "NOTFOUND")
        set(pot_CNT "{}")
        string(JSON JSON_CNT SET "${JSON_CNT}" "pot" "${pot_CNT}")
    endif()
    list(LENGTH REF_PROP_NAME_LIST REF_PROP_NUM)
    math(EXPR REF_PROP_MAX_ID "${REF_PROP_NUM} - 1")
    foreach(REF_PROP_ID RANGE ${REF_PROP_MAX_ID})
        #
        # (1.1) Initialize '.pot.${REF_PROP_NAME}' property as empty if missing.
        #
        list(GET REF_PROP_NAME_LIST ${REF_PROP_ID} REF_PROP_NAME)
        list(GET REF_PROP_TYPE_LIST ${REF_PROP_ID} REF_PROP_TYPE)
        string(JSON ${REF_PROP_NAME}_CNT ERROR_VARIABLE ${REF_PROP_NAME}_ERR GET "${pot_CNT}" "${REF_PROP_NAME}")
        if (NOT ${REF_PROP_NAME}_ERR STREQUAL "NOTFOUND")
            if (REF_PROP_TYPE STREQUAL "STRING")
                set(${REF_PROP_NAME}_CNT "\"\"")
            elseif (REF_PROP_TYPE STREQUAL "OBJECT")
                set(${REF_PROP_NAME}_CNT "{}")
            endif()
            string(JSON pot_CNT SET "${pot_CNT}" "${REF_PROP_NAME}" "${${REF_PROP_NAME}_CNT}")
        endif()
        if (REF_PROP_NAME STREQUAL "commit")
            #
            # (1.2) Initialize '.pot.commit.${COMMIT_PROP_NAME}' property as empty if missing.
            #
            list(LENGTH COMMIT_PROP_NAME_LIST COMMIT_PROP_NUM)
            math(EXPR COMMIT_PROP_MAX_ID "${COMMIT_PROP_NUM} - 1")
            foreach(COMMIT_PROP_ID RANGE ${COMMIT_PROP_MAX_ID})
                list(GET COMMIT_PROP_NAME_LIST ${COMMIT_PROP_ID} COMMIT_PROP_NAME)
                list(GET COMMIT_PROP_TYPE_LIST ${COMMIT_PROP_ID} COMMIT_PROP_TYPE)
                string(JSON ${COMMIT_PROP_NAME}_CNT ERROR_VARIABLE ${COMMIT_PROP_NAME}_ERR GET "${commit_CNT}" "${COMMIT_PROP_NAME}")
                if (NOT ${COMMIT_PROP_NAME}_ERR STREQUAL "NOTFOUND")
                    if (COMMIT_PROP_TYPE STREQUAL "STRING")
                        set(${COMMIT_PROP_NAME}_CNT "\"\"")
                    elseif (COMMIT_PROP_TYPE STREQUAL "OBJECT")
                        set(${COMMIT_PROP_NAME}_CNT "{}")
                    endif()
                    string(JSON commit_CNT SET "${commit_CNT}" "${COMMIT_PROP_NAME}" "${${COMMIT_PROP_NAME}_CNT}")
                endif()
            endforeach()
            string(JSON pot_CNT SET "${pot_CNT}" "commit" "${commit_CNT}")
        endif()
    endforeach()
    unset(REF_PROP_ID)
    string(JSON JSON_CNT SET "${JSON_CNT}" "pot" "${pot_CNT}")
    #
    # (2) Initialize 'po' property as empty if missing.
    #
    string(JSON po_CNT ERROR_VARIABLE po_ERR GET "${JSON_CNT}" "po")
    if (NOT po_ERR STREQUAL "NOTFOUND")
        set(po_CNT "{}")
        string(JSON JSON_CNT SET "${JSON_CNT}" "po" "${po_CNT}")
    endif()
    foreach(_LANG ${LANG_LIST})
        #
        # (2.1) Initialize '.po.${_LANG}' objects as empty if missing.
        #
        string(JSON ${_LANG}_CNT ERROR_VARIABLE ${_LANG}_ERR GET "${po_CNT}" "${_LANG}")
        if (NOT ${_LANG}_ERR STREQUAL "NOTFOUND")
            set(${_LANG}_CNT "{}")
            string(JSON po_CNT SET "${po_CNT}" "${_LANG}" "${${_LANG}_CNT}")
        endif()
        list(LENGTH REF_PROP_NAME_LIST REF_PROP_NUM)
        math(EXPR REF_PROP_MAX_ID "${REF_PROP_NUM} - 1")
        foreach(REF_PROP_ID RANGE ${REF_PROP_MAX_ID})
            #
            # (2.2) Initialize '.po.${_LANG}.${REF_PROP_NAME}' property as empty if missing.
            #
            list(GET REF_PROP_NAME_LIST ${REF_PROP_ID} REF_PROP_NAME)
            list(GET REF_PROP_TYPE_LIST ${REF_PROP_ID} REF_PROP_TYPE)
            string(JSON ${REF_PROP_NAME}_CNT ERROR_VARIABLE ${REF_PROP_NAME}_ERR GET "${${_LANG}_CNT}" "${REF_PROP_NAME}")
            if (NOT ${REF_PROP_NAME}_ERR STREQUAL "NOTFOUND")
                if (REF_PROP_TYPE STREQUAL "STRING")
                    set(${REF_PROP_NAME}_CNT "\"\"")
                elseif (REF_PROP_TYPE STREQUAL "OBJECT")
                    set(${REF_PROP_NAME}_CNT "{}")
                endif()
                string(JSON ${_LANG}_CNT SET "${${_LANG}_CNT}" "${REF_PROP_NAME}" "${${REF_PROP_NAME}_CNT}")
            endif()
            if (REF_PROP_NAME STREQUAL "commit")
                list(LENGTH COMMIT_PROP_NAME_LIST COMMIT_PROP_NUM)
                math(EXPR COMMIT_PROP_MAX_ID "${COMMIT_PROP_NUM} - 1")
                foreach(COMMIT_PROP_ID RANGE ${COMMIT_PROP_MAX_ID})
                    #
                    # (2.3) Initialize '.po.${_LANG}.commit.${COMMIT_PROP_NAME}' property as empty if missing.
                    #
                    list(GET COMMIT_PROP_NAME_LIST ${COMMIT_PROP_ID} COMMIT_PROP_NAME)
                    list(GET COMMIT_PROP_TYPE_LIST ${COMMIT_PROP_ID} COMMIT_PROP_TYPE)
                    string(JSON ${COMMIT_PROP_NAME}_CNT ERROR_VARIABLE ${COMMIT_PROP_NAME}_ERR GET "${commit_CNT}" "${COMMIT_PROP_NAME}")
                    if (NOT ${COMMIT_PROP_NAME}_ERR STREQUAL "NOTFOUND")
                        if (COMMIT_PROP_TYPE STREQUAL "STRING")
                            set(${COMMIT_PROP_NAME}_CNT "\"\"")
                        elseif (COMMIT_PROP_TYPE STREQUAL "OBJECT")
                            set(${COMMIT_PROP_NAME}_CNT "{}")
                        endif()
                        string(JSON commit_CNT SET "${commit_CNT}" "${COMMIT_PROP_NAME}" "${${COMMIT_PROP_NAME}_CNT}")
                    endif()
                endforeach()
                string(JSON ${_LANG}_CNT SET "${${_LANG}_CNT}" "commit" "${commit_CNT}")
            endif()
        endforeach()
        string(JSON po_CNT SET "${po_CNT}" "${_LANG}" "${${_LANG}_CNT}")
    endforeach()
    unset(_LANG)
    string(JSON JSON_CNT SET "${JSON_CNT}" "po" "${po_CNT}")
endmacro()


macro(_init_references_json_file_for_branch_repository)
    #
    # For 'branch' type:
    # (1)   Initialize '.${_REPO}' property as empty if missing.
    # (1.1) Initialize '.${_REPO}.${REF_PROP_NAME}' property as empty if missing.
    # (1.2) Initialize '.${_REPO}.commit.${COMMIT_PROP_NAME}' property as empty if missing.
    #
    set(REPO_LIST "${IRJF_IN_INIT_LIST}")
    set(REF_PROP_NAME_LIST branch commit)
    set(REF_PROP_TYPE_LIST STRING OBJECT)
    set(COMMIT_PROP_NAME_LIST date hash title)
    set(COMMIT_PROP_TYPE_LIST STRING STRING STRING)
    foreach(_REPO ${REPO_LIST})
        #
        # (1) Initialize '.${_REPO}' property as empty if missing.
        #
        string(JSON ${_REPO}_CNT ERROR_VARIABLE ${_REPO}_ERR GET "${JSON_CNT}" "${_REPO}")
        if (NOT ${_REPO}_ERR STREQUAL "NOTFOUND")
            set(${_REPO}_CNT "{}")
            string(JSON JSON_CNT SET "${JSON_CNT}" "${_REPO}" "${${_REPO}_CNT}")
        endif()
        list(LENGTH REF_PROP_NAME_LIST REF_PROP_NUM)
        math(EXPR REF_PROP_MAX_ID "${REF_PROP_NUM} - 1")
        foreach(REF_PROP_ID RANGE ${REF_PROP_MAX_ID})
            #
            # (1.1) Initialize '.${_REPO}.${REF_PROP_NAME}' property as empty if missing.
            #
            list(GET REF_PROP_NAME_LIST ${REF_PROP_ID} REF_PROP_NAME)
            list(GET REF_PROP_TYPE_LIST ${REF_PROP_ID} REF_PROP_TYPE)
            string(JSON ${REF_PROP_NAME}_CNT ERROR_VARIABLE ${REF_PROP_NAME}_ERR GET "${${_REPO}_CNT}" "${REF_PROP_NAME}")
            if (NOT ${REF_PROP_NAME}_ERR STREQUAL "NOTFOUND")
                if (REF_PROP_TYPE STREQUAL "STRING")
                    set(${REF_PROP_NAME}_CNT "\"\"")
                elseif (REF_PROP_TYPE STREQUAL "OBJECT")
                    set(${REF_PROP_NAME}_CNT "{}")
                endif()
                string(JSON ${_REPO}_CNT
                    SET "${${_REPO}_CNT}" "${REF_PROP_NAME}" "${${REF_PROP_NAME}_CNT}")
            endif()
            if (REF_PROP_NAME STREQUAL "commit")
                #
                # (1.2) Initialize '.${_REPO}.commit.${COMMIT_PROP_NAME}' property as empty if missing.
                #
                list(LENGTH COMMIT_PROP_NAME_LIST COMMIT_PROP_NUM)
                math(EXPR COMMIT_PROP_MAX_ID "${COMMIT_PROP_NUM} - 1")
                foreach(COMMIT_PROP_ID RANGE ${COMMIT_PROP_MAX_ID})
                    list(GET COMMIT_PROP_NAME_LIST ${COMMIT_PROP_ID} COMMIT_PROP_NAME)
                    list(GET COMMIT_PROP_TYPE_LIST ${COMMIT_PROP_ID} COMMIT_PROP_TYPE)
                    string(JSON ${COMMIT_PROP_NAME}_CNT ERROR_VARIABLE ${COMMIT_PROP_NAME}_ERR GET "${commit_CNT}" "${COMMIT_PROP_NAME}")
                    if (NOT ${COMMIT_PROP_NAME}_ERR STREQUAL "NOTFOUND")
                        if (COMMIT_PROP_TYPE STREQUAL "STRING")
                            set(${COMMIT_PROP_NAME}_CNT "\"\"")
                        elseif (COMMIT_PROP_TYPE STREQUAL "OBJECT")
                            set(${COMMIT_PROP_NAME}_CNT "{}")
                        endif()
                        string(JSON commit_CNT SET "${commit_CNT}" "${COMMIT_PROP_NAME}" "${${COMMIT_PROP_NAME}_CNT}")
                    endif()
                endforeach()
                string(JSON ${_REPO}_CNT SET "${${_REPO}_CNT}" "commit" "${commit_CNT}")
            endif()
        endforeach()
        unset(REF_PROP_ID)
        string(JSON JSON_CNT SET "${JSON_CNT}" "${_REPO}" "${${_REPO}_CNT}")
    endforeach()
endmacro()


function(get_members_of_json_object)
    #
    # Parse arguments.
    #
    set(OPTIONS)
    set(ONE_VALUE_ARGS      IN_JSON_OBJECT
                            OUT_MEMBER_NAMES
                            OUT_MEMBER_VALUES
                            OUT_MEMBER_NUMBER)
    set(MULTI_VALUE_ARGS)
    cmake_parse_arguments(GMOJO
        "${OPTIONS}"
        "${ONE_VALUE_ARGS}"
        "${MULTI_VALUE_ARGS}"
        ${ARGN})
    #
    # Ensure all required arguments are provided.
    #
    set(REQUIRED_ARGS       IN_JSON_OBJECT)
    foreach(_ARG ${REQUIRED_ARGS})
        if (NOT DEFINED GMOJO_${_ARG})
            message(FATAL_ERROR "Missing GMOJO_${_ARG} argument.")
        endif()
    endforeach()
    unset(_ARG)
    #
    # Extract and store member names and values.
    #
    set(MEMBER_NAMES)
    set(MEMBER_VALUES)
    string(JSON MEMBER_LENGTH LENGTH "${GMOJO_IN_JSON_OBJECT}")
    math(EXPR MEMBER_MAX_ID "${MEMBER_LENGTH} - 1")
    foreach(MEMBER_ID RANGE ${MEMBER_MAX_ID})
        string(JSON MEMBER_NAME MEMBER "${GMOJO_IN_JSON_OBJECT}" "${MEMBER_ID}")
        string(JSON MEMBER_VALUE GET "${GMOJO_IN_JSON_OBJECT}" "${MEMBER_NAME}")
        list(APPEND MEMBER_NAMES "${MEMBER_NAME}")
        list(APPEND MEMBER_VALUES "${MEMBER_VALUE}")
    endforeach()
    unset(MEMBER_ID)
    #
    # Return the content of ${MEMBER_NAMES}   to the argument of OUT_MEMBER_NAMES.
    # Return the content of ${MEMBER_VALUES}  to the argument of MEMBER_VALUES.
    # Return the content of ${MEMBER_LENGTH}  to the argument of OUT_MEMBER_NUMBER.
    #
    set(${GMOJO_OUT_MEMBER_NAMES}   "${MEMBER_NAMES}"   PARENT_SCOPE)
    set(${GMOJO_OUT_MEMBER_VALUES}  "${MEMBER_VALUES}"  PARENT_SCOPE)
    set(${GMOJO_OUT_MEMBER_NUMBER}  "${MEMBER_LENGTH}"  PARENT_SCOPE)
endfunction()


function(set_members_of_commit_json_object)
    #
    # Parse arguments.
    #
    set(OPTIONS)
    set(ONE_VALUE_ARGS      IN_MEMBER_DATE
                            IN_MEMBER_HASH
                            IN_MEMBER_TITLE
                            OUT_JSON_OBJECT)
    set(MULTI_VALUE_ARGS)
    cmake_parse_arguments(SMOCJO
        "${OPTIONS}"
        "${ONE_VALUE_ARGS}"
        "${MULTI_VALUE_ARGS}"
        ${ARGN})
    #
    # Validate required arguments.
    #
    set(REQUIRED_ARGS ${ONE_VALUE_ARGS})
    foreach(_ARG ${REQUIRED_ARGS})
        if (NOT DEFINED SMOCJO_${_ARG})
            message(FATAL_ERROR "Missing SMOCJO_${_ARG} argument.")
        endif()
    endforeach()
    unset(_ARG)
    #
    # Construct JSON object for 'commit'.
    #
    set(COMMIT_OBJECT "{}")
    string(JSON COMMIT_OBJECT SET "${COMMIT_OBJECT}" "date"  "${SMOCJO_IN_MEMBER_DATE}")
    string(JSON COMMIT_OBJECT SET "${COMMIT_OBJECT}" "hash"  "${SMOCJO_IN_MEMBER_HASH}")
    string(JSON COMMIT_OBJECT SET "${COMMIT_OBJECT}" "title" "${SMOCJO_IN_MEMBER_TITLE}")
    #
    # Return the content of ${COMMIT_OBJECT} to the argument of OUT_JSON_OBJECT.
    #
    set(${SMOCJO_OUT_JSON_OBJECT} "${COMMIT_OBJECT}" PARENT_SCOPE)
endfunction()


function(set_members_of_reference_json_object)
    #
    # Parse arguments.
    #
    set(OPTIONS)
    set(ONE_VALUE_ARGS      IN_VERSION_TYPE
                            IN_MEMBER_BRANCH
                            IN_MEMBER_COMMIT
                            IN_MEMBER_TAG
                            OUT_JSON_OBJECT)
    set(MULTI_VALUE_ARGS)
    cmake_parse_arguments(SMORJO
        "${OPTIONS}"
        "${ONE_VALUE_ARGS}"
        "${MULTI_VALUE_ARGS}"
        ${ARGN})
    #
    # Ensure all required arguments are provided.
    #
    if (SMORJO_IN_VERSION_TYPE STREQUAL "tag")
        set(REQUIRED_ARGS   IN_VERSION_TYPE
                            IN_MEMBER_TAG
                            OUT_JSON_OBJECT)
    elseif (SMORJO_IN_VERSION_TYPE STREQUAL "branch")
        set(REQUIRED_ARGS   IN_VERSION_TYPE
                            IN_MEMBER_BRANCH
                            IN_MEMBER_COMMIT
                            OUT_JSON_OBJECT)
    else()
        message(FATAL_ERROR "Missing/Invalid IRJF_IN_VERSION_TYPE argument. (${SMORJO_IN_VERSION_TYPE})")
    endif()
    foreach(_ARG ${REQUIRED_ARGS})
        if (NOT DEFINED SMORJO_${_ARG})
            message(FATAL_ERROR "Missing SMORJO_${_ARG} argument.")
        endif()
    endforeach()
    unset(_ARG)
    #
    # Construct JSON object for 'reference' based on ${SMORJO_IN_VERSION_TYPE}.
    #
    set(REF_OBJECT "{}")
    if (SMORJO_IN_VERSION_TYPE STREQUAL "branch")
        if (NOT DEFINED SMORJO_IN_MEMBER_BRANCH)
            message(FATAL_ERROR "Missing SMORJO_IN_MEMBER_BRANCH argument.")
        endif()
        if (NOT DEFINED SMORJO_IN_MEMBER_COMMIT)
            message(FATAL_ERROR "Missing SMORJO_IN_MEMBER_COMMIT argument.")
        endif()
        string(JSON REF_OBJECT SET "${REF_OBJECT}" "branch" "${SMORJO_IN_MEMBER_BRANCH}")
        string(JSON REF_OBJECT SET "${REF_OBJECT}" "commit" "${SMORJO_IN_MEMBER_COMMIT}")
    elseif (SMORJO_IN_VERSION_TYPE STREQUAL "tag")
        if (NOT DEFINED SMORJO_IN_MEMBER_TAG)
            message(FATAL_ERROR "Missing SMORJO_IN_MEMBER_TAG argument.")
        endif()
        string(JSON REF_OBJECT SET "${REF_OBJECT}" "tag" "${SMORJO_IN_MEMBER_TAG}")
    else()
        message(FATAL_ERROR "Invalid SMORJO_IN_VERSION_TYPE value. (${SMORJO_IN_VERSION_TYPE})")
    endif()
    #
    # Return the content of ${REF_OBJECT} to the argument of OUT_JSON_OBJECT.
    #
    set(${SMORJO_OUT_JSON_OBJECT} "${REF_OBJECT}" PARENT_SCOPE)
endfunction()


function(set_json_value_by_dot_notation)
    #
    # Parse arguments.
    #
    set(OPTIONS)
    set(ONE_VALUE_ARGS      ERROR_VARIABLE
                            IN_JSON_OBJECT
                            IN_DOT_NOTATION
                            IN_JSON_VALUE
                            OUT_JSON_OBJECT)
    set(MULTI_VALUE_ARGS)
    cmake_parse_arguments(SJVBDN
        "${OPTIONS}"
        "${ONE_VALUE_ARGS}"
        "${MULTI_VALUE_ARGS}"
        ${ARGN})
    #
    # Ensure all required arguments are provided.
    #
    set(REQUIRED_ARGS       IN_JSON_OBJECT
                            IN_DOT_NOTATION
                            IN_JSON_VALUE
                            OUT_JSON_OBJECT)
    foreach(_ARG ${REQUIRED_ARGS})
        if (NOT DEFINED SJVBDN_${_ARG})
            message(FATAL_ERROR "Missing SJVBDN_${_ARG} argument.")
        endif()
    endforeach()
    unset(_ARG)
    #
    # Ensure the dot notation starts with a '.'.
    #
    if (SJVBDN_IN_DOT_NOTATION MATCHES "^\\.")
        string(SUBSTRING "${SJVBDN_IN_DOT_NOTATION}" 1 -1 SJVBDN_IN_DOT_NOTATION_NO_1ST_DOT)
    else()
        #
        # Return the error message to ERROR_VARIABLE if ERROR_VARIABLE is provided.
        # Print the error message as a fatal error if ERROR_VARIABLE is not provided.
        #
        set(ERROR_MESSAGE "Dot Notation must start with a '.' (${SJVBDN_IN_DOT_NOTATION})")
        if (DEFINED SJVBDN_ERROR_VARIABLE)
            set(${SJVBDN_ERROR_VARIABLE} "${ERROR_MESSAGE}" PARENT_SCOPE)
            return()
        else()
            message(FATAL_ERROR "${ERROR_MESSAGE}")
        endif()
    endif()
    #
    # Split the dot notation path and collect property names and JSON fragments.
    #
    set(NAME_STACK)
    set(JSON_STACK)
    set(CUR_NAME)
    set(CUR_PATH "${SJVBDN_IN_DOT_NOTATION_NO_1ST_DOT}")
    set(CUR_JSON "${SJVBDN_IN_JSON_OBJECT}")
    # https://discourse.cmake.org/t/checking-for-empty-string-doesnt-work-as-expected/3639/4
    if (NOT "${CUR_PATH}" STREQUAL "")
        list(APPEND JSON_STACK "${CUR_JSON}")
    endif()
    while(CUR_PATH MATCHES "\\.")
        string(FIND "${CUR_PATH}" "." DOT_POS)
        math(EXPR DOT_NEXT_POS "${DOT_POS} + 1")
        string(SUBSTRING "${CUR_PATH}" 0 ${DOT_POS}       CUR_NAME)
        string(SUBSTRING "${CUR_PATH}" ${DOT_NEXT_POS} -1 CUR_PATH)
        string(JSON CUR_JSON ERROR_VARIABLE ERR_VAR GET "${CUR_JSON}" "${CUR_NAME}")
        if (CUR_JSON MATCHES "NOTFOUND$")
            #
            # Return the error message to ERROR_VARIABLE if ERROR_VARIABLE is provided.
            # Print the error message as a fatal error if ERROR_VARIABLE is not provided.
            #
            set(ERROR_MESSAGE "${ERR_VAR} (${SJVBDN_IN_DOT_NOTATION})")
            if (DEFINED SJVBDN_ERROR_VARIABLE)
                set(${SJVBDN_ERROR_VARIABLE} "${ERROR_MESSAGE}" PARENT_SCOPE)
                return()
            else()
                message(FATAL_ERROR "${ERROR_MESSAGE}")
            endif()
        endif()
        list(APPEND NAME_STACK "${CUR_NAME}")
        list(APPEND JSON_STACK "${CUR_JSON}")
    endwhile()
    # https://discourse.cmake.org/t/checking-for-empty-string-doesnt-work-as-expected/3639/4
    if ("${CUR_NAME}" STREQUAL "" AND "${CUR_PATH}" STREQUAL "")
        #
        # If the dot notation is '.',
        # then no post-processing is needed after the while loop is executed.
        #
    else()
        #
        # If the dot notation is the correct syntax of '.xxx.yyy.zzz',
        # then push the CUR_PATH at the end of the while loop into NAME_STACK as CUR_NAME.
        #
        set(CUR_NAME "${CUR_PATH}")
        set(CUR_PATH)
        string(JSON CUR_JSON ERROR_VARIABLE ERR_VAR GET "${CUR_JSON}" "${CUR_NAME}")
        if (CUR_JSON MATCHES "NOTFOUND$")
            #
            # Return the error message to ERROR_VARIABLE if ERROR_VARIABLE is provided.
            # Print the error message as a fatal error if ERROR_VARIABLE is not provided.
            #
            set(ERROR_MESSAGE "${ERR_VAR} (${SJVBDN_IN_DOT_NOTATION})")
            if (DEFINED SJVBDN_ERROR_VARIABLE)
                set(${SJVBDN_ERROR_VARIABLE} "${ERROR_MESSAGE}" PARENT_SCOPE)
                return()
            else()
                message(FATAL_ERROR "${ERROR_MESSAGE}")
            endif()
        endif()
        list(APPEND NAME_STACK "${CUR_NAME}")
    endif()
    #
    # Update the value at the specified path by reversing through the property names and JSON fragments.
    #
    set(CUR_NAME)
    set(CUR_JSON)
    set(CUR_VALUE "${SJVBDN_IN_JSON_VALUE}")
    while(JSON_STACK)
        list(POP_BACK NAME_STACK CUR_NAME)
        list(POP_BACK JSON_STACK CUR_JSON)
        string(JSON CUR_JSON SET "${CUR_JSON}" "${CUR_NAME}" "${CUR_VALUE}")
        set(CUR_VALUE "${CUR_JSON}")
    endwhile()
    if (NOT CUR_JSON)
        set(CUR_JSON "${CUR_VALUE}")
    endif()
    #
    # Return the string of "NOTFOUND"   to the argument of ERROR_VARIABLE.
    # Return the content of ${CUR_JSON} to the argument of OUT_JSON_OBJECT.
    #
    set(${SJVBDN_ERROR_VARIABLE}  "NOTFOUND"    PARENT_SCOPE)
    set(${SJVBDN_OUT_JSON_OBJECT} "${CUR_JSON}" PARENT_SCOPE)
endfunction()


function(get_json_value_by_dot_notation)
    #
    # Parse arguments.
    #
    set(OPTIONS)
    set(ONE_VALUE_ARGS      ERROR_VARIABLE
                            IN_JSON_OBJECT
                            IN_DOT_NOTATION
                            OUT_JSON_VALUE)
    set(MULTI_VALUE_ARGS)
    cmake_parse_arguments(GJVBDN
        "${OPTIONS}"
        "${ONE_VALUE_ARGS}"
        "${MULTI_VALUE_ARGS}"
        ${ARGN})
    #
    # Ensure all required arguments are provided.
    #
    set(REQUIRED_ARGS       IN_JSON_OBJECT
                            IN_DOT_NOTATION
                            OUT_JSON_VALUE)
    foreach(_ARG ${REQUIRED_ARGS})
        if (NOT DEFINED GJVBDN_${_ARG})
            message(FATAL_ERROR "Missing GJVBDN_${_ARG} argument.")
        endif()
    endforeach()
    unset(_ARG)
    #
    # Validate the IN_DOT_NOTATION argument.
    #
    if (GJVBDN_IN_DOT_NOTATION MATCHES "^\\.")
        string(SUBSTRING "${GJVBDN_IN_DOT_NOTATION}" 1 -1 GJVBDN_IN_DOT_NOTATION_NO_1ST_DOT)
    else()
        #
        # Return the error message to ERROR_VARIABLE if ERROR_VARIABLE is provided.
        # Print the error message as a fatal error if ERROR_VARIABLE is not provided.
        #
        set(ERROR_MESSAGE "Dot Notation must start with a '.' (${GJVBDN_IN_DOT_NOTATION})")
        if (DEFINED GJVBDN_ERROR_VARIABLE)
            set(${GJVBDN_ERROR_VARIABLE} "${ERROR_MESSAGE}" PARENT_SCOPE)
            return()
        else()
            message(FATAL_ERROR "${ERROR_MESSAGE}")
        endif()
    endif()
    #
    # Navigate through the JSON object using the dot notation to find the desired value.
    # Split the dot notation at each dot to traverse nested objects.
    #
    set(CUR_NAME)
    set(CUR_PATH "${GJVBDN_IN_DOT_NOTATION_NO_1ST_DOT}")
    set(CUR_JSON "${GJVBDN_IN_JSON_OBJECT}")
    while(CUR_PATH MATCHES "\\.")
        string(FIND "${CUR_PATH}" "." DOT_POS)
        math(EXPR DOT_NEXT_POS "${DOT_POS} + 1")
        string(SUBSTRING "${CUR_PATH}" 0 ${DOT_POS}       CUR_NAME)
        string(SUBSTRING "${CUR_PATH}" ${DOT_NEXT_POS} -1 CUR_PATH)
        string(JSON CUR_JSON ERROR_VARIABLE ERR_VAR GET "${CUR_JSON}" "${CUR_NAME}")
        if (CUR_JSON MATCHES "NOTFOUND$")
            #
            # Return the error message to ERROR_VARIABLE if ERROR_VARIABLE is provided.
            # Print the error message as a fatal error if ERROR_VARIABLE is not provided.
            #
            set(ERROR_MESSAGE "${ERR_VAR} (${GJVBDN_IN_DOT_NOTATION})")
            if (DEFINED GJVBDN_ERROR_VARIABLE)
                set(${GJVBDN_ERROR_VARIABLE} "${ERROR_MESSAGE}" PARENT_SCOPE)
                return()
            else()
                message(FATAL_ERROR "${ERROR_MESSAGE}")
            endif()
        endif()
    endwhile()
    # https://discourse.cmake.org/t/checking-for-empty-string-doesnt-work-as-expected/3639/5
    if ("${CUR_NAME}" STREQUAL "" AND "${CUR_PATH}" STREQUAL "")
        #
        # If the dot notation is '.',
        # then no post-processing is needed after the while loop is executed.
        #
    else()
        #
        # If the dot notation is the correct syntax of '.xxx.yyy.zzz',
        # then push the CUR_PATH at the end of the while loop into NAME_STACK as CUR_NAME.
        #
        set(CUR_NAME "${CUR_PATH}")
        set(CUR_PATH)
        string(JSON CUR_JSON ERROR_VARIABLE ERR_VAR GET "${CUR_JSON}" "${CUR_NAME}")
        if (CUR_JSON MATCHES "NOTFOUND$")
            #
            # Return the error message to the ERROR_VARIABLE argument if ERROR_VARIABLE is provided.
            # Print the error message as a fatal error if ERROR_VARIABLE is not provided.
            #
            set(ERROR_MESSAGE "${ERR_VAR} (${GJVBDN_IN_DOT_NOTATION})")
            if (DEFINED GJVBDN_ERROR_VARIABLE)
                set(${GJVBDN_ERROR_VARIABLE} "${ERROR_MESSAGE}" PARENT_SCOPE)
                return()
            else()
                message(FATAL_ERROR "${ERROR_MESSAGE}")
            endif()
        endif()
    endif()
    #
    # Return the constant "NOTFOUND"    to the argument of ERROR_VARIABLE.
    # Return the content of ${CUR_JSON} to the argument of OUT_JSON_VALUE.
    #
    set(${GJVBDN_ERROR_VARIABLE}  "NOTFOUND"    PARENT_SCOPE)
    set(${GJVBDN_OUT_JSON_VALUE}  "${CUR_JSON}" PARENT_SCOPE)
endfunction()


function(get_reference_of_latest_from_repo_and_current_from_json)
    #
    # Parse arguments.
    #
    set(OPTIONS)
    set(ONE_VALUE_ARGS      IN_JSON_CNT
                            IN_LOCAL_PATH
                            IN_DOT_NOTATION
                            IN_VERSION_TYPE
                            IN_BRANCH_NAME
                            IN_TAG_PATTERN
                            IN_TAG_SUFFIX
                            OUT_LATEST_OBJECT
                            OUT_LATEST_REFERENCE
                            OUT_CURRENT_OBJECT
                            OUT_CURRENT_REFERENCE)
    set(MULTI_VALUE_ARGS)
    cmake_parse_arguments(GRLCJ
        "${OPTIONS}"
        "${ONE_VALUE_ARGS}"
        "${MULTI_VALUE_ARGS}"
        ${ARGN})
    #
    # Ensure all required arguments are provided.
    #
    set(REQUIRED_ARGS       IN_JSON_CNT
                            IN_LOCAL_PATH
                            IN_DOT_NOTATION
                            IN_VERSION_TYPE)
    foreach(ARG ${REQUIRED_ARGS})
        if (NOT DEFINED GRLCJ_${ARG})
            message(FATAL_ERROR "Missing ${ARG} argument.")
        endif()
    endforeach()
    unset(ARG)
    #
    # Extract the current reference object from the input JSON content.
    # Extract the latest reference object from the local repository.
    #
    get_json_value_by_dot_notation(
        IN_JSON_OBJECT                  "${GRLCJ_IN_JSON_CNT}"
        IN_DOT_NOTATION                 "${GRLCJ_IN_DOT_NOTATION}"
        OUT_JSON_VALUE                  CURRENT_OBJECT)
    if (GRLCJ_IN_VERSION_TYPE STREQUAL "branch")
        get_json_value_by_dot_notation(
            IN_JSON_OBJECT              "${CURRENT_OBJECT}"
            IN_DOT_NOTATION             ".commit.hash"
            OUT_JSON_VALUE              CURRENT_COMMIT_HASH)
        get_git_latest_commit_on_branch_name(
            IN_LOCAL_PATH               "${GRLCJ_IN_LOCAL_PATH}"
            IN_SOURCE_TYPE              "local"
            IN_BRANCH_NAME              "${GRLCJ_IN_BRANCH_NAME}"
            OUT_COMMIT_DATE             LATEST_COMMIT_DATE
            OUT_COMMIT_HASH             LATEST_COMMIT_HASH
            OUT_COMMIT_TITLE            LATEST_COMMIT_TITLE)
        set_members_of_commit_json_object(
            IN_MEMBER_DATE              "\"${LATEST_COMMIT_DATE}\""
            IN_MEMBER_HASH              "\"${LATEST_COMMIT_HASH}\""
            IN_MEMBER_TITLE             "\"${LATEST_COMMIT_TITLE}\""
            OUT_JSON_OBJECT             COMMIT_CNT)
        set_members_of_reference_json_object(
            IN_VERSION_TYPE             "branch"
            IN_MEMBER_BRANCH            "\"${GRLCJ_IN_BRANCH_NAME}\""
            IN_MEMBER_COMMIT            "${COMMIT_CNT}"
            OUT_JSON_OBJECT             LATEST_OBJECT)
        set(LATEST_REFERENCE            "${LATEST_COMMIT_HASH}")
        set(CURRENT_REFERENCE           "${CURRENT_COMMIT_HASH}")
    elseif (GRLCJ_IN_VERSION_TYPE STREQUAL "tag")
        get_json_value_by_dot_notation(
            IN_JSON_OBJECT              "${CURRENT_OBJECT}"
            IN_DOT_NOTATION             ".tag"
            OUT_JSON_VALUE              CURRENT_TAG)
        get_git_latest_tag_on_tag_pattern(
            IN_LOCAL_PATH               "${PROJ_OUT_REPO_DIR}"
            IN_SOURCE_TYPE              "local"
            IN_TAG_PATTERN              "${GRLCJ_IN_TAG_PATTERN}"
            IN_TAG_SUFFIX               "${GRLCJ_IN_TAG_SUFFIX}"
            OUT_TAG                     LATEST_TAG)
        set_members_of_reference_json_object(
            IN_VERSION_TYPE             "tag"
            IN_MEMBER_TAG               "\"${LATEST_TAG}\""
            OUT_JSON_OBJECT             LATEST_OBJECT)
        set(LATEST_REFERENCE            "${LATEST_TAG}")
        set(CURRENT_REFERENCE           "${CURRENT_TAG}")
    else()
        message(FATAL_ERROR "Invalid IN_VERSION_TYPE value. (${GRLCJ_IN_VERSION_TYPE})")
    endif()
    #
    # Return the content of ${CURRENT_OBJECT}     to the argument of OUT_CURRENT_OBJECT.
    # Return the content of ${CURRENT_REFERENCE}  to the argument of OUT_CURRENT_REFERENCE.
    # Return the content of ${LATEST_OBJECT}      to the argument of OUT_LATEST_OBJECT.
    # Return the content of ${LATEST_REFERENCE}   to the argument of OUT_LATEST_REFERENCE.
    #
    set(${GRLCJ_OUT_CURRENT_OBJECT}     "${CURRENT_OBJECT}"     PARENT_SCOPE)
    set(${GRLCJ_OUT_CURRENT_REFERENCE}  "${CURRENT_REFERENCE}"  PARENT_SCOPE)
    set(${GRLCJ_OUT_LATEST_OBJECT}      "${LATEST_OBJECT}"      PARENT_SCOPE)
    set(${GRLCJ_OUT_LATEST_REFERENCE}   "${LATEST_REFERENCE}"   PARENT_SCOPE)
endfunction()


function(get_reference_of_pot_and_po_from_json)
    #
    # Parse arguments.
    #
    set(OPTIONS)
    set(ONE_VALUE_ARGS      IN_JSON_CNT
                            IN_VERSION_TYPE
                            IN_LANGUAGE
                            OUT_POT_OBJECT
                            OUT_POT_REFERENCE
                            OUT_PO_OBJECT
                            OUT_PO_REFERENCE)
    set(MULTI_VALUE_ARGS)
    cmake_parse_arguments(GRPPJ
        "${OPTIONS}"
        "${ONE_VALUE_ARGS}"
        "${MULTI_VALUE_ARGS}"
        ${ARGN})
    #
    # Ensure all required arguments are provided.
    #
    set(REQUIRED_ARGS       IN_JSON_CNT
                            IN_VERSION_TYPE
                            IN_LANGUAGE)
    foreach(ARG ${REQUIRED_ARGS})
        if (NOT DEFINED GRPPJ_${ARG})
            message(FATAL_ERROR "Missing ${ARG} argument.")
        endif()
    endforeach()
    unset(ARG)
    #
    # Extract '.pot' and '.po' objects and their references (commit hash or tag)
    # from the input JSON, based on the specified version type and language.
    #
    get_json_value_by_dot_notation(
        IN_JSON_OBJECT              "${GRPPJ_IN_JSON_CNT}"
        IN_DOT_NOTATION             ".pot"
        OUT_JSON_VALUE              POT_OBJECT)
    get_json_value_by_dot_notation(
        IN_JSON_OBJECT              "${GRPPJ_IN_JSON_CNT}"
        IN_DOT_NOTATION             ".po.${GRPPJ_IN_LANGUAGE}"
        OUT_JSON_VALUE              PO_OBJECT)
    if (GRPPJ_IN_VERSION_TYPE STREQUAL "branch")
        set(DOT_NOTATION            ".commit.hash")
    else()
        set(DOT_NOTATION            ".tag")
    endif()
    get_json_value_by_dot_notation(
        IN_JSON_OBJECT              "${POT_OBJECT}"
        IN_DOT_NOTATION             "${DOT_NOTATION}"
        OUT_JSON_VALUE              POT_REFERENCE)
    get_json_value_by_dot_notation(
        IN_JSON_OBJECT              "${PO_OBJECT}"
        IN_DOT_NOTATION             "${DOT_NOTATION}"
        OUT_JSON_VALUE              PO_REFERENCE)
    #
    # Return the content of ${POT_OBJECT}     to the argument of OUT_POT_OBJECT.
    # Return the content of ${POT_REFERENCE}  to the argument of OUT_POT_REFERENCE.
    # Return the content of ${PO_OBJECT}      to the argument of OUT_PO_OBJECT.
    # Return the content of ${PO_REFERENCE}   to the argument of OUT_PO_REFERENCE.
    #
    set(${GRPPJ_OUT_POT_OBJECT}     "${POT_OBJECT}"     PARENT_SCOPE)
    set(${GRPPJ_OUT_POT_REFERENCE}  "${POT_REFERENCE}"  PARENT_SCOPE)
    set(${GRPPJ_OUT_PO_OBJECT}      "${PO_OBJECT}"      PARENT_SCOPE)
    set(${GRPPJ_OUT_PO_REFERENCE}   "${PO_REFERENCE}"   PARENT_SCOPE)
endfunction()
