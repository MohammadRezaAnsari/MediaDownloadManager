//
//  MediaDownloadManager.swift
//  
//
//  Created by MohammadReza Ansary on 11/15/21.
//

import Foundation

public typealias ProgressBlock = (written: String, total: String, percentage: String)
public typealias FailureBlock = (status: Int?, response: URLResponse?, error: Error?)



public protocol URLRequestAdapter {
    func adaptedURLRequest(from urlRequest: URLRequest) -> URLRequest
}

public protocol DownloadManager: AnyObject {
    
    var urlSession: URLSession { get }
    var urlRequestAdapters: [URLRequestAdapter] { get set }
    
    func download(with url: URL,
                  onProgress: @escaping (ProgressBlock) -> Void,
                  onResult:   @escaping (Data) -> Void,
                  onError:    @escaping (FailureBlock) -> Void)
    
    func download(with request: URLRequest,
                  onProgress: @escaping (ProgressBlock) -> Void,
                  onResult:   @escaping (Data) -> Void,
                  onError:    @escaping (FailureBlock) -> Void)
}




/// - Note: It should be `NSObject` because of `URLSessionDelegate`
///
public class MediaDownloadManagerImplementation: NSObject, DownloadManager {
    
    // Byte Formatter to using for formatting downloading bytes
    private lazy var byteFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        return formatter
    }()
    
    public lazy var urlSession: URLSession = {
        URLSession.init(configuration: .default, delegate: self, delegateQueue: currentQueue)
    }()
    
    private lazy var currentQueue: OperationQueue = {
        guard let operation = OperationQueue.current else { return OperationQueue.main }
        return operation
    }()
    
    public var urlRequestAdapters: [URLRequestAdapter] = []
    
    
    private var progressBlock: ((ProgressBlock) -> Void)!
    private var failureBlock: ((FailureBlock) -> Void)!
    private var resultBlock: ((Data) -> Void)!
    
    public var rootDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    public var storage: Cacheable = DefaultCacheable()
    
    @DirectoryCreator var imageDirectory: URL
    @DirectoryCreator var videoDirectory: URL
    @DirectoryCreator var audioDirectory: URL
    @DirectoryCreator var documentDirectory: URL
    
    
    public override init() {
        super.init()
        setupDirectories()
    }
    
    
    
    /// Download Media
    ///
    /// - parameter request: The URL Request of file which need to be download.
    /// - parameter caching: Ask for caching data which is downloaded. Default value is `true`.
    /// - parameter result: The result of downloading file as `Result<Data, Error>`.
    ///
    /// - Note: The default flow is search for file or data from storage. If there is NO file in storage with given url path name it would download it
    ///
    /// - Warning: Never should call result in method definition directly. Only resultBlock call result completion.
    ///
    public func download(with request: URLRequest,
                         onProgress: @escaping (ProgressBlock) -> Void = { print($0) },
                         onResult:   @escaping (Data) -> Void          = { _ in },
                         onError:    @escaping (FailureBlock) -> Void  = { _ in })
    {
        
        progressBlock = { onProgress($0) }
        resultBlock   = { onResult($0) }
        failureBlock  = { onError($0) }
        
        guard let url = request.url else { return }
        
        // First check storage if file exist then return existing file
        if let name = url.pathComponents.last {
            
            let file: Data? = storage.checkFileExist(from: url.pathExtension.type.directory(with: rootDirectory), with: name)
            
            guard file == nil else {
                resultBlock(file!)
                return
            }
        }
        
        // If could `NOT` find data from storage then download it.
        
        var adaptedRequest = request
        for adapter in urlRequestAdapters {
            adaptedRequest = adapter.adaptedURLRequest(from: adaptedRequest)
        }
        
        let task = urlSession.downloadTask(with: adaptedRequest)
        task.resume()
    }
    
    
    public func download(with url: URL,
                         onProgress: @escaping (ProgressBlock) -> Void = { print($0) },
                         onResult:   @escaping (Data) -> Void          = { _ in },
                         onError:    @escaping (FailureBlock) -> Void  = { _ in })
    {
        let request = URLRequest(url: url)
        download(with: request, onProgress: onProgress, onResult: onResult, onError: onError)
    }
    
    
    // MARK: - Caching
    
    private func setupDirectories() {
        imageDirectory = rootDirectory.appendingPathComponent(MediaType.image.directory)
        videoDirectory = rootDirectory.appendingPathComponent(MediaType.video.directory)
        audioDirectory = rootDirectory.appendingPathComponent(MediaType.audio.directory)
        documentDirectory = rootDirectory.appendingPathComponent(MediaType.document.directory)
    }
    
    private func cache(_ data: Data, mediaType: MediaType, name: String) {
        switch mediaType {
        case .image: storage.cache(data, to: imageDirectory, with: name)
        case .video: storage.cache(data, to: videoDirectory, with: name)
        case .audio: storage.cache(data, to: audioDirectory, with: name)
        case .document: storage.cache(data, to: documentDirectory, with: name)
        }
    }
}



// MARK: - URLSessionDelegate & URLSessionDownloadDelegate

extension MediaDownloadManagerImplementation: URLSessionDelegate, URLSessionDownloadDelegate {
    
    public func urlSession(_ session: URLSession,
                           downloadTask: URLSessionDownloadTask,
                           didWriteData bytesWritten: Int64,
                           totalBytesWritten: Int64,
                           totalBytesExpectedToWrite: Int64) {
        
        guard totalBytesExpectedToWrite != 0 && totalBytesWritten != 0 else { return }
        
        let written  = byteFormatter.string(fromByteCount: totalBytesWritten)
        let expected = byteFormatter.string(fromByteCount: totalBytesExpectedToWrite)
        
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        let percentage = String(format: "%.0f%%", progress * 100)

        progressBlock((written: written, total: expected ,percentage: percentage))
    }
    

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            
            // Retrieve data from given temporary location
            let data = try Data(contentsOf: location)

            // Get url of get file name and type from it.
            guard let url: URL = downloadTask.originalRequest?.url else {
                
                // error
                return
            }
            
            // Save and return result block
            cache(data, mediaType: url.pathExtension.type, name: url.pathComponents.last ?? "unknown-file-\(Date())")
            resultBlock(data)
            
        } catch let error {
            failureBlock((status: nil, response: downloadTask.response, error: error))
        }
    }
    

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let statusCode = (task.response as? HTTPURLResponse)?.statusCode ?? 0
        switch statusCode {
        case 200...399: return
        default: failureBlock((status: statusCode, response: task.response, error: error))
        }
    }
    
    
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        failureBlock((status: nil, response: nil, error: error))
    }
}
