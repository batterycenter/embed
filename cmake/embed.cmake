set_property(GLOBAL PROPERTY USE_FOLDERS ON)

# Remember the source directory of this library
get_filename_component(EMBED_SOURCE_DIR "${CMAKE_CURRENT_LIST_DIR}" DIRECTORY)
set(EMBED_SOURCE_DIR ${EMBED_SOURCE_DIR} CACHE INTERNAL "source directory of the embed library")

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

function(embed_validate_identifier IDENTIFIER)  # Validate the identifier against C variable naming rules
    if (NOT IDENTIFIER MATCHES "^[a-zA-Z_][a-zA-Z0-9_]*$")
        message(FATAL_ERROR "embed: Identifier contains invalid characters: '${IDENTIFIER}'")
    endif()
endfunction()

function(embed TARGET FILEPATH FILEMODE IDENTIFIER)
    get_filename_component(FILEPATH "${FILEPATH}" ABSOLUTE) # Make the file path absolute
    embed_validate_identifier("${IDENTIFIER}")

    target_sources(${TARGET} PUBLIC ${FILEPATH})
    source_group("resources" FILES ${FILEPATH})

    execute_process(COMMAND 
        "${Python3_EXECUTABLE}" 
        "${EMBED_SOURCE_DIR}/scripts/embed.py" 
        "${FILEPATH}" 
        "${FILEMODE}" 
        "${IDENTIFIER}" 
        # OUTPUT_VARIABLE EMBEDDED_FILE
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    
endfunction()