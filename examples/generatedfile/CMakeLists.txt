
set(RESOURCES_DIR "${CMAKE_CURRENT_SOURCE_DIR}/resources")
set(ARCHIVE_FILE_PATH "${RESOURCES_DIR}/helloworld.zip")

add_example(generatedfile)

add_custom_command(
    COMMAND ${CMAKE_COMMAND} -E tar xzf ${ARCHIVE_FILE_PATH} "helloworld.txt"
    DEPENDS ${ARCHIVE_FILE_PATH}
    OUTPUT "${RESOURCES_DIR}/helloworld.txt"
    WORKING_DIRECTORY ${RESOURCES_DIR}
)
b_embed(generatedfile "resources/helloworld.txt")