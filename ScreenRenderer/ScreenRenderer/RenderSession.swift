//
//  MetalSession.swift
//  ScreenRenderer
//
//  Created by Shanmuganathan on 03/07/21.
//

import Foundation

public protocol RenderSessionDelegate {
    func renderSession(_ session: RenderSession, didReceiveFrameAsTextures texture: MTLTexture)
}

public protocol RenderSessionDecoderDelegate {
    func renderSession(_ session: RenderSession, didDecodeCompleted imageBuffer: CVImageBuffer)
}
public class RenderSession : NSObject{
    
    public var delegate: RenderSessionDelegate?
    /// Texture cache we will use for converting frame images to textures
    internal var textureCache: CVMetalTextureCache?

    /// `MTLDevice` we need to initialize texture cache
    internal var metalDevice = MTLCreateSystemDefaultDevice()
    
    var renderTransport : RendererTransport? = nil
    
    var decoder : Decoder? = nil
    
    public init(delegate: RenderSessionDelegate? = nil) {
        super.init()
        self.delegate = delegate
        try? self.initializeTextureCache()
        renderTransport = RendererTransport(delegate: self)
        decoder = Decoder(delegate: self)
    }
    
    /**
     initialized the texture cache. We use it to convert frames into textures.
     
     */
    fileprivate func initializeTextureCache() throws {
        guard
            let metalDevice = metalDevice,
            CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, metalDevice, nil, &self.textureCache) == kCVReturnSuccess
        else {
            return
        }
    }
    
    private func createTexture(imageBuffer: CVImageBuffer, textureCache: CVMetalTextureCache?, planeIndex: Int = 0, pixelFormat: MTLPixelFormat = .bgra8Unorm) throws -> MTLTexture? {

        guard let textureCache = textureCache else {
            return nil
        }
        
        let isPlanar = CVPixelBufferIsPlanar(imageBuffer)
        let width = isPlanar ? CVPixelBufferGetWidthOfPlane(imageBuffer, planeIndex) : CVPixelBufferGetWidth(imageBuffer)
        let height = isPlanar ? CVPixelBufferGetHeightOfPlane(imageBuffer, planeIndex) : CVPixelBufferGetHeight(imageBuffer)
        
        var imageTexture: CVMetalTexture?
        
        let result = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, imageBuffer, nil, pixelFormat, width, height, planeIndex, &imageTexture)

        guard
            let unwrappedImageTexture = imageTexture,
            let texture = CVMetalTextureGetTexture(unwrappedImageTexture),
            result == kCVReturnSuccess
        else {
             return nil
        }

        return texture
    }
    
    /**
     Strips out the timestamp value out of the sample buffer received from camera.
     
     - parameter sampleBuffer: Sample buffer with the frame data
     
     - returns: Double value for a timestamp in seconds or nil
     */
    private func timestamp(sampleBuffer: CMSampleBuffer?) throws -> Double {
        guard let sampleBuffer = sampleBuffer else {
            return 0
        }
        
        let time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        
        guard time != CMTime.invalid else {
            return 0
        }
        
        return (Double)(time.value) / (Double)(time.timescale);
    }
}

extension RenderSession : RendererTransportDelegate {
    func renderTransport(_ transport: RendererTransport, didReceiveData data: Data) {
        var mutableData = data

        mutableData.withUnsafeMutableBytes({ (bytes: UnsafeMutablePointer<UInt8>) -> Void in
            guard let decoder = decoder else { return }
            decoder.receivedRawVideoFrame(bytes, withSize: UInt32(data.count))
        })
    }
}

extension RenderSession : DecoderDelegate
{
    public func decoderCompletion(with imageBuffer: CVImageBuffer) {
        let texture: MTLTexture? = try? createTexture(imageBuffer: imageBuffer, textureCache: self.textureCache)
        guard let textureToRender = texture else {
            return
        }
        DispatchQueue.main.async {
            self.delegate?.renderSession(self, didReceiveFrameAsTextures: textureToRender)
        }
    }
}
