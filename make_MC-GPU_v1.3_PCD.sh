# !/bin/bash
# 
#   ** Simple script to compile the code MC-GPU v1.3_PCD with CUDA 5.0 **
#
#      The installations paths to the CUDA toolkit and SDK (http://www.nvidia.com/cuda) and the MPI 
#      library path may have to be adapted before runing the script!
#      The zlib.h library is used to allow gzip-ed input files.
# 
#      Default paths:
#         CUDA:  /usr/local/cuda
#         SDK:   /usr/local/cuda/samples
#         MPI:   /usr/include/openmpi
#
# 
#                      @file    make_MC-GPU_v1.3_PCD.sh
#                      @author  Preetham Rudrarju [Preetham.Rudraraju(at)fda.hhs.gov]
#                               Andreu Badal [Andreu.Badal-Soler@fda.hhs.gov]
#                               Bahaa Ghammraoui  [Bahaa.Ghammraoui(at)fda.hhs.gov]
#                               
#                               
#                      @date    02/01/2024
#   

# -- Compile GPU code for compute capability 1.3 and 2.0, with MPI:

echo " "
echo " -- Compiling MC-GPU v1.3_PCD with CUDA <11.5 for both compute capability 2.0 and 3.0 (64 bits), with MPI:"
echo "    To run a simulation in parallel with openMPI execute:"
echo "      $ time mpirun --tag-output -v -x LD_LIBRARY_PATH -hostfile hostfile_gpunodes -n 22 /GPU_cluster/MC-GPU_v1.3_PCD.x /GPU_cluster/MC-GPU_v1.3_PCD.in | tee MC-GPU_v1.3_PCD.out"
echo " "
echo "nvcc MC-GPU_v1.3_PCD.cu -o MC-GPU_v1.3_PCD.x -m64 -O3 -use_fast_math -DUSING_CUDA -I. -I/usr/local/cuda/include -I/usr/local/cuda/samples/common/inc -I/usr/local/cuda/samples/shared/inc/ -I/usr/include/openmpi -L/usr/lib/ -lz --ptxas-options=-v -gencode=arch=compute_20,code=sm_20 -gencode=arch=compute_30,code=sm_30"
nvcc MC-GPU_v1.3_PCD.cu -o MC-GPU_v1.3_PCD.x -m64 -O3 -use_fast_math -DUSING_CUDA -I. -I/usr/local/cuda/include -I/usr/local/cuda/samples/common/inc -I/usr/local/cuda/samples/shared/inc/ -I/usr/include/openmpi -L/usr/lib/ -lz --ptxas-options=-v -gencode=arch=compute_20,code=sm_20 -gencode=arch=compute_30,code=sm_30

## Notes on gencode:  For later cuda version, you may use -arch=native to save time looking up the capability number.
## i.e. `-arch=native` instead of `-gencode=arch=compute_30,code=sm_30`
