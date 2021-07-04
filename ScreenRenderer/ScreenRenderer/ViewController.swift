//
//  ViewController.swift
//  ScreenRenderer
//
//  Created by Shanmuganathan on 29/06/21.
//

import Cocoa
import MetalKit

class ViewController : MTKViewController {
    @IBOutlet var displayView: NSView!
    var renderSession : RenderSession? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        renderSession = RenderSession(delegate: self)
        //DisplayLayerRender.sharedManager().setView(displayView)
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}

extension ViewController : RenderSessionDelegate
{
    func renderSession(_ session: RenderSession, didReceiveFrameAsTextures texture: MTLTexture) {
//        let image = NSImage(named: "SampleImage.jpg")
//        let textureLoader = MTKTextureLoader(device: self.device!)
//        let cgImage = (image?.cgImage(forProposedRect: nil, context: nil, hints: nil))!
//        let imageTexture = try! textureLoader.newTexture(cgImage: cgImage, options: nil)
//        self.texture = imageTexture
        self.texture = texture
    }
    
    
}
