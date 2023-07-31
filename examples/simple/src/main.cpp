
#include <iostream>
#include "Embed/MyResource/Data/Message.hpp"
#include "Embed/MyResource/Banner.hpp"

int main() {
    std::cout << "Running example 'simple'" << std::endl;
    std::cout << "Embedded file: \n" << Embed::MyResource::Banner << std::endl;
    return 0;
}