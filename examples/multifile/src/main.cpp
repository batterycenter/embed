
#include <iostream>
#include "battery/embed.hpp"

int main() {
    std::cout << std::endl << "[main.cpp] This is: resources/message.txt" << std::endl;
    std::cout << b::embed<"resources/message.txt">() << std::endl;

    std::cout << std::endl << "[main.cpp] This is: resources/FirstFolder/config.json" << std::endl;
    std::cout << b::embed<"resources/FirstFolder/config.json">() << std::endl;
    
    std::cout << std::endl << "[main.cpp] This is: resources/FirstFolder/templates/template.txt" << std::endl;
    std::cout << b::embed<"resources/FirstFolder/templates/template.txt">() << std::endl;
    
    return 0;
}