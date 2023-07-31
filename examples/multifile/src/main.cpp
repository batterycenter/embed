
#include <iostream>
#include "Embed/Message.hpp"
#include "Embed/FirstFolder/ConfigJson.hpp"
#include "Embed/FirstFolder/templates/Template.hpp"

int main() {
    std::cout << std::endl << "[main.cpp] This is: resources/message.txt" << std::endl;
    std::cout << Embed::Message << std::endl;

    std::cout << std::endl << "[main.cpp] This is: resources/FirstFolder/config.json" << std::endl;
    std::cout << Embed::FirstFolder::ConfigJson << std::endl;
    
    std::cout << std::endl << "[main.cpp] This is: resources/FirstFolder/templates/template.txt" << std::endl;
    std::cout << Embed::FirstFolder::templates::Template << std::endl;
    
    return 0;
}