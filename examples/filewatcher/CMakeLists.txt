
add_executable(filewatcher src/main.cpp)
target_compile_features(filewatcher PRIVATE cxx_std_20)
source_group("src" FILES src/main.cpp)

b_embed(filewatcher resources/config.json)
