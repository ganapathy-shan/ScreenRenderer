//
//  H264Decoder.h
//  ScreenRenderer
//
//  Created by Shanmuganathan on 01/07/21.
//

#import <Foundation/Foundation.h>
#import <VideoToolbox/VideoToolbox.h>

NS_ASSUME_NONNULL_BEGIN
@protocol H264DecoderDelegate <NSObject>

- (void) h264DecoderCompletionWithImageBuffer:(CVImageBufferRef) imageBuffer;

@end

@interface H264Decoder : NSObject

@property (nonatomic, assign) VTDecompressionSessionRef decompressionSession;
@property (nonatomic, weak) id<H264DecoderDelegate> delegate;

- (id) initWithDelegate:(id<H264DecoderDelegate>)delegate;
- (void) createDecompSessionWithDescription:(CMVideoFormatDescriptionRef)formatDesc;
- (void) h264DecompressSampleBuffer:(CMSampleBufferRef)sampleBuffer;
- (BOOL) needNewSessionForDescription:(CMVideoFormatDescriptionRef)formatDesc;

@end

NS_ASSUME_NONNULL_END
