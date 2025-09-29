#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:05:00   

# Load the necessary modules
module purge
module load OpenMPI/4.1.4-GCC-12.2.0 CMake/3.24.3-GCCcore-12.2.0 #cuDNN

# Define paths
LAMMPS_EXEC='/mnt/parscratch/users/ce1ls/software/lammps/exec/lmp_eph'
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

# Run the LAMMPS job using MPI
mpirun -np $SLURM_NTASKS $LAMMPS_EXEC -h
