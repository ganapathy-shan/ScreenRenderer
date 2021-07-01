# ScreenRenderer

Render H264 image streams received through socket by using GPU.

- Recieves H264 encoded image stream through socket.
- Decode it into CMSampleBuffer.
- Decompress it using VideoToolbox or display data directly using AVSampleBufferDisplayLayer.
- All the above functionalities runs on the background queue.


Issues:
- Facing issues when creating Decompressionsession using VTDecompressionSessionCreate. Getting an error code 12909(kVTVideoDecoderBadDataErr). Issue seems to be with the Sample Buffer as AVSampleBufferDisplayLayer is unable to render it.

TODO:
- Fix the issue with Sample Buffer to fix H264 Decompression.
- Render the decompressed data using MetalKit.


Build instruction: 
Run pod install from project folder before building. 
If any issues while building the project, run rm -rf Pods/ Podfile.lock and the run pod install.


