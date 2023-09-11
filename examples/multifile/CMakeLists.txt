
add_executable(multifile src/main.cpp)
target_compile_features(multifile PRIVATE cxx_std_20)

source_group("src" FILES src/main.cpp)

b_embed(multifile resources/message.txt)
b_embed(multifile resources/FirstFolder/config.json)
b_embed(multifile resources/FirstFolder/templates/template.txt)