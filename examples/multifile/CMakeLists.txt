
add_executable(multifile src/main.cpp)
target_compile_features(multifile PRIVATE cxx_std_17)

source_group("src" FILES src/main.cpp)

embed_text(multifile resources/message.txt Message)
embed_text(multifile resources/FirstFolder/config.json FirstFolder/ConfigJson)
embed_text(multifile resources/FirstFolder/templates/template.txt FirstFolder/templates/Template)