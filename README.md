# ScreenRenderer

Render H264 image streams received through socket by using GPU.

- Recieves H264 encoded image stream through socket.
- Decode it into CMSampleBuffer.
- Decompress it using VideoToolbox or display data directly using AVSampleBufferDisplayLayer.
- All the above functionalities runs on the background queue.

TODO:
- Fix the shaders to render the images properly(It is distorted currently)


Build instruction: 
Run pod install from project folder before building. 
If any issues while building the project, run rm -rf Pods/ Podfile.lock and the run pod install.


