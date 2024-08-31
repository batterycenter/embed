
function(add_example TARGET)
    add_executable(${TARGET} src/main.cpp)
    target_compile_features(${TARGET} PRIVATE cxx_std_20)
    source_group("src" FILES src/main.cpp)
    target_compile_options(${TARGET} PRIVATE
            $<$<CXX_COMPILER_ID:MSVC>:/W4 /WX>
            $<$<NOT:$<CXX_COMPILER_ID:MSVC>>:-Wall -Wextra -Wpedantic -Werror>
    )
endfunction()

add_subdirectory(binaryfile)
add_subdirectory(generatedfile)
add_subdirectory(filewatcher)
add_subdirectory(multifile)
add_subdirectory(multitarget)
add_subdirectory(simple)
add_subdirectory(subdirectory)

add_custom_target(run_all_examples)
add_dependencies(run_all_examples
        binaryfile
        filewatcher
        generatedfile
        multifile
        multitarget1
        multitarget2
        multitarget3
        simple
        subdirectory
)

add_custom_command(
        TARGET run_all_examples
        POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E echo "Running Example binaryfile ..."
        COMMAND $<TARGET_FILE:binaryfile>
        COMMAND ${CMAKE_COMMAND} -E echo "Running Example filewatcher ..."
        COMMAND $<TARGET_FILE:filewatcher>
        COMMAND ${CMAKE_COMMAND} -E echo "Running Example generatedfile ..."
        COMMAND $<TARGET_FILE:generatedfile>
        COMMAND ${CMAKE_COMMAND} -E echo "Running Example multifile ..."
        COMMAND $<TARGET_FILE:multifile>
        COMMAND ${CMAKE_COMMAND} -E echo "Running Example multitarget1 ..."
        COMMAND $<TARGET_FILE:multitarget1>
        COMMAND ${CMAKE_COMMAND} -E echo "Running Example multitarget2 ..."
        COMMAND $<TARGET_FILE:multitarget2>
        COMMAND ${CMAKE_COMMAND} -E echo "Running Example multitarget3 ..."
        COMMAND $<TARGET_FILE:multitarget3>
        COMMAND ${CMAKE_COMMAND} -E echo "Running Example simple ..."
        COMMAND $<TARGET_FILE:simple>
        COMMAND ${CMAKE_COMMAND} -E echo "Running Example subdirectory ..."
        COMMAND $<TARGET_FILE:subdirectory>
        COMMAND ${CMAKE_COMMAND} -E echo "Done running all examples."
)