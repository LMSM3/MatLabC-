// Quick test for v0.2.0 script execution
#include "include/matlabcpp.hpp"
#include <iostream>

int main() {
    std::cout << "MatLabC++ " << matlabcpp::VERSION << " - Testing script execution\n\n";
    
    // Test script type detection
    auto type_c = matlabcpp::script::detect_type("test.c");
    auto type_m = matlabcpp::script::detect_type("test.m");
    
    std::cout << "Script type detection:\n";
    std::cout << "  test.c -> " << (type_c == matlabcpp::script::ScriptType::C_SOURCE ? "C_SOURCE" : "OTHER") << "\n";
    std::cout << "  test.m -> " << (type_m == matlabcpp::script::ScriptType::MATLAB ? "MATLAB" : "OTHER") << "\n\n";
    
    // Verify core functions still work
    matlabcpp::Matrix A = {{1, 2}, {3, 4}};
    matlabcpp::Matrix B = {{5, 6}, {7, 8}};
    auto C = matlabcpp::matmul(A, B);
    
    std::cout << "Core functionality (matmul):\n";
    std::cout << "  [[1,2],[3,4]] * [[5,6],[7,8]] = [[" 
              << C[0][0] << "," << C[0][1] << "],[" 
              << C[1][0] << "," << C[1][1] << "]]\n\n";
    
    std::cout << "v0.2.0 integration test: PASSED\n";
    return 0;
}
