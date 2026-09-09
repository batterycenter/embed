cmake_minimum_required(VERSION 3.21)
set_property(GLOBAL PROPERTY USE_FOLDERS ON)
project(embed LANGUAGES CXX)

# Options
option(B_EMBED_BUILD_EXAMPLES "Build battery::embed examples" ${PROJECT_IS_TOP_LEVEL})
option(B_PRODUCTION_MODE "Enable production mode and disable development tools such as hotreload" OFF)
option(B_EMBED_SILENCE_DEVMODE_WARNING "Disable the battery::embed devmode warning" OFF)

# Remember the binary dir for later
set(EMBED_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/embed CACHE INTERNAL "binary directory of the battery::embed library" FORCE)
set(EMBED_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR} CACHE INTERNAL "source directory of the battery::embed library" FORCE)

set(EMBED_IDENTIFIERS "" CACHE INTERNAL "list of all identifiers used by battery::embed")
set(EMBED_FILENAMES "" CACHE INTERNAL "list of all filenames used by battery::embed")
set(EMBED_TARGETS "" CACHE INTERNAL "list of all targets used by battery::embed")

# Defer the function call until the end of the configure step
cmake_language(DEFER DIRECTORY ${CMAKE_SOURCE_DIR} CALL _embed_generate_all_hpps())
function(_embed_generate_all_hpps)
    message(STATUS "Generating b::embed() HPP files ...")
    foreach (TARGET ${EMBED_TARGETS})
        _embed_generate_hpp(${TARGET})
    endforeach()
    message(STATUS "Generating b::embed() HPP files ... Done")
endfunction(_embed_generate_all_hpps)

function(_embed_generate_hpp TARGET)
    string(TOLOWER "${TARGET}" TARGET)
    string(REGEX REPLACE "[^a-zA-Z0-9_]" "_" TARGET "${TARGET}")

    if (NOT EMBED_IDENTIFIERS)
        return()
    endif()
    set(EMBEDDED_FILES_DECLARATIONS "")
    list(LENGTH EMBED_IDENTIFIERS num_identifiers)
    foreach (IDENTIFIER IN LISTS EMBED_IDENTIFIERS)
        if (IDENTIFIER MATCHES "^${TARGET}_")
            set(EMBEDDED_FILES_DECLARATIONS "${EMBEDDED_FILES_DECLARATIONS}static EmbeddedFile ${IDENTIFIER};\n        ")
        endif()
    endforeach()
    set(EMBEDDED_FILES_RETURNS "")
    math(EXPR num_identifiers "${num_identifiers} - 1")
    foreach (INDEX RANGE ${num_identifiers})
        list(GET EMBED_IDENTIFIERS ${INDEX} IDENTIFIER)
        list(GET EMBED_FILENAMES ${INDEX} FILENAME)
        if (IDENTIFIER MATCHES "^${TARGET}_")
            set(EMBEDDED_FILES_RETURNS "${EMBEDDED_FILES_RETURNS}if constexpr (identifier == \"${FILENAME}\") { return EmbedInternal::${IDENTIFIER}; }\n        else ")
        endif()
    endforeach()
    set(EMBED_HPP "${EMBED_BINARY_DIR}/autogen/${TARGET}/include/battery/embed.hpp")
    configure_file(
        "${EMBED_SOURCE_DIR}/script/embed_header_file_template.hpp"
        "${EMBED_HPP}")
endfunction(_embed_generate_hpp)

# Internal function for validating an identifier
function(embed_validate_identifier IDENTIFIER)  # Validate the identifier against C variable naming rules
    if (NOT IDENTIFIER MATCHES "^[a-zA-Z_][a-zA-Z0-9_]*$")
        message(FATAL_ERROR "embed: Identifier contains invalid characters: '${IDENTIFIER}'")
    endif()
endfunction()

# The main function for embedding files
function(b_embed TARGET FILENAME)
    string(TOLOWER "${TARGET}" TARGET_ID)
    string(REGEX REPLACE "[^a-zA-Z0-9_]" "_" TARGET_ID "${TARGET_ID}")

    if (IS_ABSOLUTE "${FILENAME}")
        message(FATAL_ERROR "embed: File name must be relative to the current source directory: '${FILENAME}'")
    endif()

    # Make the identifier
    string(TOLOWER "${TARGET_ID}_${FILENAME}" IDENTIFIER)
    string(REGEX REPLACE "[^a-zA-Z0-9_]" "_" IDENTIFIER "${IDENTIFIER}") # Replace all invalid characters with underscores
    embed_validate_identifier("${IDENTIFIER}") # Validate the identifier against C variable naming rules

    # Set up paths
    get_filename_component(FULL_PATH "${FILENAME}" ABSOLUTE) # Make the file path absolute
    set(CPP_FILE "${EMBED_BINARY_DIR}/autogen/${TARGET_ID}/src/${IDENTIFIER}.cpp")

    # If identifier already in use
    list(FIND EMBED_IDENTIFIERS ${IDENTIFIER} EMBED_USED_IDENTIFIERS_INDEX)
    if (NOT EMBED_USED_IDENTIFIERS_INDEX EQUAL -1)
        message(FATAL_ERROR "embed: Identifier already in use: '${IDENTIFIER}'")
    endif()
    set(EMBED_IDENTIFIERS ${EMBED_IDENTIFIERS} ${IDENTIFIER} CACHE INTERNAL "list of all identifiers used by the embed library")
    set(EMBED_FILENAMES ${EMBED_FILENAMES} ${FILENAME} CACHE INTERNAL "list of all filenames used by the embed library")
    set(EMBED_TARGETS ${EMBED_TARGETS} ${TARGET} CACHE INTERNAL "list of all targets used by the embed library")

    # This action generates both files and is called on-demand whenever the resource file changes
    set(EMBED_HPP "${EMBED_BINARY_DIR}/autogen/${TARGET_ID}/include/battery/embed.hpp")
    set(EMBED_CPP_TEMPLATE "${EMBED_SOURCE_DIR}/script/embed_source_file_template.cpp")
    add_custom_command(
            COMMAND ${CMAKE_COMMAND}
                -DINFILE=${EMBED_CPP_TEMPLATE}
                -DOUTFILE=${CPP_FILE}
                -DFULL_PATH=${FULL_PATH}
                -DIDENTIFIER=${IDENTIFIER}
                -DFILENAME=${FILENAME}
                -P "${EMBED_SOURCE_DIR}/script/generate.cmake"
            DEPENDS "${FULL_PATH}" "${EMBED_HPP}" "${EMBED_SOURCE_DIR}/script/generate.cmake" "${EMBED_SOURCE_DIR}/script/embed_source_file_template.cpp"
            OUTPUT ${CPP_FILE}
            VERBATIM
    )

    # Add the generated files to the target
    target_include_directories(${TARGET} PUBLIC 
        $<BUILD_INTERFACE:${EMBED_BINARY_DIR}/autogen/${TARGET_ID}/include>
        $<INSTALL_INTERFACE:>
    )
    target_sources(${TARGET} PRIVATE ${CPP_FILE} ${EMBED_SOURCE_DIR}/script/embed_impl.cpp ${EMBED_HPP})
    target_compile_definitions(${TARGET} PRIVATE _SILENCE_CXX17_CODECVT_HEADER_DEPRECATION_WARNING)

    if (NOT B_PRODUCTION_MODE)
        find_package(Threads REQUIRED)
        target_link_libraries(${TARGET} PRIVATE Threads::Threads)
    else ()
        target_compile_definitions(${TARGET} PUBLIC B_PRODUCTION_MODE)
    endif ()

    if (MSVC)
        target_sources(${TARGET} PRIVATE ${FULL_PATH})
        source_group(TREE ${EMBED_BINARY_DIR}/autogen/${TARGET_ID}/src PREFIX "embed/autogen" FILES ${CPP_FILE})
        source_group(TREE ${EMBED_BINARY_DIR} PREFIX "embed/autogen" FILES ${EMBED_SOURCE_DIR}/script/embed_impl.cpp)
        source_group(TREE ${EMBED_BINARY_DIR}/autogen/${TARGET_ID}/include/battery PREFIX "embed/autogen" FILES ${EMBED_HPP})
        source_group(TREE "${CMAKE_CURRENT_SOURCE_DIR}" PREFIX "/embed" FILES ${FULL_PATH})
    endif()

endfunction()

function(b_embed_proxy_target MAIN_TARGET PROXY_TARGET)
    add_library(${PROXY_TARGET} STATIC)
    target_compile_features(${PROXY_TARGET} PUBLIC cxx_std_20)
    target_link_libraries(${MAIN_TARGET} PRIVATE ${PROXY_TARGET})
    set_target_properties(${PROXY_TARGET} PROPERTIES FOLDER "embed-proxy-targets")
endfunction()

# Build all examples
if (B_EMBED_BUILD_EXAMPLES)
    add_subdirectory(examples)      # Set Example 'simple' as the default project in Visual Studio
    set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT simple)
endif()

# Set the predefined targets folder for Visual Studio
if (PROJECT_IS_TOP_LEVEL)
    set(PREDEFINED_TARGETS_FOLDER "CMakePredefinedTargets")
endif()

if (NOT B_EMBED_SILENCE_DEVMODE_WARNING AND NOT B_PRODUCTION_MODE)
    message(WARNING "Battery::Embed is in development mode, enabling hotreload. Before deploying your application, use -DB_PRODUCTION_MODE=ON to strip all development features such as hotreload and absolute filepaths.")
endif ()
