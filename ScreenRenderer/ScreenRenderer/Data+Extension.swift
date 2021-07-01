//
//  Data+Extension.swift
//  ScreenRenderer
//
//  Created by Shanmuganathan on 30/06/21.
//

import Foundation
import Foundation

extension Data {
    var bytes: [UInt8] {
        withUnsafeBytes {
            guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                return []
            }
            return [UInt8](UnsafeBufferPointer(start: pointer, count: count))
        }
    }
}
