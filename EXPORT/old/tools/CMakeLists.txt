# CMakeLists.txt for bundle_installer
# Intent: Build standalone C++ installer for MatLabC++ examples
# No external dependencies, pure stdlib

cmake_minimum_required(VERSION 3.10)
project(matlabcpp_bundle_installer VERSION 0.3.0 LANGUAGES CXX)

# ========== COMPILER SETTINGS ==========
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Compiler flags
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    add_compile_options(-Wall -Wextra -pedantic -O2)
elseif(MSVC)
    add_compile_options(/W4 /O2)
endif()

# ========== PLATFORM DETECTION ==========
if(WIN32)
    add_definitions(-DPLATFORM_WINDOWS)
elseif(APPLE)
    add_definitions(-DPLATFORM_MACOS)
elseif(UNIX)
    add_definitions(-DPLATFORM_LINUX)
endif()

# ========== TARGET ==========
add_executable(bundle_installer
    tools/bundle_installer.cpp
)

# Platform-specific libraries
if(UNIX AND NOT APPLE)
    # Linux: no extra libs needed
elseif(APPLE)
    # macOS: no extra libs needed
elseif(WIN32)
    # Windows: link against kernel32 for memory info
    target_link_libraries(bundle_installer PRIVATE kernel32)
endif()

# ========== INSTALLATION ==========
install(TARGETS bundle_installer
    RUNTIME DESTINATION bin
)

# ========== TESTING ==========
enable_testing()

# Test 1: Build succeeds
add_test(NAME build_test
    COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR}
)

# Test 2: Executable exists
add_test(NAME executable_test
    COMMAND test -f $<TARGET_FILE:bundle_installer>
)

# Test 3: Help message works
add_test(NAME help_test
    COMMAND bundle_installer
)
set_tests_properties(help_test PROPERTIES WILL_FAIL TRUE)  # Should fail without args

# ========== BUILD INFO ==========
message(STATUS "MatLabC++ Bundle Installer")
message(STATUS "  Version: ${PROJECT_VERSION}")
message(STATUS "  Compiler: ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")
message(STATUS "  Platform: ${CMAKE_SYSTEM_NAME}")
message(STATUS "  Build type: ${CMAKE_BUILD_TYPE}")

# ========== DOCUMENTATION ==========
# Build: cmake -B build && cmake --build build
# Install: cmake --install build
# Test: ctest --test-dir build
