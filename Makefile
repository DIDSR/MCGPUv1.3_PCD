# ========================================================================================
#                                  MAKEFILE MC-GPU v1.3_PCD
#
# 
#   ** Simple script to compile the code MC-GPU v1.3_PCD.
#      For information on how to compile the code for the CPU or using MPI, read the
#      file "make_MC-GPU_v1.3_PCD.sh".
#
#      The installation paths to the CUDA toolkit and SDK (http://www.nvidia.com/cuda) 
#      and the MPI libraries (openMPI) may have to be modified by the user. 
#      The zlib.h library is used to allow gzip-ed input files.
#
#      Default paths:
#         CUDA:  /usr/local/cuda
#         SDK:   /usr/local/cuda/samples
#         MPI:   /usr/include/openmpi
#
# 
#                      @file    Makefile
#                      @author  Preetham Rudrarju [Preetham.Rudraraju(at)fda.hhs.gov]
#                               Andreu Badal [Andreu.Badal-Soler(at)fda.hhs.gov]
#                               Bahaa Ghammraoui  [Bahaa.Ghammraoui(at)fda.hhs.gov]
#                      @date    02/01/2024
#   
# ========================================================================================

SHELL = /bin/sh

# Suffixes:
.SUFFIXES: .cu .o

# Compilers and linker:
CC = nvcc

# Program's name:
PROG = MC-GPU_v1.3_PCD.x

# Include and library paths:
CUDA_PATH = /usr/local/cuda/include/
CUDA_LIB_PATH = /usr/local/cuda/lib64/
CUDA_SDK_PATH = /usr/local/cuda/samples/common/inc/
CUDA_SDK_LIB_PATH = /usr/local/cuda/samples/common/lib/linux/x86_64/
OPENMPI_PATH = /usr/include/openmpi


# Compiler's flags:
CFLAGS = -m64 -O3 -use_fast_math -DUSING_CUDA -I./ -I$(CUDA_PATH) -I$(CUDA_SDK_PATH) -L$(CUDA_SDK_LIB_PATH) -I$(OPENMPI_PATH) -L$(CUDA_LIB_PATH) -lz --ptxas-options=-v 
#  NOTE: you can compile the code for a specific GPU compute capability. For example, for compute capabilities 5.0 and 6.1, use flags:
#    -gencode=arch=compute_50,code=sm_50 -gencode=arch=compute_61,code=sm_61


# Command to erase files:
RM = /bin/rm -vf

# .cu files path:
SRCS = MC-GPU_v1.3_PCD.cu

# Building the application:
default: $(PROG)
$(PROG):
	$(CC) $(CFLAGS) $(SRCS) -o $(PROG)

# Rule for cleaning re-compilable files
clean:
	$(RM) $(PROG)

