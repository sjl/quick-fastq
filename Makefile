all: build/quick-fastq


build/asdf-manifest: Makefile quick-fastq.asd
	mkdir -p build/
	sbcl --disable-debugger --quit --eval '(ql:write-asdf-manifest-file "build/asdf-manifest")'

build/quick-fastq: quick-fastq.lisp build-binary.sh build/asdf-manifest Makefile
	mkdir -p build/
	./build-binary.sh
