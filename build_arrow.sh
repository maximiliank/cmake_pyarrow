#!/bin/bash

set -e

VERSION=6.0.0
VERSIONSTR=${VERSION//./_}
ARROW_DIR=arrow-apache-arrow-${VERSION}
ARROW_TGZ=apache-arrow-${VERSION}.tar.gz
INSTALLATIONFOLDER=/opt/arrow_${VERSIONSTR}

if [ ! -f ${ARROW_DIR} ]; then
    if [ ! -f ${ARROW_TGZ} ]; then
        wget https://github.com/apache/arrow/archive/refs/tags/${ARROW_TGZ}
    fi
    tar xf ${ARROW_TGZ}
fi
mkdir -p build_arrow
cd build_arrow

#CC=/usr/bin/gcc-10 CXX=/usr/bin/g++-10 
cmake -DARROW_SIMD_LEVEL=AVX512 -DARROW_PYTHON=ON -DCMAKE_INSTALL_PREFIX=${INSTALLATIONFOLDER} ../${ARROW_DIR}/cpp
make -j 12
sudo make install

cd ../${ARROW_DIR}/python
PYARROW_CMAKE_OPTIONS="-DARROW_HOME=${INSTALLATIONFOLDER}" python setup.py build_ext --build-type=release --bundle-arrow-cpp bdist_wheel
