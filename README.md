# battery-embed
![](https://github.com/batterycenter/embed/actions/workflows/examples.yml/badge.svg)

Embedding files into executables made easy. Single CMake file, Modern C++, a minute of setup time. What else?

## What is this?

This is a CMake-based C++20 library that allows you to very easily embed resource files 
into your executable. It is meant to be used for files such as icons, images, shader code, 
configuration files, etc.. You don't have to worry about distributing them with your application 
as the files are part of the application once compiled. It might also be an advantage that an end 
user cannot modify the files once shipped. You can develop your application data in conventional 
files in your favourite text editor (your IDE) and don't have to deal with multi-line 
C++ strings or converting files using external tool. Conversion is fully automatic.

This library is developed in the context of [Battery](https://github.com/batterycenter/battery). 
The feature set might make more sense in the bigger picture of Battery. However, it is designed 
to be used as a standalone library for any of your projects, that do not rely on Battery. 
Feel free to use it for any of your projects.

## What this is NOT

This is not a 1-to-1 replacement or reference implementation of 
[std::embed](https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2020/p1040r6.html). 
This is a `std::embed`/`#embed` replacement until it finally makes its way 
into the standard. This library might deprecate with `std::embed`, but it might be more comfortable 
to work with even then.

## You can embed ...

... files that are easier to develop in a text editor, or binary files, that would be a burden to ship with 
the portable application, that is:

 - Text files such as
   - text messages, ASCII art
   - small configuration files such as default settings in json, XML, etc..
   - templating files for generating files like jinja (or more like [inja](https://github.com/pantor/inja))
   - shader code, base-64 encoded data that is too long for C++ strings
 - Binary files such as
   - images, icons or splash screens
   - color palette files
   - language/localization files
   - audio files

What is NOT to be embedded:  
- Very large files (>50Mb), as this bloats the executable size and will take forever to compile. In some cases it might not even compile because the compiler needs too much RAM to compile the gigabytes of char-arrays. They are recommended to be shipped with the application and loaded at runtime.
- Or files that are to be modified at runtime, by the end user or other applications.

## Features

 - Embed any file as a C++ byte array, compiled into the executable
 - The file is hot-reloaded at runtime if the source changed
 - Compile-time checking of the file path
 - Conversion is fully automatic (No CMake reload needed)
 - Implemented in a single CMake file, no dependencies
 - Suitable to be used with cross-compilation

## To be implemented

 - In the future, file globbing might be implemented, so that a whole directory can be embedded 
without specifying each file's name. This might be useful for embedded web servers, that might have hundreds of files.
 - A function for writing a file or a whole directory to disk, to allow legacy APIs to load the file from disk. 
Currently, every file would need to be retrieved and written to disk manually.

## Requirements

 - CMake >=3.21
 - A C++20 compiler

This project requires C++20. If you are stuck with an older version, you can use [Release v1.0.0](https://github.com/batterycenter/embed/releases/tag/v1.0.0). It was made for C++14.

## How it works

The entire library is implemented in a single CMake file.
The function `b_embed(<target> <filename>)` can be used to mark a file for embedding. 
Later when building your project, all files are automatically converted to C++ byte arrays and added to your project. 
Also, it automatically regenerates whenever the file changes. 
The byte arrays are compiled into your application and you can access them with the filename.

https://github.com/vector-of-bool/cmrc is another library with the same goal. In the latest version of Battery::embed, 
there are not many differences remaining. The main advantage of Battery::embed over cmcr is that the API
is a lot more minimalistic.

https://github.com/MKlimenko/embed has a different approach, it builds a C++ CLI app and compiles it as part 
of your application, and then calls it to generate the files, doing the conversion in C++. `Battery-embed` 
also used this approach in the beginning, but this was later changed as it makes cross-compilation almost impossible 
because the target architecture might not match the host architecture, meaning the compiled program cannot run on 
the same machine it was compiled on.

## Line endings

Line endings are not converted. Every file is read and written in binary mode. 
This means, you are responsible for storing all your files on disk with LF line endings, 
even on Windows. For an explanation, consult http://utf8everywhere.org/.

You might want to configure your Git client to always
[checkout files with LF line endings](https://stackoverflow.com/questions/2517190/how-do-i-force-git-to-use-lf-instead-of-crlf-under-windows).

## Binary Size

Here is a small, quick test to see how much the executable size increases. It is not a serious benchmark, just a quick reference. I built a small hello world executable using iostream, which turned out to be `70kB` in Debug mode on Windows/MSVC. Then I embedded a `127kB` TTF file. The executable size jumped to `415kB`, which is a difference of `345kB`. That is about 2.7 times the size of the TTF file.

Release mode showed an increase from `14kB` to `183kB`, which is a difference of only `169kB`. Comparing that to the original file size concludes that in Release mode on MSVC at least, the executable size only grows by about `30%` more than the file size being embedded.

The last test may be the most influential, it tests from one embedded file to another embedded file. With the same file embedded, the executable was `183kB` in Release mode. Adding another file with `108kB` brought the executable size to `290kB`, a difference of `107kB`. That is even less than the file size. The compiler seems to have optimized something.

So as a conclusion, the mechanism is very efficient and gets more efficient the more files you add. The increase of the executable size compared to the filesize being embedded seems to be somewhere between `100%` - `150%` in MSVC Release mode.

# Building the Examples

Building the examples:

```bash
git clone https://github.com/batterycenter/embed.git
cd embed
cmake . -B build
cmake --build build
```

Locate the built executable in the `build` directory (location depends on your compiler) and run it in a terminal.

# Example usage

## Getting the library

There are multiple ways to get the library:

### 1. Use [FetchContent](https://cmake.org/cmake/help/latest/module/FetchContent.html) or [CPM.cmake](https://github.com/cpm-cmake/CPM.cmake.git) to let CMake download it on-demand (Recommended)

```cmake
include(FetchContent)
FetchContent_Declare(
  battery-embed
  GIT_REPOSITORY https://github.com/batterycenter/embed.git
  GIT_TAG        <latest-git-tag>
)
FetchContent_MakeAvailable(battery-embed)
```

Or, if you use `CPM.cmake`:

```cmake
CPMAddPackage("gh:batterycenter/embed@<latest-git-tag>")
```

Make sure to use the git tag of the latest release, but not 'main', to make sure your project stays reproducible for a long time and does not break by itself at some point.

### 2. Use git submodules or place the library itself in your repository

```bash
git submodule add https://github.com/batterycenter/embed external/embed
```

This adds it to your repository as a submodule, it is automatically cloned when you clone your repository using `git clone --recursive`. You can also just copy the library into your repository, but then you have to make sure to update it manually. See the License when doing that.

In both cases, just add the subdirectory:
```cmake
add_subdirectory(external/embed)
```

### 3. Copying the CMake file directly

Since Version 1.1.0, the library is implemented in a single CMake file and the Python dependency was dropped. 
Now, you can simply copy the CMakeLists.txt into a subdirectory of your project, add it and start using the library.

### 4. Conan (not planned yet)

This library does not have Conan support yet. Let me know if there is interest to add this library to Conan!

## Full Example

CMakeLists.txt
```cmake
cmake_minimum_required(VERSION 3.21)
project(Test)

include(FetchContent)
FetchContent_Declare(
  battery-embed
  GIT_REPOSITORY https://github.com/batterycenter/embed.git
  GIT_TAG        <latest-git-tag>
)
FetchContent_MakeAvailable(battery-embed)

add_executable(Test src/main.cpp)

b_embed(Test resources/message.txt)
```

src/main.cpp
```cpp

#include <iostream>
#include "battery/embed.hpp"

int main() {
    std::cout << b::embed<"resources/message.txt">() << std::endl;
    return 0;
}
```

resources/message.txt
```
Hello World! This is a very long text!
It even has multiple lines!
```

And build it:
```bash
cmake . -B build
cmake --build build
```
That's it, now run it and see what happens!

### Type conversions

The returned object is a class that provides a number of functions and conversion operators for convenience.

```cpp
std::string file =            b::embed<"resources/message.txt">().str();
const char* pointer =         b::embed<"resources/message.txt">().data();
size_t length =               b::embed<"resources/message.txt">().length();
size_t size =                 b::embed<"resources/message.txt">().size();
std::vector<uint8_t> vec =    b::embed<"resources/message.txt">().vec();
```

And all conversions also exist as operators, allowing for this:

```cpp
void foo_str(const std::string& test);
void foo_vec(const std::vector<uint8_t>& test);

foo_str(b::embed<"resources/message.txt">());
foo_vec(b::embed<"resources/message.txt">());
```

### Hot-reloading files

Files can be hot-reloaded at runtime, whenever they change. The `.get()` function can be used for this purpose, by providing a lambda function. In Debug mode (default), the lambda will be called once as soon as it is called, and from there on, it will always continue to be called from another thread, when the original file is modified. This is only supposed to be used for development.

You can add `B_PRODUCTION_MODE` as a define. This comes from Battery and if you use this library outside of Battery, you must define it across the entire build system so that it applies to all source files.

If `B_PRODUCTION_MODE` is defined across the entire build, all development features will be disabled. This means, no hot-reloading, no global file watcher thread, no absolute file paths compiled into the binary. The `.get()` function continues to work as usual, but the lambda will be called immediately from the same thread, and then it will not be called any more time. In production mode, it is basically a straight pipe.

```cpp
#include "battery/embed.hpp"
#include <iostream>
#include <thread>

int main() {
    std::string file;

    // This lambda is called from another thread every time the file changes on-disk, 
    // and in production mode, it is called immediately from the same thread, once.
    b::embed<"assets/source.txt">().get([&file] (const auto& content) {
        file = content.str();
        std::cout << "File changed: " << file << std::endl;
    });
    
    while (true) {
        // Do something with file
        std::this_thread::sleep_for(std::chrono::seconds(1));
    }
}
```

Try running this code, and you will see that if you change the file, the lambda will automatically be called.

### C-Style functions

```cpp
#include "battery/embed.hpp"

void old_c_style_function(const char* data, unsigned long size);

void test() {
    // Looping through all bytes
    for (uint8_t byte : b::embed<"resources/icon.png">().vec()) {
        std::cout << byte << std::endl;
    }

    // Or pass it along
    auto icon = b::embed<"resources/message.txt">();
    old_c_style_function(icon.data(), icon.size());
}
```

Most legacy APIs provide functions to either load files from the filesystem, or from a memory buffer taking a 
pointer and a size. In this case you can always use the memory variant to achieve the exact same thing, 
but without actually interacting with the filesystem. Everything is enclosed in the executable itself.

If there is strictly no other way than loading from the filesystem, you can still embed the file and write it to 
disk when needed, let the legacy API load it, and then delete it again, if you want to keep your application 
portable and want to avoid shipping resource files.

### Embedding files from a subdirectory

Say you want to achieve following structure:
```
 - CMakeLists.txt       -> 'add_executable(MyTarget)' and 'add_subdirectory(resources)'
 - resources
   - CMakeLists.txt     -> Here, calling 'b_embed(MyTarget ...)'
   - resource1.txt
   - resource2.txt
   - ...
```

This structure unfortunately cannot be achieved easily, due to CMake's encapsulation rules.
Any generated resource in CMake must be defined in the same directory as the target it is applied to (also applies to `b_embed()`).
Hence, you must always keep `b_embed()` in the same CMake file where the target is created.

Therefore, the idiomatic way to achieve said goal is to create a static proxy library in the subdirectory, call
`b_embed()` on the proxy library, and then link your executable to the proxy library. The convenience function `b_embed_proxy_target()` can be used for this task. 

#### Example
resources/CMakeLists.txt:  
```cmake
b_embed_proxy_target(MyTarget MyTarget-resources)
b_embed(MyTarget-resources resource1.txt)
b_embed(MyTarget-resources resource2.txt)
...
```
CMakeLists.txt:
```cmake
add_executable(MyTarget)
target_compile_features(MyTarget PUBLIC cxx_std_20)

add_subdirectory(resources)
```

# Contribution

This library is open for contributions. Feel free to open an issue or a pull request, I am very happy about feedback 
and ideas to improve it!

# Attribution

The examples contain an icon file that is 
<a href="https://www.flaticon.com/free-icons/global" title="global icons">provided by Freepik - Flaticon</a>

# License

This project is licensed under the Apache License 2.0. This means that when using the library in a C++ project like 
it is intended to, you are allowed to do whatever you like, commercial or non-commercial. Compiled binaries that 
rely on this library as a build dependency do not include large parts of this codebase.

Regarding the library itself, you are allowed to modify it and redistribute it according to the Apache License 2.0.

Since Version 1.1.0, this library is implemented in a single CMake file. You are allowed to re-upload this file
as part of your own public repository, as long as the license header in the top is retained and any modifications
are clearly marked.

## Support 💪

I do all of my projects in my free time and I do not get any money for that. I just like what I do, do it for myself and want to share it so that others can benefit too.

I like beer and any support is greatly apprechiated :)

<a href="https://www.buymeacoffee.com/herrnamenlos123"><img src="https://img.buymeacoffee.com/button-api/?text=Buy me a beer&emoji=🍺&slug=herrnamenlos123&button_colour=FFDD00&font_colour=000000&font_family=Lato&outline_colour=000000&coffee_colour=ffffff" /></a>
