//
//  DisplayLayerRender.h
//  ScreenRenderer
//
//  Created by Shanmuganathan on 01/07/21.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <CoreMedia/CoreMedia.h>

NS_ASSUME_NONNULL_BEGIN

@interface DisplayLayerRender : NSObject
+ (DisplayLayerRender *)sharedManager;
-(void) setView:(NSView*) view;
- (void) render:(CMSampleBufferRef)sampleBuffer;
@end

NS_ASSUME_NONNULL_END
