//
//  Filter.swift
//  ScreenCaptureApp
//
//  Created by Shanmuganathan on 29/06/21.
//


import Metal
import MetalKit
import CoreImage

class Filter {
    
    var device: MTLDevice
    var defaultLib: MTLLibrary?
    var grayscaleShader: MTLFunction?
    var commandQueue: MTLCommandQueue?
    var commandBuffer: MTLCommandBuffer?
    var commandEncoder: MTLComputeCommandEncoder?
    var pipelineState: MTLComputePipelineState?
    
    var inputImage: CGImage? = nil
    var height, width: Int
    
    // most devices have a limit of 512 threads per group
    let threadsPerBlock = MTLSize(width: 16, height: 16, depth: 1)
    
    init(){
        self.device = MTLCreateSystemDefaultDevice()!
        self.defaultLib = self.device.makeDefaultLibrary()
        self.grayscaleShader = self.defaultLib?.makeFunction(name: "transparent")
        self.commandQueue = self.device.makeCommandQueue()
        
        self.commandBuffer = self.commandQueue?.makeCommandBuffer()
        self.commandEncoder = self.commandBuffer?.makeComputeCommandEncoder()
        if let shader = grayscaleShader {
            self.pipelineState = try? self.device.makeComputePipelineState(function: shader)
        } else { fatalError("unable to make compute pipeline") }
        self.height = 0
        self.width = 0
    }
    
    func setInputImage(imageBuffer:CVImageBuffer)
    {
        self.inputImage = getCGImageFromImageBuffer(imageBuffer: imageBuffer)
        if let inputImage = self.inputImage
        {
            self.height = Int(inputImage.height)
            self.width = Int(inputImage.width)
        }
    }
    
    func getCGImageFromImageBuffer(imageBuffer:CVImageBuffer) -> CGImage? {
        
        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(ciImage, from: CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(imageBuffer), height: CVPixelBufferGetHeight(imageBuffer)))
        return cgImage
    }
    
    func getMTLTexture(from cgimg: CGImage) -> MTLTexture {
        
        let textureLoader = MTKTextureLoader(device: self.device)
        
        do{
            let texture = try textureLoader.newTexture(cgImage: cgimg, options: nil)
            let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: texture.pixelFormat, width: width, height: height, mipmapped: false)
            textureDescriptor.usage = [.shaderRead, .shaderWrite]
            return texture
        } catch {
            fatalError("Couldn't convert CGImage to MTLtexture")
        }
        
    }
    
    func getCGImage(from mtlTexture: MTLTexture) -> CGImage? {
        
        var data = Array<UInt8>(repeatElement(0, count: 4*width*height))
        
        mtlTexture.getBytes(&data,
                            bytesPerRow: 4*width,
                            from: MTLRegionMake2D(0, 0, width, height),
                            mipmapLevel: 0)
        
        let bitmapInfo = CGBitmapInfo(rawValue: (CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue))
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let context = CGContext(data: &data,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: 4*width,
                                space: colorSpace,
                                bitmapInfo: bitmapInfo.rawValue)
        
        return context?.makeImage()
    }
    
    
    func getEmptyMTLTexture() -> MTLTexture? {
        
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: MTLPixelFormat.rgba8Unorm,
            width: width,
            height: height,
            mipmapped: false)
        
        textureDescriptor.usage = [.shaderRead, .shaderWrite]
        
        return self.device.makeTexture(descriptor: textureDescriptor)
    }
    
    func getInputMTLTexture() -> MTLTexture? {
        guard let inputImage = self.inputImage else {
            return nil
        }
        return getMTLTexture(from: inputImage)
    }
    
    func getBlockDimensions() -> MTLSize {
        let blockWidth = width / self.threadsPerBlock.width
        let blockHeight = height / self.threadsPerBlock.height
        return MTLSizeMake(blockWidth, blockHeight, 1)
    }
    
    func applyFilter() -> CGImage? {
        
        if let encoder = self.commandEncoder, let buffer = self.commandBuffer,
           let outputTexture = getEmptyMTLTexture(), let inputTexture = getInputMTLTexture(), let pipelineState = self.pipelineState {
            encoder.setComputePipelineState(pipelineState)
            encoder.setTextures([outputTexture, inputTexture], range: 0..<2)
            encoder.dispatchThreadgroups(self.getBlockDimensions(), threadsPerThreadgroup: threadsPerBlock)
            encoder.endEncoding()
            
            buffer.commit()
            buffer.waitUntilCompleted()
            
            guard let outputImage = getCGImage(from: outputTexture) else { fatalError("Couldn't obtain CGImage from MTLTexture") }
            
            return outputImage
            
        } else { fatalError("optional unwrapping failed") }
    }
    
    
}
