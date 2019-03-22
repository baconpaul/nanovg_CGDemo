bld:
	mkdir bld

product:
	mkdir product

clean:
	rm -rf bld product

OPT=-g
CLANG_FLAGS=$(OPT) -Werror
OBJS=bld/minimalApp.o bld/demo.o bld/nanovg.o bld/nanovg_CoreGraphics.o bld/nanovg_CoreGraphicsCocoa.o

bld/%.o: src/%.mm bld
	clang $(CLANG_FLAGS) -c -ObjC++ -Ilibs/nanovg/example -Ilibs/nanovg/src -Ilibs/nanovg_CoreGraphics/include -fobjc-arc -fmodules -mmacosx-version-min=10.11  $< -o $@

bld/nanovg_CoreGraphics.o: libs/nanovg_CoreGraphics/src/nanovg_CoreGraphics.cpp
	clang $(CLANG_FLAGS) -c -ObjC++ -Ilibs/nanovg/example -Ilibs/nanovg/src -Ilibs/nanovg_CoreGraphics/include -fobjc-arc -fmodules -mmacosx-version-min=10.11  $< -o $@	

bld/nanovg_CoreGraphicsCocoa.o: libs/nanovg_CoreGraphics/src/nanovg_CoreGraphicsCocoa.mm
	clang $(CLANG_FLAGS) -c -ObjC++ -Ilibs/nanovg/example -Ilibs/nanovg/src -Ilibs/nanovg_CoreGraphics/include -fobjc-arc -fmodules -mmacosx-version-min=10.11  $< -o $@	

bld/demo.c: libs/nanovg/example/demo.c Makefile
	cat $< | sed 's/glReadPixel/\/\/glPixel/' \
			 | sed 's/\.\.\/example/libs\/nanovg\/example/' \
			 | sed 's/drawParagraph(vg/return; drawParagraph(vg/' \
		> $@

bld/demo.o:	bld/demo.c
	clang $(CLANG_FLAGS) -c $<  -Ilibs/nanovg/example -Ilibs/nanovg/src -o $@

bld/nanovg.o:	libs/nanovg/src/nanovg.c
	clang $(CLANG_FLAGS) -c $<  -Ilibs/nanovg/src -o $@

product/minimalApp:	product $(OBJS)
	clang $(CLANG_FLAGS) -o $@ $(OBJS) -framework Cocoa -lstdc++


all:	product/minimalApp

run:	all
	./product/minimalApp

cleanrun:	clean run

cleandebug:	clean product/minimalApp
	lldb ./product/minimalApp
