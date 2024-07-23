#!/bin/bash
#SBATCH --job-name=CPU_sleep_test
#SBATCH --output=CPU_sleep_test.out
#SBATCH --error=CPU_sleep_test.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:01:00
#SBATCH --partition=parallel

# Print to the output
echo "This is a test: 60 seconds of sleep will begin"

# Run the sleep command
sleep 60

# Print to the output
echo "This is a test: 60 seconds of sleep has finished"