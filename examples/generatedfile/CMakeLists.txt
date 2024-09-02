function(embed_extracted_file TARGET)
    set(RESOURCES_DIR "${CMAKE_CURRENT_SOURCE_DIR}/resources")
    set(ARCHIVE_FILE_PATH "${RESOURCES_DIR}/helloworld.zip")
    set(EXTRACTED_FILE_PATH "${RESOURCES_DIR}/helloworld.txt")
    add_custom_command(
        OUTPUT ${EXTRACTED_FILE_PATH}
        COMMAND ${CMAKE_COMMAND} -E tar xzf ${ARCHIVE_FILE_PATH} "helloworld.txt"
        DEPENDS ${ARCHIVE_FILE_PATH}
        WORKING_DIRECTORY ${RESOURCES_DIR}
    )
    add_custom_target(extractedfile
        DEPENDS ${EXTRACTED_FILE_PATH}
    )
    add_dependencies(${TARGET} extractedfile)
    file(RELATIVE_PATH EXTRACTED_RELATIVE_FILE_PATH ${CMAKE_CURRENT_SOURCE_DIR} ${EXTRACTED_FILE_PATH})
    b_embed(${TARGET} ${EXTRACTED_RELATIVE_FILE_PATH} DEPENDENCIES ${extractedfile})
endfunction(embed_extracted_file)

add_example(generatedfile)
embed_extracted_file(generatedfile)
