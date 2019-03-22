bld:
	mkdir bld

product:
	mkdir product

clean:
	rm -rf bld product

OPT=-g

bld/%.o: src/%.mm bld
	clang $(OPT) -c -ObjC++ -Ilibs/nanovg/example -Ilibs/nanovg/src -Ilibs/nanovg_CoreGraphics/include -fobjc-arc -fmodules -mmacosx-version-min=10.11  $< -o $@

bld/nanovg_CoreGraphics.o: libs/nanovg_CoreGraphics/src/nanovg_CoreGraphics.mm
	clang $(OPT) -c -ObjC++ -Ilibs/nanovg/example -Ilibs/nanovg/src -Ilibs/nanovg_CoreGraphics/include -fobjc-arc -fmodules -mmacosx-version-min=10.11  $< -o $@	

bld/demo.c: libs/nanovg/example/demo.c Makefile
	cat $< | sed 's/glReadPixel/\/\/glPixel/' \
			 | sed 's/\.\.\/example/libs\/nanovg\/example/' \
			 | sed 's/drawParagraph(vg/return; drawParagraph(vg/' \
		> $@

bld/demo.o:	bld/demo.c
	clang $(OPT) -c $<  -Ilibs/nanovg/example -Ilibs/nanovg/src -o $@

bld/nanovg.o:	libs/nanovg/src/nanovg.c
	clang $(OPT) -c $<  -Ilibs/nanovg/src -o $@

product/minimalApp:	product bld/minimalApp.o bld/demo.o bld/nanovg.o bld/nanovg_CoreGraphics.o
	clang $(OPT) -o $@ bld/minimalApp.o bld/demo.o bld/nanovg.o bld/nanovg_CoreGraphics.o -framework Cocoa -lstdc++


all:	product/minimalApp

run:	all
	./product/minimalApp

cleanrun:	clean run

cleandebug:	clean product/minimalApp
	lldb ./product/minimalApp
