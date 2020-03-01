# sander-pmf-build
Utilities for testing and building of the [sander-pmf](https://github.com/kulhanek/sander-pmf) package.

## sander-pmf Features:
* modified version of sander from [AMBER](https://ambermd.org)
* integration with [PMFLib](https://github.com/kulhanek/pmflib)

## Building and Installation

### Testing Mode
```bash
$ git clone --recursive https://github.com/kulhanek/sander-pmf-build.git
$ cd sander-pmf-build
$ ./build-utils/00.init-links.sh
$ ./01.pull-code.sh
$ ./04.build-inline.sh   # build the code inline in src/
```

### Production Build into the Infinity software repository
```bash
$ git clone --recursive https://github.com/kulhanek/sander-pmf-build.git
$ cd sander-pmf-build
$ ./build-utils/00.init-links.sh
$ ./01.pull-code.sh
$ ./10.build-final.sh
```

### Production Build into Custom Directory
```bash
$ git clone --recursive https://github.com/kulhanek/sander-pmf-build.git
$ cd sander-pmf-build
$ ./build-utils/00.init-links.sh
$ ./01.pull-code.sh
$ cmake -DCMAKE_INSTALL_PREFIX=/path/to/sander-pmf/installation/directory
$ make
$ make install
```

