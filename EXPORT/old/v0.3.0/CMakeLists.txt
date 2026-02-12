cmake_minimum_required(VERSION 3.14...3.31)
project(MatLabCPP VERSION 0.3.0 LANGUAGES CXX)

# C++ Standard
if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.20")
    set(CMAKE_CXX_STANDARD 23)
    set(CMAKE_CXX_STANDARD_REQUIRED OFF)
else()
    set(CMAKE_CXX_STANDARD 20)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
endif()
set(CMAKE_CXX_EXTENSIONS OFF)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

option(MATLABCPP_NATIVE_ARCH "Use -march=native" ON)
option(MATLABCPP_BUILD_TESTS "Build test programs" OFF)

# Optimization flags
set(OPT_FLAGS "")
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    set(OPT_FLAGS 
        -O3 -ffast-math -funroll-loops -fomit-frame-pointer 
        -fno-exceptions -fno-rtti -Wall -Wextra
    )
    
    if(MATLABCPP_NATIVE_ARCH)
        list(APPEND OPT_FLAGS -march=native -mtune=native)
    endif()
    
    include(CheckCXXCompilerFlag)
    check_cxx_compiler_flag(-mavx2 HAS_AVX2)
    if(HAS_AVX2)
        list(APPEND OPT_FLAGS -mavx2 -mfma)
    endif()
    
    if(CMAKE_BUILD_TYPE STREQUAL "Release")
        check_cxx_compiler_flag(-flto HAS_LTO)
        if(HAS_LTO)
            list(APPEND OPT_FLAGS -flto)
            set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -flto")
        endif()
    endif()
elseif(MSVC)
    set(OPT_FLAGS /O2 /Ot /Oi /Ob3 /fp:fast /GF /Gy /GR- /EHs-c- /W4)
    if(MATLABCPP_NATIVE_ARCH)
        list(APPEND OPT_FLAGS /arch:AVX2)
    endif()
endif()

# Main executable
add_executable(matlabcpp src/main.cpp)
target_include_directories(matlabcpp PRIVATE include)
target_compile_options(matlabcpp PRIVATE ${OPT_FLAGS})
if(NOT WIN32)
    target_link_libraries(matlabcpp PRIVATE pthread m)
endif()

# Benchmark executable
add_executable(benchmark_inference src/benchmark_inference.cpp)
target_include_directories(benchmark_inference PRIVATE include)
target_compile_options(benchmark_inference PRIVATE ${OPT_FLAGS})
if(NOT WIN32)
    target_link_libraries(benchmark_inference PRIVATE pthread m)
endif()

# Install
install(TARGETS matlabcpp benchmark_inference DESTINATION bin)
install(DIRECTORY include/ DESTINATION include FILES_MATCHING PATTERN "*.hpp")

message(STATUS "===============================================")
message(STATUS "MatLabC++ v0.3.0 - Production Build")
message(STATUS "===============================================")
message(STATUS "  C++ Standard:  ${CMAKE_CXX_STANDARD}")
message(STATUS "  Build Type:    ${CMAKE_BUILD_TYPE}")
message(STATUS "  Native Arch:   ${MATLABCPP_NATIVE_ARCH}")
message(STATUS "===============================================")
