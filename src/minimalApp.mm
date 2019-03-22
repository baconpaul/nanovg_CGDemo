#import <Cocoa/Cocoa.h>

#include "nanovg.h"
#include "nanovg_CoreGraphics.h"

#include "demo.h"

@interface minimalDemoView : NSView
{
   // members
   NVGcontext *ctx;
   DemoData data;
   float t;
}

-(id)initWithFrame:(NSRect)frame;
-(void)drawRect:(NSRect)rect;

@end

void timerCallback( CFRunLoopTimerRef timer, void *info )
{
   NSView *view = (__bridge NSView *)info;
   //[view setNeedsDisplay:YES];
}

@implementation minimalDemoView

- (id)initWithFrame:(NSRect)frame {
   self = [super initWithFrame:frame];
   if (self) {
      self->ctx = nvgCreateCoreGraphics(0);
      NSLog( @"self->ctx=%lu", (size_t)(self->ctx) );
      loadDemoData(self->ctx, &self->data);
      self->t = 0;
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
    [[NSColor whiteColor] set];
    [NSBezierPath fillRect:rect];

    renderDemo(self->ctx, 1.0, 1.0, 1000, 600, self->t, 2.0, &(self->data));

    nvgBeginFrame( self->ctx, 1000, 600, 1.0 );

    for( int i=10; i<200; i+= 20 )
    {
       int off = 10 + i / 10;
       nvgResetTransform(self->ctx);
       nvgRotate(self->ctx, i / 200.0 );
       nvgTranslate( self->ctx, 200, 200 );

       nvgBeginPath(self->ctx);
       nvgMoveTo(self->ctx, i, i);
       nvgLineTo(self->ctx, i+off, i);
       nvgLineTo(self->ctx, i+off, i+off);
       nvgLineTo(self->ctx, i, i+off);
       nvgClosePath(self->ctx);
       nvgFillColor(self->ctx, nvgRGB(i,255,255-i));
       nvgFill(self->ctx);
    }

    nvgResetTransform(self->ctx);
    nvgBeginPath(self->ctx);
    int i=200, off=300;
    nvgMoveTo(self->ctx, i, i);
    nvgLineTo(self->ctx, i+off, i);
    nvgLineTo(self->ctx, i+off, i+off);
    nvgLineTo(self->ctx, i, i+off);
    nvgClosePath(self->ctx);
    NVGpaint lg = nvgLinearGradient(self->ctx, 0,0,1,0, nvgRGB(255,0,0), nvgRGB(0,255,0));
    nvgFillPaint(self->ctx, lg);
    nvgFill(self->ctx);
    
    nvgEndFrame(self->ctx );
    
    self->t += 1.0 / 10.0;
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
