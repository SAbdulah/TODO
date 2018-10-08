module load ecrc-extras
module load mkl/2018-update-1
module load gcc/7.2.0
module load cmake/3.11.1
module load gsl/2.4-gcc-7.2.0
module load nlopt/2.4.2-gcc-7.2.0
module load hwloc/1.11.8-gcc-7.2.0
module load starpu/1.2.4-gcc-7.2.0-mkl-openmpi-3.0.0
module load hdf5/1.10.1-gcc-7.2.0
module load netcdf/4.5.0-gcc-7.2.0
module load r


sed -i '/## EXAGEOSTAT-INSTALLATION-BEGIN/,/## EXAGEOSTAT-INSTALLATION-END/d'  ~/.bashrc
echo '## EXAGEOSTAT-INSTALLATION-BEGIN' >> ~/.bashrc


echo 'module load ecrc-extras' >> ~/.bashrc
echo 'module load mkl/2018-update-1' >> ~/.bashrc
echo 'module load gcc/7.2.0' >> ~/.bashrc
echo 'module load cmake/3.11.1' >> ~/.bashrc
echo 'module load gsl/2.4-gcc-7.2.0' >> ~/.bashrc
echo 'module load nlopt/2.4.2-gcc-7.2.0' >> ~/.bashrc
echo 'module load hwloc/1.11.8-gcc-7.2.0' >> ~/.bashrc
echo 'module load starpu/1.2.4-gcc-7.2.0-mkl-openmpi-3.0.0' >> ~/.bashrc
echo 'module load hdf5/1.10.1-gcc-7.2.0' >> ~/.bashrc
echo 'module load netcdf/4.5.0-gcc-7.2.0' >> ~/.bashrc
echo 'module load r' >> ~/.bashrc

MKL_DIR=/opt/intel/mkl
echo '. '$MKLROOT'/bin/mklvars.sh intel64' >> ~/.bashrc
echo 'export MKLROOT='$MKL_DIR >> ~/.bashrc


rm -rf exageostatR-dev
git clone https://github.com/ecrc/exageostatR-dev.git
export DIR=$PWD
cd exageostatR-dev/
git checkout sabdulah/gen-locs-with-seed
git submodule update --init --recursive
export EXAGEOSTATDEVDIR=$PWD/src
cd $EXAGEOSTATDEVDIR
export HICMADIR=$EXAGEOSTATDEVDIR/hicma-dev
export CHAMELEONDIR=$EXAGEOSTATDEVDIR/hicma-dev/chameleon
export STARSHDIR=$EXAGEOSTATDEVDIR/stars-h-dev

## STARS-H
cd $STARSHDIR
rm -rf build
mkdir -p build
cd build
CC=gcc cmake .. -DCMAKE_INSTALL_PREFIX=$STARSHDIR/build -DMPI=OFF -DOPENMP=OFF -DSTARPU=OFF -DCMAKE_C_FLAGS="-fPIC"
make -j
make install

export PKG_CONFIG_PATH=$STARSHDIR/build/lib/pkgconfig:$PKG_CONFIG_PATH
echo 'PKG_CONFIG_PATH='$STARSHDIR'/build/lib/pkgconfig:$PKG_CONFIG_PATH' >> ~/.bashrc

## CHAMELEON
cd $CHAMELEONDIR
rm -rf build
mkdir -p build
cd build
CC=gcc cmake .. -DCMAKE_INSTALL_PREFIX=$CHAMELEONDIR/build -DCMAKE_BUILD_TYPE=Debug -DCHAMELEON_USE_MPI=OFF -DCHAMELEON_ENABLE_EXAMPLE=OFF -DCHAMELEON_ENABLE_TESTING=OFF -DCHAMELEON_ENABLE_TIMING=OFF -DBUILD_SHARED_LIBS:BOOL=ON # -DCMAKE_C_FLAGS="-fPIC"
make -j # CHAMELEON parallel build seems to be fixed
make install

export PKG_CONFIG_PATH=$CHAMELEONDIR/build/lib/pkgconfig:$PKG_CONFIG_PATH
echo 'export PKG_CONFIG_PATH='$CHAMELEONDIR'/build/lib/pkgconfig:$PKG_CONFIG_PATH' >> ~/.bashrc

## HICMA
cd $HICMADIR
rm -rf build
mkdir -p build
cd build
CC=gcc cmake .. -DCMAKE_INSTALL_PREFIX=$HICMADIR/build -DHICMA_USE_MPI=OFF -DHICMA_ENABLE_TESTING=OFF -DHICMA_ENABLE_TIMING=OFF -DBUILD_SHARED_LIBS:BOOL=ON # -DCMAKE_C_FLAGS="-fPIC"
make -j
make install

export PKG_CONFIG_PATH=$HICMADIR/build/lib/pkgconfig:$PKG_CONFIG_PATH
echo 'export PKG_CONFIG_PATH='$HICMADIR'/build/lib/pkgconfig:$PKG_CONFIG_PATH' >> ~/.bashrc

echo '## EXAGEOSTAT-INSTALLATION-END' >> ~/.bashrc

cd $DIR
#export CPATH=$CPATH:/usr/local/include/coreblas && \
#export LD_LIBRARY_PATH="${MKLROOT}/lib/intel64_lin:$LD_LIBRARY_PATH" && \
#export LIBRARY_PATH="$LD_LIBRARY_PATH"
echo $PWD

## Modify src/Makefile, compilation flagss -> flagsl
R CMD build exageostatR-dev

#mkdir R-libraries
#R CMD INSTALL --library=./R-libraries --repos="http://cran.us.r-project.org"  RhpcBLASctl
#R CMD INSTALL --library=./R-libraries ./exageostat_0.1.0.tar.gz
