//
//  DirectoryCreator.swift
//  
//
//  Created by MohammadReza Ansary on 11/17/21.
//

import Foundation

@propertyWrapper public struct DirectoryCreator {
    
    var url: URL
    
    public var wrappedValue: URL {
        get { url }
        set { url = directoryChecker(newValue) }
    }

    public init() {
        url = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        self.wrappedValue = url
    }
    
    func directoryChecker(_ url: URL) -> URL {
        if !FileManager.default.fileExists(atPath: url.path) {
            try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        return url
    }
}
