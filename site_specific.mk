## Site-dependent definitions included in Makefiles

## Machine for which to build Ferret
## Use $(HOSTTYPE) to build natively for the machine you are using
# BUILDTYPE	= $(HOSTTYPE)
# BUILDTYPE	= x86_64-linux
# BUILDTYPE	= i386-linux
# BUILDTYPE	= i386-apple-darwin
BUILDTYPE	= intel-mac

## Installation directory for built Ferret.  Using the "install"
## Makefile target circumvents the need to create the fer_*.tar.gz
## files just for creating a Ferret installation.
# INSTALL_FER_DIR = $(HOME)/ferret_distributions/rhel6_64
INSTALL_FER_DIR = $(FER_DIR)

## Installation directory for HDF5 static libraries
## (contains include and lib or lib64 subdirectories)
# HDF5_DIR	= /usr
# HDF5_DIR	= /usr/local
HDF5_DIR	= /usr/local/hdf5-1.8.16

## Installation directory for NetCDF static libraries
## (contains include and lib or lib64 subdirectories)
# NETCDF4_DIR	= /usr
# NETCDF4_DIR	= /usr/local
NETCDF4_DIR	= /usr/local/netcdf-4.4.0

## Installation directory for readline static libraries
## (contains include and lib or lib64 subdirectories)
# READLINE_DIR	= /
READLINE_DIR	= /usr
# READLINE_DIR	= /usr/local

## Installation directory for libz static library
## (contains include and lib or lib64 subdirectories)
## Version 1.2.5 or higher recommended by NetCDF
# LIBZ_DIR	= /
LIBZ_DIR	= /usr
# LIBZ_DIR	= /usr/local

## Java home directory - this may be predefined
## from your shell environment.  If JAVA_HOME is defined,
## $(JAVA_HOME)/bin/javac and $(JAVA_HOME)/bin/jar is
## called to build threddsBrowser.jar; otherwise, 
## threddsBrowser.jar is not built and the Ferret command
## SET DATA /BROWSE (or the alias OPEN) will not work.
# JAVA_HOME	= /usr/java/latest
# JAVA_HOME	= /usr/lib/jvm/java-oracle
# JAVA_HOME	= /usr/lib/jvm/java-sun
# JAVA_HOME	= /usr/lib/jvm/java
JAVA_HOME	= /Library/Java/JavaVirtualMachines/jdk1.8.0_60.jdk/Contents/Home

##
