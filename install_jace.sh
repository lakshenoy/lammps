#!/bin/bash

# Make build directory 
mkdir build
cd build

# Load necessary modules
module purge 
module load CMake/3.24.3-GCCcore-11.3.0 
module load FFTW/3.3.10-GCC-11.3.0 Python/3.10.4-GCCcore-11.3.0 

# Load the virtual environment
export VIRTUAL_ENV=$WORK/venv/jace
source $VIRTUAL_ENV/bin/activate

wget -O libpace.tar.gz https://github.com/wcwitt/lammps-user-pace/archive/main.tar.gz

# # Configure the build
cmake ../cmake \
      -D CMAKE_BUILD_TYPE=Release -D PKG_ML-PACE=ON -D PKG_MANYBODY=ON  \
      -D CMAKE_INSTALL_PREFIX=$VIRTUAL_ENV \
      -D BUILD_SHARED_LIBS=ON \
      -D PACELIB_MD5=$(md5sum libpace.tar.gz | awk '{print $1}')

# Build 
cmake --build . -- -j 8

# Install - required since this is shared library mode
make install 
make install-python

# Clean up
# cd ..
# rm -r build

# Modify the venv activate script to include LAMMPS libraries in LD_LIBRARY_PATH
echo 'export LD_LIBRARY_PATH=$VIRTUAL_ENV/lib64:$LD_LIBRARY_PATH' >> $VIRTUAL_ENV/bin/activate
echo 'export LAMMPS_POTENTIALS=$VIRTUAL_ENV/share/lammps/potentials' >> $VIRTUAL_ENV/bin/activate
