//
//  Cacheable.swift
//  
//
//  Created by MohammadReza Ansary on 11/17/21.
//

import Foundation


public protocol Cacheable {
    
    func cache(_ data: Data, to directory: URL, with name: String)
    
    func clear(_ data: Data, from directory: URL, with name: String)
    
    func clear(_ directory: URL)
    
    func retrieve(from directory: URL, with name: String) -> Data?
    
    func checkFileExist(from directory: URL, with name: String) -> Data?
    
}


extension Cacheable {

    func cache(_ data: Data, to directory: URL, with name: String) {
        do {
            try data.write(to: directory.appendingPathComponent(name), options: .atomic)
        } catch let error {
            assertionFailure("Could NOT write data to: \(directory) with name: \(name), error: \(error.localizedDescription)")
        }
    }
    
    
    // TODO: Should check data is that data to delete
    func clear(_ data: Data, from directory: URL, with name: String) {
        do {
            try FileManager.default.removeItem(at: directory.appendingPathComponent(name))
        } catch let error {
            assertionFailure("Could NOT remove item at: \(directory) with name: \(name), error: \(error.localizedDescription)")
        }
    }
    
    
    func clear(_ directory: URL) {
        FileManager.default.deleteDirectory(at: directory)
    }
    
    
    func retrieve(from directory: URL, with name: String) -> Data? {
        do {
            return try Data(contentsOf: directory.appendingPathComponent(name), options: .mappedIfSafe)
        } catch let error {
            assertionFailure("Could NOT read item at: \(directory) with name: \(name), error: \(error.localizedDescription)")
        }
        return nil
    }
    
    
    func checkFileExist(from directory: URL, with name: String) -> Data? {
        if FileManager.default.fileExists(atPath: directory.appendingPathComponent(name).path) {
            return retrieve(from: directory, with: name)
        }
        return nil
    }
}
