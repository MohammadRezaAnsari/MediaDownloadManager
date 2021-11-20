//
//  String+MediaType.swift
//  
//
//  Created by MohammadReza Ansary on 11/17/21.
//


extension String {
    var type: MediaType {
        switch self {
        case "png", "jpeg", "jpg": return .image
        case "mp4", "gif", "tiff", "mpeg", ".avi": return .video
        case "mp3", "aac", "oga", "wav": return .audio
        default: return .document
        }
    }
}
