ScreenRenderer
==============

Overview
--------

The **ScreenRenderer** project receives the H.264-encoded video stream, decodes it, and renders it in real time using **AVSampleBufferDisplayLayer** or GPU.

### Features

-   Receives the encoded video stream through a socket.
-   Decodes the stream into `CMSampleBuffer` using **VideoToolbox**.
-   Renders the decoded video via GPU-based rendering.

* * * * *

Setup Instructions
------------------

### Prerequisites

-   macOS with Xcode installed.
-   CocoaPods installed (`sudo gem install cocoapods`).

### Steps to Build

1.  Navigate to the `ScreenRenderer` project directory.
2.  Run the following command to install dependencies:
    `pod install`
3.  Open the `.xcworkspace` file in Xcode.
4.  Build and run the project.

### Troubleshooting

If you encounter build issues:

1.  Remove the Pods directory and lock file:
    `rm -rf Pods/ Podfile.lock`

2.  Reinstall CocoaPods:
    `pod install`

* * * * *

How to Use
----------

1.  Launch the **ScreenRenderer** app.
2.  Ensure that the IP address and port match the **ScreenCapture** app's configuration.
3.  The app connects to the socket, receives the video stream, decodes it, and renders it.

* * * * *

Data Flow
---------

1.  Receives the H.264 stream over the network socket.
2.  Decodes the data into `CMSampleBuffer`.
3.  Renders frames using `AVSampleBufferDisplayLayer` or GPU.

* * * * *

TODO
----

-   **Rendering Issue**: Fix the issue with rendering `420v` (kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) image buffers.
-   Optimize GPU rendering for better compatibility.
