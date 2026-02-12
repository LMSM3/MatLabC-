# MatLabC++ v0.5.0 Build System

cmake_minimum_required(VERSION 3.15)
project(MatLabCPlusPlus VERSION 0.5.0 LANGUAGES CXX)


set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# ========== OPTIONS ==========
option(BUILD_SHARED_LIBS "Build shared libraries" ON)
option(BUILD_EXAMPLES "Build example programs" ON)
option(BUILD_TESTS "Build unit tests" ON)
option(BUILD_PACKAGES "Build module packages" ON)
option(BUILD_PLOTTING "Build plotting module" ON)
option(WITH_CAIRO "Enable Cairo backend for plotting" ON)
option(WITH_OPENGL "Enable OpenGL backend for 3D plotting" ON)
option(WITH_GPU "Enable GPU support" ON)

# ========== DEPENDENCIES ==========
find_package(Threads REQUIRED)

# Optional dependencies
if(WITH_CAIRO)
    find_package(PkgConfig)
    if(PkgConfig_FOUND)
        pkg_check_modules(CAIRO cairo)
        if(CAIRO_FOUND)
            add_compile_definitions(HAVE_CAIRO)
        endif()
    endif()
endif()

if(WITH_OPENGL)
    find_package(OpenGL)
    if(OPENGL_FOUND)
        add_compile_definitions(HAVE_OPENGL)
    endif()
endif()

if(WITH_GPU)
    find_package(CUDA QUIET)
    if(CUDA_FOUND)
        add_compile_definitions(HAVE_CUDA)
    endif()
endif()

# ========== CORE LIBRARY ==========
add_library(matlabcpp_core
    src/core/matrix.cpp
    src/core/vector.cpp
    src/core/functions.cpp
    src/core/interpreter.cpp
    src/active_window.cpp
    src/value.cpp
    src/matrix_parser.cpp
    src/debug_flags.cpp
    src/publishing/publisher.cpp
    src/gpu/complex_tensor_cpu.cpp
)

target_include_directories(matlabcpp_core
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
)

target_link_libraries(matlabcpp_core
    PUBLIC
        Threads::Threads
)

# ========== MATERIALS MODULE ==========
add_library(matlabcpp_materials
    src/materials_smart.cpp
)

target_include_directories(matlabcpp_materials
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
)

target_link_libraries(matlabcpp_materials
    PUBLIC
        matlabcpp_core
)

# ========== PLOTTING MODULE ==========
if(BUILD_PLOTTING)
    add_library(matlabcpp_plotting
        src/plotting/renderer_2d.cpp
        src/plotting/renderer_3d.cpp
        src/plotting/plot_spec.cpp
        src/plotting/style_presets.cpp
    )
    
    target_include_directories(matlabcpp_plotting
        PUBLIC
            $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
            $<INSTALL_INTERFACE:include>
    )
    
    target_link_libraries(matlabcpp_plotting
        PUBLIC
            matlabcpp_core
    )
    
    if(CAIRO_FOUND)
        target_include_directories(matlabcpp_plotting PRIVATE ${CAIRO_INCLUDE_DIRS})
        target_link_libraries(matlabcpp_plotting PRIVATE ${CAIRO_LIBRARIES})
    endif()
    
    if(OPENGL_FOUND)
        target_link_libraries(matlabcpp_plotting PRIVATE OpenGL::GL)
    endif()
endif()

# ========== PACKAGE MANAGER ==========
add_library(matlabcpp_pkg
    src/package_manager/database.cpp
    src/package_manager/repository.cpp
    src/package_manager/resolver.cpp
    src/package_manager/installer.cpp
    src/package_manager/capability_registry.cpp
)

target_include_directories(matlabcpp_pkg
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
)

target_link_libraries(matlabcpp_pkg
    PUBLIC
        matlabcpp_core
)

# ========== MAIN EXECUTABLE ==========
add_executable(mlab++
    src/main.cpp
    src/cli/argument_parser.cpp
    src/cli/repl.cpp
)

target_link_libraries(mlab++
    PRIVATE
        matlabcpp_core
        matlabcpp_materials
        matlabcpp_pkg
)

if(BUILD_PLOTTING)
    target_link_libraries(mlab++ PRIVATE matlabcpp_plotting)
endif()

# ========== PACKAGE MANAGER CLI ==========
# Disabled: mlab_pkg moved to EXPORT/old/tools/, not yet implemented

# ========== TESTS ==========
if(BUILD_TESTS)
    enable_testing()
    
    add_executable(test_active_window
        tests/test_active_window.cpp
    )
    
    target_link_libraries(test_active_window
        PRIVATE
            matlabcpp_core
    )
    
    add_test(NAME ActiveWindow COMMAND test_active_window)
endif()

# ========== EXAMPLES ==========
if(BUILD_EXAMPLES)
    add_executable(materials_demo
        examples/materials_smart_demo.cpp
    )
    
    target_link_libraries(materials_demo
        PRIVATE
            matlabcpp_core
            matlabcpp_materials
    )
endif()

# ========== INSTALLATION ==========
install(TARGETS matlabcpp_core matlabcpp_materials matlabcpp_pkg mlab++
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

if(BUILD_PLOTTING)
    install(TARGETS matlabcpp_plotting
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib
    )
endif()

install(DIRECTORY include/matlabcpp
    DESTINATION include
)

install(DIRECTORY packages/
    DESTINATION share/matlabcpp/packages
)

install(DIRECTORY examples/
    DESTINATION share/matlabcpp/examples
)

install(FILES
    README.md
    CHANGELOG.md
    DESTINATION share/doc/matlabcpp
)

# ========== PACKAGE GENERATION ==========
set(CPACK_PACKAGE_NAME "MatLabCPlusPlus")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
set(CPACK_PACKAGE_VENDOR "MatLabC++ Contributors")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Professional MATLAB-compatible numerical computing")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE")
set(CPACK_RESOURCE_FILE_README "${CMAKE_CURRENT_SOURCE_DIR}/README.md")

set(CPACK_GENERATOR "TGZ;ZIP")
set(CPACK_SOURCE_GENERATOR "TGZ;ZIP")

include(CPack)

# ========== SUMMARY ==========
message(STATUS "")
message(STATUS "MatLabC++ v${PROJECT_VERSION} Build Configuration")
message(STATUS "==========================================")
message(STATUS "Build type:           ${CMAKE_BUILD_TYPE}")
message(STATUS "Build shared libs:    ${BUILD_SHARED_LIBS}")
message(STATUS "Build examples:       ${BUILD_EXAMPLES}")
message(STATUS "Build tests:          ${BUILD_TESTS}")
message(STATUS "Build plotting:       ${BUILD_PLOTTING}")
message(STATUS "")
message(STATUS "Optional Dependencies:")
message(STATUS "  Cairo:              ${CAIRO_FOUND}")
message(STATUS "  OpenGL:             ${OPENGL_FOUND}")
message(STATUS "  CUDA:               ${CUDA_FOUND}")
message(STATUS "")
message(STATUS "Install prefix:       ${CMAKE_INSTALL_PREFIX}")
message(STATUS "")

