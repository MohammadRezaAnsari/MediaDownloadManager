//
//  FileManager+DeleteDirectory.swift
//  
//
//  Created by MohammadReza Ansary on 11/17/21.
//

import Foundation

extension FileManager {
    
    func deleteDirectory(at url: URL) {
        
        do {
            try self.removeItem(at: url)
            
            #if DEBUG
            let isSuccessful = FileManager.default.fileExists(atPath: url.path)
            let successTitle = isSuccessful ? "succeed" : "failed"
            print("Folder with url: `\(url)` is \(successTitle) to delete.")
            #endif
            
        } catch let error {
            assertionFailure("Could not remove item at url: `\(url)` ,\n error: \(error)")
        }
    }
}
