#import <Cocoa/Cocoa.h>

#include "nanovg.h"
#include "nanovg_CoreGraphics.h"

#include "demo.h"

#include <iostream>

#define NDOGS 5

@interface minimalDemoView : NSView
{
    // members
    NVGcontext *ctx;
    DemoData data;
    float t;

    int dogImage[NDOGS];
}

-(id)initWithFrame:(NSRect)frame;
-(void)drawRect:(NSRect)rect;
-(BOOL)isFlipped;

@end

void timerCallback( CFRunLoopTimerRef timer, void *info )
{
    NSView *view = (__bridge NSView *)info;
    [view setNeedsDisplay:YES];
}

@implementation minimalDemoView

- (BOOL) isFlipped
{
    return YES;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self->ctx = nvgCreateCoreGraphics(0);
        NSLog( @"self->ctx=%lu", (size_t)(self->ctx) );
        loadDemoData(self->ctx, &self->data);
        self->t = 0;

        for(int i=1;i<=NDOGS;++i)
        {
            char dogf[256];
            sprintf(dogf,"img/dog%d.png", i);
            std::cerr << "Loading image " << dogf << std::endl;
            self->dogImage[i-1] = nvgCreateImage(self->ctx, dogf, 0);
        }
    }
    
   
    CFTimeInterval      TIMER_INTERVAL = 1.0/60.0; // 60 FPS
    CFRunLoopTimerContext TimerContext = {0, (void *)CFBridgingRetain(self), NULL, NULL, NULL};
    CFAbsoluteTime             FireTime = CFAbsoluteTimeGetCurrent() + TIMER_INTERVAL;
    CFRunLoopTimerRef idleTimer = CFRunLoopTimerCreate(kCFAllocatorDefault,
                                                       FireTime,
                                                       TIMER_INTERVAL,
                                                       0, 0,
                                                       timerCallback,
                                                       &TimerContext);
    if (idleTimer)
        CFRunLoopAddTimer (CFRunLoopGetMain (), idleTimer, kCFRunLoopCommonModes);
    
    return self;
}

- (void)drawRect:(NSRect)rect
{
    // erase the background by drawing white
    [[NSColor colorWithDeviceRed:0.3f green:0.3f blue:0.3f alpha:1.0f] set]; //glClearColor(0.3f, 0.3f, 0.32f, 1.0f);
    [NSBezierPath fillRect:rect];
    NVGcontext *vg = self->ctx;

    //renderDemo(vg, 1.0, 1.0, 1000, 600, self->t, 2.0, &(self->data));

    nvgBeginFrame( vg, 1000, 600, 1.0 );

    for( int i=10; i<200; i+= 20 )
    {
       int off = 10 + i / 10;
       nvgResetTransform(vg);
       nvgRotate(vg, i / 200.0 );
       nvgTranslate( vg, 200, 200 );

       nvgBeginPath(vg);
       nvgMoveTo(vg, i, i);
       nvgLineTo(vg, i+off, i);
       nvgLineTo(vg, i+off, i+off);
       nvgLineTo(vg, i, i+off);
       nvgClosePath(vg);
       nvgFillColor(vg, nvgRGB(i,255,255-i));
       nvgFill(vg);
    }

    nvgResetTransform(vg);
    {
        nvgBeginPath(vg);
        int i=200, off=300;
        nvgMoveTo(vg, i, i);
        nvgLineTo(vg, i+off, i);
        nvgLineTo(vg, i+off, i+off);
        nvgLineTo(vg, i, i+off);
        nvgClosePath(vg);
        NVGpaint lg = nvgLinearGradient(vg, i, i, i+off, i+off, nvgRGB(255,0,0), nvgRGB(0,255,0));
        nvgFillPaint(vg, lg);
        nvgFill(vg);
    }
    for( int cdog = 0; cdog < NDOGS; ++cdog )
    {
        nvgBeginPath(vg);
        int i=20, ix=i+cdog * 100, offx=75 + sin(self->t) * 50, offy=150 + cos(self->t*2) * 30;
        nvgMoveTo(vg, ix, i);
        nvgLineTo(vg, ix+offx, i);
        nvgLineTo(vg, ix+offx, i+offy);
        nvgLineTo(vg, ix, i+offy);
        nvgClosePath(vg);
        NVGpaint lg = nvgImagePattern(vg, 0, 0, 100, 100, 0, self->dogImage[cdog], 1);
        nvgFillPaint(vg, lg);
        nvgFill(vg);
    }

    nvgEndFrame(vg );
    
    self->t += 1.0 / 60.0;
}

@end

int main ()
{
#if ! __has_feature(objc_arc)
   You muse compile this application with ARC;
#endif
   [NSApplication sharedApplication];
   [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
   
   id menubar = [NSMenu new];
   id appMenuItem = [NSMenuItem new];
   [menubar addItem:appMenuItem];
   [NSApp setMainMenu:menubar];
   
   id appMenu = [NSMenu new];
   id appName = [[NSProcessInfo processInfo] processName];
   id quitTitle = [@"Quit " stringByAppendingString:appName];
   id quitMenuItem = [[NSMenuItem alloc] initWithTitle:quitTitle
                                                action:@selector(terminate:)
                                         keyEquivalent:@"q"];
   
   [appMenu addItem:quitMenuItem];
   [appMenuItem setSubmenu:appMenu];
    
   id window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 1000, 600)
                                           styleMask:NSTitledWindowMask
                                             backing:NSBackingStoreBuffered defer:NO];

   id mView = [[minimalDemoView alloc] initWithFrame:NSMakeRect(0,0,1000,600)];
   [[window contentView] addSubview:mView];
   
   [window cascadeTopLeftFromPoint:NSMakePoint(20,20)];
   [window setTitle:appName];
   [window makeKeyAndOrderFront:nil];
   
   [NSApp activateIgnoringOtherApps:YES];
   [NSApp run];

   return 0;
}
