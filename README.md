# DIC-MedianFilter

## files
* `testfixture.v` is the testbench of verilog module `MFE`
* `MFE_MJ.v` is the final verilog solution for this task
* `MF.cpp` is the c++ implementation of `MFE_MJ.v`
* `main.py` is the python tool for generating salf-and-pepper noise image
* `cppMFE.cpp` is the c++ implementation of median filter, used for generating `golden_cpp.dat`
* `img.dat` is the input image data of the verilog module MFE
* `golden.dat` is the expected result of processed `img.dat`
* `golden_cpp.dat` is the `golden.dat` generated with `cppMFE.cpp`
* `presim/` contains the results of presim
* `postsim/` contains the results of postsim
* `unused/` contains the abandoned solutions

## tools usage
$ make help  
Show help messages

$ make gentest  
Call main.py to generate img.dat & golden.dat from image.jpg

$ make cppMFE  
Compile cppMFE.cpp & Call cppMFE.out to generate golden_cpp.dat from img.dat

$ make cppMJ  
Run MJ.cpp

$ make clean  
Clean compiled files
