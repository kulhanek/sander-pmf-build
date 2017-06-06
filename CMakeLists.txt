# ==============================================================================
# SANDER-PMF Composite CMake File
# ==============================================================================

CMAKE_MINIMUM_REQUIRED(VERSION 2.8 FATAL_ERROR)
#SET(CMAKE_VERBOSE_MAKEFILE ON)

# ==============================================================================
# conditional setup ------------------------------------------------------------
# ==============================================================================

# target architecture: allowed values are: i686, em64t
SET(TARGET_ARCHITECTURE em64t)

# ==============================================================================
# project setup ----------------------------------------------------------------
# ==============================================================================

# what languages we use ---------------------------
ENABLE_LANGUAGE(C)
ENABLE_LANGUAGE(CXX)
ENABLE_LANGUAGE(Fortran)

# this is composite project ----------------------
SET(COMPOSITE_PROJECT TRUE)
SET(DEVELOPMENT_ROOT "${CMAKE_BINARY_DIR}/src")

# extra options ----------------------------------
SET(LIBS_COMPLEX        OFF CACHE BOOL "Support for complex numbers?" FORCE)
SET(PMFLIB_HAVE_XBPLIB  OFF  CACHE BOOL "Is XBPLib available?" FORCE)
SET(TRY_QT_LIB          OFF  CACHE INTERNAL "QT is not neccessary" FORCE)
SET(PMFLIB_SANDER_DRV   ON   CACHE BOOL "Should the driver for sander be built?" FORCE)
SET(PMFLIB_PMEMD_DRV    OFF  CACHE BOOL "Should the driver for pmemd be built?" FORCE)
SET(PMFLIB_CPMD_DRV     OFF  CACHE BOOL "Should the driver for cpmd be built?" FORCE)
SET(PMFLIB_CP2K_DRV     OFF  CACHE BOOL "Should the driver for cp2k be built?" FORCE)
SET(PMFLIB_XDYNBP_DRV   OFF  CACHE BOOL "Should the driver for xdynbp be built?")
SET(PMFLIB_LIBATOMS_DRV OFF  CACHE BOOL "Should the driver for libatoms be built?" FORCE)

# ==============================================================================
# libraries --------------------------------------------------------------------
# ==============================================================================

# try to find math kernel library
SET(MKL_HOME "$ENV{MKL_HOME}")

IF(MKL_HOME)
    SET(MKL_FOUND TRUE)
    LINK_DIRECTORIES(${MKL_HOME})
    IF(TARGET_ARCHITECTURE STREQUAL i686)
        SET(MKL_LIBS mkl_intel mkl_sequential mkl_core pthread)
    ELSEIF(TARGET_ARCHITECTURE STREQUAL em64t)
        SET(MKL_LIBS mkl_intel_lp64 mkl_sequential mkl_core pthread)
    ELSE(TARGET_ARCHITECTURE STREQUAL i686)
        MESSAGE(FATAL_ERROR "ERROR: Unsupported target architecture: ${TARGET_ARCHITECTURE}")
    ENDIF(TARGET_ARCHITECTURE STREQUAL i686)
ENDIF(MKL_HOME)

# MPI ======================
GET_FILENAME_COMPONENT(FCOMP_NAME ${CMAKE_Fortran_COMPILER} NAME_WE)
if(FCOMP_NAME STREQUAL mpif90)
    SET(MPI_ENABLED TRUE)
    SET(MPI_HOME "$ENV{MPI_HOME}")
    MESSAGE("-- MPI status: enabled")
    MESSAGE("-- MPI home:   ${MPI_HOME}")
ENDIF(FCOMP_NAME STREQUAL mpif90)

# -----------------------------------------------------------------------------

# intel core libraries
SET(INTEL_CORE_HOME "$ENV{INTEL_CORE_HOME}")

# -----------------------------------------------------------------------------

LINK_DIRECTORIES(${CMAKE_BINARY_DIR}/lib)
LINK_DIRECTORIES(${CMAKE_BINARY_DIR}/lib/drivers)

# ==============================================================================
# rpaths -----------------------------------------------------------------------
# ==============================================================================

# use, i.e. don't skip the full RPATH for the build tree
SET(CMAKE_SKIP_BUILD_RPATH  FALSE)

# when building, don't use the install RPATH already
# (but later on when installing)
SET(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE) 

# the RPATH to be used when installing
SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib/drivers:${CMAKE_INSTALL_PREFIX}/lib")

IF(INTEL_CORE_HOME)
    MESSAGE("INTEL_CORE_HOME: ${INTEL_CORE_HOME}")
    SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_RPATH}:${INTEL_CORE_HOME}")
ENDIF(INTEL_CORE_HOME)

IF(MPI_ENABLED)
    SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_RPATH}:${MPI_HOME}/lib")
ENDIF(MPI_ENABLED)

# add the automatically determined parts of the RPATH
# which point to directories outside the build tree to the install RPATH
SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH FALSE)

# ==============================================================================
# compiler setups --------------------------------------------------------------
# ==============================================================================

IF(TARGET_ARCHITECTURE STREQUAL i686)
    # C options
    SET(CMAKE_C_FLAGS_RELEASE "-O2 -m32")
    SET(CMAKE_C_FLAGS_DEBUG "-g -m32 -Wall -Werror -pedantic-errors -Wundef -Wno-long-long")
    # C++ options
    SET(CMAKE_CXX_FLAGS_RELEASE "-O2 -m32")
    SET(CMAKE_CXX_FLAGS_DEBUG "-O0 -m32 -g -Wall -Werror -pedantic-errors -Wundef -Wno-long-long")
    SET(CPU_ARCH 32)
    SET_PROPERTY(GLOBAL PROPERTY FIND_LIBRARY_USE_LIB64_PATHS FALSE)
ELSEIF(TARGET_ARCHITECTURE STREQUAL em64t)
    # C options
    SET(CMAKE_C_FLAGS_RELEASE "-O2 -m64")
    SET(CMAKE_C_FLAGS_DEBUG "-g -m64 -Wall -Werror -pedantic-errors -Wundef -Wno-long-long")
    # C++ options
    SET(CMAKE_CXX_FLAGS_RELEASE "-O2 -m64")
    SET(CMAKE_CXX_FLAGS_DEBUG "-O0 -m64 -g -Wall -Werror -pedantic-errors -Wundef -Wno-long-long")
    SET(CPU_ARCH 64)
ELSE(TARGET_ARCHITECTURE STREQUAL i686)
    MESSAGE(FATAL_ERROR "ERROR: Unsupported target architecture: ${TARGET_ARCHITECTURE}")
ENDIF(TARGET_ARCHITECTURE STREQUAL i686)

# get the name of fortran compiler
get_filename_component(FCOMP_NAME ${CMAKE_Fortran_COMPILER} NAME_WE)

# Fortran options
SET(CMAKE_Fortran_FLAGS_RELEASE "-O2 ")
SET(CMAKE_Fortran_FLAGS_DEBUG "-O0")

# fix the problem with dynamic libraries and xlf compiler on SP5
IF(FCOMP_NAME STREQUAL ifort)
    # ifort
    IF(TARGET_ARCHITECTURE STREQUAL em64t)
        SET(CMAKE_Fortran_FLAGS_RELEASE "-O3 -ip")
        SET(CMAKE_Fortran_FLAGS_DEBUG "-O0 -g -std95 -traceback -check all -warn all")
    ELSE(TARGET_ARCHITECTURE STREQUAL em64t)
        MESSAGE(FATAL_ERROR "ERROR: Unsupported target architecture: ${TARGET_ARCHITECTURE}")
    ENDIF(TARGET_ARCHITECTURE STREQUAL em64t)
ELSEIF(FCOMP_NAME STREQUAL gfortran)
    # gfortran
    IF(TARGET_ARCHITECTURE STREQUAL em64t)
        SET(CMAKE_Fortran_FLAGS_RELEASE "-O3 -ffree-line-length-none")
        SET(CMAKE_Fortran_FLAGS_DEBUG "-O0 -g")
    ELSE(TARGET_ARCHITECTURE STREQUAL em64t)
        MESSAGE(FATAL_ERROR "ERROR: Unsupported target architecture: ${TARGET_ARCHITECTURE}")
    ENDIF(TARGET_ARCHITECTURE STREQUAL em64t)
ELSEIF(FCOMP_NAME STREQUAL mpif90)
    # mpif90 ifort
    IF(TARGET_ARCHITECTURE STREQUAL em64t)
        SET(CMAKE_Fortran_FLAGS_RELEASE "-O3 -ffree-line-length-none")
        SET(CMAKE_Fortran_FLAGS_DEBUG "-O0 -g")
    ELSE(TARGET_ARCHITECTURE STREQUAL em64t)
        MESSAGE(FATAL_ERROR "ERROR: Unsupported target architecture: ${TARGET_ARCHITECTURE}")
    ENDIF(TARGET_ARCHITECTURE STREQUAL em64t)
ENDIF(FCOMP_NAME STREQUAL ifort)

SET(CMAKE_BUILD_TYPE Release)
#SET(CMAKE_BUILD_TYPE Debug)

# ==============================================================================
# project subdirectories  ------------------------------------------------------
# ==============================================================================

# third party ------------------------------------
IF(NOT MKL_FOUND)
    ADD_SUBDIRECTORY(src/thirdparty/blas/netlib)
    ADD_SUBDIRECTORY(src/thirdparty/lapack/3.1.1)
ENDIF(NOT MKL_FOUND)
ADD_SUBDIRECTORY(src/thirdparty/ranlux/1.0)
ADD_SUBDIRECTORY(src/thirdparty/csparse/2.2.1)
ADD_SUBDIRECTORY(src/thirdparty/netcdfcore/4.0.1)

# projects ---------------------------------------
ADD_SUBDIRECTORY(src/projects/hipoly/1.0)
ADD_SUBDIRECTORY(src/projects/scimafic/1.0)
ADD_SUBDIRECTORY(src/projects/prmfile/1.0)
ADD_SUBDIRECTORY(src/projects/netlib/1.0)
ADD_SUBDIRECTORY(src/projects/pmflib/5.0)

# proprietary ------------------------------------
ADD_SUBDIRECTORY(src/thirdparty/sander-pmf/17)

