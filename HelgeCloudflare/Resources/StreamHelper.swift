//
//  StreamHelper.swift
//  HelgeCloudflare
//
//  Created by Ryan Helgeson on 10/21/25.
//

import Foundation

final class StreamHelper {
    static let shared: StreamHelper = .init()
    
    var streamKey: String = ""
    var bcId: String = ""
    var streamId: String = ""
}
