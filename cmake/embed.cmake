set_property(GLOBAL PROPERTY USE_FOLDERS ON)
set(_EMBED_USED_IDENTIFIERS "" CACHE INTERNAL "list of all identifiers used by the embed library")

# Remember the source directory of this library
get_filename_component(_EMBED_SOURCE_DIR "${CMAKE_CURRENT_LIST_DIR}" DIRECTORY)
set(_EMBED_SOURCE_DIR ${_EMBED_SOURCE_DIR} CACHE INTERNAL "source directory of the embed library")

# We need Python as a strict build dependency
find_package(Python3 COMPONENTS Interpreter)
if (NOT Python3_Interpreter_FOUND)
    message(FATAL_ERROR "Python3 not found. Please install it using your package manager or download it from https://www.python.org/downloads/")
endif()

# We need the Python module 'jinja2' as a strict build dependency
execute_process(COMMAND "${Python3_EXECUTABLE}" "-c" "import jinja2" OUTPUT_QUIET ERROR_QUIET RESULT_VARIABLE Python3_Jinja2_Result)
if (NOT Python3_Jinja2_Result EQUAL 0)
    message(FATAL_ERROR "Python module 'jinja2' not found. Please install it using \n'pip install jinja2'")
endif()
set(_EMBED_PYTHON_EXECUTABLE "${Python3_EXECUTABLE}" CACHE INTERNAL "Python executable used by the embed library")

function(embed_validate_identifier IDENTIFIER)  # Validate the identifier against C variable naming rules
    if (NOT IDENTIFIER MATCHES "^[a-zA-Z_][a-zA-Z0-9_]*$")
        message(FATAL_ERROR "embed: Identifier contains invalid characters: '${IDENTIFIER}'")
    endif()
endfunction()

function(embed TARGET RESOURCE_FILE FILEMODE FULL_IDENTIFIER)
    get_filename_component(RESOURCE_FILE "${RESOURCE_FILE}" ABSOLUTE) # Make the file path absolute
    get_filename_component(RESOURCE_FOLDER "${RESOURCE_FILE}" DIRECTORY)  # Get the resource file's parent directory

    STRING(REGEX REPLACE "/" "_" IDENTIFIER "${FULL_IDENTIFIER}")
    embed_validate_identifier("${IDENTIFIER}")
    get_filename_component(IDENTIFIER_FOLDERS_SLASH "${FULL_IDENTIFIER}" DIRECTORY) # Remove the filename of the identifier to get the parent folders
    STRING(REGEX REPLACE "/" ";" IDENTIFIER_NAMESPACES "${IDENTIFIER_FOLDERS_SLASH}")
    get_filename_component(FILE_IDENTIFIER "${FULL_IDENTIFIER}" NAME) # Remove the folders from the identifier to get just the identifier-filename

    # If identifier already in use
    list(FIND _EMBED_USED_IDENTIFIERS ${IDENTIFIER} EMBED_USED_IDENTIFIERS_INDEX)
    if (NOT EMBED_USED_IDENTIFIERS_INDEX EQUAL -1)
        message(FATAL_ERROR "embed: Identifier already in use: '${IDENTIFIER}'")
    endif()
    set(_EMBED_USED_IDENTIFIERS ${_EMBED_USED_IDENTIFIERS} ${IDENTIFIER} CACHE INTERNAL "list of all identifiers used by the embed library")

    target_sources(${TARGET} PUBLIC ${RESOURCE_FILE})
    source_group(TREE "${RESOURCE_FOLDER}" PREFIX "resources/${IDENTIFIER_FOLDERS_SLASH}" FILES ${RESOURCE_FILE})

    if (NOT FILEMODE STREQUAL "BINARY" AND NOT FILEMODE STREQUAL "TEXT")
        message(FATAL_ERROR "embed: Invalid file mode: '${FILEMODE}'. Valid modes are 'BINARY' and 'TEXT'")
    endif()

    # The filepaths of the files to be generated
    set(OUTPUT_HEADER ${CMAKE_CURRENT_BINARY_DIR}/embedded_files/Embed/${IDENTIFIER_FOLDERS_SLASH}${FILE_IDENTIFIER}.hpp)
    set(OUTPUT_SOURCE ${CMAKE_CURRENT_BINARY_DIR}/embedded_files/Embed/${IDENTIFIER_FOLDERS_SLASH}${FILE_IDENTIFIER}.cpp)

    set(EMBED_PY_SCRIPT "${_EMBED_SOURCE_DIR}/scripts/embed.py")
    set(EMBED_COMMAND "${_EMBED_PYTHON_EXECUTABLE}"
        "${EMBED_PY_SCRIPT}"
        "${OUTPUT_HEADER}"
        "${OUTPUT_SOURCE}"
        "${RESOURCE_FILE}"
        "${FILEMODE}"
        "${IDENTIFIER}"
        "${FULL_IDENTIFIER}"
        "${FILE_IDENTIFIER}"
        --identifier-namespaces "${IDENTIFIER_NAMESPACES}"
        --additional-header-files "${EMBED_ADDITIONAL_HEADER_FILES}"
        --additional-string-classes "${EMBED_ADDITIONAL_STRING_CLASSES}"
        --additional-operators "${EMBED_ADDITIONAL_OPERATORS}"
    )

    # This action generates both files and is called on-demand whenever the resource file changes
    add_custom_command(
        COMMAND ${EMBED_COMMAND}
        DEPENDS "${RESOURCE_FILE}" 
            "${_EMBED_SOURCE_DIR}/templates/header.hpp" 
            "${_EMBED_SOURCE_DIR}/templates/source.cpp" 
            "${_EMBED_SOURCE_DIR}/cmake/embed.cmake" 
            "${EMBED_PY_SCRIPT}"
        OUTPUT "${OUTPUT_HEADER}" "${OUTPUT_SOURCE}"
        WORKING_DIRECTORY ${_EMBED_SOURCE_DIR}
    )

    # Add the generated files to the target
    target_include_directories(${TARGET} PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/embedded_files")
    target_sources(${TARGET} PRIVATE "${OUTPUT_HEADER}" "${OUTPUT_SOURCE}")
    source_group(TREE ${CMAKE_CURRENT_BINARY_DIR}/embedded_files/Embed/ PREFIX "autogen" FILES "${OUTPUT_HEADER}" "${OUTPUT_SOURCE}")
    
endfunction()

function(embed_text TARGET RESOURCE_FILE FULL_IDENTIFIER)
    embed(${TARGET} "${RESOURCE_FILE}" "TEXT" "${FULL_IDENTIFIER}")
endfunction()

function(embed_binary TARGET RESOURCE_FILE FULL_IDENTIFIER)
    embed(${TARGET} "${RESOURCE_FILE}" "BINARY" "${FULL_IDENTIFIER}")
endfunction()