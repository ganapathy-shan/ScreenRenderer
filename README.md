# ScreenRenderer

Render H264 image streams received through socket by using GPU.

- Recieves H264 encoded image stream through socket.
- Decode it into CMSampleBuffer.
- Decompress it using VideoToolbox or display data directly using AVSampleBufferDisplayLayer.
- All the above functionalities runs on the background queue.

TODO:
- Fix the issue with rendering. Needs to find a way to properly render 420v (kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) image buffer.


Build instruction: 
Run pod install from project folder before building. 
If any issues while building the project, run rm -rf Pods/ Podfile.lock and the run pod install.


