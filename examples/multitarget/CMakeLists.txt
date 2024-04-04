
source_group("src" FILES src/target1.cpp)

add_executable(multitarget1 src/target1.cpp)
target_compile_features(multitarget1 PRIVATE cxx_std_20)
b_embed(multitarget1 resources/message.txt)
b_embed(multitarget1 resources/FirstFolder/config.json)

add_executable(multitarget2 src/target2.cpp)
target_compile_features(multitarget2 PRIVATE cxx_std_20)
b_embed(multitarget2 resources/message.txt)
b_embed(multitarget2 resources/FirstFolder/config.json)

add_executable(multitarget3 src/target3.cpp)
target_compile_features(multitarget3 PRIVATE cxx_std_20)
b_embed(multitarget3 resources/message.txt)
b_embed(multitarget3 resources/FirstFolder/config.json)