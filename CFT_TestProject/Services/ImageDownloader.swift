//
//  ImageDownloader.swift
//  CFT_TestProject
//
//  Created by Alexander on 25/11/2018.
//  Copyright © 2018 Alexander. All rights reserved.
//

import UIKit

protocol ImageDownloaderDelegate: class {
    func imageIsDownloadedAction(downloadedImage: UIImage?)
    func updateDownloadProgressAction(progress: Float)
}

final class ImageDownloader: NSObject {
    
    private static var lastQueueId = 0
    private let queue: DispatchQueue
    private var downloadTask: URLSessionDownloadTask?
    weak var delegate: ImageDownloaderDelegate?
    
    override init() {
        ImageDownloader.lastQueueId += 1
        queue = DispatchQueue(label: "ImageDownloaderQueue \(ImageDownloader.lastQueueId)")
        super.init()
    }
    
    func downloadImage(with url: URL) {
        downloadTask?.cancel()
        let session = URLSession(configuration: .default,
                                 delegate: self,
                                 delegateQueue: nil)
        downloadTask = session.downloadTask(with: url)
        downloadTask?.resume()
    }
}

extension ImageDownloader: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        guard let httpResponse = downloadTask.response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.imageIsDownloadedAction(downloadedImage: nil)
                }
                return
        }
        guard let documentsURL = try? FileManager.default.url(for: .documentDirectory,
                                                              in: .userDomainMask,
                                                              appropriateFor: nil,
                                                              create: false) else {
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.imageIsDownloadedAction(downloadedImage: nil)
            }
            return
        }
        let savedURL = documentsURL.appendingPathComponent(randomString(length: 10) + "_Image.png")
        try? FileManager.default.moveItem(at: location, to: savedURL)
        queue.async {
            guard let imageData = try? Data(contentsOf: savedURL),
                let image = UIImage(data: imageData) else {
                    DispatchQueue.main.async { [weak self] in
                        self?.delegate?.imageIsDownloadedAction(downloadedImage: nil)
                    }
                    return
            }
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.imageIsDownloadedAction(downloadedImage: image)
            }
        }
    }

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        var progress: Float = 0
        if totalBytesWritten >= 0,
            totalBytesExpectedToWrite > 0,
            totalBytesWritten <= totalBytesExpectedToWrite {
            progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        }
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.updateDownloadProgressAction(progress: progress)
        }
    }
    
    // For generating unique url
    private func randomString(length: Int) -> String {
        let letters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let amountOfSymbols = UInt32(letters.length)
        var randomString = ""
        for _ in 0 ..< length {
            let randomNumber = arc4random_uniform(amountOfSymbols)
            var nextChar = letters.character(at: Int(randomNumber))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }
}
