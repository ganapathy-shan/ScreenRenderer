//
//  RendererTransport.swift
//  ScreenRenderer
//
//  Created by Shanmuganathan on 29/06/21.
//

import Foundation
import CocoaAsyncSocket
import VideoToolbox

class RendererTransport: NSObject, GCDAsyncUdpSocketDelegate {
    
    var hostIP : String = "127.0.0.1"
    var port : UInt16 = 22560
    var socket : GCDAsyncUdpSocket? = nil
    var dispatchQueue = DispatchQueue.init(label: "com.receive.queue", qos: .background, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)

    let decoder = Decoder()
    override init() {
        super.init()
        
        setUpConnection()
    }
    
    func setUpConnection() {
        
        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatchQueue)
        guard let socket = self.socket else { return  }
        do {
            try socket.bind(toPort: port)
            try socket.enableReusePort(true)
            try socket.beginReceiving()
        } catch let err {
            print(err)
        }
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didConnectToAddress address: Data) {
        print("Socket Connected")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error?) {
        print("Socket connection failed \(String(describing: error))")
    }

    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        print("Data Received")
        
        var mutableData = data

        mutableData.withUnsafeMutableBytes({ (bytes: UnsafeMutablePointer<UInt8>) -> Void in
            decoder.receivedRawVideoFrame(bytes, withSize: UInt32(data.count))
        })        
    }
    
    func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
        print("Socket closed")
    }
    
}
