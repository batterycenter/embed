
add_executable(simple src/main.cpp)
target_compile_features(simple PRIVATE cxx_std_20)

source_group("src" FILES src/main.cpp)

b_embed(simple resources/banner.txt Banner)