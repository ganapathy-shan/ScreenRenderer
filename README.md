# ScreenRenderer

Render H264 image streams received through socket by using GPU.

- Recieves H264 encoded image stream through socket.
- Decode it into CMSampleBuffer.
- Decompress it using VideoToolbox or display data directly using AVSampleBufferDisplayLayer.
- All the above functionalities runs on the background queue.


Issues:
- Facing issues when creating Decompressionsession using VTDecompressionSessionCreate. Getting an error code 12909(kVTVideoDecoderBadDataErr). Issue seems to be with the Sample Buffer as AVSampleBufferDisplayLayer is unable to render it.
- Please find the sample buffer details on both end of the pipe.

#Sample Buffer after H264 Compression before sending through the socket.
CMSampleBuffer 0x10062ec60 retainCount: 9 allocator: 0x7fff8dd65cc0
	invalid = NO
	dataReady = YES
	makeDataReadyCallback = 0x0
	makeDataReadyRefcon = 0x0
	formatDescription = <CMVideoFormatDescription 0x600000c58330 [0x7fff8dd65cc0]> {
	mediaType:'vide' 
	mediaSubType:'avc1' 
	mediaSpecific: {
		codecType: 'avc1'		dimensions: 1280 x 720 
	} 
	extensions: {{
    CVPixelAspectRatio =     {
        HorizontalSpacing = 1;
        VerticalSpacing = 1;
    };
    FormatName = "H.264";
    SampleDescriptionExtensionAtoms =     {
        avcC = {length = 38, bytes = 0x014d001f ffe10017 274d001f 898b6028 ... 28010004 28ee1f20 };
    };
}}
}
	sbufToTrackReadiness = 0x0
	numSamples = 1
	outputPTS = {1/3 = 0.333}(based on cachedOutputPresentationTimeStamp)
	sampleTimingArray[1] = {
		{PTS = {1/3 = 0.333}, DTS = {1/3 = 0.333}, duration = {INVALID}},
	}
	sampleSizeArray[1] = {
		sampleSize = 58845,
	}
	sampleAttachmentsArray[1] = {
		sample 0:
			DependsOnOthers = false
			EarlierDisplayTimesAllowed = false
	}
	dataBuffer = 0x600003014f30

#Sample Buffer after receiving from the socket.
CMSampleBuffer 0x100715da0 retainCount: 1 allocator: 0x7fff8dd65cc0
	invalid = NO
	dataReady = YES
	makeDataReadyCallback = 0x0
	makeDataReadyRefcon = 0x0
	formatDescription = <CMVideoFormatDescription 0x600000c9c360 [0x7fff8dd65cc0]> {
	mediaType:'vide' 
	mediaSubType:'avc1' 
	mediaSpecific: {
		codecType: 'avc1'		dimensions: 1280 x 720 
	} 
	extensions: {{
    CVFieldCount = 1;
    CVImageBufferChromaLocationBottomField = Left;
    CVImageBufferChromaLocationTopField = Left;
    CVPixelAspectRatio =     {
        HorizontalSpacing = 1;
        VerticalSpacing = 1;
    };
    FullRangeVideo = 0;
    SampleDescriptionExtensionAtoms =     {
        avcC = {length = 38, bytes = 0x014d001f ffe10017 274d001f 898b6028 ... 28010004 28ee1f20 };
    };
}}
}
	sbufToTrackReadiness = 0x0
	numSamples = 1
	outputPTS = {INVALID}(computed from PTS, duration and attachments)
	sampleSizeArray[1] = {
		sampleSize = 13331,
	}
	sampleAttachmentsArray[1] = {
		sample 0:
			DisplayImmediately = true
	}
	dataBuffer = 0x600003005050


- There seems to be a difference in extensions and outputPTS shows as invlid. Need to check if it is the issue.

TODO:
- Fix the issue with Sample Buffer to fix H264 Decompression.
- Render the decompressed data using MetalKit.








Build instruction: 
Run pod install from project folder before building. 
If any issues while building the project, run rm -rf Pods/ Podfile.lock and the run pod install.


