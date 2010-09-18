OOC_FLAGS=-driver=sequence -v -gcc -g -noclean +-w -sourcepath=source/ $(shell echo $$OOC_FLAGS)
OOC?=rock
TEST?=track_editor

%:
	${OOC} ${OOC_FLAGS} test/$@ -o=$@.x

all:
	@echo "Usage: make <testname>"

clean:
	rm -rf rock_tmp/ .libs/ *.x

prof:
	GC_DONT_GC=1 valgrind --tool=callgrind ./${TEST}.x
