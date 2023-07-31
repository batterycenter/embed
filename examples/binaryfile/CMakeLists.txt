
add_executable(binaryfile src/main.cpp)
target_compile_features(binaryfile PRIVATE cxx_std_14)
source_group("src" FILES src/main.cpp)

embed_binary(binaryfile resources/worldwide.png Icon)