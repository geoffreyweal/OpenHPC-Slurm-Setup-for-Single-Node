#!/bin/bash
#SBATCH --job-name=test_gpu     # Job name
#SBATCH --output=test_gpu.out   # Name of stdout output file
#SBATCH --error=test_gpu.err    # Name of stderr error file
#SBATCH --time=00:10:00         # Run time (hh:mm:ss)
#SBATCH --partition=gpu         # Partition (queue) name
#SBATCH --gres=gpu:1            # Request 1 GPU

# Load necessary modules
module load CUDA/12.4.0 # Adjust according to your system's available modules

# Run nvidia-smi to test GPU
echo "Running nvidia-smi to check GPU status..."
nvidia-smi

# Run a simple GPU test program
echo "Running a simple GPU test program..."
cat <<EOF > gpu_test.cu
#include <stdio.h>
__global__ void testKernel(void) {
    printf("Hello from GPU!\\n");
}
int main(void) {
    testKernel<<<1,1>>>();
    cudaDeviceSynchronize();
    return 0;
}
EOF

# Compile the test program
nvcc -o gpu_test gpu_test.cu

# Run the compiled GPU test program
./gpu_test