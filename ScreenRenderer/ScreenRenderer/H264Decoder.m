//
//  H264Decoder.m
//  ScreenRenderer
//
//  Created by Shanmuganathan on 01/07/21.
//

#import "H264Decoder.h"

@implementation H264Decoder

- (void) createDecompSessionWithDescription:(CMVideoFormatDescriptionRef)formatDesc
{
    // make sure to destroy the old VTD session
    _decompressionSession = NULL;
    VTDecompressionOutputCallbackRecord callBackRecord;
    callBackRecord.decompressionOutputCallback = decompressionSessionDecodeFrameCallback;
    
    // this is necessary if you need to make calls to Objective C "self" from within in the callback method.
    callBackRecord.decompressionOutputRefCon = (__bridge void *)self;
    
    // you can set some desired attributes for the destination pixel buffer.  I didn't use this but you may
    // if you need to set some attributes, be sure to uncomment the dictionary in VTDecompressionSessionCreate
    NSDictionary *destinationImageBufferAttributes =
    [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool:YES], (id)kCVPixelBufferMetalCompatibilityKey,
     nil];
    
    OSStatus status =  VTDecompressionSessionCreate(NULL, formatDesc, NULL,
                                                    NULL, // (__bridge CFDictionaryRef)(destinationImageBufferAttributes)
                                                    &callBackRecord, &_decompressionSession);
    NSLog(@"Video Decompression Session Create: \t %@", (status == noErr) ? @"successful!" : @"failed...");
    if(status != noErr) NSLog(@"\t\t VTD ERROR type: %d", (int)status);
}

void decompressionSessionDecodeFrameCallback(void *decompressionOutputRefCon,
                                             void *sourceFrameRefCon,
                                             OSStatus status,
                                             VTDecodeInfoFlags infoFlags,
                                             CVImageBufferRef imageBuffer,
                                             CMTime presentationTimeStamp,
                                             CMTime presentationDuration)
{
    
    if (status != noErr)
    {
        NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        NSLog(@"Decompressed error: %@", error);
    }
    else
    {
        NSLog(@"Decompressed sucessfully");
        
        // TODO: Render using MetalKit View
    }
}

- (void) render:(CMSampleBufferRef)sampleBuffer
{
    VTDecodeFrameFlags flags = kVTDecodeFrame_EnableAsynchronousDecompression;
    VTDecodeInfoFlags flagOut;
    NSDate* currentTime = [NSDate date];
    VTDecompressionSessionDecodeFrame(_decompressionSession, sampleBuffer, flags, (void*)CFBridgingRetain(currentTime), &flagOut);

    CFRelease(sampleBuffer);
}

- (BOOL)needNewSessionForDescription:(CMVideoFormatDescriptionRef)formatDesc
{
    return (VTDecompressionSessionCanAcceptFormatDescription(_decompressionSession, formatDesc) == NO);
}
@end
