
export FGLRESOURCEPATH=$(PWD)/etc

all:
	gsmake introspect.4pw

run:
	cd bin && fglrun main

run2:
	cd bin && fglrun interactive

clean:
	find . -name \*.42? -delete ;
	find . -name \*.4pdb -delete ;
