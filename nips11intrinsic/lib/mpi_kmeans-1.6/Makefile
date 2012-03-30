#
# Choose your compiler
#

# 
#CC = gcc-4.2
#CPP = g++-4.2
#CFLAGS=-O3 -ffast-math -fomit-frame-pointer -fPIC -mtune=k8 -march=k8 -Werror
CC = gcc
CPP = g++
CFLAGS=-O3 -ffast-math -fomit-frame-pointer -fPIC -Werror 
#CC=/agbs/share/sw/icc/bin/icc
#CFLAGS= -fast -DCOMPILE_WITH_ICC -Werror

#
# MPI KMEANS FLAGS
#
#VERBOSEFLAG=-DKMEANS_VERBOSE=0 # 0: silent, 1:iteration counter, 2:everything
#PRECISION=-DINPUT_TYPE=0 # 0: double, 1:float 


#
# MATLAB
#	
MATLABDIR=/Applications/MATLAB_R2011b.app
MATLAB_INCLUDE=-I$(MATLABDIR)/extern/include

#
# BOOST LIBS (for standalone only)
#
BOOST_LIB=-L/usr/local/Cellar/boost/1.49.0/lib -lboost_program_options-mt -lboost_filesystem-mt -lboost_system-mt
BOOST_INCLUDE=-I/usr/local/Cellar/boost/1.49.0/include/
# BOOST_LIB=-L/scratch_net/biwidl07/opt/boost-1.39.0/lib -lboost_program_options-gcc43-mt -lboost_filesystem-gcc43-mt -lboost_system-gcc43-mt
#BOOST_INCLUDE=-I/kyb/agbs/pgehler/include/boost-1_36/

#
# PYTHON
#
PYTHON_INCLUDE=-I/usr/include/python2.5
PYTHON_LIB=-lpython2.5
NUMPY_INCLUDE=-I/usr/lib/python2.5/site-packages/numpy/core/include

#
# ARCHITECURE
# 

# 32 bit
#SUFFIX=mexglx
#MATLAB_LIB=-L$(MATLABDIR)/bin/glnx86 -lmex

# 64 bit
#SUFFIX=mexa64
#MATLAB_LIB=-L$(MATLABDIR)/bin/glnxa64 -lmex

# 64 bit mac (change by aj)
SUFFIX=mexmaci64
MATLAB_LIB=-L$(MATLABDIR)/bin/maci64 -lmex -lmx -lmat


LIBS=/usr/lib/libstdc++.dylib /usr/lib/libm.dylib


all: standalone matlab libmpikmeans python
matlab: mpi_kmeans_mex.$(SUFFIX) mpi_assign_mex.$(SUFFIX)

standalone:	mpi_kmeans_main mpi_assign_main
python:	cython_wrapper

mpi_kmeans.o:	mpi_kmeans.cxx mpi_kmeans.h
	$(CC) $(CFLAGS) $(VERBOSEFLAG) $(PRECISION) -c -o $@ mpi_kmeans.cxx

libmpikmeans:	mpi_kmeans.o
	ar rc libmpikmeans.a mpi_kmeans.o
	ranlib libmpikmeans.a
	$(CC) -shared -Wl,-install_name,libmpikmeans.so -fPIC $(CFLAGS) $(VERBOSEFLAG) -o libmpikmeans.so $(VERBOSEFLAGS) $(PRECISION) mpi_kmeans.cxx

mpi_kmeans_main.o:	mpi_kmeans_main.cxx
	$(CC) $(CFLAGS) $(VERBOSEFLAG) $(BOOST_INCLUDE) -c -o mpi_kmeans_main.o mpi_kmeans_main.cxx 

mpi_assign_main.o:	mpi_assign_main.cxx
	$(CC) $(CFLAGS) $(VERBOSEFLAG) $(BOOST_INCLUDE) -c -o mpi_assign_main.o mpi_assign_main.cxx 

mpi_kmeans_main:	libmpikmeans mpi_kmeans_main.o
#removed -static option 
	$(CC) mpi_kmeans_main.o  $(CFLAGS) $(VERBOSEFLAG) -L/usr/lib/ -o mpi_kmeans -lm libmpikmeans.a \
		$(BOOST_LIB) $(LIBS)

mpi_assign_main:	libmpikmeans mpi_assign_main.o
#removed -static option 
	$(CC) mpi_assign_main.o $(CFLAGS) $(VERBOSEFLAG) -L/usr/lib/ -o mpi_assign -lm libmpikmeans.a \
		$(BOOST_LIB) $(LIBS)

%_mex.o:	%_mex.cxx
	$(CC) $(CFLAGS) $(VERBOSEFLAG) $(MATLAB_INCLUDE) $(PRECISION) -c $^ -o $@

mpi_kmeans_mex.$(SUFFIX):	libmpikmeans mpi_kmeans_mex.o 
	$(CC) mpi_kmeans_mex.o -shared -o mpi_kmeans_mex.$(SUFFIX) libmpikmeans.a $(MATLAB_LIB) 
#MATLAB_LIB=-L$(MATLABDIR)/bin/maci64 -lmex
mpi_assign_mex.$(SUFFIX):	libmpikmeans mpi_assign_mex.o
	$(CC) mpi_assign_mex.o -shared -o mpi_assign_mex.$(SUFFIX) libmpikmeans.a $(MATLAB_LIB)

cython_wrapper:	py_kmeans.c mpi_kmeans.o
	$(CPP) $(CFLAGS) $(VERBOSEFLAG) $(PYTHON_INCLUDE) $(NUMPY_INCLUDE) -c -o py_kmeans.o py_kmeans.c
	$(CPP) $(CFLAGS) $(VERBOSEFLAG) $(PYTHON_LIB) -lm -pthread -shared py_kmeans.o mpi_kmeans.o  -o py_kmeans.so 

test:	
	matlab -nojvm -r "test_code;exit"

clean:	
	rm -f *.o
	rm -f *.mexglx
	rm -f *.mexa64
	rm -f libmpikmeans.so
	rm -f libmpikmeans.a
	rm -f mpi_assign mpi_kmeans

