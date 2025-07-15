# Distributed under the OSI-approved BSD 3-Clause License.
# See accompanying file LICENSE-BSD for details.


include_guard()


function(update_sphinx_pot_from_def_to_pkg)
    #
    # Parse arguments.
    #
    set(OPTIONS)
    set(ONE_VALUE_ARGS      IN_DEF_FILE
                            IN_PKG_FILE
                            IN_WRAP_WIDTH)
    set(MULTI_VALUE_ARGS)
    cmake_parse_arguments(USPFSTD
        "${OPTIONS}"
        "${ONE_VALUE_ARGS}"
        "${MULTI_VALUE_ARGS}"
        ${ARGN})
    #
    # Ensure all required arguments are provided.
    #
    set(REQUIRED_ARGS       IN_DEF_FILE
                            IN_PKG_FILE
                            IN_WRAP_WIDTH)
    foreach(ARG ${REQUIRED_ARGS})
        if (NOT DEFINED USPFSTD_${ARG})
            message(FATAL_ERROR "Missing ${ARG} argument.")
        endif()
    endforeach()
    #
    # Find msgcat executable if not exists.
    #
    if (NOT EXISTS "${Gettext_MSGCAT_EXECUTABLE}")
        find_package(Gettext QUIET MODULE REQUIRED COMPONENTS Msgcat)
    endif()
    #
    #
    #
    if (EXISTS "${USPFSTD_IN_PKG_FILE}")
        #
        # Concatenate the package 'sphinx.pot' with the default 'sphinx.pot'.
        #
        message("msgcat:")
        message("  --use-first")
        message("  --width        ${USPFSTD_IN_WRAP_WIDTH}")
        message("  --output-file  ${USPFSTD_IN_PKG_FILE}")
        message("  [inputfile]    ${USPFSTD_IN_PKG_FILE}")
        message("  [inputfile]    ${USPFSTD_IN_DEF_FILE}")
        execute_process(
            COMMAND ${Gettext_MSGCAT_EXECUTABLE}
                    --use-first
                    --width=${USPFSTD_IN_WRAP_WIDTH}
                    --output-file=${USPFSTD_IN_PKG_FILE}
                    ${USPFSTD_IN_PKG_FILE}  # [inputfile]
                    ${USPFSTD_IN_DEF_FILE}  # [inputfile]
            RESULT_VARIABLE RES_VAR
            OUTPUT_VARIABLE OUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_VARIABLE  ERR_VAR ERROR_STRIP_TRAILING_WHITESPACE)
        if (RES_VAR EQUAL 0)
            if (ERR_VAR)
                string(APPEND WARNING_REASON
                "The command succeeded but had some warnings.\n\n"
                "    result:\n\n${RES_VAR}\n\n"
                "    stderr:\n\n${ERR_VAR}")
                message("${WARNING_REASON}")
            endif()
        else()
            string(APPEND FAILURE_REASON
            "The command failed with fatal errors.\n"
            "    result:\n${RES_VAR}\n"
            "    stdout:\n${OUT_VAR}\n"
            "    stderr:\n${ERR_VAR}")
            message(FATAL_ERROR "${FAILURE_REASON}")
        endif()
    else()
        #
        # Generate the package 'sphinx.pot' from the default 'sphinx.pot'.
        #
        message("msgcat:")
        message("  --use-first")
        message("  --width        ${USPFSTD_IN_WRAP_WIDTH}")
        message("  --output-file  ${USPFSTD_IN_PKG_FILE}")
        message("  [inputfile]    ${USPFSTD_IN_DEF_FILE}")
        execute_process(
            COMMAND ${Gettext_MSGCAT_EXECUTABLE}
                    --width=${USPFSTD_IN_WRAP_WIDTH}
                    --output-file=${USPFSTD_IN_PKG_FILE}
                    ${USPFSTD_IN_DEF_FILE}
            RESULT_VARIABLE RES_VAR
            OUTPUT_VARIABLE OUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_VARIABLE  ERR_VAR ERROR_STRIP_TRAILING_WHITESPACE)
        if (RES_VAR EQUAL 0)
        else()
            string(APPEND FAILURE_REASON
            "The command failed with fatal errors.\n"
            "    result:\n${RES_VAR}\n"
            "    stdout:\n${OUT_VAR}\n"
            "    stderr:\n${ERR_VAR}")
            message(FATAL_ERROR "${FAILURE_REASON}")
        endif()
    endif()
endfunction()


function(_override_header_entry_from_src_to_dst)
    #
    # Parse arguments.
    #
    set(OPTIONS)
    set(ONE_VALUE_ARGS      IN_SRC_FILE
                            IN_DST_FILE)
    set(MULTI_VALUE_ARGS)
    cmake_parse_arguments(OHESD
        "${OPTIONS}"
        "${ONE_VALUE_ARGS}"
        "${MULTI_VALUE_ARGS}"
        ${ARGN})
    #
    # Ensure all required arguments are provided.
    #
    set(REQUIRED_ARGS       IN_SRC_FILE
                            IN_DST_FILE)
    foreach(ARG ${REQUIRED_ARGS})
        if (NOT DEFINED OHESD_${ARG})
            message(FATAL_ERROR "Missing ${ARG} argument.")
        endif()
    endforeach()
    #
    #
    #
    file(READ ${OHESD_IN_SRC_FILE} IN_SRC_FILE_CNT)
    file(READ ${OHESD_IN_DST_FILE} IN_DST_FILE_CNT)
    set(HEADER_ENTRY_NAME   "Project-Id-Version")
    string(REGEX MATCH      "${HEADER_ENTRY_NAME}: [^\\]+" HEADER_ENTRY_LINE ${IN_SRC_FILE_CNT})
    string(REGEX REPLACE    "${HEADER_ENTRY_NAME}: " "" HEADER_ENTRY_VALUE ${HEADER_ENTRY_LINE})
    string(REGEX REPLACE    "${HEADER_ENTRY_NAME}: [^\\]+"
                            "${HEADER_ENTRY_NAME}: ${HEADER_ENTRY_VALUE}"
                            IN_DST_FILE_CNT "${IN_DST_FILE_CNT}")
    file(WRITE ${OHESD_IN_DST_FILE} "${IN_DST_FILE_CNT}")
endfunction()


function(update_pot_from_src_to_dst)
    #
    # Parse arguments.
    #
    set(OPTIONS)
    set(ONE_VALUE_ARGS      IN_SRC_DIR
                            IN_DST_DIR
                            IN_WRAP_WIDTH)
    set(MULTI_VALUE_ARGS)
    cmake_parse_arguments(UPFSTD
        "${OPTIONS}"
        "${ONE_VALUE_ARGS}"
        "${MULTI_VALUE_ARGS}"
        ${ARGN})
    #
    # Ensure all required arguments are provided.
    #
    set(REQUIRED_ARGS       IN_SRC_DIR
                            IN_DST_DIR
                            IN_WRAP_WIDTH)
    foreach(ARG ${REQUIRED_ARGS})
        if (NOT DEFINED UPFSTD_${ARG})
            message(FATAL_ERROR "Missing ${ARG} argument.")
        endif()
    endforeach()
    #
    # Find msgcat executables if not exists.
    #
    if (NOT EXISTS "${Gettext_MSGCAT_EXECUTABLE}")
        find_package(Gettext QUIET MODULE REQUIRED COMPONENTS Msgcat)
    endif()
    #
    # Process each .pot file in the source directory.
    #
    file(GLOB_RECURSE SRC_FILES "${UPFSTD_IN_SRC_DIR}/*.pot")
    foreach(SRC_FILE ${SRC_FILES})
        string(REPLACE "${UPFSTD_IN_SRC_DIR}/" "" SRC_FILE_RELATIVE "${SRC_FILE}")
        set(DST_FILE "${UPFSTD_IN_DST_DIR}/${SRC_FILE_RELATIVE}")
        get_filename_component(DST_FILE_DIR "${DST_FILE}" DIRECTORY)
        file(MAKE_DIRECTORY "${DST_FILE_DIR}")
        if (EXISTS "${DST_FILE}")
            #
            # If the ${DST_FILE} exists, then merge it using msgmerge.
            #
            message("msgmerge:")
            message("  --quiet")
            message("  --width      ${UPFSTD_IN_WRAP_WIDTH}")
            message("  --backup     off")
            message("  --update")
            message("  --force-po")
            message("  --no-fuzzy-matching")
            message("  [def.po]     ${DST_FILE}")
            message("  [ref.pot]    ${SRC_FILE}")
            execute_process(
                COMMAND ${Gettext_MSGMERGE_EXECUTABLE}
                        --quiet     # Suppress progress indicator
                        --width=${UPFSTD_IN_WRAP_WIDTH}
                        --backup=off
                        --update
                        --force-po
                        --no-fuzzy-matching
                        ${DST_FILE}   # [def.po]
                        ${SRC_FILE}   # [ref.pot]
                RESULT_VARIABLE RES_VAR
                OUTPUT_VARIABLE OUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
                ERROR_VARIABLE  ERR_VAR ERROR_STRIP_TRAILING_WHITESPACE)
            if (RES_VAR EQUAL 0)
                if (ERR_VAR)
                    string(APPEND WARNING_REASON
                    "The command succeeded but had some warnings.\n\n"
                    "    result:\n\n${RES_VAR}\n\n"
                    "    stderr:\n\n${ERR_VAR}")
                    message("${WARNING_REASON}")
                endif()
            else()
                string(APPEND FAILURE_REASON
                "The command failed with fatal errors.\n"
                "    result:\n${RES_VAR}\n"
                "    stdout:\n${OUT_VAR}\n"
                "    stderr:\n${ERR_VAR}")
                message(FATAL_ERROR "${FAILURE_REASON}")
            endif()
            _override_header_entry_from_src_to_dst(
                IN_SRC_FILE   "${SRC_FILE}"
                IN_DST_FILE   "${DST_FILE}")
        else()
            #
            # If the ${DST_FILE} doesn't exist, then create it using msgcat.
            #
            message("msgcat:")
            message("  --width        ${UPFSTD_IN_WRAP_WIDTH}")
            message("  --output-file  ${DST_FILE}")
            message("  [inputfile]    ${SRC_FILE}")
            execute_process(
                COMMAND ${Gettext_MSGCAT_EXECUTABLE}
                        --width=${UPFSTD_IN_WRAP_WIDTH}
                        --output-file=${DST_FILE}
                        ${SRC_FILE}   # [inputfile]
                RESULT_VARIABLE RES_VAR
                OUTPUT_VARIABLE OUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
                ERROR_VARIABLE  ERR_VAR ERROR_STRIP_TRAILING_WHITESPACE)
            if (RES_VAR EQUAL 0)
                if (ERR_VAR)
                    string(APPEND WARNING_REASON
                    "The command succeeded but had some warnings.\n\n"
                    "    result:\n\n${RES_VAR}\n\n"
                    "    stderr:\n\n${ERR_VAR}")
                    message("${WARNING_REASON}")
                endif()
            else()
                string(APPEND FAILURE_REASON
                "The command failed with fatal errors.\n"
                "    result:\n${RES_VAR}\n"
                "    stdout:\n${OUT_VAR}\n"
                "    stderr:\n${ERR_VAR}")
                message(FATAL_ERROR "${FAILURE_REASON}")
            endif()
        endif()
    endforeach()
    unset(SRC_FILE)
endfunction()


function(update_po_from_pot_in_locale)
    #
    # Parse arguments.
    #
    set(OPTIONS)
    set(ONE_VALUE_ARGS      IN_LOCALE_POT_DIR
                            IN_LOCALE_PO_DIR
                            IN_LANGUAGE
                            IN_WRAP_WIDTH)
    set(MULTI_VALUE_ARGS)
    cmake_parse_arguments(UPFP
        "${OPTIONS}"
        "${ONE_VALUE_ARGS}"
        "${MULTI_VALUE_ARGS}"
        ${ARGN})
    #
    # Ensure all required arguments are provided.
    #
    set(REQUIRED_ARGS       IN_LOCALE_POT_DIR
                            IN_LOCALE_PO_DIR
                            IN_LANGUAGE
                            IN_WRAP_WIDTH)
    foreach(ARG ${REQUIRED_ARGS})
        if (NOT DEFINED UPFP_${ARG})
            message(FATAL_ERROR "Missing ${ARG} argument.")
        endif()
    endforeach()
    #
    # Find msgmerge and msgcat executables if not exists.
    #
    if (NOT EXISTS "${Gettext_MSGMERGE_EXECUTABLE}" OR
        NOT EXISTS "${Gettext_MSGCAT_EXECUTABLE}")
        find_package(Gettext QUIET MODULE REQUIRED COMPONENTS Msgmerge Msgcat)
    endif()
    #
    # Process .pot files from the locale directory and generate or update corresponding .po files.
    #
    file(GLOB_RECURSE POT_FILES "${UPFP_IN_LOCALE_POT_DIR}/*.pot")
    foreach(POT_FILE ${POT_FILES})
        string(REPLACE "${UPFP_IN_LOCALE_POT_DIR}/" "" POT_FILE_RELATIVE "${POT_FILE}")
        string(REGEX REPLACE "\\.pot$" ".po" PO_FILE_RELATIVE "${POT_FILE_RELATIVE}")
        set(PO_FILE "${UPFP_IN_LOCALE_PO_DIR}/${PO_FILE_RELATIVE}")
        get_filename_component(PO_FILE_DIR "${PO_FILE}" DIRECTORY)
        file(MAKE_DIRECTORY "${PO_FILE_DIR}")
        if (EXISTS "${PO_FILE}")
            #
            # If the ${PO_FILE} exists, then merge it using msgmerge.
            #
            message("msgmerge:")
            message("  --lang       ${UPFP_IN_LANGUAGE}")
            message("  --width      ${UPFP_IN_WRAP_WIDTH}")
            message("  --backup     off")
            message("  --update")
            message("  --force-po")
            message("  --no-fuzzy-matching")
            message("  [def.po]     ${PO_FILE}")
            message("  [ref.pot]    ${POT_FILE}")
            execute_process(
                COMMAND ${Gettext_MSGMERGE_EXECUTABLE}
                        --lang=${UPFP_IN_LANGUAGE}
                        --width=${UPFP_IN_WRAP_WIDTH}
                        --backup=off
                        --update
                        --force-po
                        --no-fuzzy-matching
                        ${PO_FILE}      # [def.po]
                        ${POT_FILE}     # [ref.pot]
                RESULT_VARIABLE RES_VAR
                OUTPUT_VARIABLE OUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
                ERROR_VARIABLE  ERR_VAR ERROR_STRIP_TRAILING_WHITESPACE)
            if (RES_VAR EQUAL 0)
            else()
                string(APPEND FAILURE_REASON
                "The command failed with fatal errors.\n"
                "    result:\n${RES_VAR}\n"
                "    stdout:\n${OUT_VAR}\n"
                "    stderr:\n${ERR_VAR}")
                message(FATAL_ERROR "${FAILURE_REASON}")
            endif()
            _override_header_entry_from_src_to_dst(
                IN_SRC_FILE   "${POT_FILE}"
                IN_DST_FILE   "${PO_FILE}")
        else()
            #
            # If the ${PO_FILE} doesn't exist, then create it using msgcat.
            #
            message("msgcat:")
            message("  --lang         ${UPFP_IN_LANGUAGE}")
            message("  --width        ${UPFP_IN_WRAP_WIDTH}")
            message("  --output-file  ${PO_FILE}")
            message("  [inputfile]    ${POT_FILE}")
            execute_process(
                COMMAND ${Gettext_MSGCAT_EXECUTABLE}
                        --lang=${UPFP_IN_LANGUAGE}
                        --width=${UPFP_IN_WRAP_WIDTH}
                        --output-file=${PO_FILE}
                        ${POT_FILE}
                RESULT_VARIABLE RES_VAR
                OUTPUT_VARIABLE OUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
                ERROR_VARIABLE  ERR_VAR ERROR_STRIP_TRAILING_WHITESPACE)
            if (RES_VAR EQUAL 0)
            else()
                string(APPEND FAILURE_REASON
                "The command failed with fatal errors.\n"
                "    result:\n${RES_VAR}\n"
                "    stdout:\n${OUT_VAR}\n"
                "    stderr:\n${ERR_VAR}")
                message(FATAL_ERROR "${FAILURE_REASON}")
            endif()
        endif()
    endforeach()
    unset(POT_FILE)
endfunction()


function(concat_po_from_locale_to_single)
    #
    # Parse arguments.
    #
    set(OPTIONS)
    set(ONE_VALUE_ARGS      IN_LOCALE_PO_DIR
                            IN_SINGLE_PO_FILE
                            IN_WRAP_WIDTH)
    set(MULTI_VALUE_ARGS)
    cmake_parse_arguments(CPFLTC
        "${OPTIONS}"
        "${ONE_VALUE_ARGS}"
        "${MULTI_VALUE_ARGS}"
        ${ARGN})
    #
    # Ensure all required arguments are provided.
    #
    set(REQUIRED_ARGS       IN_LOCALE_PO_DIR
                            IN_SINGLE_PO_FILE
                            IN_WRAP_WIDTH)
    foreach(ARG ${REQUIRED_ARGS})
        if (NOT DEFINED CPFLTC_${ARG})
            message(FATAL_ERROR "Missing ${ARG} argument.")
        endif()
    endforeach()
    #
    # Find msgcat executable if not exists.
    #
    if (NOT EXISTS "${Gettext_MSGCAT_EXECUTABLE}")
        find_package(Gettext QUIET MODULE REQUIRED COMPONENTS Msgcat)
    endif()
    #
    # Concatenate all .po files from the locale directory into a single compendium file.
    #
    file(GLOB_RECURSE LOCALE_PO_FILES "${CPFLTC_IN_LOCALE_PO_DIR}/*.po")
    get_filename_component(SINGLE_PO_DIR "${CPFLTC_IN_SINGLE_PO_FILE}" DIRECTORY)
    file(MAKE_DIRECTORY "${SINGLE_PO_DIR}")
    message("msgcat:")
    message("  --width=${CPFLTC_IN_WRAP_WIDTH}")
    message("  --use-first")
    message("  --output-file ${CPFLTC_IN_SINGLE_PO_FILE}")
    foreach(LOCALE_PO_FILE ${LOCALE_PO_FILES})
    message("  ${LOCALE_PO_FILE}")
    endforeach()
    execute_process(
        COMMAND ${Gettext_MSGCAT_EXECUTABLE}
                --width=${CPFLTC_IN_WRAP_WIDTH}
                --use-first
                --output-file=${CPFLTC_IN_SINGLE_PO_FILE}
                ${LOCALE_PO_FILES}
        RESULT_VARIABLE RES_VAR
        OUTPUT_VARIABLE OUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE  ERR_VAR ERROR_STRIP_TRAILING_WHITESPACE)
    if (RES_VAR EQUAL 0)
    else()
        string(APPEND FAILURE_REASON
        "The command failed with fatal errors.\n"
        "    result:\n${RES_VAR}\n"
        "    stdout:\n${OUT_VAR}\n"
        "    stderr:\n${ERR_VAR}")
        message(FATAL_ERROR "${FAILURE_REASON}")
    endif()
endfunction()


function(merge_po_with_compendium_from_src_to_dst)
    #
    # Parse arguments.
    #
    set(OPTIONS)
    set(ONE_VALUE_ARGS      IN_SRC_LOCALE_PO_DIR
                            IN_SRC_SINGLE_PO_FILE
                            IN_DST_LOCALE_PO_DIR
                            IN_DST_LOCALE_POT_DIR
                            IN_LANGUAGE
                            IN_WRAP_WIDTH)
    set(MULTI_VALUE_ARGS)
    cmake_parse_arguments(MPFSDC
        "${OPTIONS}"
        "${ONE_VALUE_ARGS}"
        "${MULTI_VALUE_ARGS}"
        ${ARGN})
    #
    # Ensure all required arguments are provided.
    #
    set(REQUIRED_ARGS       IN_SRC_SINGLE_PO_FILE
                            IN_DST_LOCALE_PO_DIR
                            IN_DST_LOCALE_POT_DIR
                            IN_LANGUAGE
                            IN_WRAP_WIDTH)
    foreach(ARG ${REQUIRED_ARGS})
        if (NOT DEFINED MPFSDC_${ARG})
            message(FATAL_ERROR "Missing ${ARG} argument.")
        endif()
    endforeach()
    #
    # Find msgmerge executable if not exists.
    #
    if (NOT EXISTS "${Gettext_MSGMERGE_EXECUTABLE}")
        find_package(Gettext QUIET MODULE REQUIRED COMPONENTS Msgmerge)
    endif()
    #
    # For each .po file found in the destination locale directory:
    # - Locate the corresponding .pot file in the destination directory.
    # - Locate the corresponding .po file in the source directory.
    # - Determine the compendium file to use:
    #   - If a matching .po file exists in the source directory, use it as the compendium file.
    #   - If no matching .po file is found, fall back to the provided general compendium file.
    #
    file(GLOB_RECURSE DST_LOCALE_PO_FILES "${MPFSDC_IN_DST_LOCALE_PO_DIR}/*.po")
    foreach(DST_LOCALE_PO_FILE ${DST_LOCALE_PO_FILES})
        string(REPLACE "${MPFSDC_IN_DST_LOCALE_PO_DIR}/" "" PO_FILE_RELATIVE "${DST_LOCALE_PO_FILE}")
        string(REGEX REPLACE "\\.po$" ".pot" POT_FILE_RELATIVE "${PO_FILE_RELATIVE}")
        set(SRC_LOCALE_PO_FILE      "${MPFSDC_IN_SRC_LOCALE_PO_DIR}/${PO_FILE_RELATIVE}")
        set(DST_LOCALE_PO_FILE      "${MPFSDC_IN_DST_LOCALE_PO_DIR}/${PO_FILE_RELATIVE}")
        set(DST_LOCALE_POT_FILE     "${MPFSDC_IN_DST_LOCALE_POT_DIR}/${POT_FILE_RELATIVE}")
        if (EXISTS "${SRC_LOCALE_PO_FILE}")
        set(SRC_COMPENDIUM_FILE     "${SRC_LOCALE_PO_FILE}")
        else()
        set(SRC_COMPENDIUM_FILE     "${MPFSDC_IN_SRC_SINGLE_PO_FILE}")
        endif()
        message("msgmerge:")
        message("  --quiet")
        message("  --lang           ${MPFSDC_IN_LANGUAGE}")
        message("  --width          ${MPFSDC_IN_WRAP_WIDTH}")
        message("  --compendium     ${SRC_COMPENDIUM_FILE}")
        message("  --output-file    ${DST_LOCALE_PO_FILE}")
        message("  [def.po]         ${DST_LOCALE_POT_FILE}")
        message("  [ref.pot]        ${DST_LOCALE_POT_FILE}")
        execute_process(
            COMMAND ${Gettext_MSGMERGE_EXECUTABLE}
                    --quiet   # Suppress progress indicator
                    --lang=${MPFSDC_IN_LANGUAGE}
                    --width=${MPFSDC_IN_WRAP_WIDTH}
                    --compendium=${SRC_COMPENDIUM_FILE}
                    --output-file=${DST_LOCALE_PO_FILE}
                    ${DST_LOCALE_POT_FILE}  # [def.po]
                    ${DST_LOCALE_POT_FILE}  # [ref.pot]
            RESULT_VARIABLE RES_VAR
            OUTPUT_VARIABLE OUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_VARIABLE  ERR_VAR ERROR_STRIP_TRAILING_WHITESPACE)
        if (RES_VAR EQUAL 0)
            if (ERR_VAR)
                string(APPEND WARNING_REASON
                "The command succeeded but had some warnings.\n\n"
                "    result:\n\n${RES_VAR}\n\n"
                "    stderr:\n\n${ERR_VAR}")
                message("${WARNING_REASON}")
            endif()
        else()
            string(APPEND FAILURE_REASON
            "The command failed with fatal errors.\n"
            "    result:\n${RES_VAR}\n"
            "    stdout:\n${OUT_VAR}\n"
            "    stderr:\n${ERR_VAR}")
            message(FATAL_ERROR "${FAILURE_REASON}")
        endif()
    endforeach()
    unset(DST_LOCALE_PO_FILE)
endfunction()


function(caculate_statistics_of_gettext)
    #
    # Parse arguments.
    #
    set(OPTIONS)
    set(ONE_VALUE_ARGS      IN_LOCALE_PO_DIR
                            IN_PADDING_LENGTH
                            OUT_NUM_OF_PO_COMPLETED
                            OUT_NUM_OF_PO_PROGRESSING
                            OUT_NUM_OF_PO_UNSTARTED
                            OUT_NUM_OF_PO_TOTAL
                            OUT_PCT_OF_PO_COMPLETED
                            OUT_NUM_OF_MSGID_TRANSLATED
                            OUT_NUM_OF_MSGID_FUZZY
                            OUT_NUM_OF_MSGID_TOTAL
                            OUT_PCT_OF_MSGID_TRANSLATED)
    set(MULTI_VALUE_ARGS)
    cmake_parse_arguments(CSIOG
        "${OPTIONS}"
        "${ONE_VALUE_ARGS}"
        "${MULTI_VALUE_ARGS}"
        ${ARGN})
    #
    # Ensure all required arguments are provided.
    #
    set(REQUIRED_ARGS       IN_LOCALE_PO_DIR
                            IN_PADDING_LENGTH)
    foreach(ARG ${REQUIRED_ARGS})
        if (NOT DEFINED CSIOG_${ARG})
            message(FATAL_ERROR "Missing ${ARG} argument.")
        endif()
    endforeach()
    #
    # Find msgattrib executable if not exists.
    #
    if (NOT EXISTS "${Gettext_MSGATTRIB_EXECUTABLE}")
        find_package(Gettext QUIET MODULE REQUIRED COMPONENTS Msgattrib)
    endif()
    #
    # Initialize the statistical infomation.
    #
    set(NUM_OF_PO_COMPLETED 0)      # Number     of completed   po    files
    set(NUM_OF_PO_PROGRESSING 0)    # Number     of progressing po    files
    set(NUM_OF_PO_UNSTARTED 0)      # Number     of unstarted   po    files
    set(NUM_OF_PO_TOTAL 0)          # Number     of total       po    files
    set(PCT_OF_PO_COMPLETED 0)      # Percentage of completed   po    files
    set(NUM_OF_MSGID_TRANSLATED 0)  # Number     of translated  msgid entries
    set(NUM_OF_MSGID_FUZZY 0)       # Number     of fuzzy       msgid entries
    set(NUM_OF_MSGID_TOTAL 0)       # Number     of total       msgid entries
    set(PCT_OF_MSGID_TRANSLATED 0)  # Percentage of translated  msgid entries
    #
    # Caculate the statistical infomation.
    #
    file(GLOB_RECURSE PO_FILES "${CSIOG_IN_LOCALE_PO_DIR}/*.po")
    if (NOT PO_FILES)
        message(FATAL_ERROR "PO_FILES is empty!")
    endif()
    foreach(PO_FILE ${PO_FILES})
        #
        # Calculate the total msgid entries.
        #
        execute_process(
            COMMAND ${Gettext_MSGATTRIB_EXECUTABLE} --no-fuzzy --no-obsolete ${PO_FILE}
            RESULT_VARIABLE TOTAL_MSGID_RES
            OUTPUT_VARIABLE TOTAL_MSGID_OUT OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_VARIABLE  TOTAL_MSGID_ERR ERROR_STRIP_TRAILING_WHITESPACE)
        if (TOTAL_MSGID_RES EQUAL 0)
            if (TOTAL_MSGID_OUT)
                string(REGEX MATCHALL "msgid" TOTAL_MSGID_MATCHES "${TOTAL_MSGID_OUT}")
                list(LENGTH TOTAL_MSGID_MATCHES TOTAL_MSGID_COUNT)
                math(EXPR TOTAL_MSGID_COUNT "${TOTAL_MSGID_COUNT} - 1") # Subtract 1 for the header msgid
                math(EXPR NUM_OF_MSGID_TOTAL "${NUM_OF_MSGID_TOTAL} + ${TOTAL_MSGID_COUNT}")
            else()
                set(TOTAL_MSGID_COUNT 0)
            endif()
        else()
            string(APPEND FAILURE_REASON
            "The command failed with fatal errors.\n"
            "    result:\n${TOTAL_MSGID_RES}\n"
            "    stdout:\n${TOTAL_MSGID_OUT}\n"
            "    stderr:\n${TOTAL_MSGID_ERR}")
            message(FATAL_ERROR "${FAILURE_REASON}")
        endif()
        #
        # Calculate the "translated" msgid entries.
        #
        execute_process(
            COMMAND ${Gettext_MSGATTRIB_EXECUTABLE} --translated ${PO_FILE}
            RESULT_VARIABLE TRANSLATED_MSGID_RES
            OUTPUT_VARIABLE TRANSLATED_MSGID_OUT OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_VARIABLE  TRANSLATED_MSGID_ERR ERROR_STRIP_TRAILING_WHITESPACE)
        if (TRANSLATED_MSGID_RES EQUAL 0)
            if (TRANSLATED_MSGID_OUT)
                string(REGEX MATCHALL "msgid" TRANSLATED_MSGID_MATCHES "${TRANSLATED_MSGID_OUT}")
                list(LENGTH TRANSLATED_MSGID_MATCHES TRANSLATED_MSGID_COUNT)
                math(EXPR TRANSLATED_MSGID_COUNT "${TRANSLATED_MSGID_COUNT} - 1") # Subtract 1 for the header msgid
                math(EXPR NUM_OF_MSGID_TRANSLATED "${NUM_OF_MSGID_TRANSLATED} + ${TRANSLATED_MSGID_COUNT}")
            else()
                set(TRANSLATED_MSGID_COUNT 0)
            endif()
        else()
            string(APPEND FAILURE_REASON
            "The command failed with fatal errors.\n"
            "    result:\n${TRANSLATED_MSGID_RES}\n"
            "    stdout:\n${TRANSLATED_MSGID_OUT}\n"
            "    stderr:\n${TRANSLATED_MSGID_ERR}")
            message(FATAL_ERROR "${FAILURE_REASON}")
        endif()
        #
        # Calculate the "fuzzy" msgid entries.
        #
        execute_process(
            COMMAND ${Gettext_MSGATTRIB_EXECUTABLE} --only-fuzzy --no-obsolete ${PO_FILE}
            RESULT_VARIABLE FUZZY_MSGID_RES
            OUTPUT_VARIABLE FUZZY_MSGID_OUT OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_VARIABLE  FUZZY_MSGID_ERR ERROR_STRIP_TRAILING_WHITESPACE)
        if (FUZZY_MSGID_RES EQUAL 0)
            if (FUZZY_MSGID_OUT)
                string(REGEX MATCHALL "msgid" FUZZY_MSGID_MATCHES ${FUZZY_MSGID_OUT})
                list(LENGTH FUZZY_MSGID_MATCHES FUZZY_MSGID_COUNT)
                math(EXPR FUZZY_MSGID_COUNT "${FUZZY_MSGID_COUNT} - 1") # Subtract 1 for the header msgid
                math(EXPR NUM_OF_MSGID_FUZZY "${NUM_OF_MSGID_FUZZY} + ${FUZZY_MSGID_COUNT}")
                return()
            else()
                set(FUZZY_MSGID_COUNT 0)
            endif()
        else()
            string(APPEND FAILURE_REASON
            "The command failed with fatal errors.\n"
            "    result:\n${FUZZY_MSGID_RES}\n"
            "    stdout:\n${FUZZY_MSGID_OUT}\n"
            "    stderr:\n${FUZZY_MSGID_ERR}")
            message(FATAL_ERROR "${FAILURE_REASON}")
        endif()
        #
        #
        #
        if (NOT TOTAL_MSGID_RES AND NOT TRANSLATED_MSGID_RES)
            math(EXPR TRANSLATED_MSGID_PCT "100 * ${TRANSLATED_MSGID_COUNT} / ${TOTAL_MSGID_COUNT}")
            #
            # Prepend leading whitespaces to the 'PERCENTAGE_STR' until its length is ${CSIOG_IN_PADDING_LENGTH}.
            #
            set(PERCENTAGE_STR "${TRANSLATED_MSGID_PCT}")
            string(LENGTH "${PERCENTAGE_STR}" PERCENTAGE_LEN)
            while("${PERCENTAGE_LEN}" LESS ${CSIOG_IN_PADDING_LENGTH})
                string(PREPEND PERCENTAGE_STR " ")
                string(LENGTH "${PERCENTAGE_STR}" PERCENTAGE_LEN)
            endwhile()
            #
            # Prepend leading whitespaces to the 'TRANSLATED_MSGID_STR' until its length is ${CSIOG_IN_PADDING_LENGTH}.
            #
            set(TRANSLATED_MSGID_STR "${TRANSLATED_MSGID_COUNT}")
            string(LENGTH "${TRANSLATED_MSGID_STR}" TRANSLATED_MSGID_LEN)
            while("${TRANSLATED_MSGID_LEN}" LESS ${CSIOG_IN_PADDING_LENGTH})
                string(PREPEND TRANSLATED_MSGID_STR " ")
                string(LENGTH "${TRANSLATED_MSGID_STR}" TRANSLATED_MSGID_LEN)
            endwhile()
            #
            # Prepend leading whitespaces to the 'TOTAL_MSGID_STR' until its length is ${CSIOG_IN_PADDING_LENGTH}.
            #
            set(TOTAL_MSGID_STR "${TOTAL_MSGID_COUNT}")
            string(LENGTH "${TOTAL_MSGID_STR}" TOTAL_MSGID_LEN)
            while("${TOTAL_MSGID_LEN}" LESS ${CSIOG_IN_PADDING_LENGTH})
                string(PREPEND TOTAL_MSGID_STR " ")
                string(LENGTH "${TOTAL_MSGID_STR}" TOTAL_MSGID_LEN)
            endwhile()
            #
            # Example out:
            # - [  0%][  0/ 99] path/to/po/file
            # - [ 30%][ 33/ 99] path/to/po/file
            # - [100%][ 99/ 99] path/to/po/file
            #
            message("[${PERCENTAGE_STR}%][${TRANSLATED_MSGID_STR}/${TOTAL_MSGID_STR}] ${PO_FILE}")
            #
            # Increment counters
            #
            if (TRANSLATED_MSGID_PCT EQUAL 100)
                math(EXPR NUM_OF_PO_COMPLETED "${NUM_OF_PO_COMPLETED} + 1")
            elseif (TRANSLATED_MSGID_PCT EQUAL 0)
                math(EXPR NUM_OF_PO_UNSTARTED "${NUM_OF_PO_UNSTARTED} + 1")
            else()
                math(EXPR NUM_OF_PO_PROGRESSING "${NUM_OF_PO_PROGRESSING} + 1")
            endif()
            math(EXPR NUM_OF_PO_TOTAL "${NUM_OF_PO_TOTAL} + 1")
        else()
            message(WARNING "Failed to get msgid counts for ${PO_FILE}.")
        endif()
    endforeach()
    unset(PO_FILE)
    math(EXPR NUM_OF_MSGID_UNTRANSLATED "${NUM_OF_MSGID_TOTAL} - ${NUM_OF_MSGID_TRANSLATED}")
    math(EXPR PCT_OF_PO_COMPLETED "(${NUM_OF_PO_COMPLETED} * 100) / ${NUM_OF_PO_TOTAL}")
    math(EXPR PCT_OF_MSGID_TRANSLATED "(${NUM_OF_MSGID_TRANSLATED} * 100) / ${NUM_OF_MSGID_TOTAL}")
    #
    # Return the content of ${NUM_OF_PO_COMPLETED}      to the argument of OUT_NUM_OF_PO_COMPLETED.
    # Return the content of ${NUM_OF_PO_PROGRESSING}    to the argument of OUT_NUM_OF_PO_PROGRESSING.
    # Return the content of ${NUM_OF_PO_UNSTARTED}      to the argument of OUT_NUM_OF_PO_UNSTARTED.
    # Return the content of ${NUM_OF_PO_TOTAL}          to the argument of OUT_NUM_OF_PO_TOTAL.
    # Return the content of ${PCT_OF_PO_COMPLETED}      to the argument of OUT_PCT_OF_PO_COMPLETED.
    # Return the content of ${NUM_OF_MSGID_TRANSLATED}  to the argument of OUT_NUM_OF_MSGID_TRANSLATED.
    # Return the content of ${NUM_OF_MSGID_FUZZY}       to the argument of OUT_NUM_OF_MSGID_FUZZY.
    # Return the content of ${NUM_OF_MSGID_TOTAL}       to the argument of OUT_NUM_OF_MSGID_TOTAL.
    # Return the content of ${PCT_OF_MSGID_TRANSLATED}  to the argument of OUT_PCT_OF_MSGID_TRANSLATED.
    #
    set(${CSIOG_OUT_NUM_OF_PO_COMPLETED}      "${NUM_OF_PO_COMPLETED}"      PARENT_SCOPE)
    set(${CSIOG_OUT_NUM_OF_PO_PROGRESSING}    "${NUM_OF_PO_PROGRESSING}"    PARENT_SCOPE)
    set(${CSIOG_OUT_NUM_OF_PO_UNSTARTED}      "${NUM_OF_PO_UNSTARTED}"      PARENT_SCOPE)
    set(${CSIOG_OUT_NUM_OF_PO_TOTAL}          "${NUM_OF_PO_TOTAL}"          PARENT_SCOPE)
    set(${CSIOG_OUT_PCT_OF_PO_COMPLETED}      "${PCT_OF_PO_COMPLETED}"      PARENT_SCOPE)
    set(${CSIOG_OUT_NUM_OF_MSGID_TRANSLATED}  "${NUM_OF_MSGID_TRANSLATED}"  PARENT_SCOPE)
    set(${CSIOG_OUT_NUM_OF_MSGID_FUZZY}       "${NUM_OF_MSGID_FUZZY}"       PARENT_SCOPE)
    set(${CSIOG_OUT_NUM_OF_MSGID_TOTAL}       "${NUM_OF_MSGID_TOTAL}"       PARENT_SCOPE)
    set(${CSIOG_OUT_PCT_OF_MSGID_TRANSLATED}  "${PCT_OF_MSGID_TRANSLATED}"  PARENT_SCOPE)
endfunction()


function(copy_po_from_src_to_dst)
    #
    # Parse arguments.
    #
    set(OPTIONS)
    set(ONE_VALUE_ARGS      IN_SRC_DIR
                            IN_DST_DIR)
    set(MULTI_VALUE_ARGS)
    cmake_parse_arguments(CPFSTD
        "${OPTIONS}"
        "${ONE_VALUE_ARGS}"
        "${MULTI_VALUE_ARGS}"
        ${ARGN})
    #
    # Ensure all required arguments are provided.
    #
    set(REQUIRED_ARGS       IN_SRC_DIR
                            IN_DST_DIR)
    foreach(ARG ${REQUIRED_ARGS})
        if (NOT DEFINED CPFSTD_${ARG})
            message(FATAL_ERROR "Missing ${ARG} argument.")
        endif()
    endforeach()
    #
    # Copy all .po files from the source directory to the destination directory.
    #
    file(GLOB_RECURSE PO_SRC_FILES "${CPFSTD_IN_SRC_DIR}/*.po")
    foreach(PO_SRC_FILE ${PO_SRC_FILES})
        string(REPLACE "${CPFSTD_IN_SRC_DIR}/" "" PO_SRC_FILE_RELATIVE "${PO_SRC_FILE}")
        set(PO_DST_FILE "${CPFSTD_IN_DST_DIR}/${PO_SRC_FILE_RELATIVE}")
        get_filename_component(PO_DST_FILE_DIR "${PO_DST_FILE}" DIRECTORY)
        file(MAKE_DIRECTORY "${PO_DST_FILE_DIR}")
        file(COPY_FILE "${PO_SRC_FILE}" "${PO_DST_FILE}" RESULT RES_VAR)
        message("Copied: ${PO_DST_FILE}")
    endforeach()
    unset(PO_SRC_FILE)
endfunction()
