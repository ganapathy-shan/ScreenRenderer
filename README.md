# ScreenRenderer

Render H264 image streams received through socket.

- Recieves H264 encoded image stream through socket.
- Decode it into CMSampleBuffer 
- Decompress it using VideoToolbox or display data directly using AVSampleBufferDisplayLayer.


Issues:
- Facing issues when creating Decompressionsession using VTDecompressionSessionCreate. Getting an error code 12909(kVTVideoDecoderBadDataErr). Issue seems to be with the Sample Buffer as AVSampleBufferDisplayLayer is unable to render it.

TODO:
- Fix the issue with Sample Buffer to fix H264 Decompression.
- Render the decompressed data using MetalKit.





