#!/bin/bash

# Make required directories
mkdir exec 2>/dev/null # Directory for the executable
mkdir build
cd build

# For all installs
py="False"

#-----------------------------
## EAM and MPI, with VORONOI

# # Load necessary modules
# module load OpenMPI/4.1.4-GCC-12.2.0 CMake/3.24.3-GCCcore-12.2.0

# # Configure the build
# cmake -D BUILD_MPI=ON -D BUILD_OMP=ON \
#     -D PKG_MANYBODY=ON -D PKG_VORONOI=ON -D DOWNLOAD_VORO=ON \
#     ../cmake

#-----------------------------
## Above plus ML-PACE (no python, and only CPU)

# # Load necessary modules
# module purge ; module load OpenMPI/4.1.4-GCC-12.2.0 CMake/3.24.3-GCCcore-12.2.0

# # Configure the build
# cmake -D CMAKE_BUILD_TYPE=Release -D BUILD_MPI=ON -D PKG_ML-PACE=ON \
#       -D PKG_MANYBODY=ON -D PKG_VORONOI=ON -D DOWNLOAD_VORO=ON \
#       ../cmake

#-----------------------------
## EAM, TabGAP and MPI, with VORONOI

# Placed tabgap pair styles in lammps/src

# # Load necessary modules
# module load OpenMPI CMake

# # Configure the build
# cmake -D BUILD_MPI=ON -D BUILD_OMP=ON \
#     -D PKG_MANYBODY=ON -D PKG_VORONOI=ON -D DOWNLOAD_VORO=ON \
#     ../cmake

#-----------------------------
## EAM, TabGAP, ML-PACE, VORONOI, MISC, MPI

# Placed tabgap pair styles in lammps/src

# Load necessary modules
module purge ; module load OpenMPI/4.1.5-GCC-12.3.0 CMake/3.26.3-GCCcore-12.3.0

# Configure the build
cmake -D CMAKE_BUILD_TYPE=Release -D BUILD_MPI=ON -D PKG_ML-PACE=ON \
      -D PKG_MANYBODY=ON -D PKG_VORONOI=ON -D DOWNLOAD_VORO=ON -D PKG_EXTRA-FIX=ON \
      ../cmake

#-----------------------------
## Python and ML-PACE, no MPI

# # Load the necessary modules
# module load Python/3.10.8-GCCcore-12.2.0 CMake/3.24.3-GCCcore-12.2.0

# # Load the virtual environment
# export VIRTUAL_ENV=$WORK/venv/frac
# source $VIRTUAL_ENV/bin/activate
# py="True"

# cmake ../cmake -D CMAKE_BUILD_TYPE=Release -D BUILD_SHARED_LIBS=yes -D CMAKE_INSTALL_PREFIX=$VIRTUAL_ENV \
#                -D PKG_PYTHON=yes -D PKG_ML-PACE=yes -D BUILD_OMP=yes -D BUILD_LIB=ON -D LAMMPS_EXCEPTIONS=yes \

#-----------------------------
## Python and Julia ACE, no MPI

# # Load the necessary modules
# module load Python/3.10.8-GCCcore-12.2.0 CMake/3.24.3-GCCcore-12.2.0

# # Load the virtual environment
# export VIRTUAL_ENV=$WORK/venv/frac
# source $VIRTUAL_ENV/bin/activate
# py="True"

# wget -O libpace.tar.gz https://github.com/wcwitt/lammps-user-pace/archive/main.tar.gz

# cmake ../cmake -D CMAKE_BUILD_TYPE=Release -D BUILD_SHARED_LIBS=yes -D CMAKE_INSTALL_PREFIX=$VIRTUAL_ENV \
#                -D PKG_PYTHON=yes -D PKG_ML-PACE=yes -D PKG_OPENMP=yes -D BUILD_LIB=ON -D LAMMPS_EXCEPTIONS=yes \
#                #-D BUILD_MPI=yes -D PKG_MPIIO=ON \
#                -D PKG_EXTRA-COMPUTE=ON -D PKG_EXTRA-DUMP=ON -D PKG_EXTRA-FIX=ON \
#                -D PKG_ML-QUIP=yes -D QUIP_LIBRARY=/home/eng/phrddn/venv/chap7/lib64/python3.10/site-packages/quippy/libquip.a \
#                -D PKG_EXTRA-PAIR=ON -D PKG_MANYBODY=ON -D PKG_MISC=ON -D PACELIB_MD5=$(md5sum libpace.tar.gz | awk '{print $1}') \

#-----------------------------

# Build the executable
cmake --build . -- -j 8

# Make python, if needed
if [ "$py" = "True" ]; then
    make install-python
fi

# Copy the executable to the root directory
mv lmp* ../exec

# Clean up
cd ..
rm -r build

#-----------------------------
# Modify the venv activation script to recognize the lammps install, if needed
if [ "$py" = "True" ]; then
    echo 'export LD_LIBRARY_PATH=$VIRTUAL_ENV/lib64:$LD_LIBRARY_PATH' >> $VIRTUAL_ENV/bin/activate
    echo 'export LAMMPS_POTENTIALS=$VIRTUAL_ENV/share/lammps/potentials/' >> $VIRTUAL_ENV/bin/activate
fi
