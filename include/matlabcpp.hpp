pragma once

/*
 * MatLabC++ - High-Performance Numerical Computing
 * Single-header include for entire system
 * 
 * Usage:
 *   #include <matlabcpp.hpp>
 *   using namespace matlabcpp;
 */

// Core numerical engine
#include "matlabcpp/core.hpp"

// Physical constants (100+ predefined)
#include "matlabcpp/constants.hpp"

// Materials database + inference engine
#include "matlabcpp/materials.hpp"
#include "matlabcpp/materials_inference.hpp"

// System diagnostics
#include "matlabcpp/system.hpp"

// Integration layer (convenience functions)
#include "matlabcpp/integration.hpp"

// Script execution (.m and .c files)
#include "matlabcpp/script.hpp"

namespace matlabcpp {

// Version info
constexpr const char* VERSION = "0.2.0";
constexpr int VERSION_MAJOR = 0;
constexpr int VERSION_MINOR = 2;
constexpr int VERSION_PATCH = 0;

} // namespace matlabcpp
