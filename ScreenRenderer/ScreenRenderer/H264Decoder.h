//
//  H264Decoder.h
//  ScreenRenderer
//
//  Created by Shanmuganathan on 01/07/21.
//

#import <Foundation/Foundation.h>
#import <VideoToolbox/VideoToolbox.h>

NS_ASSUME_NONNULL_BEGIN

@interface H264Decoder : NSObject

@property (nonatomic, assign) VTDecompressionSessionRef decompressionSession;

- (void) createDecompSessionWithDescription:(CMVideoFormatDescriptionRef)formatDesc;
- (void) render:(CMSampleBufferRef)sampleBuffer;
- (BOOL) needNewSessionForDescription:(CMVideoFormatDescriptionRef)formatDesc;

@end

NS_ASSUME_NONNULL_END
