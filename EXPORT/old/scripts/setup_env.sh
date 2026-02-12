#!/bin/bash
set -e

echo "=========================================="
echo "MatLabC++ Environment Setup"
echo "=========================================="

if ! command -v conda &> /dev/null; then
    echo "Error: conda not found. Install Miniconda/Anaconda first."
    exit 1
fi

echo "Creating conda environment..."
conda create -n matlabcpp_journal python=3.11 -y

source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate matlabcpp_journal

echo "Installing Python packages..."
conda install -c conda-forge numpy scipy matplotlib jupyter jupyterlab notebook -y

pip install --upgrade jupytext myst-parser nbconvert

echo ""
echo "=========================================="
echo "Setup complete!"
echo "=========================================="
echo "Activate with: conda activate matlabcpp_journal"
echo "Launch with:   jupyter notebook"
