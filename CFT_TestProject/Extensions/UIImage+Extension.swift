//
//  UIImage+Extension.swift
//  CFT_TestProject
//
//  Created by Alexander on 24/11/2018.
//  Copyright © 2018 Alexander. All rights reserved.
//

import UIKit

extension UIImage {
    
    func getFilterResult(filter: ImageFilter) -> UIImage? {
        switch filter {
        case .greyscale:
            return grayscale
        case .mirrorImage:
            return mirrored
        case .rotate:
            return rotatedRight
        }
    }
    
    var rotatedRight: UIImage? {
        let rotatedSize = CGSize(width: size.height,
                                 height: size.width)
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()
        bitmap?.translateBy(x: rotatedSize.width / 2.0,
                            y: rotatedSize.height / 2.0)
        bitmap?.rotate(by: .pi / 2)
        draw(in: CGRect(x: -size.width / 2,
                        y: -size.height / 2,
                        width: size.width,
                        height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    var grayscale: UIImage? {
        let context = CIContext()
        let currentFilter = CIFilter(name: "CIPhotoEffectMono")
        let imageForFilter = CIImage(image: self)
        currentFilter?.setValue(imageForFilter,
                                forKey: kCIInputImageKey)
        guard let outputImage = currentFilter?.outputImage,
            let cgImage = context.createCGImage(outputImage,
                                                from: outputImage.extent) else {
                return nil
        }
        let resultImage = UIImage(cgImage: cgImage,
                                  scale: scale,
                                  orientation: imageOrientation)
        return resultImage
    }
    
    var mirrored: UIImage? {
        guard let cgImage = cgImage else {
            return nil
        }
        return UIImage(cgImage: cgImage,
                       scale: 1.0,
                       orientation: .upMirrored)
    }
}

extension UIImage {
    
    var png: Data? {
        guard let flattened = flattened else {
            return nil
        }
        return flattened.pngData()
    }
    
    var flattened: UIImage? {
        if imageOrientation == .up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(size,
                                               false,
                                               scale)
        defer {
            UIGraphicsEndImageContext()
        }
        let rect = CGRect(origin: .zero,
                          size: size)
        draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
