//
//  Decoder.m
//  ScreenRenderer
//
//  Created by Shanmuganathan on 01/07/21.
//

#import "Decoder.h"
#import "DisplayLayerRender.h"
#import "H264Decoder.h"

@implementation Decoder

/* Uncomment to use DisplayLayerRender Decompression*/
// DisplayLayerRender *renderer;

H264Decoder* h264Decoder;

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        /* Uncomment to use DisplayLayerRender Decompression*/
        // renderer = [DisplayLayerRender sharedManager];
        
        h264Decoder = [[H264Decoder alloc] init];
    }
    return self;
}

-(void) receivedRawVideoFrame:(uint8_t *)frame withSize:(uint32_t)frameSize
{
    @synchronized (self) {
        //MARK: Critical Section START
        OSStatus status = 0;
        
        uint8_t *data = NULL;
        uint8_t *pps = NULL;
        uint8_t *sps = NULL;
        
        int startCodeIndex = 0;
        int secondStartCodeIndex = 0;
        int thirdStartCodeIndex = 0;
        
        long blockLength = 0;
        
        __block CMSampleBufferRef sampleBuffer = NULL;
        CMBlockBufferRef blockBuffer = NULL;
        
        for (int i = 0; i < startCodeIndex + 40; i++)
        {
            if (frame[i] == 0x00 && frame[i+1] == 0x00 && frame[i+2] == 0x00 && frame[i+3] == 0x01)
            {
                startCodeIndex = i;   // includes the header in the size
                break;
            }
        }
        int nalu_type = (frame[startCodeIndex + 4] & 0x1F);
        
        /* HEVC NALU */
        //    int nalu_type = (frame[startCodeIndex + 4] & 0x7E) >> 1;
        
        NSLog(@"~~~~~~~ Received NALU Type \"%@\" ~~~~~~~~", naluTypesStrings[nalu_type]);
        
        // if we havent already set up our format description with our SPS PPS parameters, we
        // can't process any frames except type 7 that has our parameters
        if (nalu_type != 7 && _formatDesc == NULL)
        {
            NSLog(@"Video error: Frame is not an I Frame and format description is null");
            return;
        }
        
        // NALU type 7 is the SPS parameter NALU
        if (nalu_type == 7)
        {
            // find where the second PPS start code begins, (the 0x00 00 00 01 code)
            // from which we also get the length of the first SPS code
            for (int i = startCodeIndex + 4; i < startCodeIndex + 40; i++)
            {
                if (frame[i] == 0x00 && frame[i+1] == 0x00 && frame[i+2] == 0x00 && frame[i+3] == 0x01)
                {
                    secondStartCodeIndex = i;
                    _spsSize = secondStartCodeIndex;   // includes the header in the size
                    break;
                }
            }
            
            // find what the second NALU type is
            nalu_type = (frame[secondStartCodeIndex + 4] & 0x1F);
            NSLog(@"~~~~~~~ Received NALU Type \"%@\" ~~~~~~~~", naluTypesStrings[nalu_type]);
        }
        
        // type 8 is the PPS parameter NALU
        if(nalu_type == 8)
        {
            // find where the NALU after this one starts so we know how long the PPS parameter is
            for (int i = _spsSize + 4; i < _spsSize + 30; i++)
            {
                if (frame[i] == 0x00 && frame[i+1] == 0x00 && frame[i+2] == 0x00 && frame[i+3] == 0x01)
                {
                    thirdStartCodeIndex = i;
                    _ppsSize = thirdStartCodeIndex - _spsSize;
                    break;
                }
            }
            
            // allocate enough data to fit the SPS and PPS parameters into our data objects.
            // VTD doesn't want you to include the start code header (4 bytes long) so we add the - 4 here
            sps = malloc(_spsSize - 4);
            pps = malloc(_ppsSize - 4);
            
            // copy in the actual sps and pps values, again ignoring the 4 byte header
            memcpy (sps, &frame[4], _spsSize-4);
            memcpy (pps, &frame[_spsSize+4], _ppsSize-4);
            
            // now we set our H264 parameters
            uint8_t*  parameterSetPointers[2] = {sps, pps};
            size_t parameterSetSizes[2] = {_spsSize-4, _ppsSize-4};
            
            if (_formatDesc)
            {
                CFRelease(_formatDesc);
                _formatDesc = NULL;
            }
            
            status = CMVideoFormatDescriptionCreateFromH264ParameterSets(kCFAllocatorDefault, 2,
                                                                         (const uint8_t *const*)parameterSetPointers,
                                                                         parameterSetSizes, 4,
                                                                         &_formatDesc);
            
            NSLog(@"\t\t Creation of CMVideoFormatDescription: %@", (status == noErr) ? @"successful!" : @"failed...");
            if(status != noErr) NSLog(@"\t\t Format Description ERROR type: %d", (int)status);
            
            /* Uncomment to use VT H.264 Decompression*/
            BOOL needNewDecompSession = [h264Decoder needNewSessionForDescription:_formatDesc];
             if(needNewDecompSession)
             {
                 [h264Decoder createDecompSessionWithDescription:_formatDesc];
             }
            
            // now lets handle the IDR frame that (should) come after the parameter sets
            // I say "should" because that's how I expect my H264 stream to work, YMMV
            nalu_type = (frame[thirdStartCodeIndex + 4] & 0x1F);
            NSLog(@"~~~~~~~ Received NALU Type \"%@\" ~~~~~~~~", naluTypesStrings[nalu_type]);
        }
        
        /* Uncomment to use VT H.264 Decompression*/
        if((status == noErr) && (h264Decoder.decompressionSession == NULL))
        {
            [h264Decoder createDecompSessionWithDescription:_formatDesc];
        }
    
        // type 5 is an IDR frame NALU.  The SPS and PPS NALUs should always be followed by an IDR (or IFrame) NALU, as far as I know
        if(nalu_type == 5)
        {
            // find the offset, or where the SPS and PPS NALUs end and the IDR frame NALU begins
            int offset = _spsSize + _ppsSize;
            blockLength = frameSize - offset;
            data = malloc(blockLength);
            data = memcpy(data, &frame[offset], blockLength);
            
            // replace the start code header on this NALU with its size.
            // AVCC format requires that you do this.
            // htonl converts the unsigned int from host to network byte order
            uint32_t dataLength32 = htonl (blockLength - 4);
            memcpy (data, &dataLength32, sizeof (uint32_t));
            
            // create a block buffer from the IDR NALU
            status = CMBlockBufferCreateWithMemoryBlock(NULL, data,  // memoryBlock to hold buffered data
                                                        blockLength,  // block length of the mem block in bytes.
                                                        kCFAllocatorNull, NULL,
                                                        0, // offsetToData
                                                        blockLength,   // dataLength of relevant bytes, starting at offsetToData
                                                        0, &blockBuffer);
            
            NSLog(@"\t\t BlockBufferCreation: \t %@", (status == kCMBlockBufferNoErr) ? @"successful!" : @"failed...");
        }
        
        // NALU type 1 is non-IDR (or PFrame) picture
        if (nalu_type == 1)
        {
            // non-IDR frames do not have an offset due to SPS and PSS, so the approach
            // is similar to the IDR frames just without the offset
            blockLength = frameSize;
            data = malloc(blockLength);
            data = memcpy(data, &frame[0], blockLength);
            
            // again, replace the start header with the size of the NALU
            uint32_t dataLength32 = htonl (blockLength - 4);
            memcpy (data, &dataLength32, sizeof (uint32_t));
            
            status = CMBlockBufferCreateWithMemoryBlock(NULL, data,  // memoryBlock to hold data. If NULL, block will be alloc when needed
                                                        blockLength,  // overall length of the mem block in bytes
                                                        kCFAllocatorNull, NULL,
                                                        0,     // offsetToData
                                                        blockLength,  // dataLength of relevant data bytes, starting at offsetToData
                                                        0, &blockBuffer);
            
            NSLog(@"\t\t BlockBufferCreation: \t %@", (status == kCMBlockBufferNoErr) ? @"successful!" : @"failed...");
        }
        
        // now create our sample buffer from the block buffer,
        if(status == noErr)
        {
            const size_t sampleSize = blockLength - 4;
            status = CMSampleBufferCreateReady(kCFAllocatorDefault, blockBuffer, _formatDesc, 1, 0, NULL, 1, &sampleSize, &sampleBuffer);
            
            NSLog(@"\t\t SampleBufferCreate: \t %@", (status == noErr) ? @"successful!" : @"failed...");
        }
        
        if(status == noErr)
        {
            // set some values of the sample buffer's attachments
            CFArrayRef attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, YES);
            CFMutableDictionaryRef dict = (CFMutableDictionaryRef)CFArrayGetValueAtIndex(attachments, 0);
            CFDictionarySetValue(dict, kCMSampleAttachmentKey_DisplayImmediately, kCFBooleanTrue);
            
            /* Unomment to use VT H.264 Decompression*/
            [h264Decoder render:sampleBuffer];
            
            /* Uncomment to use DisplayLayerRender Decompression*/
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [renderer render:sampleBuffer];
//                sampleBuffer = NULL;
//            });
        }
        
        // free memory to avoid a memory leak
        if (NULL != data)
        {
            free (data);
            data = NULL;
            free(sps);
            sps = NULL;
            free(pps);
            pps = NULL;
            
        }
        //MARK: Critical Section END
    }
}

@end
