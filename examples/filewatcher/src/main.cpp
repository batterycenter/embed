
#include "battery/embed.hpp"
#include <iostream>
#include <thread>

int main() {
    std::string file;

    // This lambda is called from another thread every time the file changes on-disk, 
    // and in production mode, it is called immediately from the same thread, once.
    b::embed<"resources/config.json">().get([&file] (const auto& content) {
        file = content.str();
        std::cout << "File changed: " << file << std::endl;
    });
    
    while (true) {
        // Do something with file
        std::this_thread::sleep_for(std::chrono::seconds(1));
    }
    return 0;
}
