//
//  FilteredImage.swift
//  CFT_TestProject
//
//  Created by Alexander on 26/11/2018.
//  Copyright © 2018 Alexander. All rights reserved.
//

import UIKit

protocol ImageOwnerDelegate: class {
    func updateCell(row: Int,
                    progress: Float)
    func showImageInCell(row: Int)
}

enum ImageFilter {
    case rotate
    case greyscale
    case mirrorImage
    
    init?(rawValue: String?) {
        switch rawValue {
        case String.rotate:
            self = .rotate
        case String.greyscale:
            self = .greyscale
        case String.mirrorImage:
            self = .mirrorImage
        default:
            return nil
        }
    }
    
    func getText() -> String {
        switch self {
        case .rotate:
            return String.rotate
        case .greyscale:
            return String.greyscale
        case .mirrorImage:
            return String.mirrorImage
        }
    }
}

final class FilteredImage {
    
    private static let opeartionQueue = OperationQueue()
    
    weak var delegate: ImageOwnerDelegate?
    
    private let inputImage: UIImage
    private var filterDuration: Int
    private var operation = FilterOperation()
    let filter: ImageFilter
    var outputImage: UIImage?
    var filterFinished: Bool
    var currentArrayIndex = ThreadSafeInt()
    var managedObject: FilterImage?
    
    init(inputImage: UIImage,
         filter: ImageFilter,
         arrayIndex: Int) {
        self.inputImage = inputImage
        self.filter = filter
        filterDuration = 0
        filterFinished = false
        currentArrayIndex.int = arrayIndex
    }
    
    init(inputImage: UIImage,
         filter: ImageFilter,
         filterDuration: Int,
         arrayIndex: Int) {
        self.inputImage = inputImage
        self.filter = filter
        self.filterDuration = filterDuration
        filterFinished = false
        currentArrayIndex.int = arrayIndex
    }
    
    func startFiltering() {
        operation.action = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            let resultImage = strongSelf.inputImage.getFilterResult(filter: strongSelf.filter)
            for tik in 1 ... strongSelf.filterDuration * 10 {
                if strongSelf.operation.isCancelled {
                    return
                }
                DispatchQueue.main.async {
                    if let row = self?.currentArrayIndex.int {
                        let progress = Float(tik) / Float(strongSelf.filterDuration * 10)
                        self?.delegate?.updateCell(row: row,
                                                   progress: progress)
                    }
                }
                usleep(100000)
            }
            self?.filterFinished = true
            self?.outputImage = resultImage
            DispatchQueue.main.async {
                if let row = self?.currentArrayIndex.int {
                    self?.delegate?.showImageInCell(row: row)
                }
            }
        }
        FilteredImage.opeartionQueue.addOperation(operation)
    }
    
    func stopFiltering() {
        operation.cancel()
    }
}

private extension String {
    
    static let rotate = "IMAGE_FILTER__ROTATE".localized()
    static let greyscale = "IMAGE_FILTER__GREYSCALE".localized()
    static let mirrorImage = "IMAGE_FILTER__MIRROR_IMAGE".localized()
}
