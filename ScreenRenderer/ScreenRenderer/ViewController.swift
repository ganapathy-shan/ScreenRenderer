//
//  ViewController.swift
//  ScreenRenderer
//
//  Created by Shanmuganathan on 29/06/21.
//

import Cocoa

class ViewController : NSViewController {
    @IBOutlet var displayView: NSView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        DisplayLayerRender.sharedManager().setView(displayView)
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
}

