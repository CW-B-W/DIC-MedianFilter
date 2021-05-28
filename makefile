.PHONY: help
help:
	@printf 'usage: make <option>\n'
	@printf '\n'
	@printf 'options:\n'
	@printf '\tgentest\t\tgenerate img.dat & golden.dat with image.jpg\n'
	@printf '\tcppMFE\t\tuse c++ MFE to generate golden_cpp.dat\n'
	@printf '\tclean\t\tclean compiled files\n'

.PHONY: gentest
gentest:
	python3 main.py

.PHONY: cppMFE
cppMFE: cppMFE.out
	./cppMFE.out

cppMFE.out: cppMFE.cpp
	g++ cppMFE.cpp -o cppMFE.out --std=c++14 -O3

.PHONY: clean
clean:
	rm *.out
