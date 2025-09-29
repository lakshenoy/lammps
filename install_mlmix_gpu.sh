#!/bin/bash

# Make build directory 
mkdir build_mlml
cd build_mlml

# Load necessary modules
module purge 
module load CMake/3.24.3-GCCcore-11.3.0 cuDNN/8.7.0.84-CUDA-11.8.0 OpenMPI/4.1.4-GCC-11.3.0
module load FFTW/3.3.10-GCC-11.3.0 Python/3.10.4-GCCcore-11.3.0 

# Load the virtual environment
export VIRTUAL_ENV=$WORK/venv/mlml_casc
source $VIRTUAL_ENV/bin/activate

wget -O libpace.tar.gz https://github.com/wcwitt/lammps-user-pace/archive/main.tar.gz
cmake ../cmake \
  -C ../cmake/presets/basic.cmake \
  -D CMAKE_CXX_COMPILER=/mnt/parscratch/users/ce1ls/software/lammps/lib/kokkos/bin/nvcc_wrapper \
  -D CMAKE_BUILD_TYPE=Release \
  -D CMAKE_INSTALL_PREFIX=$VIRTUAL_ENV \
  -D BUILD_SHARED_LIBS=ON \
  -D BUILD_MPI=ON \
  -D BUILD_OMP=ON \
  -D PKG_KOKKOS=ON \
  -D Kokkos_ENABLE_SERIAL=ON \
  -D Kokkos_ENABLE_CUDA=ON \
  -D Kokkos_ARCH_AMPERE80=ON \
  -D FFT_KOKKOS=CUFFT \
  -D PKG_ML-UF3=ON \
  -D PKG_ML-PACE=ON \
  -D PKG_ML-SNAP=ON \
  -D PKG_RIGID=ON \
  -D PKG_MANYBODY=ON \
  -D PKG_MOLECULE=ON \
  -D PKG_EXTRA-PAIR=ON \
  -D PACELIB_MD5=$(md5sum libpace.tar.gz | awk '{print $1}') \
  -D PKG_EXTRA-FIX=ON

# Build 
cmake --build . -- -j 8

# Install - required since this is shared library mode
make install 
make install-python

# Clean up
cd ..
rm -r build_mlml

# Modify the venv activate script to include LAMMPS libraries in LD_LIBRARY_PATH
echo 'export LD_LIBRARY_PATH=$VIRTUAL_ENV/lib64:$LD_LIBRARY_PATH' >> $VIRTUAL_ENV/bin/activate
echo 'export LAMMPS_POTENTIALS=$VIRTUAL_ENV/share/lammps/potentials' >> $VIRTUAL_ENV/bin/activate
