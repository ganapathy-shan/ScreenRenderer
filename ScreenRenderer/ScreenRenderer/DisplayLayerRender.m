//
//  DisplayLayerRender.m
//  ScreenRenderer
//
//  Created by Shanmuganathan on 01/07/21.
//

#import "DisplayLayerRender.h"
#import <AVFoundation/AVFoundation.h>

@implementation DisplayLayerRender
AVSampleBufferDisplayLayer* displayLayer;
bool timebaseSet = false;
NSView *displayview;

+ (DisplayLayerRender *)sharedManager
{
    static DisplayLayerRender *displayRenderer = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,
                  ^{
        displayRenderer = [[self alloc] init];
    });
    
    return displayRenderer;
}

-(id) init
{
    self = [super init];
    
    if(self)
    {
        [self initializeDisplayLayer];
    }
    
    return self;
}

-(void) initializeDisplayLayer
{
    displayLayer = [[AVSampleBufferDisplayLayer alloc] init];
}

-(void) setView:(NSView*) view
{
    displayview = view;
    displayLayer.bounds = view.bounds;
    displayLayer.frame = view.frame;
    displayLayer.backgroundColor = (__bridge CGColorRef _Nullable)([NSColor blackColor]);
    displayLayer.position = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds));
    displayLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    // Remove from previous view if exists
    [displayLayer removeFromSuperlayer];
    
    [view.layer addSublayer:displayLayer];
}

-(void) render:(CMSampleBufferRef) sampleBuffer
{
    double pts = CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer));
    
    if(!timebaseSet && pts != 0)
    {
        timebaseSet = true;
        
        CMTimebaseRef controlTimebase;
        CMTimebaseCreateWithMasterClock( CFAllocatorGetDefault(), CMClockGetHostTimeClock(), &controlTimebase );
        
        displayLayer.controlTimebase = controlTimebase;
        CMTimebaseSetTime(displayLayer.controlTimebase, CMTimeMake(pts, 1));
        CMTimebaseSetRate(displayLayer.controlTimebase, 1.0);
    }
    
    if([displayLayer isReadyForMoreMediaData])
    {
        [displayLayer enqueueSampleBuffer:sampleBuffer];
        [displayLayer removeFromSuperlayer];
        
        [displayview.layer addSublayer:displayLayer];
    }
    else
    {
        NSLog(@"Display layer not Ready");
    }
}

@end
