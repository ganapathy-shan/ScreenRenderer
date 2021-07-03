//
//  ViewController.swift
//  ScreenRenderer
//
//  Created by Shanmuganathan on 29/06/21.
//

import Cocoa

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
        self.texture = texture
    }
    
    
}
