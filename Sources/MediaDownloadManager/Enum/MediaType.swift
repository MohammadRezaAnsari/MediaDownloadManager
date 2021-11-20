//
//  MediaType.swift
//  
//
//  Created by MohammadReza Ansary on 11/17/21.
//

import Foundation

enum MediaType: String {
    
    case image
    case video
    case audio
    case document // Unknown types also are document
    
    
    var directory: String {
        return rawValue
    }
    
    func directory(with root: URL) -> URL {
        switch self {
        case .image: return root.appendingPathComponent(MediaType.image.directory)
        case .video: return root.appendingPathComponent(MediaType.video.directory)
        case .audio: return root.appendingPathComponent(MediaType.audio.directory)
        case .document: return root.appendingPathComponent(MediaType.document.directory)
        }
    }
}
