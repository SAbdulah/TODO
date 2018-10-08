module load mkl/2018-initial
module load gcc/5.5.0
module load cmake/3.9.6
module load hwloc/1.11.8-gcc-5.5.0
module load openmpi/3.0.0-gcc-5.5.0
module load starpu/1.2.3-gcc-5.5.0-mkl-openmpi-3.0.0
module load gsl/2.4-gcc-5.5.0
module load nlopt/2.4.2-gcc-5.5.0
module load r/3.2.3

rm -rf exageostatR-dev
git clone https://github.com/ecrc/exageostatR-dev.git
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
cmake .. -DCMAKE_INSTALL_PREFIX=$STARSHDIR/build -DMPI=OFF -DOPENMP=OFF -DSTARPU=OFF -DCMAKE_C_FLAGS="-fPIC"
make -j
make install

export PKG_CONFIG_PATH=$STARSHDIR/build/lib/pkgconfig:$PKG_CONFIG_PATH

## CHAMELEON
cd $CHAMELEONDIR
rm -rf build
mkdir -p build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$CHAMELEONDIR/build -DCMAKE_BUILD_TYPE=Debug -DCHAMELEON_USE_MPI=OFF -DCHAMELEON_ENABLE_EXAMPLE=OFF -DCHAMELEON_ENABLE_TESTING=OFF -DCHAMELEON_ENABLE_TIMING=OFF -DBUILD_SHARED_LIBS:BOOL=ON # -DCMAKE_C_FLAGS="-fPIC"
make -j # CHAMELEON parallel build seems to be fixed
make install

export PKG_CONFIG_PATH=$CHAMELEONDIR/build/lib/pkgconfig:$PKG_CONFIG_PATH


## HICMA
cd $HICMADIR
rm -rf build
mkdir -p build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$HICMADIR/build -DHICMA_USE_MPI=OFF -DHICMA_ENABLE_TESTING=OFF -DHICMA_ENABLE_TIMING=OFF -DBUILD_SHARED_LIBS:BOOL=ON # -DCMAKE_C_FLAGS="-fPIC"
make -j
make install

export PKG_CONFIG_PATH=$HICMADIR/build/lib/pkgconfig:$PKG_CONFIG_PATH



cd $EXAGEOSTATDEVDIR/..
export CPATH=$CPATH:/usr/local/include/coreblas && \
#export LD_LIBRARY_PATH="${MKLROOT}/lib/intel64_lin:$LD_LIBRARY_PATH" && \
export LIBRARY_PATH="$LD_LIBRARY_PATH"

## Modify src/Makefile, compilation flagss -> flagsl
R CMD build . && \
R CMD INSTALL ./exageostat_0.1.0.tar.gz
